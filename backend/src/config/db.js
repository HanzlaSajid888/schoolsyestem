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
    console.error(
      'MONGODB_URI is required. Copy .env.example to .env and add your MongoDB Atlas connection string.'
    );
    process.exit(1);
  }

  try {
    // Some networks block local DNS SRV lookups required by mongodb+srv (Atlas)
    if (uri.startsWith('mongodb+srv://')) {
      dns.setServers(['8.8.8.8', '1.1.1.1']);
    }

    await mongoose.connect(uri);

    const { host, name } = mongoose.connection;
    console.log(`MongoDB connected: ${host} / ${name}`);
  } catch (err) {
    console.error('MongoDB connection failed:', err.message);
    process.exit(1);
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
