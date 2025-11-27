# Indulink E-commerce Platform

Production-ready e-commerce mobile application platform with separate Customer and Supplier apps.

## 🚀 Quick Start

### Backend
```bash
cd backend
npm install
cp .env.example .env
# Edit .env with your MongoDB URI
npm run dev
```

### Customer App
```bash
cd customer_app
flutter pub get
# Update API URL in lib/config/app_config.dart
flutter run
```

## 📱 Project Structure

- **backend/** - Node.js + Express + MongoDB API
- **customer_app/** - Flutter customer mobile app
- **supplier_app/** - Flutter supplier mobile app (to be created)

## 📚 Documentation

- [Backend README](backend/README.md)
- [Implementation Plan](file://C:/Users/chaud/.gemini/antigravity/brain/f534a51c-05d2-45a9-abc3-d32fdd5ffd99/implementation_plan.md)
- [Project Walkthrough](file://C:/Users/chaud/.gemini/antigravity/brain/f534a51c-05d2-45a9-abc3-d32fdd5ffd99/walkthrough.md)

## ✅ Completed Features

### Backend (100%)
- Complete REST API with 50+ endpoints
- JWT authentication with refresh tokens
- 7 database models (User, Product, Category, Cart, Order, Review, Message)
- Multi-role authorization (Customer/Supplier/Admin)
- File upload support
- Advanced filtering and pagination
- Revenue analytics and dashboards

### Customer App (Foundation)
- Modern UI with Material Design 3
- Riverpod state management
- Authentication screens (Login, Register)
- Home screen with product grid
- API integration layer
- Auto token refresh

## 🎯 Next Steps

1. Complete customer app features (cart, checkout, orders, profile)
2. Create supplier app
3. Add real-time features (WebSocket/Firebase)
4. Implement payment gateway
5. Add push notifications
6. Deploy to production

## 🔐 Default Test Credentials

Create via API or app registration.

## 📄 License

MIT
