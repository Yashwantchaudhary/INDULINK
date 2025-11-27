const express = require('express');
const router = express.Router();
const {
    getSupplierDashboard,
    getCustomerDashboard,
} = require('../controllers/dashboardController');
const {
    getSalesTrends,
    getProductPerformance,
    getCustomerBehavior,
    getSupplierPerformance,
    getComparativeAnalysis,
    exportCSV,
    exportPDF,
} = require('../controllers/analyticsController');
const { protect, requireCustomer, requireSupplier } = require('../middleware/authMiddleware');

// Dashboard routes
router.get('/supplier', protect, requireSupplier, getSupplierDashboard);
router.get('/customer', protect, requireCustomer, getCustomerDashboard);

// Analytics routes
router.get('/analytics/sales-trends', protect, getSalesTrends);
router.get('/analytics/product-performance', protect, getProductPerformance);
router.get('/analytics/customer-behavior', protect, getCustomerBehavior);
router.get('/analytics/supplier-performance', protect, getSupplierPerformance);
router.get('/analytics/compare', protect, getComparativeAnalysis);
router.get('/analytics/export/csv', protect, exportCSV);
router.get('/analytics/export/pdf', protect, exportPDF);

module.exports = router;

