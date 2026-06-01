const express = require('express');
const router = express.Router();
const ScheduleItem = require('../models/ScheduleItem');
const authMiddleware = require('../middleware/auth');
const roleCheck = require('../middleware/roleCheck');

// GET /api/schedule - Get schedule by group code (public for authenticated users)
router.get('/', authMiddleware, async (req, res) => {
    try {
        const { groupCode } = req.query;

        // Admin can fetch all schedules without groupCode
        const query = {};
        if (groupCode) {
            query.groupCode = groupCode;
        } else if (req.user.role !== 'ADMIN') {
            return res.status(400).json({
                success: false,
                msg: 'Group code is required'
            });
        }

        const scheduleItems = await ScheduleItem.find(query)
            .sort({ groupCode: 1, dayOfWeek: 1, pairNumber: 1 });

        res.json({
            success: true,
            groupCode: groupCode || 'ALL',
            scheduleItems
        });

    } catch (error) {
        console.error('Get schedule error:', error);
        res.status(500).json({
            success: false,
            msg: 'Ошибка при загрузке расписания'
        });
    }
});

// POST /api/schedule - Create schedule item (admin only)
router.post('/', authMiddleware, roleCheck('ADMIN'), async (req, res) => {
    try {
        const { groupCode, dayOfWeek, pairNumber, startTime, endTime, subject, teacher, room, type, weekType } = req.body;

        // Validation
        if (!groupCode || !dayOfWeek || !pairNumber || !startTime || !endTime || !subject || !teacher || !room) {
            return res.status(400).json({
                success: false,
                msg: 'Заполните все обязательные поля'
            });
        }

        const scheduleItem = new ScheduleItem({
            groupCode,
            dayOfWeek,
            pairNumber,
            startTime,
            endTime,
            subject,
            teacher,
            room,
            type: type || 'lecture',
            weekType: weekType || 'ALL'
        });

        await scheduleItem.save();

        res.status(201).json({
            success: true,
            msg: 'Занятие добавлено в расписание',
            scheduleItem
        });

    } catch (error) {
        console.error('Create schedule error:', error);
        res.status(500).json({
            success: false,
            msg: 'Ошибка при создании занятия'
        });
    }
});

// PUT /api/schedule/:id - Update schedule item (admin only)
router.put('/:id', authMiddleware, roleCheck('ADMIN'), async (req, res) => {
    try {
        const { dayOfWeek, pairNumber, startTime, endTime, subject, teacher, room, type, weekType } = req.body;

        const scheduleItem = await ScheduleItem.findById(req.params.id);

        if (!scheduleItem) {
            return res.status(404).json({
                success: false,
                msg: 'Занятие не найдено'
            });
        }

        // Update fields
        if (dayOfWeek !== undefined) scheduleItem.dayOfWeek = dayOfWeek;
        if (pairNumber !== undefined) scheduleItem.pairNumber = pairNumber;
        if (startTime) scheduleItem.startTime = startTime;
        if (endTime) scheduleItem.endTime = endTime;
        if (subject) scheduleItem.subject = subject;
        if (teacher) scheduleItem.teacher = teacher;
        if (room) scheduleItem.room = room;
        if (type) scheduleItem.type = type;
        if (weekType) scheduleItem.weekType = weekType;

        await scheduleItem.save();

        res.json({
            success: true,
            msg: 'Занятие обновлено',
            scheduleItem
        });

    } catch (error) {
        console.error('Update schedule error:', error);
        res.status(500).json({
            success: false,
            msg: 'Ошибка при обновлении занятия'
        });
    }
});

// DELETE /api/schedule/:id - Delete schedule item (admin only)
router.delete('/:id', authMiddleware, roleCheck('ADMIN'), async (req, res) => {
    try {
        const scheduleItem = await ScheduleItem.findByIdAndDelete(req.params.id);

        if (!scheduleItem) {
            return res.status(404).json({
                success: false,
                msg: 'Занятие не найдено'
            });
        }

        res.json({
            success: true,
            msg: 'Занятие удалено'
        });

    } catch (error) {
        console.error('Delete schedule error:', error);
        res.status(500).json({
            success: false,
            msg: 'Ошибка при удалении занятия'
        });
    }
});

// POST /api/schedule/clear - Clear schedule for a group
router.post('/clear', authMiddleware, roleCheck('ADMIN'), async (req, res) => {
    try {
        const { groupCode, dayOfWeek } = req.body;
        if (!groupCode) return res.status(400).json({ success: false, msg: 'groupCode required' });

        const query = { groupCode };
        if (dayOfWeek !== undefined) query.dayOfWeek = dayOfWeek;

        await ScheduleItem.deleteMany(query);
        res.json({ success: true, msg: 'Расписание очищено' });
    } catch (e) {
        res.status(500).json({ success: false });
    }
});

// POST /api/schedule/copy - Copy schedule
router.post('/copy', authMiddleware, roleCheck('ADMIN'), async (req, res) => {
    try {
        const { fromGroup, toGroup } = req.body;
        if (!fromGroup || !toGroup) return res.status(400).json({ success: false, msg: 'Missing groups' });

        const itemsToCopy = await ScheduleItem.find({ groupCode: fromGroup });
        if (itemsToCopy.length === 0) return res.status(400).json({ success: false, msg: 'Нет расписания для копирования' });

        // Clear destination first
        await ScheduleItem.deleteMany({ groupCode: toGroup });

        const newItems = itemsToCopy.map(item => ({
            groupCode: toGroup,
            dayOfWeek: item.dayOfWeek,
            pairNumber: item.pairNumber,
            startTime: item.startTime,
            endTime: item.endTime,
            subject: item.subject,
            teacher: item.teacher,
            room: item.room,
            type: item.type,
            weekType: item.weekType
        }));

        await ScheduleItem.insertMany(newItems);
        res.json({ success: true, msg: 'Расписание скопировано' });
    } catch (e) {
        res.status(500).json({ success: false });
    }
});

module.exports = router;
