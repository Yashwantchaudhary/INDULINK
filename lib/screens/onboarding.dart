import 'package:flutter/material.dart';

class OnboardingFlow extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingFlow({super.key, required this.onComplete});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  int currentStep = 0;

  final onboardingSteps = [
    {
      'icon': Icons.location_on,
      'title': 'Find Your Perfect Hostel',
      'description': 'Discover comfortable and affordable accommodations near your university with our smart search and AI recommendations.',
      'color': const Color(0xFF1976D2)
    },
    {
      'icon': Icons.favorite,
      'title': 'Save & Compare',
      'description': 'Create wishlists, compare properties, and read authentic reviews from fellow students to make informed decisions.',
      'color': const Color(0xFFDC2626)
    },
    {
      'icon': Icons.message,
      'title': 'Chat Directly with Hosts',
      'description': 'Get instant answers to your questions and build trust with verified hosts through our secure messaging system.',
      'color': const Color(0xFF16A34A)
    },
    {
      'icon': Icons.security,
      'title': 'Safe & Secure Bookings',
      'description': 'Book with confidence using our secure payment system and 24/7 support. Your safety is our priority.',
      'color': const Color(0xFF7C3AED)
    }
  ];

  void handleNext() {
    if (currentStep < onboardingSteps.length - 1) {
      setState(() {
        currentStep++;
      });
    } else {
      widget.onComplete();
    }
  }

  void handlePrevious() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
      });
    }
  }

  void handleSkip() {
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final step = onboardingSteps[currentStep];

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE0F2FE), // blue-50
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      onboardingSteps.length,
                      (index) => Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: index == currentStep
                              ? const Color(0xFF1976D2)
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: handleSkip,
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon
                    Container(
                      width: 96,
                      height: 96,
                      margin: const EdgeInsets.only(bottom: 32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(48),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 16,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        step['icon'] as IconData,
                        size: 48,
                        color: step['color'] as Color,
                      ),
                    ),

                    // Title
                    Text(
                      step['title'] as String,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 16),

                    // Description
                    Text(
                      step['description'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF6B7280),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),

                    // Illustration placeholder
                    Container(
                      width: 256,
                      height: 128,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            const Color(0xFFDBEAFE), // blue-100
                            const Color(0xFFF3E8FF), // purple-100
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'Illustration',
                          style: TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Navigation
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton.icon(
                    onPressed: currentStep == 0 ? null : handlePrevious,
                    icon: const Icon(Icons.chevron_left, size: 16),
                    label: const Text('Previous'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: currentStep == 0
                          ? Colors.grey
                          : const Color(0xFF1976D2),
                      side: BorderSide(
                        color: currentStep == 0
                            ? Colors.grey
                            : const Color(0xFF1976D2),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: handleNext,
                    icon: Icon(
                      currentStep == onboardingSteps.length - 1
                          ? Icons.check
                          : Icons.chevron_right,
                      size: 16,
                    ),
                    label: Text(
                      currentStep == onboardingSteps.length - 1
                          ? 'Get Started'
                          : 'Next',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}