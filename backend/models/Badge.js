const mongoose = require('mongoose');

const badgeSchema = new mongoose.Schema(
    {
        name: {
            type: String,
            required: true,
            unique: true,
        },
        description: {
            type: String,
            required: true,
        },
        icon: {
            type: String,
            required: true,
        },
        color: {
            type: String,
            default: '#2196F3',
        },
        criteria: {
            type: {
                type: String,
                enum: ['purchase_count', 'total_spent', 'review_count', 'referral_count', 'days_active', 'special'],
                required: true,
            },
            value: Number,
        },
        pointsReward: {
            type: Number,
            default: 0,
        },
        rarity: {
            type: String,
            enum: ['common', 'rare', 'epic', 'legendary'],
            default: 'common',
        },
        isActive: {
            type: Boolean,
            default: true,
        },
    },
    {
        timestamps: true,
    }
);

module.exports = mongoose.model('Badge', badgeSchema);
