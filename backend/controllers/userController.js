const User = require('../models/User');

// @desc    Get user profile
// @route   GET /api/users/profile
// @access  Private
exports.getProfile = async (req, res, next) => {
    try {
        const user = await User.findById(req.user.id);

        res.status(200).json({
            success: true,
            data: user,
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Update user profile
// @route   PUT /api/users/profile
// @access  Private
exports.updateProfile = async (req, res, next) => {
    try {
        const { firstName, lastName, phone, businessName, businessDescription, businessAddress } = req.body;

        const updateData = {
            firstName,
            lastName,
            phone,
        };

        // Add supplier-specific fields if user is supplier
        if (req.user.role === 'supplier') {
            updateData.businessName = businessName;
            updateData.businessDescription = businessDescription;
            updateData.businessAddress = businessAddress;
        }

        const user = await User.findByIdAndUpdate(req.user.id, updateData, {
            new: true,
            runValidators: true,
        });

        res.status(200).json({
            success: true,
            message: 'Profile updated successfully',
            data: user,
        });
    } catch (error) {
        next(error);
    }
};

// @ desc   Upload profile image
// @route   POST /api/users/profile/image
// @access  Private
exports.uploadProfileImage = async (req, res, next) => {
    try {
        if (!req.file) {
            return res.status(400).json({
                success: false,
                message: 'Please upload an image',
            });
        }

        const imageUrl = `/uploads/profiles/${req.file.filename}`;

        const user = await User.findByIdAndUpdate(
            req.user.id,
            { profileImage: imageUrl },
            { new: true }
        );

        res.status(200).json({
            success: true,
            message: 'Profile image uploaded successfully',
            data: {
                profileImage: imageUrl,
            },
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Add address
// @route   POST /api/users/addresses
// @access  Private
exports.addAddress = async (req, res, next) => {
    try {
        const user = await User.findById(req.user.id);

        // If this is set as default, unset other defaults
        if (req.body.isDefault) {
            user.addresses.forEach((addr) => (addr.isDefault = false));
        }

        user.addresses.push(req.body);
        await user.save();

        res.status(201).json({
            success: true,
            message: 'Address added successfully',
            data: user.addresses,
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Update address
// @route   PUT /api/users/addresses/:addressId
// @access  Private
exports.updateAddress = async (req, res, next) => {
    try {
        const user = await User.findById(req.user.id);
        const address = user.addresses.id(req.params.addressId);

        if (!address) {
            return res.status(404).json({
                success: false,
                message: 'Address not found',
            });
        }

        // If setting as default, unset others
        if (req.body.isDefault) {
            user.addresses.forEach((addr) => (addr.isDefault = false));
        }

        Object.assign(address, req.body);
        await user.save();

        res.status(200).json({
            success: true,
            message: 'Address updated successfully',
            data: user.addresses,
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Delete address
// @route   DELETE /api/users/addresses/:addressId
// @access  Private
exports.deleteAddress = async (req, res, next) => {
    try {
        const user = await User.findById(req.user.id);
        user.addresses.id(req.params.addressId).remove();
        await user.save();

        res.status(200).json({
            success: true,
            message: 'Address deleted successfully',
            data: user.addresses,
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Toggle wishlist item
// @route   PUT /api/users/wishlist/:productId
// @access  Private (Customer)
exports.toggleWishlist = async (req, res, next) => {
    try {
        const user = await User.findById(req.user.id);
        const productId = req.params.productId;

        const index = user.wishlist.indexOf(productId);

        if (index > -1) {
            // Remove from wishlist
            user.wishlist.splice(index, 1);
        } else {
            // Add to wishlist
            user.wishlist.push(productId);
        }

        await user.save();

        res.status(200).json({
            success: true,
            message: index > -1 ? 'Removed from wishlist' : 'Added to wishlist',
            data: { wishlist: user.wishlist },
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Get wishlist
// @route   GET /api/users/wishlist
// @access  Private (Customer)
exports.getWishlist = async (req, res, next) => {
    try {
        const user = await User.findById(req.user.id).populate({
            path: 'wishlist',
            select: 'title price images averageRating stock status',
        });

        res.status(200).json({
            success: true,
            data: user.wishlist,
        });
    } catch (error) {
        next(error);
    }
};
