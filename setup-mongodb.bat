@echo off
REM INDULINK - Automatic MongoDB Atlas Setup Script
REM This script copies the MongoDB Atlas configuration to .env

echo.
echo ╔════════════════════════════════════════════════════════╗
echo ║  INDULINK - MongoDB Atlas Configuration               ║
echo ║  Automatic Setup Script                               ║
echo ╚════════════════════════════════════════════════════════╝
echo.

cd backend

echo [1/3] Checking files...
if not exist ".env.local" (
    echo ❌ ERROR: .env.local not found
    pause
    exit /b 1
)

if not exist ".env" (
    echo ⚠️  .env not found, creating from .env.local...
    copy .env.local .env
) else (
    echo ✅ .env file found
    echo.
    echo [2/3] Creating backup...
    copy /Y .env .env.backup.%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%
    echo ✅ Backup created
    echo.
    echo [3/3] Updating .env with MongoDB Atlas configuration...
    copy /Y .env.local .env
)

echo.
echo ╔════════════════════════════════════════════════════════╗
echo ║  ✅ Configuration Complete!                            ║
echo ╚════════════════════════════════════════════════════════╝
echo.
echo Your .env file now has:
echo   - MongoDB Atlas connection
echo   - Username: yashwantchaudhary_db_user
echo   - Cluster: cluster0.r0gzvfw.mongodb.net
echo   - Database: indulink
echo.
echo Starting backend server...
echo.
pause

call npm start
