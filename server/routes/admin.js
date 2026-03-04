const express = require('express');
const router = express.Router();
const User = require('../models/User');
const Group = require('../models/Group');
const Course = require('../models/Course');
const Subject = require('../models/Subject');
const Teacher = require('../models/Teacher');
const AdminLog = require('../models/AdminLog');
const bcrypt = require('bcryptjs');
const { protect } = require('../middleware/authMiddleware');
const { role } = require('../middleware/roleMiddleware');

// Helper for admin logging
async function logAdminAction(req, action, targetId, targetModel, details) {
    try {
        await AdminLog.create({
            adminId: req.user._id,
            adminEmail: req.user.email,
            action,
            targetId: targetId ? targetId.toString() : null,
            targetModel,
            details: JSON.stringify(details)
        });
    } catch (err) {
        console.error('Failed to log admin action:', err);
    }
}

// ==========================================
// STUDENTS MANAGEMENT
// ==========================================

// Get Students
router.get('/students', protect, role(['ADMIN']), async (req, res) => {
    try {
        const { status, search, course, groupCode } = req.query;
        const query = { role: 'STUDENT', isDeleted: { $ne: true } };

        if (status) query.status = status;
        if (course) query.course = course;
        if (groupCode) query.groupCode = groupCode;

        if (search) {
            query.$or = [
                { fullName: { $regex: search, $options: 'i' } },
                { email: { $regex: search, $options: 'i' } },
                { phone: { $regex: search, $options: 'i' } },
            ];
        }

        const students = await User.find(query).select('-passwordHash').sort({ createdAt: -1 });
        res.json({ success: true, students });
    } catch (error) {
        res.status(500).json({ success: false, msg: 'Ошибка сервера' });
    }
});

// Create Student
router.post('/students', protect, role(['ADMIN']), async (req, res) => {
    try {
        const { fullName, email, phone, password, course, groupCode, status } = req.body;

        const existingError = await User.findOne({ email });
        if (existingError) return res.status(400).json({ success: false, msg: 'Email уже используется' });

        const passwordHash = await bcrypt.hash(password || '12345678', 10);

        const newStudent = new User({
            fullName, email, phone, passwordHash, role: 'STUDENT',
            course, groupCode, status: status || 'APPROVED'
        });
        await newStudent.save();

        await logAdminAction(req, 'CREATE_STUDENT', newStudent._id, 'User', { email });
        res.json({ success: true, student: newStudent });
    } catch (error) {
        res.status(500).json({ success: false, msg: 'Ошибка сервера' });
    }
});

// Update Student
router.put('/students/:id', protect, role(['ADMIN']), async (req, res) => {
    try {
        const updates = req.body;
        if (updates.password) {
            updates.passwordHash = await bcrypt.hash(updates.password, 10);
            delete updates.password;
        }

        const student = await User.findByIdAndUpdate(req.params.id, updates, { new: true }).select('-passwordHash');
        if (!student) return res.status(404).json({ success: false, msg: 'Студент не найден' });

        await logAdminAction(req, 'UPDATE_STUDENT', student._id, 'User', updates);
        res.json({ success: true, student });
    } catch (error) {
        res.status(500).json({ success: false, msg: 'Ошибка сервера' });
    }
});

// Delete Student
router.delete('/students/:id', protect, role(['ADMIN']), async (req, res) => {
    try {
        const user = await User.findById(req.params.id);
        if (!user) return res.status(404).json({ success: false, msg: 'Студент не найден' });
        if (user.role === 'ADMIN') return res.status(403).json({ success: false, msg: 'Нельзя удалить админа' });

        user.isDeleted = true;
        // Optionally update other details or clear dependencies here.
        await user.save();

        await logAdminAction(req, 'DELETE_STUDENT', req.params.id, 'User', { email: user.email, softDelete: true });
        res.json({ success: true, msg: 'Студент удален' });
    } catch (error) {
        res.status(500).json({ success: false, msg: 'Ошибка сервера' });
    }
});

// Bulk Action on Students
router.post('/students/bulk', protect, role(['ADMIN']), async (req, res) => {
    try {
        const { studentIds, action, payload } = req.body;
        // action: 'STATUS', 'GROUP', 'DELETE'

        if (action === 'DELETE') {
            await User.updateMany({ _id: { $in: studentIds }, role: 'STUDENT' }, { isDeleted: true });
        } else if (action === 'STATUS') {
            await User.updateMany({ _id: { $in: studentIds } }, { status: payload });
        } else if (action === 'GROUP') {
            await User.updateMany({ _id: { $in: studentIds } }, { groupCode: payload });
        }

        await logAdminAction(req, 'BULK_' + action, null, 'User_Bulk', { count: studentIds.length, payload });
        res.json({ success: true, msg: 'Успешно выполнено' });
    } catch (error) {
        res.status(500).json({ success: false, msg: 'Ошибка сервера' });
    }
});

// Get Audit Logs
router.get('/logs', protect, role(['ADMIN']), async (req, res) => {
    try {
        const logs = await AdminLog.find().sort({ createdAt: -1 }).limit(100);
        res.json({ success: true, logs });
    } catch (error) {
        res.status(500).json({ success: false, msg: 'Ошибка сервера' });
    }
});

// ==========================================
// COURSE MANAGEMENT
// ==========================================

router.get('/courses', protect, role(['ADMIN']), async (req, res) => {
    try {
        const courses = await Course.find().sort({ number: 1 });
        res.json({ success: true, courses });
    } catch (e) { res.status(500).json({ success: false }); }
});

router.post('/courses', protect, role(['ADMIN']), async (req, res) => {
    try {
        const course = new Course(req.body);
        await course.save();
        res.json({ success: true, course });
    } catch (e) { res.status(500).json({ success: false, msg: e.message }); }
});

router.put('/courses/:id', protect, role(['ADMIN']), async (req, res) => {
    try {
        const course = await Course.findByIdAndUpdate(req.params.id, req.body, { new: true });
        res.json({ success: true, course });
    } catch (e) { res.status(500).json({ success: false }); }
});

router.delete('/courses/:id', protect, role(['ADMIN']), async (req, res) => {
    try {
        await Course.findByIdAndDelete(req.params.id);
        res.json({ success: true });
    } catch (e) { res.status(500).json({ success: false }); }
});

// ==========================================
// GROUP MANAGEMENT
// ==========================================

router.get('/groups', protect, role(['ADMIN']), async (req, res) => {
    try {
        const groups = await Group.find().sort({ groupCode: 1 });
        res.json({ success: true, groups });
    } catch (e) { res.status(500).json({ success: false }); }
});

router.post('/groups', protect, role(['ADMIN']), async (req, res) => {
    try {
        const group = new Group(req.body);
        await group.save();
        res.json({ success: true, group });
    } catch (e) { res.status(500).json({ success: false, msg: e.message }); }
});

router.put('/groups/:id', protect, role(['ADMIN']), async (req, res) => {
    try {
        const group = await Group.findByIdAndUpdate(req.params.id, req.body, { new: true });
        res.json({ success: true, group });
    } catch (e) { res.status(500).json({ success: false }); }
});

router.delete('/groups/:id', protect, role(['ADMIN']), async (req, res) => {
    try {
        await Group.findByIdAndDelete(req.params.id);
        res.json({ success: true });
    } catch (e) { res.status(500).json({ success: false }); }
});

// ==========================================
// SUBJECT MANAGEMENT
// ==========================================

router.get('/subjects', protect, role(['ADMIN']), async (req, res) => {
    try {
        const subjects = await Subject.find().sort({ name: 1 });
        res.json({ success: true, subjects });
    } catch (e) { res.status(500).json({ success: false }); }
});

router.post('/subjects', protect, role(['ADMIN']), async (req, res) => {
    try {
        const subject = new Subject(req.body);
        await subject.save();
        res.json({ success: true, subject });
    } catch (e) { res.status(500).json({ success: false, msg: e.message }); }
});

router.put('/subjects/:id', protect, role(['ADMIN']), async (req, res) => {
    try {
        const subject = await Subject.findByIdAndUpdate(req.params.id, req.body, { new: true });
        res.json({ success: true, subject });
    } catch (e) { res.status(500).json({ success: false }); }
});

router.delete('/subjects/:id', protect, role(['ADMIN']), async (req, res) => {
    try {
        // Here we could also check if subject is used in schedules, but will handle in app for now
        await Subject.findByIdAndDelete(req.params.id);
        res.json({ success: true });
    } catch (e) { res.status(500).json({ success: false }); }
});

// ==========================================
// TEACHER MANAGEMENT
// ==========================================

router.get('/teachers', protect, role(['ADMIN']), async (req, res) => {
    try {
        const teachers = await Teacher.find().sort({ fullName: 1 });
        res.json({ success: true, teachers });
    } catch (e) { res.status(500).json({ success: false }); }
});

router.post('/teachers', protect, role(['ADMIN']), async (req, res) => {
    try {
        const teacher = new Teacher(req.body);
        await teacher.save();
        res.json({ success: true, teacher });
    } catch (e) { res.status(500).json({ success: false, msg: e.message }); }
});

router.put('/teachers/:id', protect, role(['ADMIN']), async (req, res) => {
    try {
        const teacher = await Teacher.findByIdAndUpdate(req.params.id, req.body, { new: true });
        res.json({ success: true, teacher });
    } catch (e) { res.status(500).json({ success: false }); }
});

router.delete('/teachers/:id', protect, role(['ADMIN']), async (req, res) => {
    try {
        await Teacher.findByIdAndDelete(req.params.id);
        res.json({ success: true });
    } catch (e) { res.status(500).json({ success: false }); }
});

// ─── Rooms Bulk Import ───────────────────────────
const Room = require('../models/Room');

const cyrToLatMap = {
    'С': 'C', 'А': 'A', 'Е': 'E', 'О': 'O', 'Р': 'P',
    'М': 'M', 'Т': 'T', 'Х': 'X', 'К': 'K', 'Л': 'L',
    'П': 'P', 'В': 'B', 'У': 'Y', 'Н': 'H'
};

function normalizeCode(code) {
    let c = (code || '').trim().toUpperCase();
    c = c.replaceAll(/\s+/g, '');
    c = c.replaceAll(',', '.').replaceAll('-', '.').replaceAll('_', '.');
    Object.keys(cyrToLatMap).forEach(k => {
        c = c.split(k).join(cyrToLatMap[k]);
    });
    c = c.replaceAll(/\.{2,}/g, '.');
    if (c.startsWith('.')) c = c.substring(1);
    if (c.endsWith('.')) c = c.substring(0, c.length - 1);
    return c;
}

router.post('/rooms/bulk-import', protect, role(['ADMIN']), async (req, res) => {
    try {
        const { rooms } = req.body;
        if (!rooms || !Array.isArray(rooms)) {
            return res.status(400).json({ success: false, msg: 'rooms array is required' });
        }

        let imported = 0;
        let skipped = 0;
        for (const r of rooms) {
            try {
                let normCode = normalizeCode(r.code);
                let fullCode = normCode;
                let sector = 'C1.1';
                let shortCode = normCode;

                if (normCode.startsWith('C1.')) {
                    fullCode = normCode;
                    const parts = fullCode.split('.');
                    sector = `${parts[0]}.${parts[1]}`;
                    shortCode = parts.pop() || normCode;
                } else {
                    fullCode = `C1.1.${normCode}`;
                    sector = 'C1.1';
                    shortCode = normCode;
                }

                if (r.fullCode) fullCode = r.fullCode;
                if (r.sector) sector = r.sector;
                if (r.shortCode) shortCode = r.shortCode;

                const existing = await Room.findOne({ fullCode: fullCode });
                if (existing) {
                    skipped++;
                    continue;
                }
                await Room.create({
                    code: shortCode,
                    fullCode,
                    shortCode,
                    sector,
                    building: r.building || 'C1',
                    floor: r.floor || 1,
                    description: r.label || r.code,
                    type: r.type === 'area' ? 'OTHER' : 'LECTURE',
                    isActive: true,
                });
                imported++;
            } catch (err) {
                console.error('Import error for room', r.code, err);
                skipped++;
            }
        }

        res.json({ success: true, imported, skipped, total: rooms.length });
    } catch (error) {
        console.error('Bulk import error:', error);
        res.status(500).json({ success: false, msg: error.message });
    }
});

module.exports = router;

