const User = require('../models/User');
const LoyaltyTransaction = require('../models/LoyaltyTransaction');
const Badge = require('../models/Badge');

// @desc    Get user's loyalty points and stats
// @route   GET /api/loyalty/points
// @access  Private
exports.getLoyaltyPoints = async (req, res, next) => {
    try {
        const user = await User.findById(req.user.id);

        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found',
            });
        }

        res.status(200).json({
            success: true,
            data: {
                points: user.loyaltyPoints || 0,
                tier: user.loyaltyTier || 'bronze',
                lifetimePoints: user.lifetimePoints || 0,
            },
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Get loyalty transaction history
// @route   GET /api/loyalty/transactions
// @access  Private
exports.getLoyaltyTransactions = async (req, res, next) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 20;
        const skip = (page - 1) * limit;

        const transactions = await LoyaltyTransaction.find({ userId: req.user.id })
            .sort({ createdAt: -1 })
            .skip(skip)
            .limit(limit);

        const total = await LoyaltyTransaction.countDocuments({ userId: req.user.id });

        res.status(200).json({
            success: true,
            data: {
                transactions,
                pagination: {
                    page,
                    limit,
                    total,
                    pages: Math.ceil(total / limit),
                },
            },
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Get all available badges
// @route   GET /api/loyalty/badges
// @access  Private
exports.getAllBadges = async (req, res, next) => {
    try {
        const badges = await Badge.find({ isActive: true });

        res.status(200).json({
            success: true,
            data: badges,
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Get user's earned badges
// @route   GET /api/loyalty/user-badges
// @access  Private
exports.getUserBadges = async (req, res, next) => {
    try {
        const user = await User.findById(req.user.id);

        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found',
            });
        }

        // Get badge details for each earned badge
        const earnedBadges = user.badges || [];
        const badgeDetails = await Badge.find({
            _id: { $in: earnedBadges },
        });

        res.status(200).json({
            success: true,
            data: badgeDetails,
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Award loyalty points (internal/admin use)
// @route   POST /api/loyalty/award-points
// @access  Private/Admin
exports.awardPoints = async (req, res, next) => {
    try {
        const { userId, points, reason, relatedModel, relatedId } = req.body;

        const user = await User.findById(userId);

        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found',
            });
        }

        // Update user points
        user.loyaltyPoints = (user.loyaltyPoints || 0) + points;
        user.lifetimePoints = (user.lifetimePoints || 0) + points;

        // Update tier based on lifetime points
        if (user.lifetimePoints >= 10000) {
            user.loyaltyTier = 'platinum';
        } else if (user.lifetimePoints >= 5000) {
            user.loyaltyTier = 'gold';
        } else if (user.lifetimePoints >= 1000) {
            user.loyaltyTier = 'silver';
        } else {
            user.loyaltyTier = 'bronze';
        }

        await user.save();

        // Create transaction record
        const transaction = await LoyaltyTransaction.create({
            userId,
            type: 'earn',
            points,
            reason,
            relatedModel,
            relatedId,
            balanceAfter: user.loyaltyPoints,
        });

        res.status(201).json({
            success: true,
            message: 'Points awarded successfully',
            data: {
                transaction,
                newBalance: user.loyaltyPoints,
                newTier: user.loyaltyTier,
            },
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Redeem loyalty points
// @route   POST /api/loyalty/redeem
// @access  Private
exports.redeemPoints = async (req, res, next) => {
    try {
        const { points, reason } = req.body;

        const user = await User.findById(req.user.id);

        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found',
            });
        }

        // Check if user has enough points
        if ((user.loyaltyPoints || 0) < points) {
            return res.status(400).json({
                success: false,
                message: 'Insufficient points',
            });
        }

        // Deduct points
        user.loyaltyPoints -= points;
        await user.save();

        // Create transaction record
        const transaction = await LoyaltyTransaction.create({
            userId: req.user.id,
            type: 'redeem',
            points,
            reason,
            balanceAfter: user.loyaltyPoints,
        });

        res.status(200).json({
            success: true,
            message: 'Points redeemed successfully',
            data: {
                transaction,
                newBalance: user.loyaltyPoints,
            },
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Get loyalty tier benefits
// @route   GET /api/loyalty/tiers
// @access  Public
exports.getLoyaltyTiers = async (req, res, next) => {
    try {
        const tiers = [
            {
                name: 'bronze',
                minPoints: 0,
                benefits: ['1x points on purchases', 'Standard support'],
                color: '#CD7F32',
            },
            {
                name: 'silver',
                minPoints: 1000,
                benefits: ['1.5x points on purchases', 'Priority support', '5% discount'],
                color: '#C0C0C0',
            },
            {
                name: 'gold',
                minPoints: 5000,
                benefits: ['2x points on purchases', 'VIP support', '10% discount', 'Free shipping'],
                color: '#FFD700',
            },
            {
                name: 'platinum',
                minPoints: 10000,
                benefits: ['3x points on purchases', '24/7 support', '15% discount', 'Free shipping', 'Exclusive deals'],
                color: '#E5E4E2',
            },
        ];

        res.status(200).json({
            success: true,
            data: tiers,
        });
    } catch (error) {
        next(error);
    }
};
