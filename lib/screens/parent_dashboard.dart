import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

class Child {
  final String id;
  final String name;
  final String avatar;
  final bool isActive;
  final CurrentStay? currentStay;

  Child({
    required this.id,
    required this.name,
    required this.avatar,
    required this.isActive,
    this.currentStay,
  });
}

class CurrentStay {
  final String hostelName;
  final String checkIn;
  final String roomType;
  final int monthlyRent;
  final String nextPayment;
  final String hostelImage;
  final String location;

  CurrentStay({
    required this.hostelName,
    required this.checkIn,
    required this.roomType,
    required this.monthlyRent,
    required this.nextPayment,
    required this.hostelImage,
    required this.location,
  });
}

class Activity {
  final String id;
  final String type;
  final String title;
  final String description;
  final String timestamp;
  final IconData icon;
  final Color color;

  Activity({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.icon,
    required this.color,
  });
}

class ParentDashboard extends StatefulWidget {
  final VoidCallback onBack;

  const ParentDashboard({
    super.key,
    required this.onBack,
  });

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  String selectedChild = 'john';

  final List<Child> children = [
    Child(
      id: 'john',
      name: 'John',
      avatar: 'https://images.unsplash.com/photo-1729824186570-4d4aede00043?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxzdHVkZW50JTIwcHJvZmlsZSUyMGF2YXRhcnxlbnwxfHx8fDE3NTg0MzE5MzZ8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
      isActive: true,
      currentStay: CurrentStay(
        hostelName: 'ABC Hostel',
        checkIn: 'Dec 15, 2024',
        roomType: 'Single',
        monthlyRent: 8000,
        nextPayment: 'Jan 15',
        hostelImage: 'https://images.unsplash.com/photo-1697603899008-a4027a95fd95?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxob3N0ZWwlMjByb29tJTIwaW50ZXJpb3J8ZW58MXx8fHwxNzU4NTI0MjQ1fDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
        location: 'Near DU, Delhi',
      ),
    ),
    Child(
      id: 'sarah',
      name: 'Sarah',
      avatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxmZW1hbGUlMjBzdHVkZW50JTIwYXZhdGFyfGVufDF8fHx8MTc1ODUyMzY1MXww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
      isActive: false,
    ),
    Child(
      id: 'mike',
      name: 'Mike',
      avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtYWxlJTIwc3R1ZGVudCUyMGF2YXRhcnxlbnwxfHx8fDE3NTg1MjM2ODR8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
      isActive: false,
    ),
  ];

  final Map<String, dynamic> safetyMetrics = {
    'safetyScore': 9.2,
    'areaRating': 4.5,
    'recentIncidents': 0,
    'lastSafetyCheck': '2 days ago',
  };

  final List<Activity> recentActivities = [
    Activity(
      id: '1',
      type: 'payment',
      title: 'Payment made: ₹8,000',
      description: 'Monthly rent for December 2024',
      timestamp: '2 hours ago',
      icon: Icons.attach_money,
      color: const Color(0xFF7C4DFF),
    ),
    Activity(
      id: '2',
      type: 'checkin',
      title: 'Check-in completed',
      description: 'Successfully moved into ABC Hostel',
      timestamp: '3 days ago',
      icon: Icons.check_circle,
      color: const Color(0xFF1976D2),
    ),
    Activity(
      id: '3',
      type: 'review',
      title: 'Review submitted',
      description: 'Rated hostel 4.8 stars',
      timestamp: '1 week ago',
      icon: Icons.star,
      color: Colors.yellow,
    ),
    Activity(
      id: '4',
      type: 'communication',
      title: 'Spoke with hostel manager',
      description: 'Discussed room amenities',
      timestamp: '1 week ago',
      icon: Icons.phone,
      color: const Color(0xFF7C4DFF),
    ),
  ];

  Child? get activeChild => children.firstWhere((child) => child.id == selectedChild);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 600;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        constraints: BoxConstraints(
          maxWidth: isWeb ? 1920 : 375,
        ),
        margin: EdgeInsets.symmetric(
          horizontal: isWeb ? 32 : 16,
          vertical: 16,
        ),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF3E5F5), // purple-50
              Color(0xFFE3F2FD), // blue-50
              Color(0xFFFCE4EC), // pink-50
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
                            Color(0xFF9C27B0), // purple-600
                            Color(0xFF2196F3), // blue-600
                            Color(0xFF3F51B5), // indigo-600
                          ],
                        ),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: widget.onBack,
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white.withValues(alpha: 0.2),
                              padding: const EdgeInsets.all(12),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Icon(
                              Icons.people,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Parent Monitoring Dashboard',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Real-time tracking of your children\'s accommodation',
                                  style: TextStyle(
                                    color: Colors.blue.withValues(alpha: 0.39),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Child Selector
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
                                const Text(
                                  'Select Child to Monitor',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                GridView.count(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  crossAxisCount: screenWidth > 768 ? 3 : screenWidth > 480 ? 2 : 1,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 2.5,
                                  children: children.map((child) {
                            return TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0.9, end: 1.0),
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.easeOut,
                              builder: (context, scale, childWidget) {
                                return Transform.scale(
                                  scale: scale,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedChild = child.id;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: selectedChild == child.id
                                            ? const Color(0xFFF3E5F5)
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: selectedChild == child.id
                                              ? const Color(0xFF9C27B0)
                                              : const Color(0xFFE2E8F0),
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withValues(alpha: 0.1),
                                            spreadRadius: 1,
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Stack(
                                            children: [
                                              Container(
                                                width: 56,
                                                height: 56,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(28),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(28),
                                                  child: Image.network(
                                                    child.avatar,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context, error, stackTrace) {
                                                      return Container(
                                                        color: Colors.grey[200],
                                                        child: const Icon(
                                                          Icons.person,
                                                          color: Colors.grey,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                              if (child.isActive)
                                                Positioned(
                                                  bottom: -2,
                                                  right: -2,
                                                  child: Container(
                                                    width: 16,
                                                    height: 16,
                                                    decoration: BoxDecoration(
                                                      color: Colors.green,
                                                      borderRadius: BorderRadius.circular(8),
                                                      border: Border.all(
                                                        color: Colors.white,
                                                        width: 2,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  child.name,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: selectedChild == child.id
                                                        ? const Color(0xFF9C27B0)
                                                        : const Color(0xFF1E293B),
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    Container(
                                                      width: 8,
                                                      height: 8,
                                                      decoration: BoxDecoration(
                                                        color: child.isActive
                                                            ? Colors.green
                                                            : Colors.grey,
                                                        borderRadius: BorderRadius.circular(4),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      child.isActive ? 'Active Stay' : 'No Active Stay',
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
                                    ),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // Current Stay
                    if (activeChild?.currentStay != null)
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
                                      const Icon(
                                        Icons.location_pin,
                                        size: 20,
                                        color: Color(0xFF9C27B0),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Current Accommodation Details',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFFF1F5F9),
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withValues(alpha: 0.1),
                                          spreadRadius: 1,
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 64,
                                          height: 64,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.network(
                                              activeChild!.currentStay!.hostelImage,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  color: Colors.grey[200],
                                                  child: const Icon(
                                                    Icons.home,
                                                    color: Colors.grey,
                                                  ),
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
                                              Text(
                                                activeChild!.currentStay!.hostelName,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF1E293B),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.calendar_today,
                                                    size: 12,
                                                    color: Color(0xFF64748B),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    'Check-in: ${activeChild!.currentStay!.checkIn}',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Color(0xFF64748B),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    'Room: ${activeChild!.currentStay!.roomType} • ₹${activeChild!.currentStay!.monthlyRent.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}/mo',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Color(0xFF64748B),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.schedule,
                                                    size: 12,
                                                    color: Color(0xFF64748B),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    'Next payment: ${activeChild!.currentStay!.nextPayment}',
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
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                    const SizedBox(height: 32),

                    // Main Grid Layout
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: screenWidth > 1024 ? 2 : 1,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                      childAspectRatio: screenWidth > 1024 ? 1.2 : 0.8,
                      children: [
                        // Safety Dashboard
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
                                        const Icon(
                                          Icons.security,
                                          size: 20,
                                          color: Color(0xFF9C27B0),
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Safety & Security Metrics',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1E293B),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFFF1F5F9),
                                          width: 2,
                                        ),
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
                                              Expanded(
                                                child: Container(
                                                  padding: const EdgeInsets.all(20),
                                                  decoration: BoxDecoration(
                                                    gradient: const LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end: Alignment.bottomRight,
                                                      colors: [
                                                        Color(0xFFF0FDF4), // green-50
                                                        Color(0xFFDCFCE7), // emerald-50
                                                      ],
                                                    ),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        '${safetyMetrics['safetyScore']}/10',
                                                        style: const TextStyle(
                                                          fontSize: 32,
                                                          fontWeight: FontWeight.bold,
                                                          color: Color(0xFF059669),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 8),
                                                      const Text(
                                                        'Safety Score',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w500,
                                                          color: Color(0xFF374151),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: Container(
                                                  padding: const EdgeInsets.all(20),
                                                  decoration: BoxDecoration(
                                                    gradient: const LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end: Alignment.bottomRight,
                                                      colors: [
                                                        Color(0xFFFFFBEB), // yellow-50
                                                        Color(0xFFFEF3C7), // amber-50
                                                      ],
                                                    ),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          const Icon(
                                                            Icons.star,
                                                            size: 24,
                                                            color: Colors.yellow,
                                                          ),
                                                          const SizedBox(width: 4),
                                                          Text(
                                                            '${safetyMetrics['areaRating']}',
                                                            style: const TextStyle(
                                                              fontSize: 32,
                                                              fontWeight: FontWeight.bold,
                                                              color: Color(0xFFD97706),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 8),
                                                      const Text(
                                                        'Area Rating',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w500,
                                                          color: Color(0xFF374151),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 20),
                                          const Divider(),
                                          const SizedBox(height: 16),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                'Recent Incidents:',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF64748B),
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.check_circle,
                                                    size: 12,
                                                    color: Color(0xFF7C4DFF),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  const Text(
                                                    'None',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Color(0xFF7C4DFF),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                'Last Safety Check:',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF64748B),
                                                ),
                                              ),
                                              Text(
                                                safetyMetrics['lastSafetyCheck'] as String,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF374151),
                                                ),
                                              ),
                                            ],
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

                        // Communication
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
                                        const Icon(
                                          Icons.message,
                                          size: 20,
                                          color: Color(0xFF9C27B0),
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Quick Communication',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1E293B),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFFF1F5F9),
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withValues(alpha: 0.1),
                                            spreadRadius: 1,
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: GridView.count(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 12,
                                        mainAxisSpacing: 12,
                                        childAspectRatio: 2.0,
                                        children: [
                                          ElevatedButton.icon(
                                            onPressed: () {},
                                            icon: const Icon(Icons.message, size: 16),
                                            label: const Text('Message Host'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF1976D2),
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                          OutlinedButton.icon(
                                            onPressed: () {},
                                            icon: const Icon(Icons.phone, size: 16),
                                            label: const Text('Call Child'),
                                            style: OutlinedButton.styleFrom(
                                              side: const BorderSide(color: Color(0xFFE2E8F0), width: 2),
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                          OutlinedButton.icon(
                                            onPressed: () {
                                              Navigator.of(context).pushNamed(AppRoutes.interactiveMapView);
                                            },
                                            icon: const Icon(Icons.map, size: 16),
                                            label: const Text('View Map'),
                                            style: OutlinedButton.styleFrom(
                                              side: const BorderSide(color: Color(0xFFE2E8F0), width: 2),
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                          OutlinedButton.icon(
                                            onPressed: () {},
                                            icon: const Icon(Icons.warning, size: 16),
                                            label: const Text('Emergency'),
                                            style: OutlinedButton.styleFrom(
                                              side: const BorderSide(color: Colors.red, width: 2),
                                              foregroundColor: Colors.red,
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
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
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Activity Log
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
                                    const Icon(
                                      Icons.description,
                                      size: 20,
                                      color: Color(0xFF9C27B0),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Recent Activity Log',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFFF1F5F9),
                                      width: 2,
                                    ),
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
                                    children: recentActivities.asMap().entries.map((entry) {
                                      final index = entry.key;
                                      final activity = entry.value;
                                      return TweenAnimationBuilder<double>(
                                        tween: Tween<double>(begin: -20, end: 0),
                                        duration: const Duration(milliseconds: 600),
                                        curve: Curves.easeOut,
                                        builder: (context, value, child) {
                                          return Transform.translate(
                                            offset: Offset(value, 0),
                                            child: Opacity(
                                              opacity: 1 + (value / 20),
                                              child: Container(
                                                padding: const EdgeInsets.all(20),
                                                decoration: BoxDecoration(
                                                  border: index < recentActivities.length - 1
                                                      ? const Border(
                                                          bottom: BorderSide(
                                                            color: Color(0xFFF1F5F9),
                                                            width: 2,
                                                          ),
                                                        )
                                                      : null,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 48,
                                                      height: 48,
                                                      decoration: BoxDecoration(
                                                        gradient: const LinearGradient(
                                                          begin: Alignment.topLeft,
                                                          end: Alignment.bottomRight,
                                                          colors: [
                                                            Color(0xFFEBF4FF), // blue-50
                                                            Color(0xFFE9D5FF), // purple-50
                                                          ],
                                                        ),
                                                        borderRadius: BorderRadius.circular(12),
                                                        border: Border.all(
                                                          color: const Color(0xFFF1F5F9),
                                                          width: 2,
                                                        ),
                                                      ),
                                                      child: Icon(
                                                        activity.icon,
                                                        size: 20,
                                                        color: activity.color,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 16),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            activity.title,
                                                            style: const TextStyle(
                                                              fontSize: 14,
                                                              fontWeight: FontWeight.bold,
                                                              color: Color(0xFF1E293B),
                                                            ),
                                                          ),
                                                          const SizedBox(height: 4),
                                                          Text(
                                                            activity.description,
                                                            style: const TextStyle(
                                                              fontSize: 12,
                                                              color: Color(0xFF64748B),
                                                            ),
                                                          ),
                                                          const SizedBox(height: 8),
                                                          Row(
                                                            children: [
                                                              const Icon(
                                                                Icons.schedule,
                                                                size: 12,
                                                                color: Color(0xFF64748B),
                                                              ),
                                                              const SizedBox(width: 4),
                                                              Text(
                                                                activity.timestamp,
                                                                style: const TextStyle(
                                                                  fontSize: 10,
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}