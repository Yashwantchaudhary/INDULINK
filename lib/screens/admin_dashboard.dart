import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class AdminDashboard extends StatefulWidget {
  final VoidCallback onBack;

  const AdminDashboard({super.key, required this.onBack});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  Map<String, dynamic> stats = {};
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> properties = [];
  List<Map<String, dynamic>> bookings = [];
  List<Map<String, dynamic>> reviews = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Load stats
      final statsResult = await FirestoreService.getAdminStats();
      if (statsResult['success']) {
        stats = statsResult['data'];
      } else {
        errorMessage = 'Failed to load stats: ${statsResult['message']}';
      }

      // Load users
      final usersResult = await FirestoreService.getAllUsers(limit: 10);
      if (usersResult['success']) {
        users = List<Map<String, dynamic>>.from(usersResult['data']);
      }

      // Load properties
      final propertiesResult = await FirestoreService.getAllListings(limit: 10);
      if (propertiesResult['success']) {
        properties = List<Map<String, dynamic>>.from(propertiesResult['data']);
      }

      // Load bookings
      final bookingsResult = await FirestoreService.getAllBookings(limit: 10);
      if (bookingsResult['success']) {
        bookings = List<Map<String, dynamic>>.from(bookingsResult['data']);
      }

      // Load reviews
      final reviewsResult = await FirestoreService.getAllReviews(limit: 10);
      if (reviewsResult['success']) {
        reviews = List<Map<String, dynamic>>.from(reviewsResult['data']);
      }
    } catch (e) {
      errorMessage = 'Error loading data: $e';
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: widget.onBack,
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: widget.onBack,
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onBack,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Admin Dashboard',
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
                _buildSimpleStatCard('Total Users', (stats['totalUsers'] ?? 0).toString()),
                _buildSimpleStatCard('Active Users', (stats['activeUsers'] ?? 0).toString()),
                _buildSimpleStatCard('Properties', (stats['totalProperties'] ?? 0).toString()),
                _buildSimpleStatCard('Active Properties', (stats['activeProperties'] ?? 0).toString()),
                _buildSimpleStatCard('Bookings', (stats['totalBookings'] ?? 0).toString()),
                _buildSimpleStatCard('Confirmed Bookings', (stats['confirmedBookings'] ?? 0).toString()),
                _buildSimpleStatCard('Revenue', '৳${stats['totalRevenue'] ?? 0}'),
                _buildSimpleStatCard('Avg Rating', (stats['avgRating'] ?? 0.0).toStringAsFixed(1)),
              ],
            ),

            const SizedBox(height: 32),

            // Management Tabs
            DefaultTabController(
              length: 4,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: 'Users'),
                      Tab(text: 'Properties'),
                      Tab(text: 'Bookings'),
                      Tab(text: 'Reviews'),
                    ],
                  ),
                  SizedBox(
                    height: 400,
                    child: TabBarView(
                      children: [
                        _buildUsersTable(),
                        _buildPropertiesTable(),
                        _buildBookingsTable(),
                        _buildReviewsTable(),
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

  Widget _buildUsersTable() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'User Management',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: users.isEmpty
                ? const Center(child: Text('No users found'))
                : ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return ListTile(
                        title: Text(user['name'] ?? user['displayName'] ?? 'Unknown'),
                        subtitle: Text(user['email'] ?? 'No email'),
                        trailing: Text((user['role'] ?? 'unknown').toString()),
                      );
                    },
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
            'Property Management',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: properties.isEmpty
                ? const Center(child: Text('No properties found'))
                : ListView.builder(
                    itemCount: properties.length,
                    itemBuilder: (context, index) {
                      final property = properties[index];
                      return ListTile(
                        title: Text(property['title'] ?? 'Untitled'),
                        subtitle: Text('${property['city'] ?? 'Unknown location'} - ৳${property['priceRange']?['min'] ?? property['price'] ?? 0}'),
                        trailing: Text((property['isActive'] ?? false) ? 'Active' : 'Inactive'),
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
            'Booking Management',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: bookings.isEmpty
                ? const Center(child: Text('No bookings found'))
                : ListView.builder(
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      final booking = bookings[index];
                      return ListTile(
                        title: Text('Booking #${booking['id']?.substring(0, 8) ?? 'Unknown'}'),
                        subtitle: Text('৳${booking['amount'] ?? 0} - ${booking['status'] ?? 'unknown'}'),
                        trailing: Text(booking['userId']?.substring(0, 8) ?? 'Unknown user'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsTable() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Review Management',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: reviews.isEmpty
                ? const Center(child: Text('No reviews found'))
                : ListView.builder(
                    itemCount: reviews.length,
                    itemBuilder: (context, index) {
                      final review = reviews[index];
                      return ListTile(
                        title: Text('Review for ${review['listingId']?.substring(0, 8) ?? 'Unknown property'}'),
                        subtitle: Text('Rating: ${review['rating'] ?? 0} - ${review['status'] ?? 'unknown'}'),
                        trailing: Text(review['userId']?.substring(0, 8) ?? 'Unknown user'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
