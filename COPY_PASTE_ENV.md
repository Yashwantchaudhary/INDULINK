# 📋 COPY-PASTE READY - MongoDB Atlas Connection String

For your convenience, here's the exact connection string to copy:

---

## 🔐 MongoDB Atlas URI (Copy This)

```
mongodb+srv://yashwantchaudhary_db_user:Vilgax%40%23%24123@cluster0.r0gzvfw.mongodb.net/indulink?retryWrites=true&w=majority&appName=Cluster0
```

---

## 📝 Complete .env File Example

Here's what your complete `.env` file should look like:

```env
NODE_ENV=development
PORT=5000

# Database Configuration - MongoDB Atlas
MONGODB_URI=mongodb+srv://yashwantchaudhary_db_user:Vilgax%40%23%24123@cluster0.r0gzvfw.mongodb.net/indulink?retryWrites=true&w=majority&appName=Cluster0

# JWT Secrets - CHANGE THESE IN PRODUCTION
JWT_SECRET=indulink-super-secret-jwt-key-2024-change-this
JWT_REFRESH_SECRET=indulink-super-secret-refresh-key-2024-change-this
JWT_EXPIRE=24h
JWT_REFRESH_EXPIRE=7d

# File Upload
UPLOAD_DIR=uploads
MAX_FILE_SIZE=5242880

# CORS - Add your frontend URLs
CLIENT_URL=http://localhost:3000
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8080,http://localhost:5000

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
```

---

## ✅ After Updating

1. **Save** the file (Ctrl+S)
2. **Let me know** you're ready
3. **I'll start** the backend server
4. **We'll verify** MongoDB Atlas connection

---

**Status:** Ready to test once you save the .env file! 🚀
