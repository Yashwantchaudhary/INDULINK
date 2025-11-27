const mongoose = require('mongoose');

const reviewSchema = new mongoose.Schema(
    {
        product: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'Product',
            required: true,
        },
        customer: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'User',
            required: true,
        },
        order: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'Order',
        },
        rating: {
            type: Number,
            required: [true, 'Rating is required'],
            min: [1, 'Rating must be at least 1'],
            max: [5, 'Rating cannot exceed 5'],
        },
        title: {
            type: String,
            trim: true,
            maxlength: [100, 'Review title cannot exceed 100 characters'],
        },
        comment: {
            type: String,
            required: [true, 'Review comment is required'],
            trim: true,
            maxlength: [1000, 'Review cannot exceed 1000 characters'],
        },
        images: [
            {
                url: String,
                alt: String,
            },
        ],
        isVerifiedPurchase: {
            type: Boolean,
            default: false,
        },
        helpfulCount: {
            type: Number,
            default: 0,
        },
        helpfulBy: [
            {
                type: mongoose.Schema.Types.ObjectId,
                ref: 'User',
            },
        ],
        status: {
            type: String,
            enum: ['pending', 'approved', 'rejected'],
            default: 'approved',
        },
        // Supplier response
        response: {
            comment: String,
            respondedAt: Date,
        },
    },
    {
        timestamps: true,
    }
);

// Unique compound index - one review per customer per product
reviewSchema.index({ product: 1, customer: 1 }, { unique: true });
reviewSchema.index({ product: 1, status: 1, createdAt: -1 });

// Update product ratings after review is saved
reviewSchema.post('save', async function () {
    await this.updateProductRatings();
});

// Update product ratings after review is deleted
reviewSchema.post('remove', async function () {
    await this.updateProductRatings();
});

// Method to update product rating statistics
reviewSchema.methods.updateProductRatings = async function () {
    const Product = mongoose.model('Product');
    const stats = await mongoose.model('Review').aggregate([
        {
            $match: {
                product: this.product,
                status: 'approved',
            },
        },
        {
            $group: {
                _id: '$product',
                averageRating: { $avg: '$rating' },
                totalReviews: { $sum: 1 },
            },
        },
    ]);

    if (stats.length > 0) {
        await Product.findByIdAndUpdate(this.product, {
            averageRating: Math.round(stats[0].averageRating * 10) / 10,
            totalReviews: stats[0].totalReviews,
        });
    } else {
        await Product.findByIdAndUpdate(this.product, {
            averageRating: 0,
            totalReviews: 0,
        });
    }
};

module.exports = mongoose.model('Review', reviewSchema);
