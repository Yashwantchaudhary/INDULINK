const express = require('express');
const router = express.Router();
const {
    createOrder,
    getCustomerOrders,
    getSupplierOrders,
    getOrder,
    updateOrderStatus,
    cancelOrder,
} = require('../controllers/orderController');
const { protect, requireCustomer, requireSupplier } = require('../middleware/authMiddleware');

// Customer routes
router.post('/', protect, requireCustomer, createOrder);
router.get('/', protect, requireCustomer, getCustomerOrders);
router.put('/:id/cancel', protect, requireCustomer, cancelOrder);

// Supplier routes
router.get('/supplier', protect, requireSupplier, getSupplierOrders);
router.put('/:id/status', protect, requireSupplier, updateOrderStatus);

// Common routes (both customer and supplier can view)
router.get('/:id', protect, getOrder);

module.exports = router;
