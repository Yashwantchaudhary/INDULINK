# INDULINK Screen Flows & Role-Based Access Control

## Overview

This document outlines the screen navigation flows for different user roles in the INDULINK application, along with the role-based access control (RBAC) implementation.

## User Roles

- **Customer/Buyer**: Users who purchase products
- **Supplier**: Users who sell products and manage inventory
- **Admin**: Platform administrators (future implementation)

---

## Customer Flow

### Authentication Flow
```
Splash Screen → Role Selection → Login (Customer) → Bottom Navigation (Customer View)
                                ↓
                          Register (Customer)
```

###Customer Bottom Navigation
1. **Dashboard** - Customer Dashboard Screen
2. **Home** - Enhanced Home Screen (Shopping)
3. **Categories** - Categories Screen
4. **Cart** - Cart Screen
5. **Profile** - Profile Screen

### Shopping Flow
```
Enhanced Home → Category/Product Listing → Product Detail → Add to Cart → 
Cart → Checkout Address → Checkout Payment → Order Success →
View Orders → Order Detail
```

### Profile Flow
```
Profile → Edit Profile
        → Addresses Management
        → Payment Methods
        → Orders History
        → Wishlist
        → Settings
        → Help Center
        → Logout
```

### Customer-Only Screens
- `CustomerDashboardScreen` - View order stats, recent orders
- `CartScreen` / `EnhancedCartScreen` - Shopping cart management
- `CheckoutAddressScreen` - Shipping address selection
- `CheckoutPaymentScreen` / `ModernCheckoutScreen` - Payment
- `WishlistScreen` - Saved products
- `DealsScreen` - Special offers
- `ModernCustomerOrdersScreen` - Customer order history

---

## Supplier Flow

### Authentication Flow
```
Splash Screen → Role Selection → Login (Supplier) → Bottom Navigation (Supplier View)
                                ↓
                          Register (Supplier)
```

### Supplier Bottom Navigation
1. **Dashboard** - Supplier Dashboard Screen
2. **Products** - Inventory Management
3. **Orders** - Supplier Orders Screen
4. **Analytics** - Supplier Analytics
5. **Profile** - Profile Screen

### Product Management Flow
```
Supplier Dashboard → Products List → Add/Edit Product → Inventory Management
```

### Order Management Flow
```
Supplier Dashboard → Orders List → Order Detail → Update Order Status
```

### Analytics Flow
```
Supplier Dashboard → Analytics → View Revenue/Sales Data → Date Range Selection
```

### RFQ Management Flow
```
RFQ List → RFQ Details → Respond to RFQ
```

### Supplier-Only Screens
- `SupplierDashboardScreenNew` - Revenue, orders, analytics overview
- `ModernInventoryScreen` - Stock management
- `ModernAddEditProductScreen` - Product creation/editing
- `ProductsListScreen` - Supplier's product catalog
- `SupplierOrdersScreen` - Orders received from customers
- `ModernSupplierAnalyticsScreen` - Business analytics
- `SupplierNotificationCenterScreen` - Supplier notifications
-  `ModernRFQListScreen` / `ModernRFQDetailsScreen` - RFQ management

---

## Shared Screens

These screens are accessible to both customers and suppliers:

### Profile & Settings
- `ProfileScreen` / `ProfileScreenNew` - User profile
- `EditProfileScreen` - Edit profile information
- `ModernAddressesScreen` - Address management
- `ModernPaymentMethodsScreen` - Payment methods
- `SettingsScreen` - App settings
- `HelpCenterScreen` - Support and FAQs

### Messaging
- `MessagesListScreen` - Conversations list
- `ModernChatScreen` - Chat interface
- `ModernConversationsScreen` - Conversation management

### Notifications
- `ModernNotificationsScreen` - Notifications center

### Products (Browsing)
- `EnhancedHomeScreen` - Product discovery
- `CategoriesScreen` / `EnhancedCategoriesScreen` - Category browsing
- `CategoryProductsScreen` - Products in category
- `ProductDetailScreen` / `EnhancedProductDetailScreen` - Product details
- `AllProductsScreen` - All products listing
- `ModernProductReviewsScreen` - Product reviews
- `ModernSearchScreen` - Search functionality

### Orders (Viewing)
- `OrdersListScreen` - Order history
- `OrderDetailScreen` - Order details
- `OrderSuccessScreen` - Order confirmation

### Features
- `AnalyticsScreen` - Analytics (role-based data)
- `PremiumLoyaltyScreen` - Loyalty program
- `PremiumRecommendationsScreen` - Recommendations

---

## Role-Based Access Control Matrix

| Screen Category | Customer | Supplier | Admin | Notes |
|----------------|----------|----------|-------|-------|
| **Shopping** (Cart, Checkout, Wishlist) | ✅ | ❌ | ✅ | Customer-only |
| **Inventory Management** | ❌ | ✅ | ✅ | Supplier-only |
| **Supplier Analytics** | ❌ | ✅ | ✅ | Supplier-only |
| **Product Discovery** | ✅ | ✅ | ✅ | Shared |
| **Profile & Settings** | ✅ | ✅ | ✅ | Shared |
| **Messaging** | ✅ | ✅ | ✅ | Shared |
| **Order Viewing** | ✅ | ✅ | ✅ | Shared (different data) |

---

## Route Guard Implementation

### Public Routes (No Authentication)
- `/` (Splash)
- `/role-selection`
- `/login`
- `/register`

### Customer-Only Routes
- `/cart`
- `/wishlist`
- `/checkout-address`
- `/checkout-payment`
- `/deals`
- `/customer-dashboard`

### Supplier-Only Routes
- `/supplier-dashboard`
- `/supplier-inventory`
- `/supplier-products`
- `/supplier-analytics`
- `/supplier-add-product`
- `/supplier-edit-product`
- `/supplier-rfq`
- `/supplier-rfq-details`

### Shared Routes (All Authenticated Users)
- `/home`
- `/enhanced-home`
- `/categories`
- `/category-products`
- `/product-detail`
- `/all-products`
- `/profile`
- `/edit-profile`
- `/orders-list`
- `/order-detail`
- `/settings`
- `/messages`
- `/analytics`

---

## Navigation Logic

### After Successful Login
```dart
if (user.role == 'supplier') {
  navigate to '/home' (BottomNav with supplier tabs)
} else if (user.role == 'customer' || user.role == 'buyer') {
  navigate to '/home' (BottomNav with customer tabs)
} else {
  navigate to '/home' (default)
}
```

### Unauthorized Access Attempt
```dart
if (!RouteGuard.canAccessRoute(targetRoute, user.role)) {
  redirect to RouteGuard.getUnauthorizedRedirect(user.role)
  show SnackBar('You don\'t have permission to access this page')
}
```

### No Authentication
```dart
if (RouteGuard.requiresAuth(targetRoute) && !user.isAuthenticated) {
  redirect to '/login'
}
```

---

## Bottom Navigation Configuration

### Customer Bottom Nav
```dart
[
  DashboardTab (CustomerDashboardScreen),
  HomeTab (EnhancedHomeScreen),
  CategoriesTab (CategoriesScreen),
  CartTab (CartScreen) with badge,
  ProfileTab (ProfileScreen),
]
```

### Supplier Bottom Nav
```dart
[
  DashboardTab (SupplierDashboardScreen),
  ProductsTab (ModernInventoryScreen),
  OrdersTab (SupplierOrdersScreen),
  AnalyticsTab (ModernSupplierAnalyticsScreen),
  ProfileTab (ProfileScreen),
]
```

---

## API Endpoint Mapping

| Screen | Primary Endpoint | Role Required |
|--------|-----------------|---------------|
| Customer Dashboard | `GET /dashboard/customer` | customer |
| Supplier Dashboard | `GET /dashboard/supplier?days=30` | supplier |
| Orders List (Customer) | `GET /orders` | customer |
| Orders List (Supplier) | `GET /orders/supplier` | supplier |
| Product Management | `GET/POST/PUT/DELETE /products` | supplier |
| Inventory | `GET /products/supplier` | supplier |
| Analytics | `GET /dashboard/supplier` | supplier |

---

## Implementation Status

✅ **Completed**
- Screen identification and categorization
- RouteGuard utility class
- Dashboard service token fix
- Role-based route definitions

🟡 **In Progress**
- Route guard integration in generateRoute
- Bottom navigation role filtering
- Authentication enhancements

⏳ **Pending**
- Complete route guard testing
- Error flow documentation
- Admin role implementation

---

## Testing Checklist

### Customer Flow Testing
- [ ] Login as customer → see customer dashboard
- [ ] Browse products → add to cart → checkout
- [ ] View orders history
- [ ] Cannot access supplier-only screens
- [ ] Bottom nav shows correct tabs

### Supplier Flow Testing
- [ ] Login as supplier → see supplier dashboard
- [ ] Manage products → edit inventory
- [ ] View received orders
- [ ] View analytics
- [ ] Cannot access customer cart/checkout
- [ ] Bottom nav shows correct tabs

### Cross-Role Testing
- [ ] Both roles can access profile
- [ ] Both roles can use messaging
- [ ] Both roles can browse products
- [ ] Proper redirection on unauthorized access
- [ ] Logout works correctly for both roles
