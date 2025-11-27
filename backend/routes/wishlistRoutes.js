const express = require('express');
const router = express.Router();
const {
    getWishlist,
    addToWishlist,
    removeFromWishlist,
    clearWishlist,
    checkWishlist
} = require('../controllers/wishlistController');
const { protect } = require('../middleware/authMiddleware');

// Wishlist routes
router.get('/', protect, getWishlist);
router.get('/check/:productId', protect, checkWishlist);
router.post('/:productId', protect, addToWishlist);
router.delete('/:productId', protect, removeFromWishlist);
router.delete('/', protect, clearWishlist);

module.exports = router;
