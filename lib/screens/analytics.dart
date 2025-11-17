import 'package:flutter/material.dart';

class AnalyticsScreen extends StatefulWidget {
  final VoidCallback onBack;

  const AnalyticsScreen({super.key, required this.onBack});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String selectedPeriod = 'month';

  // Sample data for charts
  final List<Map<String, dynamic>> revenueData = [
    {'month': 'Jul', 'revenue': 35000},
    {'month': 'Aug', 'revenue': 38000},
    {'month': 'Sep', 'revenue': 42000},
    {'month': 'Oct', 'revenue': 40000},
    {'month': 'Nov', 'revenue': 45000},
    {'month': 'Dec', 'revenue': 50000}
  ];

  final List<Map<String, dynamic>> occupancyData = [
    {'month': 'Jul', 'occupancy': 72},
    {'month': 'Aug', 'occupancy': 78},
    {'month': 'Sep', 'occupancy': 85},
    {'month': 'Oct', 'occupancy': 82},
    {'month': 'Nov', 'occupancy': 89},
    {'month': 'Dec', 'occupancy': 85}
  ];

  final List<Map<String, dynamic>> metricsData = [
    {
      'label': 'Occupancy',
      'value': '85%',
      'subtext': 'Current',
      'icon': Icons.people,
      'color': const Color(0xFF1976D2),
      'change': '+7%'
    },
    {
      'label': 'Rating',
      'value': '4.5★',
      'subtext': 'Average',
      'icon': Icons.star,
      'color': Colors.yellow,
      'change': '+0.3'
    },
    {
      'label': 'Reviews',
      'value': '24',
      'subtext': 'This month',
      'icon': Icons.message,
      'color': const Color(0xFF7C4DFF),
      'change': '+12'
    },
    {
      'label': 'Response',
      'value': '98%',
      'subtext': 'Rate',
      'icon': Icons.access_time,
      'color': const Color(0xFF4CAF50),
      'change': '+2%'
    }
  ];

  final List<Map<String, dynamic>> recentActivities = [
    {
      'id': '1',
      'type': 'booking',
      'title': 'New booking: Room 101',
      'description': 'John Doe - Single room for 6 months',
      'timestamp': '2 hours ago',
      'icon': Icons.calendar_today,
      'color': const Color(0xFF1976D2)
    },
    {
      'id': '2',
      'type': 'payment',
      'title': 'Payment received: ₹8,000',
      'description': 'Monthly rent - Room 203',
      'timestamp': '5 hours ago',
      'icon': Icons.attach_money,
      'color': const Color(0xFF7C4DFF)
    },
    {
      'id': '3',
      'type': 'review',
      'title': 'Review posted: 4.8 stars',
      'description': '"Great place, excellent amenities"',
      'timestamp': '1 day ago',
      'icon': Icons.star,
      'color': Colors.yellow
    },
    {
      'id': '4',
      'type': 'inquiry',
      'title': 'Inquiry received',
      'description': 'Sarah Wilson asking about availability',
      'timestamp': '1 day ago',
      'icon': Icons.message,
      'color': const Color(0xFF4CAF50)
    },
    {
      'id': '5',
      'type': 'maintenance',
      'title': 'Maintenance completed',
      'description': 'WiFi upgrade in common areas',
      'timestamp': '2 days ago',
      'icon': Icons.check_circle,
      'color': const Color(0xFF7C4DFF)
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        constraints: const BoxConstraints(maxWidth: 375),
        margin: const EdgeInsets.symmetric(horizontal: 16),
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
                                icon: const Icon(Icons.arrow_back, color: Colors.white),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.white.withOpacity(0.2),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Analytics',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.bar_chart, size: 16),
                            label: const Text('Export'),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white),
                              foregroundColor: Colors.white,
                            ),
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
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Performance Overview
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
                                      const Icon(Icons.trending_up, size: 16, color: Color(0xFF1976D2)),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Performance Overview',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  // Period Selector
                                  Row(
                                    children: ['week', 'month', 'year'].map((period) {
                                      return Container(
                                        margin: const EdgeInsets.only(right: 8),
                                        child: OutlinedButton(
                                          onPressed: () {
                                            setState(() {
                                              selectedPeriod = period;
                                            });
                                          },
                                          style: OutlinedButton.styleFrom(
                                            backgroundColor: selectedPeriod == period
                                                ? const Color(0xFF1976D2)
                                                : Colors.transparent,
                                            foregroundColor: selectedPeriod == period
                                                ? Colors.white
                                                : const Color(0xFF1976D2),
                                            side: const BorderSide(color: Color(0xFF1976D2)),
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          ),
                                          child: Text(
                                            period.toUpperCase(),
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // Revenue Chart
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
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Monthly Revenue',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF1E293B),
                                              ),
                                            ),
                                            const Text(
                                              '₹45,000',
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF1976D2),
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                const Icon(Icons.trending_up, size: 12, color: Colors.green),
                                                const SizedBox(width: 4),
                                                const Text(
                                                  '+12% from last month',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.green,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF1976D2).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.attach_money,
                                            size: 16,
                                            color: Color(0xFF1976D2),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    // Simple bar chart representation
                                    SizedBox(
                                      height: 120,
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: revenueData.map((data) {
                                          final maxRevenue = revenueData.map((e) => e['revenue'] as int).reduce((a, b) => a > b ? a : b);
                                          final height = ((data['revenue'] as int) / maxRevenue) * 80;
                                          return Column(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              Container(
                                                width: 20,
                                                height: height,
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF1976D2),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                data['month'] as String,
                                                style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // Occupancy Chart
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
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Occupancy Rate',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF1E293B),
                                              ),
                                            ),
                                            const Text(
                                              '85%',
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF1976D2),
                                              ),
                                            ),
                                            const Text(
                                              'Average: 78%',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF64748B),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF7C4DFF).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.people,
                                            size: 16,
                                            color: Color(0xFF7C4DFF),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    // Simple line chart representation
                                    SizedBox(
                                      height: 120,
                                      child: CustomPaint(
                                        painter: OccupancyChartPainter(occupancyData),
                                        size: const Size(double.infinity, 120),
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

                      // Detailed Metrics Grid
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
                                    'Detailed Metrics',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  GridView.count(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 1.2,
                                    children: metricsData.map((metric) {
                                      return TweenAnimationBuilder<double>(
                                        tween: Tween<double>(begin: 0.9, end: 1.0),
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.elasticOut,
                                        builder: (context, scale, child) {
                                          return Transform.scale(
                                            scale: scale,
                                            child: Container(
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(12),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey.withOpacity(0.1),
                                                    spreadRadius: 1,
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    width: 32,
                                                    height: 32,
                                                    decoration: BoxDecoration(
                                                      color: (metric['color'] as Color).withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Icon(
                                                      metric['icon'] as IconData,
                                                      size: 16,
                                                      color: metric['color'] as Color,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    metric['value'] as String,
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                      color: Color(0xFF1E293B),
                                                    ),
                                                  ),
                                                  Text(
                                                    metric['label'] as String,
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      color: Color(0xFF64748B),
                                                    ),
                                                  ),
                                                  Text(
                                                    metric['subtext'] as String,
                                                    style: const TextStyle(
                                                      fontSize: 8,
                                                      color: Color(0xFF94A3B8),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: Colors.green.withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Text(
                                                      metric['change'] as String,
                                                      style: const TextStyle(
                                                        fontSize: 8,
                                                        color: Colors.green,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ],
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

                      const SizedBox(height: 24),

                      // Recent Activity
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
                                      const Icon(Icons.local_activity, size: 16, color: Color(0xFF1976D2)),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Recent Activity',
                                        style: TextStyle(
                                          fontSize: 16,
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
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.1),
                                          spreadRadius: 1,
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: recentActivities.map((activity) {
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
                                                      color: Colors.grey.withOpacity(0.1),
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
                                                        color: Colors.grey.withOpacity(0.1),
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: Icon(
                                                        activity['icon'] as IconData,
                                                        size: 14,
                                                        color: activity['color'] as Color,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            activity['title'] as String,
                                                            style: const TextStyle(
                                                              fontSize: 14,
                                                              fontWeight: FontWeight.w600,
                                                              color: Color(0xFF1E293B),
                                                            ),
                                                          ),
                                                          const SizedBox(height: 2),
                                                          Text(
                                                            activity['description'] as String,
                                                            style: const TextStyle(
                                                              fontSize: 12,
                                                              color: Color(0xFF64748B),
                                                            ),
                                                          ),
                                                          const SizedBox(height: 2),
                                                          Text(
                                                            activity['timestamp'] as String,
                                                            style: const TextStyle(
                                                              fontSize: 10,
                                                              color: Color(0xFF94A3B8),
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
            ),
          ],
        ),
      ),
    );
  }
}

class OccupancyChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;

  OccupancyChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..style = PaintingStyle.fill;

    final maxOccupancy = data.map((e) => e['occupancy'] as int).reduce((a, b) => a > b ? a : b);
    final points = <Offset>[];

    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height - ((data[i]['occupancy'] as int) / maxOccupancy) * size.height;
      points.add(Offset(x, y));
    }

    // Draw line
    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, paint);

    // Draw dots
    for (final point in points) {
      canvas.drawCircle(point, 4, dotPaint);
    }

    // Draw labels
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    for (int i = 0; i < data.length; i++) {
      textPainter.text = TextSpan(
        text: data[i]['month'] as String,
        style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
      );
      textPainter.layout();
      final x = (i / (data.length - 1)) * size.width;
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, size.height + 4));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}