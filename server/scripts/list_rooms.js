require("dotenv").config();
const mongoose = require('mongoose');
const Room = require('../models/Room');

async function listRooms() {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log("Connected to MongoDB.");

    const rooms = await Room.find({ sector: 'C1.3' });
    console.log(`Found ${rooms.length} rooms in sector C1.3:`);
    rooms.forEach(r => {
        console.log(`- ${r.fullCode} (short: ${r.shortCode}, floor: ${r.floor})`);
    });

    process.exit(0);
}
listRooms();
