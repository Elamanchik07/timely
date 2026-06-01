const mongoose = require('mongoose');

const GroupSchema = new mongoose.Schema({
    groupCode: {
        type: String,
        required: [true, 'Group code is required'],
        unique: true,
        trim: true
    },
    title: {
        type: String,
        trim: true
    },
    description: {
        type: String,
        trim: true
    },
    courseId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Course'
    },
    course: {
        type: Number,
        min: 1,
        max: 6
    },
    shift: {
        type: Number,
        required: [true, 'Shift is required'],
        enum: [1, 2],
        default: 1
    },
    isActive: {
        type: Boolean,
        default: true
    }
}, {
    timestamps: true
});

// Index for faster queries
module.exports = mongoose.model('Group', GroupSchema);
