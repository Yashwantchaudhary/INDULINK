# 🧪 Indulink App Testing Checklist

## Prerequisites
- [ ] Backend server running (`cd backend && npm start`)
- [ ] MongoDB database connected
- [ ] Flutter development environment set up
- [ ] Android device/emulator connected
- [ ] Same WiFi network for backend and device

## Phase 1: Pre-Build Testing

### 🔗 API Connectivity Testing
- [ ] Run `test_connection.bat` script
- [ ] Test connection via Settings → Test Connection
- [ ] Verify backend health endpoint responds
- [ ] Check all API endpoints are accessible

### 🔐 Authentication Testing
- [ ] **Customer Registration**
  - [ ] Valid email format validation
  - [ ] Password strength requirements
  - [ ] Confirm password matching
  - [ ] Firebase authentication success
  - [ ] Backend user creation
  - [ ] Auto-login after registration

- [ ] **Customer Login**
  - [ ] Valid credentials acceptance
  - [ ] Invalid credentials rejection
  - [ ] JWT token storage
  - [ ] Session persistence

- [ ] **Supplier Registration/Login**
  - [ ] Role-based registration
  - [ ] Business information validation
  - [ ] Separate supplier authentication flow

### 🎨 UI/UX Testing
- [ ] **Multi-Language Support**
  - [ ] Language selector in settings
  - [ ] Nepali (नेपाली) translations
  - [ ] Hindi (हिन्दी) translations
  - [ ] English (UK) translations
  - [ ] Dynamic locale switching

- [ ] **Dark Theme**
  - [ ] Theme toggle in settings
  - [ ] Light mode functionality
  - [ ] Dark mode functionality
  - [ ] System theme following
  - [ ] Theme persistence

### 📊 Dashboard Testing
- [ ] **Customer Dashboard**
  - [ ] Welcome message with user name
  - [ ] Statistics cards (orders, spending, etc.)
  - [ ] Recent orders display
  - [ ] Active orders section
  - [ ] Pull-to-refresh functionality

- [ ] **Supplier Dashboard**
  - [ ] Revenue analytics
  - [ ] Order status breakdown
  - [ ] Inventory status
  - [ ] Recent orders
  - [ ] Quick actions functionality

### 🛍️ Product Management Testing
- [ ] **Product Listing**
  - [ ] Products load from API
  - [ ] Pagination working
  - [ ] Search functionality
  - [ ] Category filtering

- [ ] **Product CRUD (Supplier)**
  - [ ] Add new product
  - [ ] Edit existing product
  - [ ] Delete product
  - [ ] Image upload
  - [ ] Stock management

### 🛒 E-commerce Features Testing
- [ ] **Cart Functionality**
  - [ ] Add to cart
  - [ ] Remove from cart
  - [ ] Quantity updates
  - [ ] Cart persistence

- [ ] **Checkout Process**
  - [ ] Order creation
  - [ ] Payment integration
  - [ ] Order confirmation

- [ ] **Order Management**
  - [ ] Order history
  - [ ] Order tracking
  - [ ] Order status updates

## Phase 2: Build Testing

### 📱 APK Build Process
- [ ] Clean build (`flutter clean`)
- [ ] Get dependencies (`flutter pub get`)
- [ ] Build APK (`flutter build apk --release`)
- [ ] Build success without errors
- [ ] APK file generated in `build/app/outputs/flutter-apk/`

### 📦 APK Installation Testing
- [ ] Transfer APK to Android device
- [ ] Install APK successfully
- [ ] App icon appears on home screen
- [ ] App launches without crashes

## Phase 3: Post-Installation Testing

### 🚀 Device Functionality Testing
- [ ] **App Launch**
  - [ ] Splash screen displays
  - [ ] Role selection screen
  - [ ] Navigation works

- [ ] **Authentication on Device**
  - [ ] Login with real credentials
  - [ ] Registration process
  - [ ] Session persistence after app close

- [ ] **Core Features on Device**
  - [ ] Dashboard loads real data
  - [ ] Product browsing
  - [ ] Cart operations
  - [ ] Settings access

- [ ] **Network Operations**
  - [ ] API calls work on mobile network
  - [ ] Image loading
  - [ ] File uploads

### 🔧 Performance Testing
- [ ] **App Performance**
  - [ ] Smooth navigation
  - [ ] No UI freezing
  - [ ] Fast loading times
  - [ ] Memory usage acceptable

- [ ] **Network Performance**
  - [ ] API response times
  - [ ] Image loading speed
  - [ ] Offline functionality

### 🐛 Bug Testing
- [ ] **Common Issues**
  - [ ] No crashes on normal usage
  - [ ] Error handling works
  - [ ] Loading states display properly
  - [ ] Empty states handled

- [ ] **Edge Cases**
  - [ ] Network disconnection handling
  - [ ] Invalid data handling
  - [ ] Large data sets
  - [ ] Memory constraints

## Testing Commands

### Backend Testing
```bash
# Start backend
cd backend && npm start

# Test health endpoint
curl http://localhost:5000/health

# Test API endpoints
curl http://localhost:5000/api/auth/test
```

### Flutter Testing
```bash
# Run tests
flutter test

# Run integration tests
flutter drive --target=test_driver/app.dart

# Analyze code
flutter analyze

# Format code
flutter format .
```

### Build Commands
```bash
# Clean and prepare
flutter clean
flutter pub get

# Build APK
flutter build apk --release

# Build app bundle
flutter build appbundle --release

# Install on device
flutter install
```

## Testing Environment Setup

### Development Environment
- [ ] Flutter SDK: 3.0+
- [ ] Dart SDK: 2.19+
- [ ] Android SDK: API 21+
- [ ] Node.js: 16+
- [ ] MongoDB: 5.0+

### Test Devices
- [ ] Android Phone (Physical)
- [ ] Android Emulator
- [ ] Different screen sizes
- [ ] Different Android versions

### Test Data
- [ ] Sample users (customer & supplier)
- [ ] Sample products
- [ ] Sample orders
- [ ] Test images

## Reporting

### Test Results Template
```
Test Case: [Test Name]
Status: ✅ PASS / ❌ FAIL / ⚠️ SKIP
Environment: [Device/Android Version]
Steps:
1. [Step 1]
2. [Step 2]
Expected: [Expected Result]
Actual: [Actual Result]
Notes: [Additional observations]
```

### Bug Report Template
```
Title: [Brief description]
Severity: Critical / Major / Minor
Steps to Reproduce:
1. [Step 1]
2. [Step 2]
Expected Behavior: [What should happen]
Actual Behavior: [What actually happens]
Environment: [Device, OS, App Version]
Screenshots: [If applicable]
Additional Info: [Logs, console output, etc.]
```

## Sign-off Checklist

### Pre-Production
- [ ] All critical bugs fixed
- [ ] Performance requirements met
- [ ] Security review completed
- [ ] User acceptance testing passed
- [ ] Documentation updated

### Production Ready
- [ ] Final build tested on target devices
- [ ] Backend deployed and stable
- [ ] Database migrations completed
- [ ] CDN configured for assets
- [ ] Monitoring tools set up