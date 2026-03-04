const jwt = require('jsonwebtoken');

module.exports = function (req, res, next) {
    // Get token from header
    const token = req.header('x-auth-token') || req.header('Authorization')?.replace('Bearer ', '');

    // Check if not token
    if (!token) {
        return res.status(401).json({ msg: 'Нет токена, авторизация отклонена' });
    }

    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET || 'secret_key');
        req.user = decoded;

        if (req.user.role !== 'ADMIN') {
            return res.status(403).json({ msg: 'Доступ запрещен. Требуются права администратора.' });
        }

        next();
    } catch (err) {
        res.status(401).json({ msg: 'Токен невалиден' });
    }
};
