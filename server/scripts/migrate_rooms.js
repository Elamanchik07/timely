require("dotenv").config();
const mongoose = require('mongoose');
const Room = require('../models/Room');
const fs = require('fs');

const cyrToLatMap = {
    'С': 'C', 'А': 'A', 'Е': 'E', 'О': 'O', 'Р': 'P',
    'М': 'M', 'Т': 'T', 'Х': 'X', 'К': 'K', 'Л': 'L',
    'П': 'P', 'В': 'B', 'У': 'Y', 'Н': 'H'
};

function normalizeCode(code) {
    let c = code.trim().toUpperCase();
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

const mapRoomDataSrc = fs.readFileSync("../lib/features/map/domain/map_room_data.dart", "utf-8");

function findByCodeSync(code) {
    const n = normalizeCode(code);
    const matches = [...mapRoomDataSrc.matchAll(/RoomArea\('([\w\.]+)',\s*'[^']+',\s*'[^']+',\s*'([\d\.]+)'/g)];
    const rooms = matches.map(m => ({ fullCode: m[1], sector: m[1].startsWith('C1.') ? 'C1.' + m[2] : '' }));

    // exact match
    const exact = rooms.find(r => r.fullCode.toUpperCase() === n);
    if (exact) return exact;

    const candidates = rooms.filter(r => {
        const parts = r.fullCode.split('.');
        const lastPart = parts[parts.length - 1].toUpperCase();
        return lastPart === n ||
            (parts.length > 2 && `${parts[1]}.${lastPart}`.toUpperCase() === n) ||
            (parts.length > 2 && `${parts[0]}.${parts[1]}.${lastPart}`.toUpperCase() === n);
    });
    if (candidates.length === 1) return candidates[0];
    return null;
}

async function migrateRooms() {
    await mongoose.connect(process.env.MONGODB_URI, { useNewUrlParser: true });
    console.log("Connected to MongoDB.");

    // Drop old indexes to recreate
    try {
        await mongoose.connection.collection('rooms').dropIndex("building_1_code_1");
    } catch (e) { }

    const rooms = await Room.find();
    for (const room of rooms) {
        if (!room.code) continue;
        let n = normalizeCode(room.code);
        let sector = "C1.1";
        let fullCode = room.fullCode;
        let shortCode = room.shortCode;

        if (!fullCode) {
            // try fast mapped
            let mapped = findByCodeSync(n);
            if (mapped) {
                fullCode = mapped.fullCode;
                sector = mapped.sector || "C1.1";
                shortCode = fullCode.split('.').pop();
            } else {
                if (n.startsWith("C1.")) {
                    fullCode = n;
                    const p = fullCode.split('.');
                    sector = `${p[0]}.${p[1]}`;
                    shortCode = p[p.length - 1];
                } else {
                    fullCode = `C1.1.${n}`;
                    sector = "C1.1";
                    shortCode = n;
                }
            }

            console.log(`Migrating ${room.code} -> fullCode: ${fullCode}, shortCode: ${shortCode}, sector: ${sector}`);
            room.fullCode = fullCode;
            room.sector = sector;
            room.shortCode = shortCode;
            try {
                await room.save();
            } catch (e) {
                console.error(e.message);
            }
        }
    }
    process.exit(0);
}
migrateRooms();
