import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';

enum UserRole { student, host }

class SignupScreen extends StatefulWidget {
  final VoidCallback onSignIn;
  final Function(UserRole?) onSignUp;

  const SignupScreen({
    super.key,
    required this.onSignIn,
    required this.onSignUp,
  });

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  UserRole? _selectedRole;
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _acceptTerms = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    // Validation
    if (_fullNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your role')),
      );
      return;
    }

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the terms and conditions')),
      );
      return;
    }

    // Show loading
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Creating account...')),
    );

    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final result = await appState.signUpWithEmailPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _fullNameController.text.trim(),
        role: _selectedRole == UserRole.student ? 'student' : 'host',
      );

      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully!')),
        );
        widget.onSignUp(_selectedRole);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(appState.errorMessage ?? 'Signup failed')),
        );
      }
    } catch (e) {
      debugPrint('Signup error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signup error: ${e.toString()}')),
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
    final maxWidth = isDesktop ? 900.0 : isTablet ? 700.0 : 375.0;
    final horizontalMargin = isDesktop ? 64.0 : isTablet ? 48.0 : 16.0;
    final horizontalPadding = isDesktop ? 48.0 : isTablet ? 32.0 : 24.0;
    final verticalPadding = isDesktop ? 48.0 : isTablet ? 40.0 : 32.0;
    final logoSize = isDesktop ? 100.0 : isTablet ? 90.0 : 80.0;
    final titleFontSize = isDesktop ? 32.0 : isTablet ? 28.0 : 24.0;
    final subtitleFontSize = isDesktop ? 18.0 : isTablet ? 17.0 : 16.0;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF7C4DFF), // purple-600
              Color(0xFF1976D2), // blue-600
              Color(0xFFFF6B35), // orange-500
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background decoration - responsive positioning
            Positioned(
              top: isDesktop ? 80 : 64,
              right: isDesktop ? 48 : 32,
              child: Container(
                width: isDesktop ? 120 : 96,
                height: isDesktop ? 120 : 96,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
            if (!isMobile) ...[
              Positioned(
                top: isDesktop ? 160 : 128,
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
              Positioned(
                bottom: isDesktop ? 200 : 160,
                right: isDesktop ? 32 : 24,
                child: Container(
                  width: isDesktop ? 80 : 64,
                  height: isDesktop ? 80 : 64,
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
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: isDesktop ? 24 : 16),

                    // Header
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: -20, end: 0),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, value),
                          child: Opacity(
                            opacity: 1 + (value / 20),
                            child: Column(
                              children: [
                                Container(
                                  width: logoSize,
                                  height: logoSize,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(50),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
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
                                    Icons.person,
                                    size: isDesktop ? 50 : isTablet ? 45 : 40,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: isDesktop ? 20 : 16),
                                Text(
                                  'Join Hostel Finder',
                                  style: TextStyle(
                                    fontSize: titleFontSize,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: isDesktop ? 8 : 4),
                                Text(
                                  'Create account to start',
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

                    SizedBox(height: isDesktop ? 40 : 32),

                    // Google Sign Up
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 20, end: 0),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, value),
                          child: Opacity(
                            opacity: 1 - (value / 20),
                            child: SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  // Show loading
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Signing in with Google...')),
                                  );

                                  try {
                                    // Call Google Sign-In from AppState
                                    final appState = Provider.of<AppState>(context, listen: false);
                                    final result = await appState.signInWithGoogle();
                                    if (result) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Google Sign-In successful!')),
                                      );
                                      widget.onSignUp(null); // Navigate to dashboard
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(appState.errorMessage ?? 'Google Sign-In failed')),
                                      );
                                    }
                                  } catch (e) {
                                    debugPrint('Google Sign-In error: $e');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Google Sign-In error: ${e.toString()}')),
                                    );
                                  }
                                },
                                icon: Image.asset(
                                  'assets/images/google_logo.png',
                                  width: 20,
                                  height: 20,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.g_mobiledata, size: 20, color: Colors.white);
                                  },
                                ),
                                label: const Text(
                                  'Continue with Google',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.white, width: 1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  backgroundColor: Colors.white.withOpacity(0.1),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Divider
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'or',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
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
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Role Selection
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
                                const Text(
                                  'I am a:',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedRole = UserRole.student;
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: _selectedRole == UserRole.student
                                                ? Colors.white
                                                : Colors.white.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: _selectedRole == UserRole.student
                                                  ? Colors.white
                                                  : Colors.white.withOpacity(0.3),
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              Icon(
                                                Icons.school,
                                                size: 32,
                                                color: _selectedRole == UserRole.student
                                                    ? const Color(0xFF1976D2)
                                                    : Colors.white,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'STUDENT',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: _selectedRole == UserRole.student
                                                      ? const Color(0xFF1976D2)
                                                      : Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedRole = UserRole.host;
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: _selectedRole == UserRole.host
                                                ? Colors.white
                                                : Colors.white.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: _selectedRole == UserRole.host
                                                  ? Colors.white
                                                  : Colors.white.withOpacity(0.3),
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              Icon(
                                                Icons.home,
                                                size: 32,
                                                color: _selectedRole == UserRole.host
                                                    ? const Color(0xFF1976D2)
                                                    : Colors.white,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'HOST',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: _selectedRole == UserRole.host
                                                      ? const Color(0xFF1976D2)
                                                      : Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),

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
                            child: Column(
                              children: [
                                // Full Name
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.95),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                    ),
                                  ),
                                  child: TextField(
                                    controller: _fullNameController,
                                    style: const TextStyle(
                                      color: Color(0xFF1a1a1a),
                                      fontSize: 16,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Full Name',
                                      hintStyle: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 16,
                                      ),
                                      prefixIcon: Icon(
                                        Icons.person,
                                        color: Colors.grey[400],
                                        size: 20,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Email
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.95),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                    ),
                                  ),
                                  child: TextField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    style: const TextStyle(
                                      color: Color(0xFF1a1a1a),
                                      fontSize: 16,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Email',
                                      hintStyle: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 16,
                                      ),
                                      prefixIcon: Icon(
                                        Icons.mail,
                                        color: Colors.grey[400],
                                        size: 20,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Phone
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.95),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                    ),
                                  ),
                                  child: TextField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    style: const TextStyle(
                                      color: Color(0xFF1a1a1a),
                                      fontSize: 16,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Phone',
                                      hintStyle: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 16,
                                      ),
                                      prefixIcon: Icon(
                                        Icons.phone,
                                        color: Colors.grey[400],
                                        size: 20,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Password
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.95),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                    ),
                                  ),
                                  child: TextField(
                                    controller: _passwordController,
                                    obscureText: !_showPassword,
                                    style: const TextStyle(
                                      color: Color(0xFF1a1a1a),
                                      fontSize: 16,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Password',
                                      hintStyle: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 16,
                                      ),
                                      prefixIcon: Icon(
                                        Icons.lock,
                                        color: Colors.grey[400],
                                        size: 20,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _showPassword ? Icons.visibility_off : Icons.visibility,
                                          color: Colors.grey[400],
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _showPassword = !_showPassword;
                                          });
                                        },
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Confirm Password
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.95),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                    ),
                                  ),
                                  child: TextField(
                                    controller: _confirmPasswordController,
                                    obscureText: !_showConfirmPassword,
                                    style: const TextStyle(
                                      color: Color(0xFF1a1a1a),
                                      fontSize: 16,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Confirm Password',
                                      hintStyle: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 16,
                                      ),
                                      prefixIcon: Icon(
                                        Icons.lock,
                                        color: Colors.grey[400],
                                        size: 20,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _showConfirmPassword ? Icons.visibility_off : Icons.visibility,
                                          color: Colors.grey[400],
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _showConfirmPassword = !_showConfirmPassword;
                                          });
                                        },
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Terms Checkbox
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Checkbox(
                                      value: _acceptTerms,
                                      onChanged: (value) {
                                        setState(() {
                                          _acceptTerms = value ?? false;
                                        });
                                      },
                                      activeColor: Colors.white,
                                      checkColor: const Color(0xFF1976D2),
                                    ),
                                    Expanded(
                                      child: Text(
                                        'I agree to Terms & Privacy Policy',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 14,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 32),

                                // Create Account Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: _handleSubmit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: const Color(0xFF1976D2),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Text(
                                      'CREATE ACCOUNT',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Sign In Link
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Already have account? ',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 14,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: widget.onSignIn,
                                      child: const Text(
                                        'Sign In',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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