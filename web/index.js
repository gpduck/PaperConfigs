
const express = require('express');

const PORT = 8080;
const HOST = '0.0.0.0';

const app = express();
app.get('/', (req, res) => {
    req.headers.host
    res.send(`Add ${req.headers.host} to your minecraft server list`);
});

app.listen(PORT, HOST);
console.log(`Running on http://${HOST}:${PORT}`);