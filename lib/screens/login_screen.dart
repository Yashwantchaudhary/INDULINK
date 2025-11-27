import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../services/crashlytics_service.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onSignUp;
  final VoidCallback onLogin;
  final VoidCallback? onForgotPassword;

  const LoginScreen({
    super.key,
    required this.onSignUp,
    required this.onLogin,
    this.onForgotPassword,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _showPassword = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    try {
      // Log login attempt
      await CrashlyticsService().logUserAction('login_attempt', parameters: {
        'login_method': 'email_password',
        'remember_me': _rememberMe,
      });

      final appState = Provider.of<AppState>(context, listen: false);
      final result = await appState.signInWithEmailPassword(_emailController.text, _passwordController.text);
      if (result) {
        // Log successful login
        await CrashlyticsService().logUserAction('login_success', parameters: {
          'login_method': 'email_password',
        });
        widget.onLogin();
      } else {
        // Log login failure
        await CrashlyticsService().logUserAction('login_failed', parameters: {
          'login_method': 'email_password',
          'error_message': appState.errorMessage,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(appState.errorMessage ?? 'Login failed')),
        );
      }
    } catch (e) {
      // Log login error
      await CrashlyticsService().logException(
        e,
        null,
        reason: 'Login error with email/password',
        information: {
          'login_method': 'email_password',
          'email_provided': _emailController.text.isNotEmpty,
        },
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    final isTablet = screenSize.width >= 600 && screenSize.width < 1024;
    final isDesktop = screenSize.width >= 1024;

    // Responsive dimensions
    final horizontalPadding = isDesktop ? 48.0 : isTablet ? 32.0 : 24.0;
    final verticalPadding = isDesktop ? 64.0 : isTablet ? 48.0 : 32.0;
    final maxWidth = isDesktop ? 500.0 : double.infinity;
    final logoSize = isDesktop ? 160.0 : isTablet ? 140.0 : 128.0;
    final titleFontSize = isDesktop ? 40.0 : isTablet ? 36.0 : 32.0;
    final subtitleFontSize = isDesktop ? 20.0 : isTablet ? 18.0 : 16.0;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1976D2), // blue-600
              Color(0xFF7C4DFF), // purple-600
              Color(0xFF1976D2), // blue-800
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background decoration - responsive positioning
            Positioned(
              top: isDesktop ? 120 : 80,
              left: isDesktop ? 64 : 32,
              child: Container(
                width: isDesktop ? 160 : 128,
                height: isDesktop ? 160 : 128,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
            if (!isMobile) ...[
              Positioned(
                top: isDesktop ? 200 : 160,
                right: isDesktop ? 32 : 16,
                child: Container(
                  width: isDesktop ? 120 : 96,
                  height: isDesktop ? 120 : 96,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
              Positioned(
                bottom: isDesktop ? 200 : 128,
                left: isDesktop ? 32 : 16,
                child: Container(
                  width: isDesktop ? 100 : 80,
                  height: isDesktop ? 100 : 80,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
            ],

            // Main content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
                  child: Container(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    margin: EdgeInsets.symmetric(horizontal: isMobile ? 16.0 : 0.0),
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: isDesktop ? 48 : 32),

                    // Logo
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: -20, end: 0),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, value),
                          child: Opacity(
                            opacity: 1 + (value / 20),
                            child: Container(
                              width: logoSize,
                              height: logoSize,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 32,
                                    spreadRadius: 8,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.home,
                                size: isDesktop ? 72 : isTablet ? 64 : 56,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: isDesktop ? 48 : 32),

                    // Welcome text
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 20, end: 0),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, value),
                          child: Opacity(
                            opacity: 1 - (value / 20),
                            child: Column(
                              children: [
                                Text(
                                  'Welcome Back',
                                  style: TextStyle(
                                    fontSize: titleFontSize,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: isDesktop ? 12 : 8),
                                Text(
                                  'Sign in to continue',
                                  style: TextStyle(
                                    fontSize: subtitleFontSize,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: isDesktop ? 64 : 48),

                    // Form
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 20, end: 0),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, value),
                          child: Opacity(
                            opacity: 1 - (value / 20),
                            child: Container(
                              constraints: BoxConstraints(maxWidth: maxWidth),
                              margin: EdgeInsets.symmetric(horizontal: isMobile ? 16.0 : 0.0),
                              child: Column(
                                children: [
                                  // Email Input
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.95),
                                      borderRadius: BorderRadius.circular(isDesktop ? 12 : 6),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.2),
                                      ),
                                    ),
                                    child: TextField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      style: TextStyle(
                                        color: const Color(0xFF1a1a1a),
                                        fontSize: isDesktop ? 18 : 16,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Email',
                                        hintStyle: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: isDesktop ? 18 : 16,
                                        ),
                                        prefixIcon: Icon(
                                          Icons.mail,
                                          color: Colors.grey[400],
                                          size: isDesktop ? 24 : 20,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: isDesktop ? 24 : 16,
                                          vertical: isDesktop ? 20 : 14,
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: isDesktop ? 20 : 16),

                                  // Password Input
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.95),
                                      borderRadius: BorderRadius.circular(isDesktop ? 12 : 6),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.2),
                                      ),
                                    ),
                                    child: TextField(
                                      controller: _passwordController,
                                      obscureText: !_showPassword,
                                      style: TextStyle(
                                        color: const Color(0xFF1a1a1a),
                                        fontSize: isDesktop ? 18 : 16,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Password',
                                        hintStyle: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: isDesktop ? 18 : 16,
                                        ),
                                        prefixIcon: Icon(
                                          Icons.lock,
                                          color: Colors.grey[400],
                                          size: isDesktop ? 24 : 20,
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _showPassword ? Icons.visibility_off : Icons.visibility,
                                            color: Colors.grey[400],
                                            size: isDesktop ? 24 : 20,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _showPassword = !_showPassword;
                                            });
                                          },
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: isDesktop ? 24 : 16,
                                          vertical: isDesktop ? 20 : 14,
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: isDesktop ? 20 : 16),

                                  // Remember & Forgot
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Checkbox(
                                            value: _rememberMe,
                                            onChanged: (value) {
                                              setState(() {
                                                _rememberMe = value ?? false;
                                              });
                                            },
                                            activeColor: Colors.white,
                                            checkColor: const Color(0xFF1976D2),
                                          ),
                                          Text(
                                            'Remember me',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: isDesktop ? 16 : 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                      TextButton(
                                        onPressed: widget.onForgotPassword,
                                        child: Text(
                                          'Forgot?',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: isDesktop ? 16 : 14,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: isDesktop ? 40 : 32),

                                  // Sign In Button
                                  SizedBox(
                                    width: double.infinity,
                                    height: isDesktop ? 60 : 50,
                                    child: ElevatedButton(
                                      onPressed: _handleSubmit,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: const Color(0xFF1976D2),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(isDesktop ? 12 : 6),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: Text(
                                        'SIGN IN',
                                        style: TextStyle(
                                          fontSize: isDesktop ? 18 : 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: isDesktop ? 32 : 24),

                                  // Divider
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          height: 1,
                                          color: Colors.white.withOpacity(0.3),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24 : 16),
                                        child: Text(
                                          'OR',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: isDesktop ? 16 : 14,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          height: 1,
                                          color: Colors.white.withOpacity(0.3),
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: isDesktop ? 32 : 24),

                                  // Google Sign In Button
                                  SizedBox(
                                    width: double.infinity,
                                    height: isDesktop ? 60 : 50,
                                    child: OutlinedButton.icon(
                                      onPressed: () async {
                                        try {
                                          // Log Google sign-in attempt
                                          await CrashlyticsService().logUserAction('login_attempt', parameters: {
                                            'login_method': 'google',
                                          });

                                          // Call Google Sign-In from AppState
                                          final appState = Provider.of<AppState>(context, listen: false);
                                          final result = await appState.signInWithGoogle();
                                          if (result) {
                                            // Log successful Google login
                                            await CrashlyticsService().logUserAction('login_success', parameters: {
                                              'login_method': 'google',
                                            });
                                            widget.onLogin();
                                          } else {
                                            // Log Google login failure
                                            await CrashlyticsService().logUserAction('login_failed', parameters: {
                                              'login_method': 'google',
                                              'error_message': appState.errorMessage,
                                            });
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text(appState.errorMessage ?? 'Google Sign-In failed')),
                                            );
                                          }
                                        } catch (e) {
                                          // Log Google sign-in error
                                          await CrashlyticsService().logException(
                                            e,
                                            null,
                                            reason: 'Google Sign-In error',
                                            information: {
                                              'login_method': 'google',
                                            },
                                          );
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Google Sign-In error: $e')),
                                          );
                                        }
                                      },
                                      icon: Image.asset(
                                        'assets/images/google_logo.png',
                                        width: isDesktop ? 24 : 20,
                                        height: isDesktop ? 24 : 20,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Icon(Icons.g_mobiledata, size: isDesktop ? 24 : 20, color: Colors.white);
                                        },
                                      ),
                                      label: Text(
                                        'Continue with Google',
                                        style: TextStyle(
                                          fontSize: isDesktop ? 18 : 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        side: const BorderSide(color: Colors.white, width: 1),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(isDesktop ? 12 : 6),
                                        ),
                                        backgroundColor: Colors.white.withOpacity(0.1),
                                        padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24 : 16),
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: isDesktop ? 40 : 32),

                                  // Sign Up Link
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Don't have account? ",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: isDesktop ? 16 : 14,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: widget.onSignUp,
                                        child: Text(
                                          'Sign Up',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: isDesktop ? 16 : 14,
                                            fontWeight: FontWeight.w600,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Forgot Password Link (if callback provided)
                                  if (widget.onForgotPassword != null) ...[
                                    SizedBox(height: isDesktop ? 20 : 16),
                                    Center(
                                      child: TextButton(
                                        onPressed: widget.onForgotPassword,
                                        child: Text(
                                          'Forgot Password?',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: isDesktop ? 16 : 14,
                                            fontWeight: FontWeight.w500,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],

                                  // Guest Access
                                  SizedBox(height: isDesktop ? 20 : 16),
                                  TextButton(
                                    onPressed: widget.onLogin,
                                    child: Text(
                                      'Continue as Guest',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isDesktop ? 16 : 14,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  ),
);
  }
}