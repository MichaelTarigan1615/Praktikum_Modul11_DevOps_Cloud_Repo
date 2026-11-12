const express = require('express');

const app = express();
app.disable('x-powered-by');
app.use(express.json());

app.get('/', (req, res) => {
  res.status(200).json({
    service: 'fargate-web-api',
    course: 'DevOps di Cloud - Modul 11 FASILKOMTI USU',
    lecturer: 'Prof. Poltak Sihombing, Ph.D (Prof. PoSi)',
    status: 'running',
    version: process.env.IMAGE_TAG || '1.0.0-local'
  });
});

app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    uptime: process.uptime(),
    timestamp: new Date().toISOString()
  });
});

module.exports = app;
