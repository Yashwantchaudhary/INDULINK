# Authentication & JWT Implementation Guide

## Overview

The INDULINK application uses JWT (JSON Web Token) based authentication with role-based access control for customers and suppliers.

## JWT Token Flow

### 1. Registration/Login
```
Client → POST /api/auth/register (or /login)
Server ← {
  success: true,
  data: {
    user: {...},
    accessToken: "ey...",
    refreshToken: "ey..."
  }
}
```

### 2. Token Storage
- **Access Token**: Stored in `SharedPreferences` with key `accessToken`
- **Refresh Token**: Stored in `SharedPreferences` with key `refreshToken`
- **User Data**: Stored in `SharedPreferences` with key `user` (JSON string)

### 3. Automatic Token Injection
`ApiService` automatically adds the token to every API request via interceptor:

```dart
// In ApiService interceptor
final token = await _getToken();
if (token != null) {
  options.headers['Authorization'] = 'Bearer $token';
}
```

### 4. Token Refresh
When a 401 error occurs, `ApiService` automatically attempts to refresh the token:

```dart
if (error.response?.statusCode == 401) {
  final refreshed = await _refreshToken();
  if (refreshed) {
    return handler.resolve(await _retry(error.requestOptions));
  }
}
```

## Authentication Components

### AuthService (`lib/services/auth_service.dart`)
Handles all authentication-related API calls:
- `register()` - User registration
- `login()` - User login
- `logout()` - User logout
- `refreshToken()` - Refresh access token
- `forgotPassword()` - Password reset request
- `resetPassword()` - Reset password with token
- `updatePassword()` - Change password (logged in)
- `getCurrentUser()` - Get current user data
- `isLoggedIn()` - Check if user has valid token

### AuthProvider (`lib/providers/auth_provider.dart`)
Riverpod state management for authentication:
- `AuthState` - Holds user, token, loading,  error states
- `checkAuthStatus()` - Validate token on app start
- `login()` - Handle login flow
- `register()` - Handle registration flow
- `logout()` - Clear auth state

### ApiService (`lib/services/api_service.dart`)
Centralized HTTP client with automatic:
- JWT token injection
- Token refresh on 401
- Error handling
- Request/response interceptors

## User Roles

### Backend Role Definition
The backend defines three roles in the User model:
```javascript
role: {
  type: String,
  enum: ['customer', 'supplier', 'admin'],
  default: 'customer',
},
```

### Frontend Role Handling
```dart
// Get user role
final userRole = ref.read(authProvider).user?.role;

// Check role
if (userRole == 'supplier') {
  // Supplier-specific logic
} else if (userRole == 'customer' || userRole == 'buyer') {
  // Customer-specific logic
}
```

## Role-Based Access Control

### RouteGuard Utility
Located in `lib/utils/route_guard.dart`, provides:

```dart
// Check if user can access route
bool canAccess = RouteGuard.canAccessRoute(route, userRole);

// Get default route for role
String defaultRoute = RouteGuard.getDefaultRoute(userRole);

// Get redirect for unauthorized access
String redirectRoute = RouteGuard.getUnauthorizedRedirect(user Role);

// Check if route requires authentication
bool needsAuth = RouteGuard.requiresAuth(route);
```

### Route Categories
- **Public Routes**: No authentication required (splash, login, register)
- **Shared Routes**: All authenticated users (profile, messages, product browsing)
- **Customer Routes**: Customer-only (cart, checkout, wishlist)
- **Supplier Routes**: Supplier-only (inventory, analytics, product management)

## Dashboard Integration

### Problem Solved
The customer dashboard was not loading because:
1. `DashboardService` was creating its own Dio instance
2. It tried to manually set tokens from `AuthState.token` (which doesn't exist)
3. Tokens weren't being passed to API requests

### Solution Implemented
1. Changed `DashboardService` to use `ApiService` instead of custom Dio
2. Removed manual token management (ApiService handles it automatically)
3. Simplified `dashboardServiceProvider` to just watch auth state changes

```dart
// Before (BROKEN)
class DashboardService {
  final Dio _dio;
  void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }
}

// After (WORKING)
class DashboardService {
  final ApiService _apiService;
  // No token management needed!
}
```

## Token Lifecycle

### App Start
```
1. App launches
2. AuthProvider.checkAuthStatus() called
3. Check if accessToken exists in SharedPreferences
4. If exists, get user data from SharedPreferences
5. Set isAuthenticated = true
6. Navigate to appropriate dashboard based on role
```

### During App Use
```
1. User makes API request (e.g., fetch dashboard)
2. ApiService intercept request
3. Add "Authorization: Bearer {token}" header
4. Send request
5. If 401 response → automatically refresh token
6. Retry original request with new token
```

### Token Expiration
```
1. Access token expires (typically 1hour)
2. API returns 401 Unauthorized
3. ApiService intercepts error
4. Calls /api/auth/refresh with refreshToken
5. Receives new accessToken
6. Updates SharedPreferences
7. Retries original request
```

### Logout
```
1. User clicks logout
2. Call /api/auth/logout (clears refresh token on server)
3. Clear local storage (accessToken, refreshToken, user)
4. Reset AuthState
5. Navigate to login screen
```

## Security Best Practices

### Implemented ✅
- JWT tokens stored in SharedPreferences (secure on mobile)
- Automatic token refresh prevents frequent re-login
- Refresh tokens separate from access tokens
- Role validation on backend (authMiddleware)
- HTTPS enforced in production

### Recommended Enhancements 🔄
- [ ] Token expiration checking before API calls
- [ ] Logout on multiple failed refresh attempts
- [ ] Biometric authentication option
- [ ] Token encryption in storage
- [ ] Rate limiting for login attempts

## API Endpoints

### Authentication Endpoints
```
POST /api/auth/register    - Register new user
POST /api/auth/login       - Login user
POST /api/auth/logout      - Logout user
POST /api/auth/refresh     - Refresh access token
POST /api/auth/forgot-password - Request password reset
POST /api/auth/reset-password  - Reset password with token
PUT  /api/auth/update-password - Change password (authenticated)
GET  /api/auth/me          - Get current user
```

### Protected Endpoints
All other endpoints require authentication header:
```
Authorization: Bearer {accessToken}
```

Backend middleware checks:
1. Token presence
2. Token validity
3. User exists and is active
4. User role (for role-specific endpoints)

## Error Handling

### Authentication Errors
- `401 Unauthorized` - Invalid/expired token → auto-refresh
- `403 Forbidden` - Insufficient permissions → show error
- `Network error` - Connection issues → retry prompt

### User Feedback
```dart
// In AuthProvider
if (!success) {
  state = state.copyWith(
    error: result['message'] ?? 'Login failed',
    isLoading: false,
  );
}
```

## Testing Authentication

### Manual Testing Steps
1. **Registration**
   ```
   - Open app
   - Tap "Sign Up"
   - Fill form with customer role
   - Verify accessToken saved
   - Verify navigation to customer dashboard
   ```

2.**Login**
   ```
   - Enter credentials
   - Verify token received
   - Verify user  data stored
   - Check role-appropriate navigation
   ```

3. **Token Refresh**
   ```
   - Wait for token expiration (or modify backend to short expiry)
   - Make API request
   - Verify automatic refresh
   - Verify request succeeds
   ```

4. **Logout**
   ```
   - Click logout
   - Verify tokens cleared
   - Verify navigation to login
   - Verify cannot access protected screens
   ```

## Troubleshooting

### Dashboard not loading
✅ **FIXED**: Use ApiService instead of custom Dio instance

### 401 errors not auto-refreshing
- Check `ApiService` interceptor is registered
- Verify refresh token exists in SharedPreferences
- Check backend /auth/refresh endpoint

### Wrong dashboard showing
- Verify user.role in backend response
- Check role comparison logic (customer vs buyer)
- Review RouteGuard.getDefaultRoute()

### Token persists after logout
- Ensure AuthService._clearStorage() is called
- Check SharedPreferences.remove() for all keys
- Verify backend clears refresh token

## Code Examples

### Check Authentication Status
```dart
final authState = ref.watch(authProvider);
if (authState.isAuthenticated) {
  // User is logged in
  final userName = authState.user?.firstName;
  final userRole = authState.user?.role;
}
```

### Make Authenticated API Request
```dart
// ApiService automatically adds token!
final response = await ApiService().get('/dashboard/customer');
```

### Handle Login
```dart
final success = await ref.read(authProvider.notifier).login(
  email,
  password,
  role: 'customer',
);

if (success) {
  Navigator.pushReplacement(...);
}
```

### Protect a Route
```dart
if (!RouteGuard.canAccessRoute(route, userRole)) {
  return RouteGuard.getUnauthorizedRedirect(userRole);
}
```

## Next Steps

1. Complete bottom_nav.dart role-based tab filtering
2. Add route guards to routes.dart
3. Test customer and supplier flows
4. Implement token expiration checking
5. Add role-based menu items in profile
6. Document admin role implementation
