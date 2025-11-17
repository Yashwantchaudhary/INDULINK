import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'routes/app_router.dart';
import 'routes/app_routes.dart';
import 'services/auth_service.dart';
import 'core/theme.dart';
import 'core/app_state.dart';

class HostelFinderApp extends StatelessWidget {
  const HostelFinderApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppState()),
        ChangeNotifierProxyProvider<AppState, AuthService>(
          create: (context) => AuthService(context.read<AppState>()),
          update: (context, appState, previous) => AuthService(appState),
        ),
      ],
      child: MaterialApp(
        title: 'Hostel Finder',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}