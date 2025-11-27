const express = require('express');
const router = express.Router();
const {
    getLoyaltyPoints,
    getLoyaltyTransactions,
    getAllBadges,
    getUserBadges,
    awardPoints,
    redeemPoints,
    getLoyaltyTiers,
} = require('../controllers/loyaltyController');
const { protect } = require('../middleware/authMiddleware');

// Public routes
router.get('/tiers', getLoyaltyTiers);

// Protected routes (require authentication)
router.use(protect);

router.get('/points', getLoyaltyPoints);
router.get('/transactions', getLoyaltyTransactions);
router.get('/badges', getAllBadges);
router.get('/user-badges', getUserBadges);
router.post('/redeem', redeemPoints);

// Admin routes (can add admin middleware later)
router.post('/award-points', awardPoints);

module.exports = router;
