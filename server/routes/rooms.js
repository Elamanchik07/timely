const express = require('express');
const router = express.Router();
const Room = require('../models/Room');
const { protect } = require('../middleware/authMiddleware');
const { role } = require('../middleware/roleMiddleware');

// Get all rooms (Public/Protected for Students)
router.get('/', protect, async (req, res) => {
    try {
        const { building, floor } = req.query;
        const query = {};
        if (building) query.building = building;
        if (floor) query.floor = floor;

        const rooms = await Room.find(query).sort({ code: 1 });
        res.json({ success: true, rooms });
    } catch (error) {
        res.status(500).json({ success: false, msg: 'Server Error' });
    }
});

// Create Room (Admin Only)
router.post('/', protect, role(['ADMIN']), async (req, res) => {
    try {
        const { code, fullCode, shortCode, sector, building, floor, description, positionX, positionY, type } = req.body;

        const room = await Room.create({
            code,
            fullCode,
            shortCode,
            sector,
            building,
            floor,
            description,
            positionX,
            positionY,
            type
        });

        res.status(201).json({ success: true, room });
    } catch (error) {
        if (error.code === 11000) {
            return res.status(400).json({ success: false, msg: 'Room already exists in this building' });
        }
        res.status(500).json({ success: false, msg: error.message });
    }
});

// Update Room (Admin Only) - e.g. updating coordinates
router.put('/:id', protect, role(['ADMIN']), async (req, res) => {
    try {
        const { code, fullCode, shortCode, sector, building, floor, description, positionX, positionY, type } = req.body;

        const updateData = {};
        if (code !== undefined) updateData.code = code;
        if (fullCode !== undefined) updateData.fullCode = fullCode;
        if (shortCode !== undefined) updateData.shortCode = shortCode;
        if (sector !== undefined) updateData.sector = sector;
        if (building !== undefined) updateData.building = building;
        if (floor !== undefined) updateData.floor = floor;
        if (description !== undefined) updateData.description = description;
        if (positionX !== undefined) updateData.positionX = positionX;
        if (positionY !== undefined) updateData.positionY = positionY;
        if (type !== undefined) updateData.type = type;

        const room = await Room.findByIdAndUpdate(req.params.id, updateData, {
            new: true,
            runValidators: true
        });

        if (!room) {
            return res.status(404).json({ success: false, msg: 'Room not found' });
        }

        res.json({ success: true, room });
    } catch (error) {
        if (error.code === 11000) {
            return res.status(400).json({ success: false, msg: 'Room already exists' });
        }
        res.status(500).json({ success: false, msg: error.message });
    }
});

// Delete Room (Admin Only)
router.delete('/:id', protect, role(['ADMIN']), async (req, res) => {
    try {
        const room = await Room.findById(req.params.id);
        if (!room) {
            return res.status(404).json({ success: false, msg: 'Room not found' });
        }
        await room.deleteOne();
        res.json({ success: true, msg: 'Room deleted' });
    } catch (error) {
        res.status(500).json({ success: false, msg: error.message });
    }
});

module.exports = router;
