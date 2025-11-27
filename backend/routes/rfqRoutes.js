const express = require('express');
const router = express.Router();
const {
    createRFQ,
    getRFQs,
    getRFQById,
    submitQuote,
    acceptQuote,
    updateRFQStatus,
    deleteRFQ,
    uploadAttachments
} = require('../controllers/rfqController');
const { protect } = require('../middleware/authMiddleware');
const { uploadMultiple } = require('../middleware/upload');

// RFQ routes
router.post('/', protect, createRFQ);
router.get('/', protect, getRFQs);
router.get('/:id', protect, getRFQById);
router.post('/:id/quote', protect, submitQuote);
router.put('/:id/accept/:quoteId', protect, acceptQuote);
router.put('/:id/status', protect, updateRFQStatus);
router.delete('/:id', protect, deleteRFQ);

// Upload route
router.post('/upload', protect, uploadMultiple('attachments', 3), uploadAttachments);

module.exports = router;
