const express = require('express');
const router = express.Router();
const {
    getConversations,
    getMessages,
    sendMessage,
    markAsRead,
    getUnreadCount,
} = require('../controllers/messageController');
const { protect } = require('../middleware/authMiddleware');

// All message routes require authentication
router.use(protect);

router.get('/conversations', getConversations);
router.get('/conversation/:userId', getMessages);
router.post('/', sendMessage);
router.put('/read/:conversationId', markAsRead);
router.get('/unread/count', getUnreadCount);

module.exports = router;
