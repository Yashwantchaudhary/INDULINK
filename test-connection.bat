@echo off
REM INDULINK - Quick Connection Test
REM This script helps you verify MongoDB Atlas connection

echo.
echo ╔════════════════════════════════════════════════════════╗
echo ║                                                        ║
echo ║     INDULINK - MongoDB Atlas Connection Test          ║
echo ║                                                        ║
echo ╚════════════════════════════════════════════════════════╝
echo.

echo [STEP 1/4] Checking if you've updated the password...
echo.

cd backend

REM Check if <PASSWORD> is still in .env.local
findstr /C:"<PASSWORD>" .env.local >nul
if %errorlevel% equ 0 (
    echo ❌ ERROR: Password placeholder detected!
    echo.
    echo You need to update the password in backend\.env.local
    echo.
    echo Find this line:
    echo   MONGODB_URI=mongodb+srv://yashwantchaudhary_db_user:^<PASSWORD^>@...
    echo.
    echo Replace ^<PASSWORD^> with your actual MongoDB password
    echo.
    echo See MONGODB_SETUP_GUIDE.md for detailed instructions.
    echo.
    pause
    exit /b 1
)

echo ✅ Password placeholder not found - looks good!
echo.

echo [STEP 2/4] Checking Node.js...
echo.

where node >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ ERROR: Node.js is not installed or not in PATH
    echo.
    echo Please install Node.js from: https://nodejs.org/
    echo.
    pause
    exit /b 1
)

node --version
echo ✅ Node.js found!
echo.

echo [STEP 3/4] Checking npm packages...
echo.

if not exist "node_modules" (
    echo ⚠️  node_modules not found. Installing dependencies...
    echo.
    call npm install
    if %errorlevel% neq 0 (
        echo ❌ ERROR: Failed to install dependencies
        pause
        exit /b 1
    )
)

echo ✅ Dependencies ready!
echo.

echo [STEP 4/4] Starting backend server...
echo.
echo This will test your MongoDB Atlas connection.
echo If you see "MongoDB Connected", you're all set!
echo.
echo Press Ctrl+C to stop the server when done.
echo.
pause

REM Start the server
call npm start
