const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const NewsItem = require('../models/NewsItem');
const { protect } = require('../middleware/authMiddleware');
const { role } = require('../middleware/roleMiddleware');

// Multer storage configuration
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        const uploadDir = path.join(__dirname, '..', 'uploads', 'news');
        if (!fs.existsSync(uploadDir)) {
            fs.mkdirSync(uploadDir, { recursive: true });
        }
        cb(null, uploadDir);
    },
    filename: (req, file, cb) => {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        const ext = path.extname(file.originalname);
        cb(null, `news-${uniqueSuffix}${ext}`);
    }
});

const fileFilter = (req, file, cb) => {
    const allowedImage = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
    const allowedVideo = ['video/mp4', 'video/webm', 'video/quicktime'];
    if ([...allowedImage, ...allowedVideo].includes(file.mimetype)) {
        cb(null, true);
    } else {
        cb(new Error('Неподдерживаемый формат файла'), false);
    }
};

const upload = multer({
    storage,
    fileFilter,
    limits: { fileSize: 50 * 1024 * 1024 } // 50MB max
});

// GET /api/news — Public: get published news (paginated)
router.get('/', async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 10;
        const skip = (page - 1) * limit;

        const query = { isPublished: true };
        if (req.query.category) {
            query.category = req.query.category;
        }

        const [news, total] = await Promise.all([
            NewsItem.find(query)
                .sort({ isPinned: -1, createdAt: -1 })
                .skip(skip)
                .limit(limit)
                .populate('authorId', 'fullName'),
            NewsItem.countDocuments(query)
        ]);

        res.json({
            success: true,
            news,
            pagination: {
                page,
                limit,
                total,
                pages: Math.ceil(total / limit),
                hasMore: skip + news.length < total
            }
        });
    } catch (error) {
        console.error('News list error:', error);
        res.status(500).json({ success: false, msg: 'Ошибка сервера' });
    }
});

// GET /api/news/admin/all — Admin: get ALL news (published + drafts)
router.get('/admin/all', protect, role(['ADMIN']), async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 20;
        const skip = (page - 1) * limit;
        const search = req.query.search || '';

        const query = {};
        if (search) {
            query.title = { $regex: search, $options: 'i' };
        }

        const [news, total] = await Promise.all([
            NewsItem.find(query)
                .sort({ isPinned: -1, createdAt: -1 })
                .skip(skip)
                .limit(limit)
                .populate('authorId', 'fullName'),
            NewsItem.countDocuments(query)
        ]);

        res.json({
            success: true,
            news,
            pagination: { page, limit, total, pages: Math.ceil(total / limit) }
        });
    } catch (error) {
        console.error('Admin news list error:', error);
        res.status(500).json({ success: false, msg: 'Ошибка сервера' });
    }
});

// GET /api/news/:id — Public: get single news
router.get('/:id', async (req, res) => {
    try {
        const news = await NewsItem.findById(req.params.id)
            .populate('authorId', 'fullName');
        if (!news) {
            return res.status(404).json({ success: false, msg: 'Новость не найдена' });
        }
        res.json({ success: true, news });
    } catch (error) {
        console.error('News detail error:', error);
        res.status(500).json({ success: false, msg: 'Ошибка сервера' });
    }
});

// POST /api/news — Admin: create news with optional media
router.post('/', protect, role(['ADMIN']), upload.single('media'), async (req, res) => {
    try {
        const { title, content, isPublished, category, isPinned } = req.body;

        const newsData = {
            title,
            content,
            isPublished: isPublished === 'true' || isPublished === true,
            category: category || 'Announcements',
            isPinned: isPinned === 'true' || isPinned === true,
            authorId: req.user._id,
            mediaType: 'none',
            mediaPath: null,
            thumbnailPath: null
        };

        if (req.file) {
            const isVideo = req.file.mimetype.startsWith('video/');
            newsData.mediaType = isVideo ? 'video' : 'image';
            newsData.mediaPath = `/uploads/news/${req.file.filename}`;
        }

        const news = await NewsItem.create(newsData);
        const populated = await NewsItem.findById(news._id).populate('authorId', 'fullName');

        console.log(`[ADMIN] Created news: "${title}" by ${req.user.email}`);
        res.status(201).json({ success: true, news: populated });
    } catch (error) {
        console.error('Create news error:', error);
        if (error.name === 'ValidationError') {
            const messages = Object.values(error.errors).map(val => val.message);
            return res.status(400).json({ success: false, msg: messages.join(', ') });
        }
        res.status(500).json({ success: false, msg: 'Ошибка сервера' });
    }
});

// PUT /api/news/:id — Admin: update news
router.put('/:id', protect, role(['ADMIN']), upload.single('media'), async (req, res) => {
    try {
        const news = await NewsItem.findById(req.params.id);
        if (!news) {
            return res.status(404).json({ success: false, msg: 'Новость не найдена' });
        }

        const { title, content, isPublished, removeMedia, category, isPinned } = req.body;
        if (title) news.title = title;
        if (content) news.content = content;
        if (category) news.category = category;
        if (isPinned !== undefined) {
            news.isPinned = isPinned === 'true' || isPinned === true;
        }
        if (isPublished !== undefined) {
            news.isPublished = isPublished === 'true' || isPublished === true;
        }

        // Handle media replacement
        if (req.file) {
            // Delete old file
            if (news.mediaPath) {
                const oldPath = path.join(__dirname, '..', news.mediaPath);
                if (fs.existsSync(oldPath)) fs.unlinkSync(oldPath);
            }
            const isVideo = req.file.mimetype.startsWith('video/');
            news.mediaType = isVideo ? 'video' : 'image';
            news.mediaPath = `/uploads/news/${req.file.filename}`;
        } else if (removeMedia === 'true') {
            // Remove media without replacement
            if (news.mediaPath) {
                const oldPath = path.join(__dirname, '..', news.mediaPath);
                if (fs.existsSync(oldPath)) fs.unlinkSync(oldPath);
            }
            news.mediaType = 'none';
            news.mediaPath = null;
            news.thumbnailPath = null;
        }

        await news.save();
        const populated = await NewsItem.findById(news._id).populate('authorId', 'fullName');

        console.log(`[ADMIN] Updated news: "${news.title}"`);
        res.json({ success: true, news: populated });
    } catch (error) {
        console.error('Update news error:', error);
        res.status(500).json({ success: false, msg: 'Ошибка сервера' });
    }
});

// PATCH /api/news/:id/publish — Admin: toggle publish
router.patch('/:id/publish', protect, role(['ADMIN']), async (req, res) => {
    try {
        const news = await NewsItem.findById(req.params.id);
        if (!news) {
            return res.status(404).json({ success: false, msg: 'Новость не найдена' });
        }

        news.isPublished = !news.isPublished;
        await news.save();

        console.log(`[ADMIN] ${news.isPublished ? 'Published' : 'Unpublished'} news: "${news.title}"`);
        res.json({ success: true, news: { id: news._id, isPublished: news.isPublished } });
    } catch (error) {
        console.error('Toggle publish error:', error);
        res.status(500).json({ success: false, msg: 'Ошибка сервера' });
    }
});

// DELETE /api/news/:id — Admin: delete news
router.delete('/:id', protect, role(['ADMIN']), async (req, res) => {
    try {
        const news = await NewsItem.findById(req.params.id);
        if (!news) {
            return res.status(404).json({ success: false, msg: 'Новость не найдена' });
        }

        // Delete media files
        if (news.mediaPath) {
            const filePath = path.join(__dirname, '..', news.mediaPath);
            if (fs.existsSync(filePath)) fs.unlinkSync(filePath);
        }
        if (news.thumbnailPath) {
            const thumbPath = path.join(__dirname, '..', news.thumbnailPath);
            if (fs.existsSync(thumbPath)) fs.unlinkSync(thumbPath);
        }

        await NewsItem.findByIdAndDelete(req.params.id);
        console.log(`[ADMIN] Deleted news: "${news.title}"`);
        res.json({ success: true, msg: 'Новость удалена' });
    } catch (error) {
        console.error('Delete news error:', error);
        res.status(500).json({ success: false, msg: 'Ошибка сервера' });
    }
});

// PUT /api/news/:id/react — Toggle/Change reaction (authenticated user)
router.put('/:id/react', protect, async (req, res) => {
    try {
        const userId = req.user._id;
        const { type } = req.body; // 'heart', 'thumbsUp', 'fire', 'party'

        const validTypes = ['heart', 'thumbsUp', 'fire', 'party'];
        if (!validTypes.includes(type)) {
            return res.status(400).json({ success: false, msg: 'Invalid reaction type' });
        }

        const news = await NewsItem.findById(req.params.id);
        if (!news) {
            return res.status(404).json({ success: false, msg: 'Новость не найдена' });
        }

        // Find existing reaction by this user
        const existingReactionIndex = news.reactions.findIndex(r => r.userId.toString() === userId.toString());

        if (existingReactionIndex !== -1) {
            const existingType = news.reactions[existingReactionIndex].type;

            if (existingType === type) {
                // If same type, user is toggling off the reaction
                news.reactions.splice(existingReactionIndex, 1);
                news.reactionCounts[existingType] = Math.max(0, news.reactionCounts[existingType] - 1);
            } else {
                // Changing reaction type
                news.reactions[existingReactionIndex].type = type;
                news.reactionCounts[existingType] = Math.max(0, news.reactionCounts[existingType] - 1);
                news.reactionCounts[type] += 1;
            }
        } else {
            // New reaction
            news.reactions.push({ userId, type });
            news.reactionCounts[type] += 1;
        }

        await news.save();

        res.json({
            success: true,
            reactions: news.reactions,
            reactionCounts: news.reactionCounts
        });
    } catch (error) {
        console.error('Reaction toggle error:', error);
        res.status(500).json({ success: false, msg: 'Ошибка сервера' });
    }
});

// POST /api/news/:id/view — Track unique view
router.post('/:id/view', protect, async (req, res) => {
    try {
        const userId = req.user._id;

        const result = await NewsItem.updateOne(
            { _id: req.params.id, viewers: { $ne: userId } },
            {
                $addToSet: { viewers: userId },
                $inc: { viewCount: 1 }
            }
        );

        res.json({ success: true, viewed: result.modifiedCount > 0 });
    } catch (error) {
        console.error('View tracking error:', error);
        res.status(500).json({ success: false, msg: 'Ошибка сервера' });
    }
});

// Error handling for multer
router.use((error, req, res, next) => {
    if (error instanceof multer.MulterError) {
        if (error.code === 'LIMIT_FILE_SIZE') {
            return res.status(400).json({ success: false, msg: 'Файл слишком большой (макс. 50MB)' });
        }
        return res.status(400).json({ success: false, msg: error.message });
    }
    if (error) {
        return res.status(400).json({ success: false, msg: error.message });
    }
    next();
});

module.exports = router;
