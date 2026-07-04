/**
 * MongoDB connection logic (Mongoose).
 * Uses MONGODB_URI from environment (Atlas or local).
 * Called from server.js on startup and from seeder.js for scripts.
 */

const dns = require('dns');
const mongoose = require('mongoose');

mongoose.connection.on('disconnected', () => {
  console.warn('MongoDB disconnected');
});

/**
 * Connect to MongoDB. Exits the process on failure.
 * @returns {Promise<void>}
 */
async function connectDB() {
  const uri = process.env.MONGODB_URI;

  if (!uri) {
    console.error('MONGODB_URI is required.');
    return; // Don't process.exit(1) in serverless
  }

  try {
    // Only set DNS locally, not in Vercel
    if (uri.startsWith('mongodb+srv://') && !process.env.VERCEL) {
      try { dns.setServers(['8.8.8.8', '1.1.1.1']); } catch(e){}
    }

    await mongoose.connect(uri);

    const { host, name } = mongoose.connection;
    console.log(`MongoDB connected: ${host} / ${name}`);

    // Auto-seed default admin user for the client
    const User = require('../models/User');
    const admin = await User.findOne({ email: 'admin@admin.com' });
    if (!admin) {
      const bcrypt = require('bcryptjs');
      const salt = await bcrypt.genSalt(10);
      const hashedPassword = await bcrypt.hash('123456', salt);
      await User.create({ name: 'Admin', email: 'admin@admin.com', password: hashedPassword, role: 'admin' });
      console.log('Default Admin user seeded.');
    }
  } catch (err) {
    console.error('MongoDB connection failed:', err.message);
    // return instead of process.exit
  }
}

/**
 * Close the MongoDB connection (e.g. after seeding).
 * @returns {Promise<void>}
 */
async function disconnectDB() {
  await mongoose.disconnect();
  console.log('MongoDB disconnected');
}

module.exports = { connectDB, disconnectDB };
