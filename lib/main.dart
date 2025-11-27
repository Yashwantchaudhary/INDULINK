import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme_provider.dart';
import 'core/app_state.dart';
import 'services/notification_service.dart';
import 'services/analytics_service.dart';
import 'services/crashlytics_service.dart';
import 'services/performance_service.dart';
import 'services/remote_config_service.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/student_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase first
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase initialized successfully in main.dart');
  } catch (e) {
    debugPrint('❌ Firebase initialization failed in main.dart: $e');
  }

  // Initialize Firebase Performance after Firebase core
  try {
    await PerformanceService.initialize();
    debugPrint('✅ Firebase Performance initialized successfully');
  } catch (e) {
    debugPrint('❌ Firebase Performance initialization failed: $e');
  }

  // Initialize Firebase Crashlytics after Firebase core
  try {
    await CrashlyticsService.initialize();
    debugPrint('✅ Firebase Crashlytics initialized successfully');
  } catch (e) {
    debugPrint('❌ Firebase Crashlytics initialization failed: $e');
  }

  // Initialize Firebase Analytics after Firebase core
  try {
    await AnalyticsService.initialize();
    debugPrint('✅ Firebase Analytics initialized successfully');
  } catch (e) {
    debugPrint('❌ Firebase Analytics initialization failed: $e');
  }

  // Initialize Firebase Remote Config after Firebase core
  try {
    await RemoteConfigService.initialize();
    debugPrint('✅ Firebase Remote Config initialized successfully');
  } catch (e) {
    debugPrint('❌ Firebase Remote Config initialization failed: $e');
  }

  // Initialize notifications after Firebase
  await NotificationService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Hostel Finder',
            theme: themeProvider.currentTheme,
            home: LoginScreen(
              onSignUp: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SignupScreen(
                      onSignIn: () {
                        Navigator.of(context).pop(); // Go back to login
                      },
                      onSignUp: (role) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => StudentDashboard(
                            onLogout: () {
                              // Handle logout - go back to login
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (context) => LoginScreen(
                                  onSignUp: () {},
                                  onLogin: () {},
                                )),
                              );
                            },
                          )),
                        );
                      },
                    ),
                  ),
                );
              },
              onLogin: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => StudentDashboard(
                    onLogout: () {
                      // Handle logout - go back to login
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => LoginScreen(
                          onSignUp: () {},
                          onLogin: () {},
                        )),
                      );
                    },
                  )),
                );
              },
            ),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
