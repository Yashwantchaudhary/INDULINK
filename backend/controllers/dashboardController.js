const Order = require('../models/Order');
const Product = require('../models/Product');

// @desc    Get supplier dashboard analytics
// @route   GET /api/dashboard/supplier
// @access  Private (Supplier)
exports.getSupplierDashboard = async (req, res, next) => {
    try {
        const supplierId = req.user.id;

        // Get date range (default: last 30 days)
        const endDate = new Date();
        const startDate = new Date();
        startDate.setDate(startDate.getDate() - 30);

        // Total revenue
        const revenueData = await Order.aggregate([
            {
                $match: {
                    supplier: req.user._id,
                    status: { $in: ['delivered', 'shipped', 'processing'] },
                    createdAt: { $gte: startDate, $lte: endDate },
                },
            },
            {
                $group: {
                    _id: null,
                    totalRevenue: { $sum: '$total' },
                    totalOrders: { $sum: 1 },
                    averageOrderValue: { $avg: '$total' },
                },
            },
        ]);

        // Orders by status
        const ordersByStatus = await Order.aggregate([
            {
                $match: {
                    supplier: req.user._id,
                },
            },
            {
                $group: {
                    _id: '$status',
                    count: { $sum: 1 },
                },
            },
        ]);

        // Top selling products
        const topProducts = await Order.aggregate([
            {
                $match: {
                    supplier: req.user._id,
                    status: 'delivered',
                },
            },
            { $unwind: '$items' },
            {
                $group: {
                    _id: '$items.product',
                    totalQuantity: { $sum: '$items.quantity' },
                    totalRevenue: { $sum: '$items.subtotal' },
                },
            },
            { $sort: { totalQuantity: -1 } },
            { $limit: 10 },
        ]);

        // Populate product details
        await Product.populate(topProducts, {
            path: '_id',
            select: 'title images price',
        });

        // Revenue over time (daily for last 30 days)
        const revenueOverTime = await Order.aggregate([
            {
                $match: {
                    supplier: req.user._id,
                    status: { $in: ['delivered', 'shipped', 'processing'] },
                    createdAt: { $gte: startDate, $lte: endDate },
                },
            },
            {
                $group: {
                    _id: {
                        $dateToString: { format: '%Y-%m-%d', date: '$createdAt' },
                    },
                    revenue: { $sum: '$total' },
                    orders: { $sum: 1 },
                },
            },
            { $sort: { _id: 1 } },
        ]);

        // Product statistics
        const productStats = await Product.aggregate([
            {
                $match: {
                    supplier: req.user._id,
                },
            },
            {
                $group: {
                    _id: null,
                    totalProducts: { $sum: 1 },
                    activeProducts: {
                        $sum: { $cond: [{ $eq: ['$status', 'active'] }, 1, 0] },
                    },
                    outOfStock: {
                        $sum: { $cond: [{ $eq: ['$stock', 0] }, 1, 0] },
                    },
                    totalStock: { $sum: '$stock' },
                },
            },
        ]);

        // Recent orders
        const recentOrders = await Order.find({ supplier: supplierId })
            .populate('customer', 'firstName lastName')
            .sort({ createdAt: -1 })
            .limit(5);

        res.status(200).json({
            success: true,
            data: {
                revenue: revenueData[0] || {
                    totalRevenue: 0,
                    totalOrders: 0,
                    averageOrderValue: 0,
                },
                ordersByStatus,
                topProducts,
                revenueOverTime,
                productStats: productStats[0] || {
                    totalProducts: 0,
                    activeProducts: 0,
                    outOfStock: 0,
                    totalStock: 0,
                },
                recentOrders,
            },
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Get customer dashboard analytics
// @route   GET /api/dashboard/customer
// @access  Private (Customer)
exports.getCustomerDashboard = async (req, res, next) => {
    try {
        // Order statistics
        const orderStats = await Order.aggregate([
            {
                $match: {
                    customer: req.user._id,
                },
            },
            {
                $group: {
                    _id: null,
                    totalOrders: { $sum: 1 },
                    totalSpent: {
                        $sum: {
                            $cond: [
                                { $eq: ['$status', 'delivered'] },
                                '$total',
                                0,
                            ],
                        },
                    },
                    deliveredOrders: {
                        $sum: { $cond: [{ $eq: ['$status', 'delivered'] }, 1, 0] },
                    },
                },
            },
        ]);

        // Recent orders
        const recentOrders = await Order.find({ customer: req.user.id })
            .populate('supplier', 'firstName lastName businessName')
            .populate('items.product', 'title images')
            .sort({ createdAt: -1 })
            .limit(5);

        // Active orders (not delivered or cancelled)
        const activeOrders = await Order.find({
            customer: req.user.id,
            status: { $nin: ['delivered', 'cancelled'] },
        })
            .populate('supplier', 'firstName lastName businessName')
            .populate('items.product', 'title images')
            .sort({ createdAt: -1 });

        res.status(200).json({
            success: true,
            data: {
                stats: orderStats[0] || {
                    totalOrders: 0,
                    totalSpent: 0,
                    deliveredOrders: 0,
                },
                recentOrders,
                activeOrders,
            },
        });
    } catch (error) {
        next(error);
    }
};
