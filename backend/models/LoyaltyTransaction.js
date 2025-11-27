const mongoose = require('mongoose');

const loyaltyTransactionSchema = new mongoose.Schema(
    {
        userId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'User',
            required: true,
        },
        type: {
            type: String,
            enum: ['earn', 'redeem'],
            required: true,
        },
        points: {
            type: Number,
            required: true,
        },
        reason: {
            type: String,
            required: true,
            maxlength: 200,
        },
        relatedModel: {
            type: String,
            enum: ['Order', 'Review', 'Referral', 'Daily', 'Other'],
        },
        relatedId: {
            type: mongoose.Schema.Types.ObjectId,
        },
        balanceAfter: {
            type: Number,
            required: true,
        },
    },
    {
        timestamps: true,
    }
);

// Indexes for performance
loyaltyTransactionSchema.index({ userId: 1, createdAt: -1 });
loyaltyTransactionSchema.index({ type: 1 });

module.exports = mongoose.model('LoyaltyTransaction', loyaltyTransactionSchema);
