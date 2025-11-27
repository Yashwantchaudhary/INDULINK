# 🔧 Quick Fix - Port Conflict Issue

## ⚠️ Issue Found

**Error:** `EADDRINUSE: address already in use :::5001`

**Cause:** 
1. Backend server is still running on port 5001
2. `.env` file may still have `PORT=5001` instead of `PORT=5000`

---

## ✅ Solution (2 Steps)

### Step 1: Stop Running Server

**Option A: Find and kill process**
```bash
# Find the process
netstat -ano | findstr :5001

# Kill it (replace XXXX with PID from above)
taskkill /PID XXXX /F
```

**Option B: Close terminal**
- If you have another terminal running `npm start`, close it
- Or press Ctrl+C in that terminal

### Step 2: Verify .env File

Make sure your `backend/.env` file has:

```env
PORT=5000
```

**NOT** `PORT=5001`

---

## 🚀 Then Restart

```bash
cd backend
npm start
```

**Should see:**
```
✅ MongoDB Connected: cluster0.r0gzvfw.mongodb.net
✓ Server running on port 5000
```

---

## 📝 Complete .env Reference

Your `.env` should have:

```env
NODE_ENV=development
PORT=5000

# MongoDB Atlas
MONGODB_URI=mongodb+srv://yashwantchaudhary_db_user:Vilgax%40%23%24123@cluster0.r0gzvfw.mongodb.net/indulink?retryWrites=true&w=majority&appName=Cluster0

# JWT Secrets
JWT_SECRET=indulink-super-secret-jwt-key-2024-change-this
JWT_REFRESH_SECRET=indulink-super-secret-refresh-key-2024-change-this
JWT_EXPIRE=24h
JWT_REFRESH_EXPIRE=7d

# File Upload
UPLOAD_DIR=uploads
MAX_FILE_SIZE=5242880

# CORS
CLIENT_URL=http://localhost:3000
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8080,http://localhost:5000

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
```

---

**Status:** Port conflict - stop old server and verify PORT=5000
