const mongoose = require('mongoose');

const NewsItemSchema = new mongoose.Schema({
    title: {
        type: String,
        required: [true, 'Заголовок обязателен'],
        trim: true,
        maxlength: [200, 'Заголовок не может быть длиннее 200 символов']
    },
    content: {
        type: String,
        required: [true, 'Содержание обязательно'],
        trim: true
    },
    mediaType: {
        type: String,
        enum: ['none', 'image', 'video'],
        default: 'none'
    },
    mediaPath: {
        type: String,
        default: null
    },
    thumbnailPath: {
        type: String,
        default: null
    },
    isPublished: {
        type: Boolean,
        default: false
    },
    authorId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    // ─── News Metadata ───
    category: {
        type: String,
        enum: ['Academic', 'Announcements', 'Events', 'Urgent'],
        default: 'Announcements',
        required: true
    },
    isPinned: {
        type: Boolean,
        default: false
    },
    // ─── Reaction System ───
    reactions: [{
        userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
        type: { type: String, enum: ['heart', 'thumbsUp', 'fire', 'party'] }
    }],
    reactionCounts: {
        heart: { type: Number, default: 0 },
        thumbsUp: { type: Number, default: 0 },
        fire: { type: Number, default: 0 },
        party: { type: Number, default: 0 }
    },
    // ─── View Tracking ───
    viewers: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User'
    }],
    viewCount: {
        type: Number,
        default: 0
    }
}, {
    timestamps: true
});

// Index for feed queries (published news, newest first)
// Pinned first, then sorted by createdAt
NewsItemSchema.index({ isPublished: 1, isPinned: -1, createdAt: -1 });
NewsItemSchema.index({ title: 'text' });

module.exports = mongoose.model('NewsItem', NewsItemSchema);
