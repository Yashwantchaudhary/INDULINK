import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firebase_api_service.dart';
import '../services/analytics_service.dart';
import '../core/theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onBack;

  const ProfileScreen({super.key, required this.onBack});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool notifications = true;
  bool locationSharing = false;

  Map<String, dynamic> userProfile = {
    'name': 'Loading...',
    'email': 'Loading...',
    'phone': 'Loading...',
    'avatar': 'https://via.placeholder.com/150x150?text=Loading',
    'profileCompletion': 0
  };

  late final List<Map<String, dynamic>> accountSettings;
  late final List<Map<String, dynamic>> safetySettings;
  late final List<Map<String, dynamic>> appSettings;

  @override
  void initState() {
    super.initState();
    // Track screen view
    AnalyticsService().logScreenView(screenName: 'Profile Screen');
    _loadUserProfile();

    accountSettings = [
      {'icon': Icons.lock, 'title': 'Change Password', 'subtitle': 'Update your password'},
      {'icon': Icons.visibility, 'title': 'Privacy Settings', 'subtitle': 'Control your privacy'},
      {'icon': Icons.notifications, 'title': 'Notification Preferences', 'subtitle': 'Manage notifications'},
      {'icon': Icons.language, 'title': 'Language', 'subtitle': 'English', 'hasValue': true}
    ];

    safetySettings = [
      {'icon': Icons.phone, 'title': 'Emergency Contacts', 'subtitle': '2 contacts added'},
      {'icon': Icons.security, 'title': 'Two-Factor Authentication', 'subtitle': 'Add extra security'},
    ];

    appSettings = [
      {'icon': Icons.storage, 'title': 'Data Usage', 'subtitle': 'Manage app data'},
      {'icon': Icons.cleaning_services, 'title': 'Clear Cache', 'subtitle': '124 MB cached data'}
    ];
  }

  Future<void> _loadUserProfile() async {
    try {
      final result = await FirebaseApiService.getCurrentUserProfile();
      if (result['success'] == true) {
        final userData = result['data'] as Map<String, dynamic>;
        setState(() {
          userProfile = {
            'name': userData['name'] ?? 'Unknown User',
            'email': userData['email'] ?? 'No email',
            'phone': userData['phone'] ?? 'No phone',
            'avatar': userData['profileImage'] ?? 'https://via.placeholder.com/150x150?text=No+Image',
            'profileCompletion': _calculateProfileCompletion(userData),
          };
        });
      } else {
        setState(() {
          userProfile = {
            'name': 'Error loading profile',
            'email': result['message'] ?? 'Failed to load profile',
            'phone': '',
            'avatar': 'https://via.placeholder.com/150x150?text=Error',
            'profileCompletion': 0,
          };
        });
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
      setState(() {
        userProfile = {
          'name': 'Error loading profile',
          'email': 'Please check your connection',
          'phone': '',
          'avatar': 'https://via.placeholder.com/150x150?text=Error',
          'profileCompletion': 0,
        };
      });
    }
  }

  int _calculateProfileCompletion(Map<String, dynamic> userData) {
    int completion = 0;
    if (userData['name']?.isNotEmpty == true) completion += 25;
    if (userData['email']?.isNotEmpty == true) completion += 25;
    if (userData['phone']?.isNotEmpty == true) completion += 25;
    if (userData['profileImage']?.isNotEmpty == true) completion += 25;
    return completion;
  }


  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: userProfile['name']);
    final phoneController = TextEditingController(text: userProfile['phone']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                hintText: 'Enter your full name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                hintText: 'Enter your phone number',
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final updatedData = {
                'name': nameController.text.trim(),
                'phone': phoneController.text.trim(),
              };

              try {
                final result = await FirebaseApiService.updateUserProfile(updatedData);
                if (result['success'] == true) {
                  // Reload profile data
                  await _loadUserProfile();
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile updated successfully')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result['message'] ?? 'Failed to update profile')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error updating profile: $e')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    final isTablet = screenSize.width >= 600 && screenSize.width < 1024;
    final isDesktop = screenSize.width >= 1024;

    // Responsive dimensions
    final maxWidth = isDesktop ? 1200.0 : isTablet ? 800.0 : double.infinity;
    final horizontalMargin = isDesktop ? 64.0 : isTablet ? 48.0 : 16.0;
    final verticalMargin = isDesktop ? 32.0 : isTablet ? 24.0 : 16.0;
    final contentPadding = isDesktop ? 32.0 : isTablet ? 24.0 : 16.0;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        constraints: BoxConstraints(maxWidth: maxWidth),
        margin: EdgeInsets.symmetric(horizontal: horizontalMargin, vertical: verticalMargin),
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
        child: Column(
          children: [
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
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color(0xFF1976D2),
                            Color(0xFF7C4DFF),
                          ],
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                onPressed: widget.onBack,
                                icon: Icon(Icons.arrow_back, color: Colors.white, size: isDesktop ? 28 : isTablet ? 24 : 20),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                                  padding: EdgeInsets.all(isDesktop ? 16 : isTablet ? 12 : 8),
                                ),
                              ),
                              SizedBox(width: isDesktop ? 16 : isTablet ? 12 : 8),
                              Text(
                                'Profile & Settings',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isDesktop ? 24 : isTablet ? 20 : 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // Content Area
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(contentPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Section
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
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withValues(alpha: 0.1),
                                      spreadRadius: 1,
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 64,
                                          height: 64,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(32),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(32),
                                            child: Image.network(
                                              userProfile['avatar'] as String,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return const Icon(
                                                  Icons.person,
                                                  size: 32,
                                                  color: Colors.grey,
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    userProfile['name'] as String,
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                      color: Color(0xFF1E293B),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFF1976D2).withValues(alpha: 0.1),
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: const Text(
                                                      '🎓 Student',
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color: Color(0xFF1976D2),
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  const Icon(Icons.mail, size: 12, color: Color(0xFF64748B)),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    userProfile['email'] as String,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Color(0xFF64748B),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Row(
                                                children: [
                                                  const Icon(Icons.phone, size: 12, color: Color(0xFF64748B)),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    userProfile['phone'] as String,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Color(0xFF64748B),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    // Profile Completion
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Profile Completion',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF64748B),
                                              ),
                                            ),
                                            Text(
                                              '${userProfile['profileCompletion']}%',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF1976D2),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        LinearProgressIndicator(
                                          value: (userProfile['profileCompletion'] as int) / 100,
                                          backgroundColor: Colors.grey[200],
                                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    OutlinedButton.icon(
                                      onPressed: _showEditProfileDialog,
                                      icon: const Icon(Icons.edit, size: 16),
                                      label: const Text('Edit Profile'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: const Color(0xFF1976D2),
                                        side: const BorderSide(color: Color(0xFF1976D2)),
                                        minimumSize: const Size(double.infinity, 40),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // Account Settings
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.lock, size: 16, color: Color(0xFF1976D2)),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Account Settings',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withValues(alpha: 0.1),
                                          spreadRadius: 1,
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: accountSettings.asMap().entries.map((entry) {
                                        final index = entry.key;
                                        final setting = entry.value;
                                        return TweenAnimationBuilder<double>(
                                          tween: Tween<double>(begin: -20, end: 0),
                                          duration: const Duration(milliseconds: 400),
                                          curve: Curves.easeOut,
                                          builder: (context, offset, child) {
                                            return Transform.translate(
                                              offset: Offset(offset, 0),
                                              child: Container(
                                                padding: const EdgeInsets.all(16),
                                                decoration: BoxDecoration(
                                                  border: index < accountSettings.length - 1
                                                      ? Border(
                                                          bottom: BorderSide(
                                                            color: Colors.grey.withValues(alpha: 0.1),
                                                            width: 1,
                                                          ),
                                                        )
                                                      : null,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 32,
                                                      height: 32,
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFF1976D2).withValues(alpha: 0.1),
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: Icon(
                                                        setting['icon'] as IconData,
                                                        size: 16,
                                                        color: const Color(0xFF1976D2),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            setting['title'] as String,
                                                            style: const TextStyle(
                                                              fontSize: 14,
                                                              fontWeight: FontWeight.w600,
                                                              color: Color(0xFF1E293B),
                                                            ),
                                                          ),
                                                          Text(
                                                            setting['subtitle'] as String,
                                                            style: const TextStyle(
                                                              fontSize: 12,
                                                              color: Color(0xFF64748B),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const Icon(
                                                      Icons.chevron_right,
                                                      size: 16,
                                                      color: Color(0xFF94A3B8),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // Safety & Security
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.security, size: 16, color: Color(0xFF1976D2)),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Safety & Security',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withValues(alpha: 0.1),
                                          spreadRadius: 1,
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        // Safety settings
                                        ...safetySettings.asMap().entries.map((entry) {
                                          final setting = entry.value;
                                          return TweenAnimationBuilder<double>(
                                            tween: Tween<double>(begin: -20, end: 0),
                                            duration: const Duration(milliseconds: 400),
                                            curve: Curves.easeOut,
                                            builder: (context, offset, child) {
                                              return Transform.translate(
                                                offset: Offset(offset, 0),
                                                child: Container(
                                                  padding: const EdgeInsets.all(16),
                                                  decoration: BoxDecoration(
                                                    border: Border(
                                                      bottom: BorderSide(
                                                        color: Colors.grey.withValues(alpha: 0.1),
                                                        width: 1,
                                                      ),
                                                    ),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        width: 32,
                                                        height: 32,
                                                        decoration: BoxDecoration(
                                                          color: const Color(0xFF7C4DFF).withValues(alpha: 0.1),
                                                          borderRadius: BorderRadius.circular(8),
                                                        ),
                                                        child: Icon(
                                                          setting['icon'] as IconData,
                                                          size: 16,
                                                          color: const Color(0xFF7C4DFF),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              setting['title'] as String,
                                                              style: const TextStyle(
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.w600,
                                                                color: Color(0xFF1E293B),
                                                              ),
                                                            ),
                                                            Text(
                                                              setting['subtitle'] as String,
                                                              style: const TextStyle(
                                                                fontSize: 12,
                                                                color: Color(0xFF64748B),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      const Icon(
                                                        Icons.chevron_right,
                                                        size: 16,
                                                        color: Color(0xFF94A3B8),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        }),
                                        // Location Sharing Toggle
                                        TweenAnimationBuilder<double>(
                                          tween: Tween<double>(begin: -20, end: 0),
                                          duration: const Duration(milliseconds: 400),
                                          curve: Curves.easeOut,
                                          builder: (context, offset, child) {
                                            return Transform.translate(
                                              offset: Offset(offset, 0),
                                              child: Container(
                                                padding: const EdgeInsets.all(16),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 32,
                                                      height: 32,
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFF7C4DFF).withValues(alpha: 0.1),
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: const Icon(
                                                        Icons.person,
                                                        size: 16,
                                                        color: Color(0xFF7C4DFF),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          const Text(
                                                            'Location Sharing',
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight: FontWeight.w600,
                                                              color: Color(0xFF1E293B),
                                                            ),
                                                          ),
                                                          const Text(
                                                            'Share location with hosts',
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color: Color(0xFF64748B),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Switch(
                                                      value: locationSharing,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          locationSharing = value;
                                                        });
                                                      },
                                                      activeThumbColor: const Color(0xFF7C4DFF),
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
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // App Settings
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.smartphone, size: 16, color: Color(0xFF1976D2)),
                                          const SizedBox(width: 8),
                                          const Text(
                                            'App Settings',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1E293B),
                                            ),
                                          ),
                                        ],
                                      ),
                                      TextButton(
                                        onPressed: () {},
                                        child: const Text(
                                          'View All',
                                          style: TextStyle(
                                            color: Color(0xFF1976D2),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withValues(alpha: 0.1),
                                          spreadRadius: 1,
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        // Theme Toggle
                                        TweenAnimationBuilder<double>(
                                          tween: Tween<double>(begin: -20, end: 0),
                                          duration: const Duration(milliseconds: 400),
                                          curve: Curves.easeOut,
                                          builder: (context, offset, child) {
                                            return Transform.translate(
                                              offset: Offset(offset, 0),
                                              child: Container(
                                                padding: const EdgeInsets.all(16),
                                                decoration: BoxDecoration(
                                                  border: Border(
                                                    bottom: BorderSide(
                                                      color: Colors.grey.withValues(alpha: 0.1),
                                                      width: 1,
                                                    ),
                                                  ),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 32,
                                                      height: 32,
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: const Icon(
                                                        Icons.dark_mode,
                                                        size: 16,
                                                        color: Color(0xFF4CAF50),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          const Text(
                                                            'Theme (Light/Dark)',
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight: FontWeight.w600,
                                                              color: Color(0xFF1E293B),
                                                            ),
                                                          ),
                                                          Consumer<ThemeProvider>(
                                                            builder: (context, themeProvider, child) {
                                                              return Text(
                                                                themeProvider.isDarkMode ? 'Dark mode enabled' : 'Dark mode disabled',
                                                                style: const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Color(0xFF64748B),
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Consumer<ThemeProvider>(
                                                      builder: (context, themeProvider, child) {
                                                        return Switch(
                                                          value: themeProvider.isDarkMode,
                                                          onChanged: (value) {
                                                            themeProvider.setDarkMode(value);
                                                          },
                                                          activeColor: const Color(0xFF4CAF50),
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        // App settings
                                        ...appSettings.asMap().entries.map((entry) {
                                          final index = entry.key;
                                          final setting = entry.value;
                                          return TweenAnimationBuilder<double>(
                                            tween: Tween<double>(begin: -20, end: 0),
                                            duration: const Duration(milliseconds: 400),
                                            curve: Curves.easeOut,
                                            builder: (context, offset, child) {
                                              return Transform.translate(
                                                offset: Offset(offset, 0),
                                                child: Container(
                                                  padding: const EdgeInsets.all(16),
                                                  decoration: BoxDecoration(
                                                    border: index < appSettings.length - 1
                                                        ? Border(
                                                            bottom: BorderSide(
                                                              color: Colors.grey.withValues(alpha: 0.1),
                                                              width: 1,
                                                            ),
                                                          )
                                                        : null,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        width: 32,
                                                        height: 32,
                                                        decoration: BoxDecoration(
                                                          color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                                                          borderRadius: BorderRadius.circular(8),
                                                        ),
                                                        child: Icon(
                                                          setting['icon'] as IconData,
                                                          size: 16,
                                                          color: const Color(0xFF4CAF50),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              setting['title'] as String,
                                                              style: const TextStyle(
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.w600,
                                                                color: Color(0xFF1E293B),
                                                              ),
                                                            ),
                                                            Text(
                                                              setting['subtitle'] as String,
                                                              style: const TextStyle(
                                                                fontSize: 12,
                                                                color: Color(0xFF64748B),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      const Icon(
                                                        Icons.chevron_right,
                                                        size: 16,
                                                        color: Color(0xFF94A3B8),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // Logout Button
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 20, end: 0),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOut,
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, value),
                            child: Opacity(
                              opacity: 1 - (value / 20),
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  try {
                                    await FirebaseApiService.signOut();
                                    // Navigate back or to login screen
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Logged out successfully')),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error logging out: $e')),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.logout, size: 16),
                                label: const Text('Logout'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                  minimumSize: const Size(double.infinity, 48),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 24),
                    ],
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