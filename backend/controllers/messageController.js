const Message = require('../models/Message');
const User = require('../models/User');

// @desc    Get conversations
// @route   GET /api/messages/conversations
// @access  Private
exports.getConversations = async (req, res, next) => {
    try {
        // Get all unique conversations for the user
        const conversations = await Message.aggregate([
            {
                $match: {
                    $or: [{ sender: req.user._id }, { receiver: req.user._id }],
                },
            },
            {
                $sort: { createdAt: -1 },
            },
            {
                $group: {
                    _id: '$conversationId',
                    lastMessage: { $first: '$$ROOT' },
                    unreadCount: {
                        $sum: {
                            $cond: [
                                {
                                    $and: [
                                        { $eq: ['$receiver', req.user._id] },
                                        { $eq: ['$isRead', false] },
                                    ],
                                },
                                1,
                                0,
                            ],
                        },
                    },
                },
            },
            {
                $sort: { 'lastMessage.createdAt': -1 },
            },
        ]);

        // Populate user details
        const populated = await Message.populate(conversations, [
            {
                path: 'lastMessage.sender',
                select: 'firstName lastName profileImage businessName role',
            },
            {
                path: 'lastMessage.receiver',
                select: 'firstName lastName profileImage businessName role',
            },
        ]);

        res.status(200).json({
            success: true,
            count: populated.length,
            data: populated,
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Get messages in conversation
// @route   GET /api/messages/conversation/:userId
// @access  Private
exports.getMessages = async (req, res, next) => {
    try {
        const otherUserId = req.params.userId;
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 50;
        const skip = (page - 1) * limit;

        // Generate conversation ID
        const ids = [req.user.id, otherUserId].sort();
        const conversationId = `${ids[0]}_${ids[1]}`;

        const messages = await Message.find({ conversationId })
            .populate('sender', 'firstName lastName profileImage businessName role')
            .populate('receiver', 'firstName lastName profileImage businessName role')
            .sort({ createdAt: 1 })
            .skip(skip)
            .limit(limit);

        const total = await Message.countDocuments({ conversationId });

        // Mark messages as read
        await Message.updateMany(
            {
                conversationId,
                receiver: req.user.id,
                isRead: false,
            },
            {
                isRead: true,
                readAt: new Date(),
            }
        );

        res.status(200).json({
            success: true,
            count: messages.length,
            total,
            page,
            pages: Math.ceil(total / limit),
            data: messages,
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Send message
// @route   POST /api/messages
// @access  Private
exports.sendMessage = async (req, res, next) => {
    try {
        const { receiver, content } = req.body;

        // Validate receiver exists
        const receiverUser = await User.findById(receiver);

        if (!receiverUser) {
            return res.status(404).json({
                success: false,
                message: 'Receiver not found',
            });
        }

        // Check roles - customers can only message suppliers and vice versa
        if (
            (req.user.role === 'customer' && receiverUser.role !== 'supplier') ||
            (req.user.role === 'supplier' && receiverUser.role !== 'customer')
        ) {
            return res.status(400).json({
                success: false,
                message: 'Invalid recipient',
            });
        }

        const message = await Message.create({
            sender: req.user.id,
            receiver,
            content,
        });

        await message.populate([
            {
                path: 'sender',
                select: 'firstName lastName profileImage businessName role',
            },
            {
                path: 'receiver',
                select: 'firstName lastName profileImage businessName role',
            },
        ]);

        res.status(201).json({
            success: true,
            message: 'Message sent',
            data: message,
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Mark messages as read
// @route   PUT /api/messages/read/:conversationId
// @access  Private
exports.markAsRead = async (req, res, next) => {
    try {
        await Message.updateMany(
            {
                conversationId: req.params.conversationId,
                receiver: req.user.id,
                isRead: false,
            },
            {
                isRead: true,
                readAt: new Date(),
            }
        );

        res.status(200).json({
            success: true,
            message: 'Messages marked as read',
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Get unread message count
// @route   GET /api/messages/unread/count
// @access  Private
exports.getUnreadCount = async (req, res, next) => {
    try {
        const count = await Message.countDocuments({
            receiver: req.user.id,
            isRead: false,
        });

        res.status(200).json({
            success: true,
            data: { unreadCount: count },
        });
    } catch (error) {
        next(error);
    }
};
