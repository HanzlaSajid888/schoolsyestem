const app = require('../src/app');
const { connectDB } = require('../src/config/db');

// Vercel serverless function entrypoint
connectDB().catch(console.error);

module.exports = app;
