const express = require('express');
const router = express.Router();
const {
    getProfile,
    updateProfile,
    uploadProfileImage,
    addAddress,
    updateAddress,
    deleteAddress,
    toggleWishlist,
    getWishlist,
} = require('../controllers/userController');
const { protect, requireCustomer } = require('../middleware/authMiddleware');
const { uploadSingle } = require('../middleware/upload');

// Profile routes
router.get('/profile', protect, getProfile);
router.put('/profile', protect, updateProfile);
router.post('/profile/image', protect, uploadSingle('profileImage'), uploadProfileImage);

// Address routes
router.post('/addresses', protect, addAddress);
router.put('/addresses/:addressId', protect, updateAddress);
router.delete('/addresses/:addressId', protect, deleteAddress);

// Wishlist routes (customer only)
router.get('/wishlist', protect, requireCustomer, getWishlist);
router.put('/wishlist/:productId', protect, requireCustomer, toggleWishlist);

module.exports = router;
