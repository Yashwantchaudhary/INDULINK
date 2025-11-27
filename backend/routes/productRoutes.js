const express = require('express');
const router = express.Router();
const {
    getProducts,
    getProduct,
    createProduct,
    updateProduct,
    deleteProduct,
    getMyProducts,
    getProductBySKU,
} = require('../controllers/productController');
const { protect, requireSupplier } = require('../middleware/authMiddleware');
const { uploadMultiple } = require('../middleware/upload');

// Public routes
router.get('/', getProducts);
router.get('/barcode/:sku', getProductBySKU);
router.get('/:id', getProduct);

// Supplier routes
router.get('/supplier/me', protect, requireSupplier, getMyProducts);
router.post('/', protect, requireSupplier, uploadMultiple('images', 5), createProduct);
router.put('/:id', protect, requireSupplier, uploadMultiple('images', 5), updateProduct);
router.delete('/:id', protect, requireSupplier, deleteProduct);

module.exports = router;
