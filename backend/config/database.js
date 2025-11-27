const mongoose = require('mongoose');

const connectDatabase = async () => {
  try {
    const conn = await mongoose.connect(process.env.MONGODB_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });

    console.log(`✅ MongoDB Connected: ${conn.connection.host}`);

    // Handle connection events
    mongoose.connection.on('error', (err) => {
      console.error(`❌ MongoDB connection error: ${err}`);
    });

    mongoose.connection.on('disconnected', () => {
      console.log('⚠️  MongoDB disconnected');
    });

    // Graceful shutdown
    process.on('SIGINT', async () => {
      await mongoose.connection.close();
      console.log('MongoDB connection closed through app termination');
      process.exit(0);
    });

  } catch (error) {
    console.error(`❌ Error connecting to MongoDB: ${error.message}`);
    console.log('⚠️  Server will continue running without database connection.');
    console.log('📝 API endpoints may fail until database connection is established.');
    console.log('');
    console.log('🔧 To fix MongoDB Atlas connection:');
    console.log('   1. Go to https://cloud.mongodb.com/');
    console.log('   2. Navigate to Network Access');
    console.log('   3. Add your current IP address to the whitelist');
    console.log('   4. Or add 0.0.0.0/0 to allow all IPs (development only)');
    console.log('');

    // Retry connection after 30 seconds
    setTimeout(() => {
      console.log('🔄 Retrying MongoDB connection...');
      connectDatabase();
    }, 30000);
  }
};

module.exports = connectDatabase;
