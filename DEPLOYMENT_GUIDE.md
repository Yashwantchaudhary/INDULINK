# 🚀 INDULINK - Quick Production Deployment Guide

**Last Updated:** November 24, 2025  
**Version:** 1.0.0

---

## 📋 PRE-DEPLOYMENT CHECKLIST

Before deploying to production, ensure you have:

- ✅ Application code (current repository)
- ⚠️ MongoDB Atlas account (or production MongoDB server)
- ⚠️ Production server (AWS, DigitalOcean, Heroku, etc.)
- ⚠️ Domain name (optional but recommended)
- ⚠️ SSL certificate (Let's Encrypt recommended)
- ⚠️ Google Play Developer account ($25 one-time fee)
- ⚠️ Firebase project (for analytics, crashlytics, push notifications)

---

## 🗄️ STEP 1: DATABASE SETUP (MongoDB Atlas)

### Create MongoDB Atlas Cluster (FREE TIER AVAILABLE)

1. **Sign up at MongoDB Atlas:**
   ```
   https://www.mongodb.com/cloud/atlas/register
   ```

2. **Create a New Cluster:**
   - Click "Build a Database"
   - Choose "Shared" (Free tier: M0)
   - Select region closest to your users
   - Cluster name: `indulink-production`

3. **Create Database User:**
   - Go to "Database Access"
   - Click "Add New Database User"
   - Username: `indulink_admin`
   - Password: Generate secure password (save it!)
   - Role: "Atlas Admin"

4. **Configure Network Access:**
   - Go to "Network Access"
   - Click "Add IP Address"
   - For testing: Click "Allow Access from Anywhere" (0.0.0.0/0)
   - For production: Add your server's IP address

5. **Get Connection String:**
   - Go to "Database" → "Connect"
   - Choose "Connect your application"
   - Copy connection string:
   ```
   mongodb+srv://indulink_admin:<password>@indulink-production.xxxxx.mongodb.net/?retryWrites=true&w=majority
   ```
   - Replace `<password>` with your actual password

6. **Create Database:**
   - Connect using MongoDB Compass or Atlas UI
   - Create database: `indulink`
   - Collections will be created automatically by Mongoose

---

## 🖥️ STEP 2: BACKEND DEPLOYMENT

### Option A: Deploy to Heroku (Easiest)

1. **Install Heroku CLI:**
   ```bash
   # Download from: https://devcenter.heroku.com/articles/heroku-cli
   ```

2. **Login to Heroku:**
   ```bash
   heroku login
   ```

3. **Create Heroku App:**
   ```bash
   cd backend
   heroku create indulink-api
   ```

4. **Set Environment Variables:**
   ```bash
   heroku config:set NODE_ENV=production
   heroku config:set PORT=5000
   heroku config:set MONGODB_URI="your-mongodb-atlas-connection-string"
   heroku config:set JWT_SECRET="your-super-secret-jwt-key-min-32-chars"
   heroku config:set JWT_REFRESH_SECRET="your-refresh-secret-key-min-32-chars"
   heroku config:set JWT_EXPIRE=24h
   heroku config:set JWT_REFRESH_EXPIRE=7d
   heroku config:set ALLOWED_ORIGINS="https://indulink.com,https://www.indulink.com"
   ```

5. **Deploy:**
   ```bash
   git add .
   git commit -m "Deploy to production"
   git push heroku main
   ```

6. **Verify Deployment:**
   ```bash
   heroku open
   # Visit: https://indulink-api.herokuapp.com/health
   ```

---

### Option B: Deploy to VPS (DigitalOcean/AWS)

1. **Create Ubuntu Server:**
   - DigitalOcean Droplet (Basic $6/month)
   - or AWS EC2 t2.micro (Free tier)

2. **SSH into Server:**
   ```bash
   ssh root@your-server-ip
   ```

3. **Install Node.js:**
   ```bash
   curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
   sudo apt-get install -y nodejs
   sudo apt-get install -y npm
   ```

4. **Install PM2 (Process Manager):**
   ```bash
   sudo npm install -g pm2
   ```

5. **Install Nginx:**
   ```bash
   sudo apt update
   sudo apt install nginx
   ```

6. **Clone Your Repository:**
   ```bash
   cd /var/www
   git clone https://github.com/yourusername/indulink.git
   cd indulink/backend
   npm install --production
   ```

7. **Create .env File:**
   ```bash
   nano .env
   ```
   
   Paste:
   ```env
   NODE_ENV=production
   PORT=5000
   MONGODB_URI=your-mongodb-atlas-connection-string
   JWT_SECRET=your-super-secret-jwt-key-min-32-chars
   JWT_REFRESH_SECRET=your-refresh-secret-key-min-32-chars
   JWT_EXPIRE=24h
   JWT_REFRESH_EXPIRE=7d
   ALLOWED_ORIGINS=https://yourdomain.com
   ```

8. **Start with PM2:**
   ```bash
   pm2 start server.js --name indulink-api
   pm2 startup
   pm2 save
   ```

9. **Configure Nginx:**
   ```bash
   sudo nano /etc/nginx/sites-available/indulink
   ```
   
   Paste:
   ```nginx
   server {
       listen 80;
       server_name api.indulink.com;

       location / {
           proxy_pass http://localhost:5000;
           proxy_http_version 1.1;
           proxy_set_header Upgrade $http_upgrade;
           proxy_set_header Connection 'upgrade';
           proxy_set_header Host $host;
           proxy_cache_bypass $http_upgrade;
       }
   }
   ```

10. **Enable Site:**
    ```bash
    sudo ln -s /etc/nginx/sites-available/indulink /etc/nginx/sites-enabled/
    sudo nginx -t
    sudo systemctl restart nginx
    ```

11. **Setup SSL with Let's Encrypt:**
    ```bash
    sudo apt install certbot python3-certbot-nginx
    sudo certbot --nginx -d api.indulink.com
    ```

---

## 📱 STEP 3: FLUTTER APP DEPLOYMENT

### Update API Base URL

1. **Edit `lib/config/app_config.dart`:**
   ```dart
   static String get apiBaseUrl {
     if (kIsWeb) {
       return 'https://api.indulink.com/api';  // Your production URL
     }
     if (Platform.isAndroid || Platform.isIOS) {
       return 'https://api.indulink.com/api';  // Your production URL
     }
     return 'https://api.indulink.com/api';
   }
   ```

### Build Release APK (Android)

1. **Configure App Signing:**
   
   Create keystore:
   ```bash
   cd customer_app/android
   keytool -genkey -v -keystore ~/indulink-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias indulink
   ```

2. **Create `android/key.properties`:**
   ```properties
   storePassword=your-keystore-password
   keyPassword=your-key-password
   keyAlias=indulink
   storeFile=C:/path/to/indulink-release-key.jks
   ```

3. **Update `android/app/build.gradle`:**
   
   Add before `android {`:
   ```gradle
   def keystoreProperties = new Properties()
   def keystorePropertiesFile = rootProject.file('key.properties')
   if (keystorePropertiesFile.exists()) {
       keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
   }
   ```
   
   Update `signingConfigs`:
   ```gradle
   android {
       ...
       signingConfigs {
           release {
               keyAlias keystoreProperties['keyAlias']
               keyPassword keystoreProperties['keyPassword']
               storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
               storePassword keystoreProperties['storePassword']
           }
       }
       buildTypes {
           release {
               signingConfig signingConfigs.release
               ...
           }
       }
   }
   ```

4. **Build Release APK:**
   ```bash
   cd customer_app
   flutter clean
   flutter pub get
   flutter build apk --release
   ```

5. **Find APK:**
   ```
   customer_app/build/app/outputs/flutter-apk/app-release.apk
   ```

### Publish to Google Play Store

1. **Create Google Play Developer Account:**
   - Go to: https://play.google.com/console
   - Pay $25 one-time registration fee

2. **Create New App:**
   - Click "Create app"
   - Fill in app details
   - Choose "Paid" or "Free"

3. **Upload APK:**
   - Go to "Release" → "Production"
   - Click "Create new release"
   - Upload your APK
   - Fill in release notes

4. **Complete Store Listing:**
   - App icon (512x512px)
   - Feature graphic (1024x500px)
   - Screenshots (at least 2)
   - Short description
   - Full description
   - Privacy policy URL

5. **Set Content Rating:**
   - Complete questionnaire
   - Get rating for your app

6. **Set Pricing:**
   - Choose countries
   - Set price (free or paid)

7. **Submit for Review:**
   - Review and submit
   - Wait for approval (1-7 days)

---

## 🔐 STEP 4: SECURITY HARDENING

### Generate Secure JWT Secrets

```bash
# In Node.js REPL
node
> require('crypto').randomBytes(64).toString('hex')
```

Use the output for `JWT_SECRET` and `JWT_REFRESH_SECRET`

### Update Environment Variables

Make sure ALL these are set in production:

```env
NODE_ENV=production
PORT=5000
MONGODB_URI=mongodb+srv://user:pass@cluster.mongodb.net/indulink
JWT_SECRET=<64-char-hex-string>
JWT_REFRESH_SECRET=<64-char-hex-string>
JWT_EXPIRE=24h
JWT_REFRESH_EXPIRE=7d
ALLOWED_ORIGINS=https://yourdomain.com,https://yourapp.com
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
UPLOAD_DIR=uploads
MAX_FILE_SIZE=5242880
```

---

## 🔍 STEP 5: POST-DEPLOYMENT TESTING

### Test Backend APIs

1. **Health Check:**
   ```bash
   curl https://your-api.com/health
   ```

2. **Test Registration:**
   ```bash
   curl -X POST https://your-api.com/api/auth/register \
     -H "Content-Type: application/json" \
     -d '{
       "firstName": "Test",
       "lastName": "User",
       "email": "test@example.com",
       "password": "Password123!",
       "phone": "1234567890",
       "role": "customer"
     }'
   ```

3. **Test Login:**
   ```bash
   curl -X POST https://your-api.com/api/auth/login \
     -H "Content-Type: application/json" \
     -d '{
       "email": "test@example.com",
       "password": "Password123!"
     }'
   ```

### Test Flutter App

1. Install APK on real device
2. Test complete user flows:
   - ✅ Registration
   - ✅ Login
   - ✅ Browse products
   - ✅ Add to cart
   - ✅ Checkout
   - ✅ View orders
   - ✅ Messaging
   - ✅ Notifications

---

## 📊 STEP 6: MONITORING & ANALYTICS

### Backend Monitoring

1. **Install PM2 Plus (Free tier):**
   ```bash
   pm2 link your-secret-key your-public-key
   ```

2. **Alternative: Use Heroku Metrics**
   - Built-in for Heroku deployments

3. **Error Tracking (Sentry):**
   ```bash
   npm install @sentry/node
   ```
   
   Add to `server.js`:
   ```javascript
   const Sentry = require("@sentry/node");
   Sentry.init({ dsn: "your-sentry-dsn" });
   ```

### Flutter Analytics

1. **Setup Firebase:**
   - Create Firebase project
   - Add Android app
   - Download `google-services.json`
   - Place in `android/app/`

2. **Add Firebase dependencies:**
   ```yaml
   dependencies:
     firebase_core: ^2.24.0
     firebase_analytics: ^10.8.0
     firebase_crashlytics: ^3.4.0
   ```

3. **Initialize in `main.dart`:**
   ```dart
   await Firebase.initializeApp();
   ```

---

## 🎯 DEPLOYMENT TIMELINE

### Week 1: Infrastructure Setup
- Day 1-2: Create MongoDB Atlas cluster
- Day 3-4: Deploy backend to production
- Day 5-6: Configure domain and SSL
- Day 7: Test all API endpoints

### Week 2: App Deployment
- Day 1-2: Build and test release APK
- Day 3-4: Create Play Store listing
- Day 5-6: Upload APK and complete store setup
- Day 7: Submit for review

### Week 3: Monitoring & Launch
- Day 1-3: Setup monitoring and analytics
- Day 4-5: Final testing
- Day 6: Soft launch (limited users)
- Day 7: Public launch

---

## 🆘 TROUBLESHOOTING

### Backend Issues

**Issue:** Cannot connect to MongoDB
- ✅ Check connection string is correct
- ✅ Verify database user credentials
- ✅ Check network access (IP whitelist)

**Issue:** Server crashes
- ✅ Check PM2 logs: `pm2 logs`
- ✅ Verify all environment variables set
- ✅ Check server resources (RAM, CPU)

### Flutter Issues

**Issue:** Build failed
- ✅ Run `flutter clean` and `flutter pub get`
- ✅ Check SDK version compatibility
- ✅ Verify all dependencies installed

**Issue:** API not connecting
- ✅ Check API base URL is correct
- ✅ Verify SSL certificate valid
- ✅ Check CORS settings on backend

---

## 📞 SUPPORT RESOURCES

### Documentation
- MongoDB Atlas: https://docs.atlas.mongodb.com/
- Heroku: https://devcenter.heroku.com/
- Flutter Deployment: https://flutter.dev/docs/deployment/android
- Firebase: https://firebase.google.com/docs

### Communities
- MongoDB Community Forum
- Stack Overflow
- Flutter Discord
- Reddit: r/flutterdev

---

## ✅ PRODUCTION CHECKLIST

### Backend ✅
- [ ] MongoDB Atlas cluster created
- [ ] Database user configured
- [ ] Backend deployed to server
- [ ] Environment variables set
- [ ] SSL certificate installed
- [ ] Health check passing
- [ ] All API endpoints tested
- [ ] Error monitoring setup

### Flutter ✅
- [ ] API URL updated to production
- [ ] Release APK built and signed
- [ ] App tested on real device
- [ ] All features working
- [ ] Play Store listing created
- [ ] App uploaded and submitted
- [ ] Firebase analytics setup
- [ ] Crashlytics enabled

### Post-Launch ✅
- [ ] Monitor server resources
- [ ] Track error rates
- [ ] Monitor user analytics
- [ ] Gather user feedback
- [ ] Plan iteration cycle

---

## 🎊 CONGRATULATIONS!

Your INDULINK application is now in production! 

**What's Next:**
1. Monitor closely for first 48 hours
2. Gather user feedback
3. Fix any critical bugs immediately
4. Plan feature updates
5. Scale infrastructure as needed

---

**Deployment Guide Version:** 1.0.0  
**Last Updated:** November 24, 2025  
**Status:** Ready for Production Deployment 🚀
