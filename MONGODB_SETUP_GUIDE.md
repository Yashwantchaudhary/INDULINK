# 🗄️ MongoDB Atlas Configuration Guide

**Date:** November 24, 2025  
**Cluster:** cluster0.5ulpbcs.mongodb.net

---

## ✅ CONNECTION STRING CONFIGURED

Your MongoDB Atlas connection string has been added to:
```
backend/.env.local
```

---

## ⚠️ IMPORTANT: REPLACE PASSWORD

**You MUST replace `<PASSWORD>` with your actual database password!**

### Step 1: Find Your Password

Your MongoDB Atlas password is:
- **NOT** the same as your MongoDB Atlas account password
- The password you created when you created the database user `yashwantchaudhary_db_user`

**If you forgot your password:**
1. Go to MongoDB Atlas: https://cloud.mongodb.com/
2. Select your project
3. Click "Database Access" in the left sidebar
4. Find user `yashwantchaudhary_db_user`
5. Click "Edit"
6. Click "Edit Password"
7. Set a new password (save it securely!)

### Step 2: Update .env.local

Open: `backend/.env.local`

Find this line:
```env
MONGODB_URI=mongodb+srv://yashwantchaudhary_db_user:<PASSWORD>@cluster0.5ulpbcs.mongodb.net/indulink?retryWrites=true&w=majority&appName=Cluster0
```

Replace `<PASSWORD>` with your actual password:
```env
MONGODB_URI=mongodb+srv://yashwantchaudhary_db_user:YourActualPassword123@cluster0.5ulpbcs.mongodb.net/indulink?retryWrites=true&w=majority&appName=Cluster0
```

**⚠️ SECURITY NOTE:**
- Never commit passwords to Git
- `.env.local` is in `.gitignore` (protected)
- Use strong passwords with special characters

---

## 🔐 SECURITY CHECKLIST

### MongoDB Atlas Network Access

**You MUST whitelist your IP addresses:**

1. Go to MongoDB Atlas
2. Click "Network Access" in the left sidebar
3. Click "Add IP Address"

**Options:**

**Option A: Allow from Anywhere (Development Only)**
```
IP Address: 0.0.0.0/0
Description: Allow from anywhere (DEVELOPMENT ONLY)
```
⚠️ **NOT recommended for production!**

**Option B: Specific IP Addresses (Production)**
```
Add your server's IP address
Add your development machine's IP
```
✅ **Recommended for production**

### Database User Permissions

Verify your user has correct permissions:
1. Go to "Database Access"
2. User: `yashwantchaudhary_db_user`
3. Should have: **Atlas Admin** or **Read and write to any database**

---

## 🗂️ DATABASE STRUCTURE

Your app will create these collections automatically:

```
Database: indulink
├── users              (User accounts)
├── products           (Product catalog)
├── orders             (Customer orders)
├── carts              (Shopping carts)
├── categories         (Product categories)
├── reviews            (Product reviews)
├── rfqs               (RFQ requests)
├── wishlists          (User wishlists)
├── messages           (Chat messages)
├── conversations      (Conversation metadata)
├── notifications      (User notifications)
├── badges             (User badges)
└── loyaltytransactions (Loyalty points)
```

**Total Collections:** 13

---

## 🧪 TEST CONNECTION

### Method 1: Start the Backend

```bash
cd backend
npm start
```

**Expected Output:**
```
✅ MongoDB Connected: cluster0.5ulpbcs.mongodb.net

╔═══════════════════════════════════════════════════════╗
║                                                       ║
║   🚀  Indulink E-commerce API Server                 ║
║                                                       ║
║   ✓ Server running on port 5000                      ║
║   ✓ Environment: development                         ║
║   ✓ API Base: http://localhost:5000/api             ║
║                                                       ║
╚═══════════════════════════════════════════════════════╝
```

### Method 2: Use MongoDB Compass

1. Download MongoDB Compass: https://www.mongodb.com/try/download/compass
2. Connection string:
   ```
   mongodb+srv://yashwantchaudhary_db_user:YourPassword@cluster0.5ulpbcs.mongodb.net/
   ```
3. Click "Connect"
4. You should see your databases

### Method 3: Run API Test Script

```bash
cd backend
node test-api.js
```

This will test all 33 API endpoints.

---

## 🚀 PRODUCTION DEPLOYMENT

### For Production Environment

Create a separate `.env` file for production:

```env
NODE_ENV=production
PORT=5000

# MongoDB Atlas Production
MONGODB_URI=mongodb+srv://yashwantchaudhary_db_user:YourProductionPassword@cluster0.5ulpbcs.mongodb.net/indulink_production?retryWrites=true&w=majority&appName=Cluster0

# JWT Secrets - CHANGE THESE!
JWT_SECRET=<64-character-random-string>
JWT_REFRESH_SECRET=<64-character-random-string>
JWT_EXPIRE=24h
JWT_REFRESH_EXPIRE=7d

# File Upload
UPLOAD_DIR=uploads
MAX_FILE_SIZE=5242880

# CORS - Your production domain
CLIENT_URL=https://yourdomain.com
ALLOWED_ORIGINS=https://yourdomain.com,https://api.yourdomain.com

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
```

**Generate secure JWT secrets:**
```bash
# In Node.js REPL
node
> require('crypto').randomBytes(64).toString('hex')
```

---

## 📊 MONITORING

### View Database Activity

1. Go to MongoDB Atlas
2. Click "Metrics" tab
3. Monitor:
   - Operations per second
   - Connections
   - Network traffic
   - Storage size

### Setup Alerts

1. Go to "Alerts" in MongoDB Atlas
2. Configure alerts for:
   - High CPU usage
   - Connection peaks
   - Storage limits
   - Query performance

---

## 🔧 TROUBLESHOOTING

### Error: "MongooseServerSelectionError"

**Cause:** Can't connect to MongoDB Atlas

**Solutions:**
1. ✅ Check password is correct (no `<` or `>` brackets)
2. ✅ Verify IP whitelist in Network Access
3. ✅ Check internet connection
4. ✅ Verify cluster is running (not paused)

### Error: "Authentication failed"

**Cause:** Wrong username or password

**Solutions:**
1. ✅ Double-check username: `yashwantchaudhary_db_user`
2. ✅ Reset password in Database Access
3. ✅ Update `.env.local` with new password

### Error: "Quota exceeded"

**Cause:** Free tier limits reached

**Solutions:**
1. ✅ Check cluster metrics
2. ✅ Optimize queries
3. ✅ Upgrade to paid tier if needed

### Connection Timeout

**Solutions:**
1. ✅ Add `serverSelectionTimeoutMS=5000` to URI
2. ✅ Check firewall settings
3. ✅ Verify DNS resolution

---

## 💡 BEST PRACTICES

### Development
- ✅ Use separate database: `indulink_dev`
- ✅ Test with sample data
- ✅ Don't use production data

### Production
- ✅ Use separate cluster or database
- ✅ Enable backup (M10+ clusters)
- ✅ Set up monitoring
- ✅ Restrict IP addresses
- ✅ Use strong passwords
- ✅ Regular backups

### Security
- ✅ Never commit `.env` files
- ✅ Rotate passwords regularly
- ✅ Use environment variables
- ✅ Enable encryption at rest (M10+)
- ✅ Audit database access logs

---

## 📝 CONNECTION STRING BREAKDOWN

Your connection string:
```
mongodb+srv://yashwantchaudhary_db_user:<PASSWORD>@cluster0.5ulpbcs.mongodb.net/indulink?retryWrites=true&w=majority&appName=Cluster0
```

**Parts:**
- `mongodb+srv://` - Protocol (SRV record)
- `yashwantchaudhary_db_user` - Database username
- `<PASSWORD>` - Your database password
- `cluster0.5ulpbcs.mongodb.net` - Cluster address
- `/indulink` - Database name
- `?retryWrites=true` - Auto-retry failed writes
- `&w=majority` - Write concern (confirm writes)
- `&appName=Cluster0` - Application identifier

---

## ✅ CHECKLIST

Before starting your app:

- [ ] MongoDB Atlas account created
- [ ] Cluster `cluster0` is running
- [ ] Database user `yashwantchaudhary_db_user` created
- [ ] User has proper permissions
- [ ] IP address whitelisted in Network Access
- [ ] Password saved securely
- [ ] Password updated in `backend/.env.local`
- [ ] Connection tested successfully
- [ ] Backend starts without errors

---

## 🎯 NEXT STEPS

### 1. Update Password
```bash
# Open backend/.env.local
# Replace <PASSWORD> with your actual password
```

### 2. Start Backend
```bash
cd backend
npm start
```

### 3. Verify Connection
Look for: `✅ MongoDB Connected: cluster0.5ulpbcs.mongodb.net`

### 4. Test APIs
```bash
# In a new terminal
cd backend
node test-api.js
```

### 5. Start Flutter App
```bash
cd customer_app
flutter run
```

### 6. Test Complete Flow
- Register a user
- Login
- Browse products
- Add to cart
- Create order
- Check that data is saved in MongoDB Atlas

---

## 📞 SUPPORT

**MongoDB Atlas Documentation:**
- https://docs.atlas.mongodb.com/

**Connection Troubleshooting:**
- https://docs.atlas.mongodb.com/troubleshoot-connection/

**MongoDB Compass:**
- https://www.mongodb.com/products/compass

**Need Help?**
- MongoDB Community Forums
- Stack Overflow (tag: mongodb-atlas)
- MongoDB Support (paid plans)

---

## 🎊 SUMMARY

✅ MongoDB Atlas connection string configured  
⚠️ **ACTION REQUIRED:** Replace `<PASSWORD>` in `.env.local`  
✅ Database structure defined (13 collections)  
✅ Security guidelines provided  
✅ Testing instructions included  

**Status:** Ready to connect once password is updated!

---

**Configuration Date:** November 24, 2025  
**Cluster:** cluster0.5ulpbcs.mongodb.net  
**Database:** indulink  
**User:** yashwantchaudhary_db_user
