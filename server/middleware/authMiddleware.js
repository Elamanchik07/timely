const jwt = require('jsonwebtoken');
const User = require('../models/User');

const protect = async (req, res, next) => {
    let token;

    if (
        req.headers.authorization &&
        req.headers.authorization.startsWith('Bearer')
    ) {
        try {
            // Get token from header
            token = req.headers.authorization.split(' ')[1];

            // Verify token
            const decoded = jwt.verify(token, process.env.JWT_SECRET || 'secret_key');

            // Get user from the token
            req.user = await User.findById(decoded.id).select('-passwordHash');

            if (!req.user) {
                return res.status(401).json({ success: false, msg: 'Пользователь не найден' });
            }

            // Strict Status Check
            if (req.user.isBlocked) {
                return res.status(403).json({ success: false, msg: 'Аккаунт заблокирован', status: 'BLOCKED' });
            }
            if (req.user.status === 'PENDING') {
                return res.status(403).json({ success: false, msg: 'Аккаунт ожидает подтверждения', status: 'PENDING' });
            }
            if (req.user.status === 'REJECTED') {
                return res.status(403).json({ success: false, msg: 'Аккаунт отклонен', status: 'REJECTED' });
            }

            next();
        } catch (error) {
            console.error(error);
            return res.status(401).json({ success: false, msg: 'Не авторизован' });
        }
    }

    if (!token) {
        return res.status(401).json({ success: false, msg: 'Нет токена, доступ запрещен' });
    }
};

module.exports = { protect };
