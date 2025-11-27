const Order = require('../models/Order');
const Product = require('../models/Product');
const User = require('../models/User');

// Helper: Generate CSV from data
const generateCSV = (headers, rows) => {
    const csvRows = [headers.join(',')];
    for (const row of rows) {
        csvRows.push(row.join(','));
    }
    return csvRows.join('\n');
};

// Helper: Calculate percentage change
const calculatePercentageChange = (current, previous) => {
    if (previous === 0) return current > 0 ? 100 : 0;
    return ((current - previous) / previous) * 100;
};

// @desc    Get sales trends analysis
// @route   GET /api/analytics/sales-trends?startDate=YYYY-MM-DD&endDate=YYYY-MM-DD&interval=day|week|month
// @access  Private (Supplier)
exports.getSalesTrends = async (req, res, next) => {
    try {
        const { startDate, endDate, interval = 'day' } = req.query;
        const userId = req.user.id;
        const userRole = req.user.role;

        // Validate dates
        if (!startDate || !endDate) {
            return res.status(400).json({
                success: false,
                message: 'Start date and end date are required',
            });
        }

        const start = new Date(startDate);
        const end = new Date(endDate);
        end.setHours(23, 59, 59, 999);

        // Build match query based on role
        const matchQuery = {
            createdAt: { $gte: start, $lte: end },
            status: { $in: ['delivered', 'shipped', 'processing'] },
        };

        if (userRole === 'supplier') {
            matchQuery.supplier = req.user._id;
        } else if (userRole === 'customer') {
            matchQuery.customer = req.user._id;
        }

        // Determine date format based on interval
        let dateFormat;
        if (interval === 'week') {
            dateFormat = '%Y-W%V'; // Year-Week
        } else if (interval === 'month') {
            dateFormat = '%Y-%m'; // Year-Month
        } else {
            dateFormat = '%Y-%m-%d'; // Year-Month-Day
        }

        // Aggregate sales data
        const salesTrends = await Order.aggregate([
            { $match: matchQuery },
            {
                $group: {
                    _id: {
                        $dateToString: { format: dateFormat, date: '$createdAt' },
                    },
                    revenue: { $sum: '$total' },
                    orders: { $sum: 1 },
                    averageOrderValue: { $avg: '$total' },
                },
            },
            { $sort: { _id: 1 } },
        ]);

        // Calculate totals
        const totals = {
            totalRevenue: salesTrends.reduce((sum, item) => sum + item.revenue, 0),
            totalOrders: salesTrends.reduce((sum, item) => sum + item.orders, 0),
            averageOrderValue: salesTrends.length > 0
                ? salesTrends.reduce((sum, item) => sum + item.averageOrderValue, 0) / salesTrends.length
                : 0,
        };

        // Calculate previous period for comparison
        const periodDuration = end - start;
        const prevStart = new Date(start.getTime() - periodDuration);
        const prevEnd = new Date(start.getTime() - 1);

        const prevMatchQuery = { ...matchQuery, createdAt: { $gte: prevStart, $lte: prevEnd } };

        const prevPeriodData = await Order.aggregate([
            { $match: prevMatchQuery },
            {
                $group: {
                    _id: null,
                    totalRevenue: { $sum: '$total' },
                    totalOrders: { $sum: 1 },
                    averageOrderValue: { $avg: '$total' },
                },
            },
        ]);

        const prevTotals = prevPeriodData[0] || {
            totalRevenue: 0,
            totalOrders: 0,
            averageOrderValue: 0,
        };

        // Calculate growth percentages
        const comparison = {
            revenueGrowth: calculatePercentageChange(totals.totalRevenue, prevTotals.totalRevenue),
            ordersGrowth: calculatePercentageChange(totals.totalOrders, prevTotals.totalOrders),
            avgOrderValueGrowth: calculatePercentageChange(totals.averageOrderValue, prevTotals.averageOrderValue),
        };

        res.status(200).json({
            success: true,
            data: {
                trends: salesTrends,
                totals,
                comparison,
                period: {
                    start: startDate,
                    end: endDate,
                    interval,
                },
            },
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Get product performance metrics
// @route   GET /api/analytics/product-performance?limit=20
// @access  Private (Supplier)
exports.getProductPerformance = async (req, res, next) => {
    try {
        const { limit = 20 } = req.query;
        const userId = req.user.id;
        const userRole = req.user.role;

        // Build match query
        const matchQuery = { status: 'delivered' };
        if (userRole === 'supplier') {
            matchQuery.supplier = req.user._id;
        }

        // Top products by revenue
        const topProducts = await Order.aggregate([
            { $match: matchQuery },
            { $unwind: '$items' },
            {
                $group: {
                    _id: '$items.product',
                    totalRevenue: { $sum: '$items.subtotal' },
                    totalQuantity: { $sum: '$items.quantity' },
                    orderCount: { $sum: 1 },
                },
            },
            { $sort: { totalRevenue: -1 } },
            { $limit: parseInt(limit) },
        ]);

        // Populate product details
        await Product.populate(topProducts, {
            path: '_id',
            select: 'title images price category stock',
        });

        // Bottom products (need improvement)
        const bottomProducts = await Order.aggregate([
            { $match: matchQuery },
            { $unwind: '$items' },
            {
                $group: {
                    _id: '$items.product',
                    totalRevenue: { $sum: '$items.subtotal' },
                    totalQuantity: { $sum: '$items.quantity' },
                },
            },
            { $sort: { totalRevenue: 1 } },
            { $limit: 10 },
        ]);

        await Product.populate(bottomProducts, {
            path: '_id',
            select: 'title images price',
        });

        // Category performance
        const categoryPerformance = await Order.aggregate([
            { $match: matchQuery },
            { $unwind: '$items' },
            {
                $lookup: {
                    from: 'products',
                    localField: 'items.product',
                    foreignField: '_id',
                    as: 'productInfo',
                },
            },
            { $unwind: '$productInfo' },
            {
                $group: {
                    _id: '$productInfo.category',
                    revenue: { $sum: '$items.subtotal' },
                    quantity: { $sum: '$items.quantity' },
                },
            },
            { $sort: { revenue: -1 } },
        ]);

        // Get all products for stock analysis (supplier only)
        let stockAnalysis = null;
        if (userRole === 'supplier') {
            const products = await Product.find({ supplier: req.user._id });
            const lowStock = products.filter(p => p.stock > 0 && p.stock < 10);
            const outOfStock = products.filter(p => p.stock === 0);

            stockAnalysis = {
                totalProducts: products.length,
                lowStock: lowStock.length,
                outOfStock: outOfStock.length,
                lowStockProducts: lowStock.slice(0, 5).map(p => ({
                    id: p._id,
                    title: p.title,
                    stock: p.stock,
                    image: p.images[0],
                })),
            };
        }

        res.status(200).json({
            success: true,
            data: {
                topProducts,
                bottomProducts,
                categoryPerformance,
                stockAnalysis,
            },
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Get customer behavior analytics
// @route   GET /api/analytics/customer-behavior
// @access  Private (Supplier/Admin)
exports.getCustomerBehavior = async (req, res, next) => {
    try {
        if (req.user.role !== 'supplier' && req.user.role !== 'admin') {
            return res.status(403).json({
                success: false,
                message: 'Access denied. Supplier or admin role required.',
            });
        }

        const supplierId = req.user.role === 'supplier' ? req.user._id : null;
        const matchQuery = supplierId ? { supplier: supplierId } : {};

        // New vs returning customers
        const customerAnalysis = await Order.aggregate([
            { $match: matchQuery },
            {
                $group: {
                    _id: '$customer',
                    orderCount: { $sum: 1 },
                    totalSpent: { $sum: '$total' },
                    firstOrder: { $min: '$createdAt' },
                    lastOrder: { $max: '$createdAt' },
                },
            },
        ]);

        const newCustomers = customerAnalysis.filter(c => c.orderCount === 1).length;
        const returningCustomers = customerAnalysis.filter(c => c.orderCount > 1).length;

        // Average customer lifetime value
        const avgLifetimeValue = customerAnalysis.length > 0
            ? customerAnalysis.reduce((sum, c) => sum + c.totalSpent, 0) / customerAnalysis.length
            : 0;

        // Purchase frequency
        const avgOrdersPerCustomer = customerAnalysis.length > 0
            ? customerAnalysis.reduce((sum, c) => sum + c.orderCount, 0) / customerAnalysis.length
            : 0;

        // Top customers
        const topCustomers = customerAnalysis
            .sort((a, b) => b.totalSpent - a.totalSpent)
            .slice(0, 10);

        await User.populate(topCustomers, {
            path: '_id',
            select: 'firstName lastName email',
        });

        res.status(200).json({
            success: true,
            data: {
                summary: {
                    totalCustomers: customerAnalysis.length,
                    newCustomers,
                    returningCustomers,
                    avgLifetimeValue,
                    avgOrdersPerCustomer,
                },
                topCustomers,
            },
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Get supplier performance KPIs
// @route   GET /api/analytics/supplier-performance
// @access  Private (Supplier)
exports.getSupplierPerformance = async (req, res, next) => {
    try {
        const supplierId = req.user._id;

        // Order fulfillment metrics
        const orderMetrics = await Order.aggregate([
            { $match: { supplier: supplierId } },
            {
                $group: {
                    _id: null,
                    totalOrders: { $sum: 1 },
                    delivered: {
                        $sum: { $cond: [{ $eq: ['$status', 'delivered'] }, 1, 0] },
                    },
                    cancelled: {
                        $sum: { $cond: [{ $eq: ['$status', 'cancelled'] }, 1, 0] },
                    },
                    processing: {
                        $sum: { $cond: [{ $eq: ['$status', 'processing'] }, 1, 0] },
                    },
                },
            },
        ]);

        const metrics = orderMetrics[0] || {
            totalOrders: 0,
            delivered: 0,
            cancelled: 0,
            processing: 0,
        };

        const fulfillmentRate = metrics.totalOrders > 0
            ? (metrics.delivered / metrics.totalOrders) * 100
            : 0;

        // Average delivery time (for delivered orders)
        const deliveryTimeData = await Order.aggregate([
            {
                $match: {
                    supplier: supplierId,
                    status: 'delivered',
                    deliveredAt: { $exists: true },
                },
            },
            {
                $project: {
                    deliveryTime: {
                        $divide: [
                            { $subtract: ['$deliveredAt', '$createdAt'] },
                            1000 * 60 * 60 * 24, // Convert to days
                        ],
                    },
                },
            },
            {
                $group: {
                    _id: null,
                    avgDeliveryTime: { $avg: '$deliveryTime' },
                },
            },
        ]);

        const avgDeliveryTime = deliveryTimeData[0]?.avgDeliveryTime || 0;

        // Product catalog stats
        const productStats = await Product.aggregate([
            { $match: { supplier: supplierId } },
            {
                $group: {
                    _id: null,
                    totalProducts: { $sum: 1 },
                    activeProducts: {
                        $sum: { $cond: [{ $eq: ['$status', 'active'] }, 1, 0] },
                    },
                },
            },
        ]);

        const products = productStats[0] || { totalProducts: 0, activeProducts: 0 };

        res.status(200).json({
            success: true,
            data: {
                orderMetrics: metrics,
                fulfillmentRate: fulfillmentRate.toFixed(2),
                avgDeliveryTime: avgDeliveryTime.toFixed(1),
                productStats: products,
            },
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Get comparative analysis (period-over-period)
// @route   GET /api/analytics/compare?period=week|month|quarter|year
// @access  Private
exports.getComparativeAnalysis = async (req, res, next) => {
    try {
        const { period = 'month' } = req.query;
        const userId = req.user.id;
        const userRole = req.user.role;

        // Calculate date ranges
        const now = new Date();
        let currentStart, currentEnd, previousStart, previousEnd;

        if (period === 'week') {
            currentEnd = new Date(now);
            currentStart = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
            previousEnd = new Date(currentStart.getTime() - 1);
            previousStart = new Date(previousEnd.getTime() - 7 * 24 * 60 * 60 * 1000);
        } else if (period === 'month') {
            currentEnd = new Date(now);
            currentStart = new Date(now.getFullYear(), now.getMonth(), 1);
            previousEnd = new Date(currentStart.getTime() - 1);
            previousStart = new Date(previousEnd.getFullYear(), previousEnd.getMonth(), 1);
        } else if (period === 'quarter') {
            const currentQuarter = Math.floor(now.getMonth() / 3);
            currentStart = new Date(now.getFullYear(), currentQuarter * 3, 1);
            currentEnd = new Date(now);
            previousEnd = new Date(currentStart.getTime() - 1);
            const prevQuarter = Math.floor(previousEnd.getMonth() / 3);
            previousStart = new Date(previousEnd.getFullYear(), prevQuarter * 3, 1);
        } else {
            // year
            currentStart = new Date(now.getFullYear(), 0, 1);
            currentEnd = new Date(now);
            previousStart = new Date(now.getFullYear() - 1, 0, 1);
            previousEnd = new Date(now.getFullYear() - 1, 11, 31);
        }

        // Build match query
        const baseMatch = { status: { $in: ['delivered', 'shipped', 'processing'] } };
        if (userRole === 'supplier') {
            baseMatch.supplier = req.user._id;
        } else if (userRole === 'customer') {
            baseMatch.customer = req.user._id;
        }

        // Current period data
        const currentData = await Order.aggregate([
            {
                $match: {
                    ...baseMatch,
                    createdAt: { $gte: currentStart, $lte: currentEnd },
                },
            },
            {
                $group: {
                    _id: null,
                    revenue: { $sum: '$total' },
                    orders: { $sum: 1 },
                    avgOrderValue: { $avg: '$total' },
                },
            },
        ]);

        // Previous period data
        const previousData = await Order.aggregate([
            {
                $match: {
                    ...baseMatch,
                    createdAt: { $gte: previousStart, $lte: previousEnd },
                },
            },
            {
                $group: {
                    _id: null,
                    revenue: { $sum: '$total' },
                    orders: { $sum: 1 },
                    avgOrderValue: { $avg: '$total' },
                },
            },
        ]);

        const current = currentData[0] || { revenue: 0, orders: 0, avgOrderValue: 0 };
        const previous = previousData[0] || { revenue: 0, orders: 0, avgOrderValue: 0 };

        // Calculate changes
        const comparison = {
            revenue: {
                current: current.revenue,
                previous: previous.revenue,
                change: calculatePercentageChange(current.revenue, previous.revenue),
                trend: current.revenue >= previous.revenue ? 'up' : 'down',
            },
            orders: {
                current: current.orders,
                previous: previous.orders,
                change: calculatePercentageChange(current.orders, previous.orders),
                trend: current.orders >= previous.orders ? 'up' : 'down',
            },
            avgOrderValue: {
                current: current.avgOrderValue,
                previous: previous.avgOrderValue,
                change: calculatePercentageChange(current.avgOrderValue, previous.avgOrderValue),
                trend: current.avgOrderValue >= previous.avgOrderValue ? 'up' : 'down',
            },
        };

        res.status(200).json({
            success: true,
            data: {
                period,
                currentPeriod: {
                    start: currentStart,
                    end: currentEnd,
                },
                previousPeriod: {
                    start: previousStart,
                    end: previousEnd,
                },
                comparison,
            },
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Export analytics as CSV
// @route   GET /api/analytics/export/csv?reportType=sales|products|customers&startDate=XXX&endDate=XXX
// @access  Private
exports.exportCSV = async (req, res, next) => {
    try {
        const { reportType, startDate, endDate } = req.query;

        if (!reportType) {
            return res.status(400).json({
                success: false,
                message: 'Report type is required',
            });
        }

        const start = startDate ? new Date(startDate) : new Date(new Date().getTime() - 30 * 24 * 60 * 60 * 1000);
        const end = endDate ? new Date(endDate) : new Date();
        end.setHours(23, 59, 59, 999);

        const matchQuery = {
            createdAt: { $gte: start, $lte: end },
        };

        if (req.user.role === 'supplier') {
            matchQuery.supplier = req.user._id;
        } else if (req.user.role === 'customer') {
            matchQuery.customer = req.user._id;
        }

        let csvData;
        let filename;

        if (reportType === 'sales') {
            const orders = await Order.find(matchQuery)
                .populate('customer', 'firstName lastName email')
                .sort({ createdAt: -1 });

            const headers = ['Order ID', 'Date', 'Customer', 'Status', 'Total', 'Items'];
            const rows = orders.map(order => [
                order._id.toString(),
                order.createdAt.toISOString().split('T')[0],
                order.customer ? `${order.customer.firstName} ${order.customer.lastName}` : 'N/A',
                order.status,
                order.total.toFixed(2),
                order.items.length,
            ]);

            csvData = generateCSV(headers, rows);
            filename = `sales_report_${start.toISOString().split('T')[0]}_to_${end.toISOString().split('T')[0]}.csv`;
        } else if (reportType === 'products') {
            const productMatch = req.user.role === 'supplier' ? { supplier: req.user._id } : {};
            const products = await Product.find(productMatch).populate('category', 'name');

            const headers = ['Product ID', 'Title', 'Category', 'Price', 'Stock', 'Status'];
            const rows = products.map(product => [
                product._id.toString(),
                product.title,
                product.category?.name || 'N/A',
                product.price.toFixed(2),
                product.stock,
                product.status,
            ]);

            csvData = generateCSV(headers, rows);
            filename = `products_report_${new Date().toISOString().split('T')[0]}.csv`;
        } else {
            return res.status(400).json({
                success: false,
                message: 'Invalid report type',
            });
        }

        res.setHeader('Content-Type', 'text/csv');
        res.setHeader('Content-Disposition', `attachment; filename="${filename}"`);
        res.status(200).send(csvData);
    } catch (error) {
        next(error);
    }
};

// @desc    Export analytics as PDF (placeholder - requires PDF library)
// @route   GET /api/analytics/export/pdf?reportType=sales|products&startDate=XXX&endDate=XXX
// @access  Private
exports.exportPDF = async (req, res, next) => {
    try {
        res.status(501).json({
            success: false,
            message: 'PDF export not yet implemented. Please use CSV export instead.',
        });
    } catch (error) {
        next(error);
    }
};
