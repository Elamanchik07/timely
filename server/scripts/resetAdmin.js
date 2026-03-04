require('dotenv').config();
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const User = require('../models/User');

const mongoURI = process.env.MONGODB_URI || 'mongodb+srv://offtimely_db_user:Freefire01@cluster0.sofdq4n.mongodb.net/timely_db?retryWrites=true&w=majority&appName=Cluster0';

async function resetAdmin() {
    try {
        await mongoose.connect(mongoURI);
        console.log('✅ Connected to MongoDB');

        const adminEmail = (process.env.ADMIN_EMAIL || 'admin@timely.kz').toLowerCase();
        const adminPassword = process.env.ADMIN_PASSWORD || 'TimelyAdmin#2026';
        const passwordHash = await bcrypt.hash(adminPassword, 10);

        let admin = await User.findOne({ email: adminEmail });

        if (admin) {
            console.log(`🔄 Updating existing admin: ${adminEmail}`);
            admin.passwordHash = passwordHash;
            admin.role = 'ADMIN';
            admin.status = 'APPROVED';
            admin.isBlocked = false;
            // Ensure required fields are present if they weren't before
            if (!admin.fullName) admin.fullName = process.env.ADMIN_FULL_NAME || 'System Administrator';
            if (!admin.phone) admin.phone = '+77000000000';
        } else {
            console.log(`✨ Creating new admin: ${adminEmail}`);
            admin = new User({
                fullName: process.env.ADMIN_FULL_NAME || 'System Administrator',
                email: adminEmail,
                phone: '+77000000000',
                passwordHash,
                role: 'ADMIN',
                status: 'APPROVED',
                isBlocked: false
            });
        }

        await admin.save();
        console.log('✅ Admin credentials reset successfully!');
        console.log(`   Email: ${adminEmail}`);
        console.log(`   Password: ${adminPassword}`);

        process.exit(0);
    } catch (error) {
        console.error('❌ Error resetting admin:', error);
        process.exit(1);
    }
}

resetAdmin();
