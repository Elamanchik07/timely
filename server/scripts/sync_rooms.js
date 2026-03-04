require("dotenv").config();
const mongoose = require('mongoose');
const Room = require('../models/Room');
const fs = require('fs');
const path = require('path');

async function syncRooms() {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log("Connected to MongoDB.");

    const dartFilePath = path.join(__dirname, '../../lib/features/map/domain/map_room_data.dart');
    const content = fs.readFileSync(dartFilePath, 'utf8');

    // Regex to match RoomArea('C1.1.139', 'Аудитория 139', 'C1', '1.1', 1, false, Rect.fromLTWH(0.170, 0.08, 0.030, 0.07))
    const regex = /RoomArea\s*\(\s*'([^']+)'\s*,\s*'([^']+)'\s*,\s*'([^']+)'\s*,\s*'([^']+)'\s*,\s*(\d+)\s*,\s*(true|false)\s*,\s*Rect\.fromLTWH\s*\(\s*([\d\.]+)\s*,\s*([\d\.]+)\s*,\s*([\d\.]+)\s*,\s*([\d\.]+)\s*\)\s*\)/g;

    let match;
    let addedCount = 0;
    let updatedCount = 0;

    const typeMap = {
        'Аудитория': 'LECTURE',
        'Практическая': 'PRACTICE',
        'Лаборатория': 'LAB',
        'Кабинет': 'OFFICE',
        'Библиотека': 'OTHER',
        'Актовый зал': 'OTHER',
        'Коворкинг': 'OTHER',
        'Атриум': 'OTHER',
        'Столовая': 'OTHER',
        'Open Space': 'OTHER'
    };

    while ((match = regex.exec(content)) !== null) {
        const [_, fullCode, label, building, block, floor, isArea, x, y, w, h] = match;

        // Calculate center for positionX/Y
        const positionX = parseFloat(x) + parseFloat(w) / 2;
        const positionY = parseFloat(y) + parseFloat(h) / 2;

        let type = 'LECTURE';
        for (const [key, value] of Object.entries(typeMap)) {
            if (label.includes(key)) {
                type = value;
                break;
            }
        }

        const sector = `${building}.${block}`;
        const shortCode = fullCode.split('.').pop();

        const existingRoom = await Room.findOne({ fullCode });

        if (!existingRoom) {
            await Room.create({
                fullCode,
                shortCode,
                sector,
                building,
                floor: parseInt(floor),
                description: label,
                positionX,
                positionY,
                type,
                code: fullCode, // Compatibility
                isActive: true
            });
            console.log(`+ Added MISSING room: ${fullCode}`);
            addedCount++;
        } else {
            // Update position and sector if needed
            existingRoom.sector = sector;
            existingRoom.positionX = positionX;
            existingRoom.positionY = positionY;
            existingRoom.description = label;
            existingRoom.floor = parseInt(floor);
            await existingRoom.save();
            updatedCount++;
        }
    }

    console.log(`Sync complete. Added: ${addedCount}, Updated: ${updatedCount}`);
    process.exit(0);
}

syncRooms().catch(err => {
    console.error(err);
    process.exit(1);
});
