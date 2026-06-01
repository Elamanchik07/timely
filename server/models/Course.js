const mongoose = require('mongoose');

const CourseSchema = new mongoose.Schema({
    number: {
        type: Number,
        required: [true, 'Course number is required'],
        unique: true,
        min: 1,
        max: 6
    },
    title: {
        type: String,
        trim: true
    },
    isActive: {
        type: Boolean,
        default: true
    }
}, {
    timestamps: true
});

module.exports = mongoose.model('Course', CourseSchema);
