const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const router = express.Router();
const User = require('../models/User');
const emailService = require('../services/emailService');

// Helper to handle Mongoose errors
const handleErrors = (res, error) => {
    if (error.name === 'ValidationError') {
        const messages = Object.values(error.errors).map(val => val.message);
        return res.status(400).json({ success: false, msg: messages.join(', ') });
    }
    console.error('Error:', error);
    return res.status(500).json({ success: false, msg: 'Ошибка сервера' });
};

// In-memory rate limiter for password reset requests
const resetRateLimiter = new Map(); // email -> { count, firstAttempt }
const RATE_LIMIT_WINDOW_MS = 15 * 60 * 1000; // 15 minutes
const RATE_LIMIT_MAX = 5; // max 5 requests per window

function checkResetRateLimit(email) {
    const now = Date.now();
    const entry = resetRateLimiter.get(email);
    if (!entry || (now - entry.firstAttempt) > RATE_LIMIT_WINDOW_MS) {
        resetRateLimiter.set(email, { count: 1, firstAttempt: now });
        return true;
    }
    if (entry.count >= RATE_LIMIT_MAX) {
        return false;
    }
    entry.count++;
    return true;
}

// POST /api/auth/register
router.post('/register', async (req, res) => {
    try {
        const { fullName, email, phone, password, course, groupCode, faculty, role } = req.body;

        // Prevent creating ADMIN via public API
        if (role === 'ADMIN') {
            return res.status(403).json({ success: false, msg: 'Регистрация администраторов запрещена' });
        }

        // Validate required fields
        if (!fullName || !email || !password) {
            return res.status(400).json({ success: false, msg: 'Заполните все обязательные поля' });
        }

        if (password.length < 8) {
            return res.status(400).json({ success: false, msg: 'Пароль должен быть не менее 8 символов' });
        }

        // Check availability
        const existingEmail = await User.findOne({ email: email.toLowerCase() });
        if (existingEmail) {
            return res.status(400).json({ success: false, msg: 'Email уже занят' });
        }

        const passwordHash = await bcrypt.hash(password, 10);

        const newUser = new User({
            fullName,
            email: email.toLowerCase(),
            phone,
            passwordHash,
            role: 'STUDENT',
            status: 'PENDING',
            course,
            groupCode,
            faculty
        });

        await newUser.save();

        console.log(`[INFO] New user registered: ${email} (PENDING)`);

        res.status(201).json({
            success: true,
            msg: 'Регистрация успешна! Ваш аккаунт на проверке у администратора.'
        });

    } catch (error) {
        handleErrors(res, error);
    }
});

// POST /api/auth/login
router.post('/login', async (req, res) => {
    try {
        const { email, password } = req.body;

        if (!email || !password) {
            return res.status(400).json({ success: false, msg: 'Введите email и пароль' });
        }

        const user = await User.findOne({ email: email.toLowerCase() });
        if (!user) {
            return res.status(404).json({ success: false, msg: 'Пользователь не найден' });
        }

        const isMatch = await bcrypt.compare(password, user.passwordHash);
        if (!isMatch) {
            return res.status(401).json({ success: false, msg: 'Неверный пароль' });
        }

        if (user.isDeleted) {
            return res.status(404).json({ success: false, msg: 'Пользователь не найден' });
        }

        // Blocked check
        if (user.isBlocked) {
            return res.status(403).json({
                success: false,
                msg: 'Ваш аккаунт заблокирован. Обратитесь к администратору.',
                status: 'BLOCKED'
            });
        }

        // Status checks
        if (user.status === 'PENDING') {
            return res.status(403).json({
                success: false,
                msg: 'Ваш аккаунт ожидает подтверждения администратором',
                status: 'PENDING'
            });
        }
        if (user.status === 'REJECTED') {
            return res.status(403).json({
                success: false,
                msg: user.rejectReason
                    ? `Ваша заявка отклонена: ${user.rejectReason}`
                    : 'Ваша заявка отклонена администратором',
                status: 'REJECTED',
                rejectReason: user.rejectReason || null
            });
        }

        const token = jwt.sign(
            { id: user._id, role: user.role, status: user.status },
            process.env.JWT_SECRET || 'secret_key',
            { expiresIn: '7d' }
        );

        res.json({
            success: true,
            token,
            user: {
                id: user._id,
                fullName: user.fullName,
                email: user.email,
                role: user.role,
                status: user.status,
                avatar: user.avatar,
                groupCode: user.groupCode,
                phone: user.phone,
                course: user.course,
                university: user.university,
                faculty: user.faculty,
                specialty: user.specialty
            }
        });

    } catch (error) {
        handleErrors(res, error);
    }
});

// ═══════════════════════════════════════════════════════════════
// PASSWORD RESET FLOW (6-digit code)
// ═══════════════════════════════════════════════════════════════

// POST /api/auth/password/reset/request
// Sends a 6-digit code to the user's email
router.post('/password/reset/request', async (req, res) => {
    try {
        const { email } = req.body;

        if (!email) {
            return res.status(400).json({ success: false, msg: 'Введите email' });
        }

        const normalizedEmail = email.toLowerCase().trim();

        // Rate limit check
        if (!checkResetRateLimit(normalizedEmail)) {
            return res.status(429).json({
                success: false,
                msg: 'Слишком много запросов. Попробуйте позже.'
            });
        }

        // Generic success response regardless of whether email exists (security)
        const genericSuccess = {
            success: true,
            msg: 'Если аккаунт существует, код отправлен на email'
        };

        const user = await User.findOne({ email: normalizedEmail });
        if (!user) {
            // Do NOT reveal that user doesn't exist
            return res.json(genericSuccess);
        }

        // Generate 6-digit code
        const code = Math.floor(100000 + Math.random() * 900000).toString();

        // Store hashed code
        user.resetPasswordToken = crypto.createHash('sha256').update(code).digest('hex');
        user.resetPasswordExpires = Date.now() + 10 * 60 * 1000; // 10 minutes
        user.resetPasswordAttempts = 0;

        await user.save();

        // Send email with code
        try {
            const emailResult = await emailService.sendPasswordResetCode(normalizedEmail, user.fullName, code);
            if (emailResult.success) {
                console.log(`[INFO] Password reset code sent to ${normalizedEmail}, MsgID: ${emailResult.messageId}`);
                user.resetPasswordEmailStatus = `SENT_SUCCESS (ID: ${emailResult.messageId})`;
            } else {
                console.error(`[WARN] Failed to send reset email to ${normalizedEmail}:`, emailResult.error);
                user.resetPasswordEmailStatus = `FAILED: ${emailResult.error}`;
            }
            await user.save(); // Save the email status
        } catch (emailErr) {
            console.error(`[WARN] Exception while sending reset email to ${normalizedEmail}:`, emailErr);
            user.resetPasswordEmailStatus = `EXCEPTION: ${emailErr.message}`;
            await user.save();
        }

        res.json(genericSuccess);

    } catch (error) {
        handleErrors(res, error);
    }
});

// POST /api/auth/password/reset/verify
// Verifies the 6-digit code and returns a one-time resetToken
router.post('/password/reset/verify', async (req, res) => {
    try {
        const { email, code } = req.body;

        if (!email || !code) {
            return res.status(400).json({ success: false, msg: 'Введите email и код' });
        }

        const normalizedEmail = email.toLowerCase().trim();
        const hashedCode = crypto.createHash('sha256').update(code.toString().trim()).digest('hex');

        const user = await User.findOne({
            email: normalizedEmail,
            resetPasswordExpires: { $gt: Date.now() }
        });

        if (!user || !user.resetPasswordToken) {
            return res.status(400).json({
                success: false,
                msg: 'Код истёк или недействителен'
            });
        }

        // Check attempts (max 5)
        if (user.resetPasswordAttempts >= 5) {
            // Invalidate the code
            user.resetPasswordToken = undefined;
            user.resetPasswordExpires = undefined;
            user.resetPasswordAttempts = undefined;
            await user.save();
            return res.status(400).json({
                success: false,
                msg: 'Превышено количество попыток. Запросите новый код.'
            });
        }

        if (user.resetPasswordToken !== hashedCode) {
            user.resetPasswordAttempts = (user.resetPasswordAttempts || 0) + 1;
            await user.save();
            return res.status(400).json({
                success: false,
                msg: 'Неверный код'
            });
        }

        // Code is correct — generate a one-time reset token for the confirm step
        const resetToken = crypto.randomBytes(32).toString('hex');
        user.resetPasswordToken = crypto.createHash('sha256').update(resetToken).digest('hex');
        user.resetPasswordExpires = Date.now() + 5 * 60 * 1000; // 5 more minutes to set password
        user.resetPasswordAttempts = undefined;
        await user.save();

        res.json({
            success: true,
            resetToken,
            msg: 'Код подтверждён'
        });

    } catch (error) {
        handleErrors(res, error);
    }
});

// POST /api/auth/password/reset/confirm
// Sets new password using the resetToken from verify step
router.post('/password/reset/confirm', async (req, res) => {
    try {
        const { resetToken, password } = req.body;

        if (!resetToken || !password) {
            return res.status(400).json({ success: false, msg: 'Отсутствуют данные' });
        }

        if (password.length < 8) {
            return res.status(400).json({ success: false, msg: 'Пароль должен быть не менее 8 символов' });
        }

        const hashedToken = crypto.createHash('sha256').update(resetToken).digest('hex');

        const user = await User.findOne({
            resetPasswordToken: hashedToken,
            resetPasswordExpires: { $gt: Date.now() }
        });

        if (!user) {
            return res.status(400).json({ success: false, msg: 'Неверный или истекший токен' });
        }

        // Set new password
        user.passwordHash = await bcrypt.hash(password, 10);
        user.resetPasswordToken = undefined;
        user.resetPasswordExpires = undefined;
        user.resetPasswordAttempts = undefined;

        await user.save();

        console.log(`[INFO] Password reset successful for ${user.email}`);

        res.json({
            success: true,
            msg: 'Пароль успешно изменён'
        });

    } catch (error) {
        handleErrors(res, error);
    }
});

// Legacy endpoint kept for backward compatibility
// POST /api/auth/forgot-password
router.post('/forgot-password', async (req, res) => {
    try {
        const { email } = req.body;
        // Redirect to new flow
        return res.json({
            success: true,
            msg: 'Используйте /password/reset/request для сброса пароля'
        });
    } catch (error) {
        handleErrors(res, error);
    }
});

// POST /api/auth/debug/test-email
// Diagnostic endpoint to verify deliverability specifically
router.post('/debug/test-email', async (req, res) => {
    try {
        const { email } = req.body;
        if (!email) {
            return res.status(400).json({ success: false, msg: 'Email is required' });
        }

        const mailOptions = {
            from: `"Timely Diagnostics" <${process.env.EMAIL_USER || 'noreply@timely.app'}>`,
            to: email,
            subject: 'Test Email Deliverability - Timely',
            html: `
            <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; text-align: center;">
                <h2 style="color: #4CAF50;">Diagnostical Test Email</h2>
                <p>Hello! If you are seeing this email, the SMTP transporter has successfully sent it from the Timely NodeJS app.</p>
                <p><strong>Configured Provider:</strong> ${process.env.EMAIL_PROVIDER || 'Not Set'}</p>
                <p><strong>Configured E-Mail:</strong> ${process.env.EMAIL_USER || 'Not Set'}</p>
                <p><strong>Timestamp:</strong> ${new Date().toISOString()}</p>
            </div>
            `
        };

        const result = await emailService._sendMail(mailOptions, 'DEBUG_TEST');
        res.json({ success: result.success, messageId: result.messageId, error: result.error });

    } catch (error) {
        handleErrors(res, error);
    }
});

module.exports = router;
