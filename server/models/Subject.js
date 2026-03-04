const mongoose = require('mongoose');

const SubjectSchema = new mongoose.Schema({
    name: {
        type: String,
        required: [true, 'Subject name is required'],
        trim: true,
        unique: true
    },
    shortName: {
        type: String,
        trim: true
    },
    color: {
        type: String,
        trim: true
    },
    icon: {
        type: String,
        trim: true
    }
}, {
    timestamps: true
});

module.exports = mongoose.model('Subject', SubjectSchema);
