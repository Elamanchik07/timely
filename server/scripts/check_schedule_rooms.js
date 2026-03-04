require("dotenv").config();
const mongoose = require('mongoose');
const ScheduleItem = require('../models/ScheduleItem');
const fs = require('fs');
const path = require('path');

async function checkScheduleRooms() {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log("Connected to MongoDB.");

    // 1. Get all unique room codes from schedule
    const scheduleItems = await ScheduleItem.find({});
    const roomCodes = [...new Set(scheduleItems.map(s => s.room))];
    console.log(`\n=== Schedule has ${scheduleItems.length} items with ${roomCodes.length} unique room codes ===`);
    roomCodes.sort().forEach(code => console.log(`  Schedule room: "${code}"`));

    // 2. Read MapRoomData and extract all fullCodes
    const dartFilePath = path.join(__dirname, '../../lib/features/map/domain/map_room_data.dart');
    const content = fs.readFileSync(dartFilePath, 'utf8');
    const regex = /RoomArea\s*\(\s*'([^']+)'/g;
    const mapCodes = [];
    let match;
    while ((match = regex.exec(content)) !== null) {
        mapCodes.push(match[1]);
    }
    console.log(`\n=== MapRoomData has ${mapCodes.length} rooms ===`);

    // 3. Check which schedule room codes DON'T exist in MapRoomData
    console.log(`\n=== MISMATCHES (schedule rooms NOT found in map) ===`);
    let mismatches = 0;
    for (const code of roomCodes) {
        // Exact match
        if (mapCodes.includes(code)) continue;
        // Case-insensitive match
        if (mapCodes.some(mc => mc.toUpperCase() === code.toUpperCase())) continue;
        // Partial match (just the number part)
        const lastPart = code.split('.').pop();
        const partialMatches = mapCodes.filter(mc => mc.split('.').pop() === lastPart);
        if (partialMatches.length > 0) {
            console.log(`  "${code}" → partial matches: ${partialMatches.join(', ')}`);
        } else {
            console.log(`  "${code}" → NO MATCH AT ALL`);
        }
        mismatches++;
    }
    if (mismatches === 0) {
        console.log("  All schedule rooms found in map data!");
    }
    console.log(`\nTotal mismatches: ${mismatches} / ${roomCodes.length}`);

    process.exit(0);
}
checkScheduleRooms().catch(err => { console.error(err); process.exit(1); });
