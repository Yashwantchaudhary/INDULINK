import '../routes.dart';

/// Route guard utility for role-based access control
///
/// Defines which routes are accessible to which user roles and provides
/// validation methods for ensuring users can only access authorized screens.
class RouteGuard {
  // Customer-only routes (shopping, cart, wishlist, checkout)
  static const List<String> customerOnlyRoutes = [
    AppRoutes.cart,
    AppRoutes.wishlist,
    AppRoutes.checkoutAddress,
    AppRoutes.checkoutPayment,
    AppRoutes.deals,
    AppRoutes.customerDashboard,
  ];

  // Supplier-only routes (inventory, analytics, products management)
  static const List<String> supplierOnlyRoutes = [
    AppRoutes.supplierDashboard,
    '/supplier-inventory',
    '/supplier-products',
    '/supplier-analytics',
    '/supplier-add-product',
    '/supplier-edit-product',
    '/supplier-rfq',
    '/supplier-rfq-details',
  ];

  // Shared routes (accessible to both customers and suppliers)
  static const List<String> sharedRoutes = [
    AppRoutes.home,
    AppRoutes.enhancedHome,
    AppRoutes.categories,
    AppRoutes.categoryProducts,
    AppRoutes.productDetail,
    AppRoutes.allProducts,
    AppRoutes.profile,
    AppRoutes.editProfile,
    AppRoutes.orderDetail,
    AppRoutes.ordersList,
    AppRoutes.settings,
    AppRoutes.messages,
    AppRoutes.analytics,
  ];

  // Public routes (no authentication required)
  static const List<String> publicRoutes = [
    AppRoutes.splash,
    AppRoutes.roleSelection,
    AppRoutes.login,
    AppRoutes.register,
  ];

  /// Check if a user with given role can access a route
  ///
  /// Returns true if:
  /// - Route is public
  /// - Route is shared
  /// - User's role matches the route's requirement
  static bool canAccessRoute(String route, String? userRole) {
    // Public routes are always accessible
    if (publicRoutes.contains(route)) {
      return true;
    }

    // If no user role, can only access public routes
    if (userRole == null) {
      return false;
    }

    // Admin can access everything
    if (userRole == 'admin') {
      return true;
    }

    // Shared routes accessible to all authenticated users
    if (sharedRoutes.contains(route)) {
      return true;
    }

    // Check customer-only routes
    if (customerOnlyRoutes.contains(route)) {
      return userRole == 'customer' || userRole == 'buyer';
    }

    // Check supplier-only routes
    if (supplierOnlyRoutes.contains(route)) {
      return userRole == 'supplier';
    }

    // If route is not categorized, allow access (fail-open for new routes)
    return true;
  }

  /// Get the appropriate redirect route for a user role
  ///
  /// Returns the home screen appropriate for the user's role
  static String getDefaultRoute(String? userRole) {
    if (userRole == null) {
      return AppRoutes.login;
    }

    switch (userRole) {
      case 'supplier':
        return AppRoutes.supplierDashboard;
      case 'customer':
      case 'buyer':
        return AppRoutes.customerDashboard;
      case 'admin':
        return AppRoutes.home;
      default:
        return AppRoutes.home;
    }
  }

  /// Get fallback route when access is denied
  ///
  /// Redirects to the appropriate dashboard based on user role
  static String getUnauthorizedRedirect(String? userRole) {
    return getDefaultRoute(userRole);
  }

  /// Check if route requires authentication
  static bool requiresAuth(String route) {
    return !publicRoutes.contains(route);
  }

  /// Get route category for logging/debugging
  static String getRouteCategory(String route) {
    if (publicRoutes.contains(route)) return 'public';
    if (sharedRoutes.contains(route)) return 'shared';
    if (customerOnlyRoutes.contains(route)) return 'customer-only';
    if (supplierOnlyRoutes.contains(route)) return 'supplier-only';
    return 'uncategorized';
  }
}
