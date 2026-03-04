const path = require('path');
const nodemailerPath = path.resolve(__dirname, 'node_modules/nodemailer/lib/nodemailer.js');
console.log('Trying to require:', nodemailerPath);

try {
    const nodemailer = require(nodemailerPath);
    console.log('Type of nodemailer:', typeof nodemailer);
    console.log('Keys of nodemailer:', Object.keys(nodemailer));
    console.log('Is createTransporter a function?', typeof nodemailer.createTransporter);
} catch (e) {
    console.error('Error requiring nodemailer:', e);
}
