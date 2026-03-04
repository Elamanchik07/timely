const mongoose = require('mongoose');

const TeacherSchema = new mongoose.Schema({
    fullName: {
        type: String,
        required: [true, 'ФИО преподавателя обязательно'],
        trim: true
    },
    phone: {
        type: String,
        trim: true
    },
    subjects: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Subject'
    }],
    isActive: {
        type: Boolean,
        default: true
    }
}, {
    timestamps: true
});

module.exports = mongoose.model('Teacher', TeacherSchema);
