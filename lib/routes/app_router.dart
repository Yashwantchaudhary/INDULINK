import 'package:flutter/material.dart';
import 'app_routes.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/forgot_password.dart' as forgot_password;
import '../screens/email_verification.dart';
import '../screens/admin_dashboard.dart';
import '../screens/host_dashboard.dart';
import '../screens/parent_dashboard.dart';
import '../screens/booking_history.dart';
import '../screens/booking_flow.dart';
import '../screens/notification_settings.dart';
import '../screens/profile.dart';
import '../screens/listings.dart';
import '../screens/booking.dart';
import '../screens/analytics.dart';
import '../screens/onboarding.dart';
import '../screens/app_settings.dart';
import '../screens/student_dashboard.dart';
import '../screens/chat_messages.dart';
import '../screens/host_verification.dart';
import '../screens/interactive_map_view.dart';
import '../screens/account_payments.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(
          builder: (context) => SplashScreen(
            onComplete: () {
              Navigator.of(context).pushReplacementNamed(AppRoutes.login);
            },
          ),
        );
      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (context) => LoginScreen(
            onLogin: () {
              Navigator.of(context).pushReplacementNamed(AppRoutes.home);
            },
            onSignUp: () {
              Navigator.of(context).pushNamed(AppRoutes.signup);
            },
          ),
        );
      case AppRoutes.signup:
        return MaterialPageRoute(
          builder: (context) => SignupScreen(
            onSignUp: (role) {
              Navigator.of(context).pushReplacementNamed(AppRoutes.home);
            },
            onSignIn: () {
              Navigator.of(context).pushReplacementNamed(AppRoutes.login);
            },
          ),
        );
      case AppRoutes.forgotPassword:
        return MaterialPageRoute(
          builder: (context) => forgot_password.ForgotPasswordScreen(
            onBack: () {
              Navigator.of(context).pop();
            },
            onResetSuccess: () {
              Navigator.of(context).pushReplacementNamed(AppRoutes.login);
            },
          ),
        );
      case AppRoutes.emailVerification:
        return MaterialPageRoute(
          builder: (context) => EmailVerification(
            onVerified: () {
              Navigator.of(context).pushReplacementNamed(AppRoutes.home);
            },
            onBack: () {
              Navigator.of(context).pop();
            },
          ),
        );
      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (context) => StudentDashboard(
            onLogout: () {
              Navigator.of(context).pushReplacementNamed(AppRoutes.login);
            },
            onNavigateToSearch: () {
              // Navigate to search screen
            },
            onNavigateToBooking: () {
              Navigator.of(context).pushNamed(AppRoutes.bookingFlow);
            },
            onNavigateToChat: () {
              Navigator.of(context).pushNamed(AppRoutes.chatMessages);
            },
            onNavigateToProfile: () {
              Navigator.of(context).pushNamed(AppRoutes.profile);
            },
            onNavigateToAI: () {
              // Navigate to AI assistant
            },
            onNavigateToMap: () {
              Navigator.of(context).pushNamed(AppRoutes.interactiveMapView);
            },
            onNavigateToAccountPayments: () {
              Navigator.of(context).pushNamed(AppRoutes.accountPayments);
            },
            onNavigateToWishlist: () {
              // Navigate to wishlist screen - could be a separate screen or tab
            },
            onNavigateToBookingHistory: () {
              Navigator.of(context).pushNamed(AppRoutes.bookingHistory);
            },
          ),
        );
      case AppRoutes.hostDashboard:
        return MaterialPageRoute(
          builder: (context) => HostDashboard(
            onLogout: () {
              Navigator.of(context).pushReplacementNamed(AppRoutes.login);
            },
          ),
        );
      case AppRoutes.parentDashboard:
        return MaterialPageRoute(
          builder: (context) => ParentDashboard(
            onBack: () {
              Navigator.of(context).pop();
            },
          ),
        );
      case AppRoutes.adminDashboard:
        return MaterialPageRoute(
          builder: (context) => AdminDashboard(
            onBack: () {
              Navigator.of(context).pop();
            },
          ),
        );
      case AppRoutes.dashboard:
        return MaterialPageRoute(
          builder: (context) => AdminDashboard(
            onBack: () {
              Navigator.of(context).pop();
            },
          ),
        );
      case AppRoutes.profile:
        return MaterialPageRoute(
          builder: (context) => ProfileScreen(
            onBack: () {
              Navigator.of(context).pop();
            },
          ),
        );
      case AppRoutes.accountPayments:
        return MaterialPageRoute(
          builder: (context) => AccountPaymentsScreen(),
        );
      case AppRoutes.bookingHistory:
        return MaterialPageRoute(
          builder: (context) => BookingHistory(
            onBack: () {
              Navigator.of(context).pop();
            },
            onBookAgain: () {
              // Handle book again
            },
            onChat: () {
              // Handle chat
            },
          ),
        );
      case AppRoutes.bookingFlow:
        return MaterialPageRoute(
          builder: (context) => BookingFlow(
            onBack: () {
              Navigator.of(context).pop();
            },
            onNavigateToPayment: () {
              Navigator.of(context).pushNamed(AppRoutes.accountPayments);
            }
          )
        );
      case AppRoutes.notificationSettings:
        return MaterialPageRoute(
          builder: (context) => NotificationSettings(
            onBack: () {
              Navigator.of(context).pop();
            },
          ),
        );
      case AppRoutes.analytics:
        return MaterialPageRoute(
          builder: (context) => AnalyticsScreen(
            onBack: () {
              Navigator.of(context).pop();
            },
          ),
        );
      case AppRoutes.listings:
        return MaterialPageRoute(
          builder: (context) => ListingsScreen(
            onBack: () {
              Navigator.of(context).pop();
            },
          ),
        );
      case AppRoutes.booking:
        return MaterialPageRoute(
          builder: (context) => BookingScreen(
            onBack: () {
              Navigator.of(context).pop();
            },
          ),
        );
      case AppRoutes.onboarding:
        return MaterialPageRoute(
          builder: (context) => OnboardingFlow(
            onComplete: () {
              Navigator.of(context).pushReplacementNamed(AppRoutes.login);
            },
          ),
        );
      case AppRoutes.appSettings:
        return MaterialPageRoute(
          builder: (context) => AppSettings(
            onBack: () {
              Navigator.of(context).pop();
            },
            onLogout: () {
              Navigator.of(context).pushReplacementNamed(AppRoutes.login);
            },
          ),
        );
      case AppRoutes.studentDashboard:
        return MaterialPageRoute(
          builder: (context) => StudentDashboard(
            onLogout: () {
              Navigator.of(context).pushReplacementNamed(AppRoutes.login);
            },
            onNavigateToSearch: () {
              // Navigate to search screen
            },
            onNavigateToBooking: () {
              Navigator.of(context).pushNamed(AppRoutes.bookingFlow);
            },
            onNavigateToChat: () {
               Navigator.of(context).pushNamed(AppRoutes.chatMessages);
             },
            onNavigateToProfile: () {
              Navigator.of(context).pushNamed(AppRoutes.profile);
            },
            onNavigateToAI: () {
               // Navigate to AI assistant
             },
             onNavigateToMap: () {
               Navigator.of(context).pushNamed(AppRoutes.interactiveMapView);
             },
            onNavigateToAccountPayments: () {
              Navigator.of(context).pushNamed(AppRoutes.accountPayments);
            },
            onNavigateToWishlist: () {
               // Navigate to wishlist screen - could be a separate screen or tab
             },
            onNavigateToBookingHistory: () {
              Navigator.of(context).pushNamed(AppRoutes.bookingHistory);
            },
          ),
        );
      case AppRoutes.chatMessages:
        return MaterialPageRoute(
          builder: (context) => ChatMessages(
            onBack: () {
              Navigator.of(context).pop();
            },
          ),
        );
      case AppRoutes.hostVerification:
        return MaterialPageRoute(
          builder: (context) => HostVerification(
            onBack: () {
              Navigator.of(context).pop();
            },
            onVerified: () {
              Navigator.of(context).pushReplacementNamed(AppRoutes.hostDashboard);
            },
          ),
        );
      case AppRoutes.interactiveMapView:
        return MaterialPageRoute(
          builder: (context) => InteractiveMapView(
            onBack: () {
              Navigator.of(context).pop();
            },
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}