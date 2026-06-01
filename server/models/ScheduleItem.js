const mongoose = require('mongoose');

const ScheduleItemSchema = new mongoose.Schema({
    groupCode: {
        type: String,
        required: [true, 'Group code is required'],
        trim: true
    },
    dayOfWeek: {
        type: Number,
        required: [true, 'Day of week is required'],
        min: 1,
        max: 7
    },
    pairNumber: {
        type: Number,
        required: [true, 'Pair number is required'],
        min: 1,
        max: 5
    },
    startTime: {
        type: String,
        required: [true, 'Start time is required'],
        validate: {
            validator: function (v) {
                return /^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/.test(v);
            },
            message: 'Invalid time format (HH:MM)'
        }
    },
    endTime: {
        type: String,
        required: [true, 'End time is required'],
        validate: {
            validator: function (v) {
                return /^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/.test(v);
            },
            message: 'Invalid time format (HH:MM)'
        }
    },
    subject: {
        type: String,
        required: [true, 'Subject is required'],
        trim: true
    },
    subjectId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Subject'
    },
    teacher: {
        type: String,
        required: [true, 'Teacher is required'],
        trim: true
    },
    teacherId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Teacher'
    },
    room: {
        type: String,
        required: [true, 'Room is required'],
        trim: true
    },
    roomId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Room'
    },
    type: {
        type: String,
        enum: ['lecture', 'practice', 'lab', 'seminar'],
        default: 'lecture'
    },
    weekType: {
        type: String,
        enum: ['ALL', 'ODD', 'EVEN'],
        default: 'ALL'
    }
}, {
    timestamps: true
});

// Indexes for faster queries
ScheduleItemSchema.index({ groupCode: 1, dayOfWeek: 1 });

module.exports = mongoose.model('ScheduleItem', ScheduleItemSchema);
