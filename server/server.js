const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const path = require('path');
const rateLimit = require('express-rate-limit');
require('dotenv').config();

const app = express();

// Middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));
app.use(cors());

// Serve static uploads
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Rate Limiters
const limiter = rateLimit({
    windowMs: 15 * 60 * 1000,
    max: 200
});
app.use(limiter);

// DB Connection
const mongoURI = process.env.MONGODB_URI || 'mongodb+srv://offtimely_db_user:Freefire01@cluster0.sofdq4n.mongodb.net/timely_db?retryWrites=true&w=majority&appName=Cluster0';
mongoose.connect(mongoURI)
    .then(async () => {
        console.log('✅ MongoDB Connected');
        try {
            const User = require('./models/User');
            const bcrypt = require('bcryptjs');
            const adminEmail = (process.env.ADMIN_EMAIL || 'admin@timely.kz').toLowerCase();
            const adminPassword = process.env.ADMIN_PASSWORD || 'TimelyAdmin#2026';

            let admin = await User.findOne({ email: adminEmail });
            const passwordHash = await bcrypt.hash(adminPassword, 10);
            if (!admin) {
                await User.create({
                    fullName: process.env.ADMIN_FULL_NAME || 'System Administrator',
                    email: adminEmail,
                    phone: process.env.ADMIN_PHONE || '+77000000000',
                    passwordHash,
                    role: 'ADMIN',
                    status: 'APPROVED'
                });
                console.log('✨ Admin user seeded successfully');
            } else {
                // Always sync password hash, role, status and phone from .env
                admin.passwordHash = passwordHash;
                admin.phone = process.env.ADMIN_PHONE || admin.phone || '+77000000000';
                if (admin.role !== 'ADMIN') admin.role = 'ADMIN';
                if (admin.status !== 'APPROVED') admin.status = 'APPROVED';
                await admin.save();
                console.log('🔄 Admin password synced from .env');
            }
        } catch (err) {
            console.error('❌ Admin seeding error:', err);
        }
    })
    .catch(err => console.log('❌ MongoDB Error:', err));

// Routes
app.use('/api/auth', require('./routes/auth'));
app.use('/api/admin', require('./routes/admin'));
app.use('/api/schedule', require('./routes/schedule'));
app.use('/api/rooms', require('./routes/rooms'));
app.use('/api/news', require('./routes/news'));

app.get('/health', (req, res) => res.json({ status: 'OK', time: new Date() }));

// Global Error Handler
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({ success: false, msg: 'Внутренняя ошибка сервера' });
});

// 404 handler
app.use((req, res) => {
    res.status(404).json({
        success: false,
        msg: 'Endpoint not found'
    });
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 Server running on port ${PORT}`);
    console.log(`📡 Environment: ${process.env.NODE_ENV || 'development'}`);
});