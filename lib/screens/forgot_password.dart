import 'package:flutter/material.dart';
import '../services/firebase_api_service.dart';
import 'sms_verification.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onResetSuccess;

  const ForgotPasswordScreen({
    super.key,
    required this.onBack,
    required this.onResetSuccess,
  });

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  bool _useEmail = true; // Toggle between email and phone reset

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    if (_useEmail && email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email address')),
      );
      return;
    }

    if (!_useEmail && phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your phone number')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_useEmail) {
        // Email reset
        final result = await FirebaseApiService.sendPasswordResetEmail(email);
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password reset email sent! Check your inbox.'),
              duration: Duration(seconds: 4),
            ),
          );
          widget.onResetSuccess();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Failed to send reset email')),
          );
        }
      } else {
        // Phone reset - send SMS verification
        final result = await FirebaseApiService.verifyPhoneNumber(phone);
        if (result['success'] == true) {
          final verificationId = result['verificationId'];
          // Navigate to SMS verification screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SmsVerificationScreen(
                phoneNumber: phone,
                verificationId: verificationId,
                onVerificationSuccess: () async {
                  // After SMS verification, reset password
                  final resetResult = await FirebaseApiService.resetPasswordWithPhone(phone, 'new_password_placeholder');
                  if (resetResult['success'] == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password reset successfully!')),
                    );
                    widget.onResetSuccess();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(resetResult['message'] ?? 'Password reset failed')),
                    );
                  }
                },
                onBack: () => Navigator.pop(context),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Failed to send SMS')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1976D2),
              Color(0xFF7C4DFF),
              Color(0xFF1976D2),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Back button
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    onPressed: widget.onBack,
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_reset,
                    color: Colors.white,
                    size: 40,
                  ),
                ),

                const SizedBox(height: 32),

                // Title
                const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Subtitle
                const Text(
                  'No worries! Enter your email or phone number\nand we\'ll send you reset instructions.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 48),

                // Method Toggle
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _useEmail = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _useEmail ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Email',
                              style: TextStyle(
                                color: _useEmail ? const Color(0xFF1976D2) : Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _useEmail = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !_useEmail ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Phone',
                              style: TextStyle(
                                color: !_useEmail ? const Color(0xFF1976D2) : Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Input Field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _useEmail ? _emailController : _phoneController,
                    keyboardType: _useEmail ? TextInputType.emailAddress : TextInputType.phone,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: _useEmail ? 'Enter your email' : 'Enter your phone number',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      prefixIcon: Icon(
                        _useEmail ? Icons.email : Icons.phone,
                        color: Colors.grey[400],
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Reset Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleReset,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1976D2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : Text(
                            _useEmail ? 'Send Reset Email' : 'Send SMS Code',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                // Back to Login
                TextButton(
                  onPressed: widget.onBack,
                  child: const Text(
                    'Back to Login',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Help text
                Text(
                  _useEmail
                      ? 'We\'ll send a password reset link to your email'
                      : 'We\'ll send a 6-digit code to verify your phone',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}