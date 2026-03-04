const role = (roles) => {
    return (req, res, next) => {
        if (!req.user) {
            return res.status(401).json({ success: false, msg: 'Не авторизован' });
        }

        if (!roles.includes(req.user.role)) {
            return res.status(403).json({
                success: false,
                msg: `Role ${req.user.role} is not authorized to access this route`
            });
        }
        next();
    };
};

module.exports = { role };
