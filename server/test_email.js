const http = require('http');

const data = JSON.stringify({ email: 'admin@timely.kz' });

const options = {
    hostname: 'localhost',
    port: 5000,
    path: '/api/auth/debug/test-email',
    method: 'POST',
    headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(data)
    }
};

const req = http.request(options, (res) => {
    let resData = '';
    res.on('data', (chunk) => {
        resData += chunk;
    });
    res.on('end', () => {
        console.log(`STATUS: ${res.statusCode}`);
        console.log(`BODY: ${resData}`);
    });
});

req.on('error', (e) => {
    console.error(`problem with request: ${e.message}`);
});

req.write(data);
req.end();
