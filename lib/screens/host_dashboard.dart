import 'package:flutter/material.dart';

class HostDashboard extends StatefulWidget {
  final VoidCallback onLogout;

  const HostDashboard({super.key, required this.onLogout});

  @override
  State<HostDashboard> createState() => _HostDashboardState();
}

class _HostDashboardState extends State<HostDashboard> {
  // Sample data for demonstration
  final Map<String, dynamic> stats = {
    'totalProperties': 5,
    'activeProperties': 4,
    'totalBookings': 45,
    'confirmedBookings': 38,
    'totalRevenue': 125000,
    'avgRating': 4.3,
  };

  final List<Map<String, dynamic>> properties = [
    {'name': 'Green Valley Hostel', 'location': 'Kathmandu', 'price': 1500, 'status': 'active', 'bookings': 12},
    {'name': 'Mountain View Lodge', 'location': 'Pokhara', 'price': 2000, 'status': 'active', 'bookings': 8},
    {'name': 'City Center Hostel', 'location': 'Lalitpur', 'price': 1200, 'status': 'inactive', 'bookings': 0},
  ];

  final List<Map<String, dynamic>> bookings = [
    {'student': 'John Doe', 'property': 'Green Valley Hostel', 'amount': 4500, 'status': 'confirmed', 'date': '2024-01-15'},
    {'student': 'Jane Smith', 'property': 'Mountain View Lodge', 'amount': 6000, 'status': 'pending', 'date': '2024-01-20'},
    {'student': 'Bob Johnson', 'property': 'City Center Hostel', 'amount': 3600, 'status': 'completed', 'date': '2024-01-10'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Host Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: widget.onLogout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Host Dashboard',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Stats Cards
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildSimpleStatCard('Properties', stats['totalProperties'].toString()),
                _buildSimpleStatCard('Active', stats['activeProperties'].toString()),
                _buildSimpleStatCard('Bookings', stats['totalBookings'].toString()),
                _buildSimpleStatCard('Revenue', '₹${stats['totalRevenue']}'),
              ],
            ),

            const SizedBox(height: 32),

            // Management Tabs
            DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: 'Properties'),
                      Tab(text: 'Bookings'),
                    ],
                  ),
                  SizedBox(
                    height: 400,
                    child: TabBarView(
                      children: [
                        _buildPropertiesTable(),
                        _buildBookingsTable(),
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
  }

  Widget _buildSimpleStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertiesTable() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My Properties',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: properties.length,
              itemBuilder: (context, index) {
                final property = properties[index];
                return ListTile(
                  title: Text(property['name']),
                  subtitle: Text('${property['location']} - ₹${property['price']}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(property['status']),
                      Text('${property['bookings']} bookings'),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsTable() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Bookings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return ListTile(
                  title: Text('${booking['student']} - ${booking['property']}'),
                  subtitle: Text('${booking['date']} - ₹${booking['amount']}'),
                  trailing: Text(booking['status']),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}