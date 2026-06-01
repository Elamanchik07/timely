require('dotenv').config();
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const User = require('../models/User');

const mongoURI = process.env.MONGODB_URI || 'mongodb+srv://offtimely_db_user:Freefire01@cluster0.sofdq4n.mongodb.net/timely_db?retryWrites=true&w=majority&appName=Cluster0';

async function seedAdmin() {
    try {
        await mongoose.connect(mongoURI, {
            useNewUrlParser: true,
            useUnifiedTopology: true
        });

        console.log('✅ Connected to MongoDB');

        // Check if admin already exists
        const adminEmail = process.env.ADMIN_EMAIL || 'admin@timely.kz';
        const existingAdmin = await User.findOne({ email: adminEmail });

        if (existingAdmin) {
            console.log(`⚠️  Admin user already exists: ${adminEmail}`);
            process.exit(0);
        }

        // Create admin user
        const adminPassword = process.env.ADMIN_PASSWORD || 'TimelyAdmin#2026';
        const passwordHash = await bcrypt.hash(adminPassword, 10);

        const admin = new User({
            fullName: process.env.ADMIN_FULL_NAME || 'System Administrator',
            email: adminEmail,
            passwordHash,
            role: 'ADMIN',
            status: 'APPROVED'
        });

        await admin.save();

        console.log('✅ Admin user created successfully!');
        console.log(`   Email: ${adminEmail}`);
        console.log(`   Password: ${adminPassword}`);
        console.log(`   Role: ADMIN`);
        console.log('\n⚠️  IMPORTANT: Change the default password after first login!');

        process.exit(0);
    } catch (error) {
        console.error('❌ Error seeding admin:', error);
        process.exit(1);
    }
}

seedAdmin();
