const mongoose = require('mongoose');

const RoomSchema = new mongoose.Schema({
    shortCode: {
        type: String,
        required: [true, 'Короткий код обязателен (например, 201)'],
        trim: true
    },
    sector: {
        type: String,
        required: [true, 'Сектор обязателен (например, C1.1)'],
        trim: true
    },
    fullCode: {
        type: String,
        required: [true, 'Полный код обязателен (например, C1.1.201)'],
        trim: true,
        unique: true
    },
    // Backwards compatibility
    code: {
        type: String,
        trim: true
    },
    building: {
        type: String,
        required: [true, 'Корпус обязателен (например, 1)'],
        trim: true,
        default: 'C1'
    },
    floor: {
        type: Number,
        required: [true, 'Этаж обязателен'],
        min: 1,
        max: 5
    },
    description: {
        type: String,
        trim: true
    },
    // Position as percentage of original map image (0.0 to 1.0)
    positionX: {
        type: Number,
        default: 0.0,
        min: 0.0,
        max: 1.0
    },
    positionY: {
        type: Number,
        default: 0.0,
        min: 0.0,
        max: 1.0
    },
    type: {
        type: String,
        enum: ['LECTURE', 'PRACTICE', 'LAB', 'OFFICE', 'OTHER'],
        default: 'LECTURE'
    },
    isActive: {
        type: Boolean,
        default: true
    }
}, {
    timestamps: true
});

module.exports = mongoose.model('Room', RoomSchema);
