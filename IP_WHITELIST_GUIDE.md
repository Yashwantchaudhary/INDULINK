# 🔐 Quick IP Whitelist Guide

## Option 1: Allow from Anywhere (Quick Test - Development Only)

1. Open: https://cloud.mongodb.com/
2. Login to your account
3. Select your project
4. Click **"Network Access"** in the left sidebar
5. Click **"+ ADD IP ADDRESS"** button
6. In the popup, click **"ALLOW ACCESS FROM ANYWHERE"**
7. This will add: `0.0.0.0/0`
8. Click **"Confirm"**
9. Wait 1-2 minutes for changes to apply

⚠️ **Warning:** This is for development only. For production, use specific IP addresses.

## Option 2: Add Your Current IP (Recommended for Production)

1. Find your IP: Go to https://whatismyipaddress.com/
2. Copy your IP address
3. In MongoDB Atlas Network Access:
   - Click **"+ ADD IP ADDRESS"**
   - Click **"Add Current IP Address"**
   - Or manually enter your IP
   - Add a comment like "My Development Machine"
   - Click **"Confirm"**

## Verify Network Access

You should see an entry like:
```
IP Address: 0.0.0.0/0 (or your specific IP)
Comment: Allow from anywhere
Status: Active
```

**Note:** Changes take 1-2 minutes to propagate.
