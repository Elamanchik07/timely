const mongoose = require('mongoose');

const AdminLogSchema = new mongoose.Schema({
    adminId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    adminEmail: {
        type: String,
        required: true
    },
    action: {
        type: String,
        required: true
    },
    targetId: {
        type: String
    },
    targetModel: {
        type: String
    },
    details: {
        type: mongoose.Schema.Types.Mixed
    }
}, {
    timestamps: true
});

module.exports = mongoose.model('AdminLog', AdminLogSchema);
