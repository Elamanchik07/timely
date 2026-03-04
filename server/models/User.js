const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
    fullName: {
        type: String,
        required: [true, 'ФИО обязательно для заполнения'],
        trim: true,
        minlength: [2, 'ФИО должно быть не короче 2 символов']
    },
    email: {
        type: String,
        required: [true, 'Email обязателен для заполнения'],
        unique: true,
        lowercase: true,
        trim: true,
        validate: {
            validator: function (v) {
                return /^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$/.test(v);
            },
            message: 'Введите корректный Email адрес'
        }
    },
    phone: {
        type: String,
        required: [true, 'Номер телефона обязателен'],
        trim: true,
        validate: {
            validator: function (v) {
                // Kazakhstan phone format: +7 followed by 10 digits
                return /^\+7\d{10}$/.test(v);
            },
            message: 'Номер телефона должен быть в формате +7XXXXXXXXXX'
        }
    },
    passwordHash: {
        type: String,
        required: [true, 'Пароль обязателен']
    },
    role: {
        type: String,
        enum: ['STUDENT', 'ADMIN'],
        default: 'STUDENT'
    },
    status: {
        type: String,
        enum: ['PENDING', 'APPROVED', 'REJECTED'],
        default: 'PENDING'
    },
    course: {
        type: Number,
        min: [1, 'Курс должен быть от 1 до 4'],
        max: [4, 'Курс должен быть от 1 до 4'],
        required: function () { return this.role === 'STUDENT'; }
    },
    groupCode: {
        type: String,
        trim: true,
        required: function () { return this.role === 'STUDENT'; }
    },
    university: {
        type: String,
        trim: true,
        default: null
    },
    faculty: {
        type: String,
        trim: true,
        default: null
    },
    specialty: {
        type: String,
        trim: true,
        default: null
    },
    rejectReason: {
        type: String,
        default: null
    },
    isBlocked: {
        type: Boolean,
        default: false
    },
    avatar: {
        type: String,
        default: null
    },
    isDeleted: {
        type: Boolean,
        default: false
    },
    resetPasswordToken: String,
    resetPasswordExpires: Date,
    resetPasswordAttempts: { type: Number, default: 0 },
    resetPasswordEmailStatus: String
}, {
    timestamps: true
});

// Indexes for faster queries
UserSchema.index({ status: 1, role: 1 });
UserSchema.index({ groupCode: 1 });

module.exports = mongoose.model('User', UserSchema);
