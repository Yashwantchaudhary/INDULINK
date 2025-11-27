import 'package:flutter/material.dart';

enum BookingStatus { completed, upcoming, cancelled, active }

class Booking {
  final String id;
  final String hostelName;
  final String location;
  final String image;
  final String checkIn;
  final String checkOut;
  final BookingStatus status;
  final int price;
  final double? rating;
  final bool hasReview;

  Booking({
    required this.id,
    required this.hostelName,
    required this.location,
    required this.image,
    required this.checkIn,
    required this.checkOut,
    required this.status,
    required this.price,
    this.rating,
    required this.hasReview,
  });
}

class BookingHistory extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onBookAgain;
  final VoidCallback onChat;

  const BookingHistory({
    super.key,
    required this.onBack,
    required this.onBookAgain,
    required this.onChat,
  });

  @override
  State<BookingHistory> createState() => _BookingHistoryState();
}

class _BookingHistoryState extends State<BookingHistory> {
  String activeFilter = 'all';
  final bool _isLoading = true;
  List<Booking> bookings = [];

  List<Booking> get filteredBookings {
    if (activeFilter == 'all') return bookings;
    return bookings.where((booking) => booking.status.toString().split('.').last == activeFilter).toList();
  }

  Color getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.completed:
        return Colors.green;
      case BookingStatus.upcoming:
        return Colors.blue;
      case BookingStatus.active:
        return Colors.yellow;
      case BookingStatus.cancelled:
        return Colors.red;
    }
  }

  String formatDateRange(String checkIn, String checkOut) {
    final start = DateTime.parse(checkIn);
    final end = DateTime.parse(checkOut);
    final startStr = '${start.month.toString().padLeft(2, '0')}/${start.day}';
    final endStr = '${end.month.toString().padLeft(2, '0')}/${end.day}/${end.year}';
    return '$startStr - $endStr';
  }

  int get totalStays => bookings.length;
  int get totalSpent => bookings.fold(0, (sum, booking) => sum + booking.price);
  double get averageRating {
    final ratedBookings = bookings.where((b) => b.rating != null).toList();
    if (ratedBookings.isEmpty) return 0.0;
    return ratedBookings.fold(0.0, (sum, booking) => sum + (booking.rating ?? 0)) / ratedBookings.length;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 600;

    if (_isLoading) {
      return Scaffold(
        body: Container(
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
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        constraints: BoxConstraints(
          maxWidth: isWeb ? 800 : 375,
        ),
        margin: EdgeInsets.symmetric(
          horizontal: isWeb ? 32 : 16,
        ),
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
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              color: const Color(0xFF1976D2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: widget.onBack,
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        style: IconButton.styleFrom(
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Booking History',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${filteredBookings.length} bookings',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Filter Tabs
            Container(
              color: Colors.white,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['all', 'active', 'upcoming', 'completed', 'cancelled'].map((filter) {
                    final count = filter == 'all'
                        ? bookings.length
                        : bookings.where((b) => b.status.toString().split('.').last == filter).length;
                    final isActive = activeFilter == filter;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          activeFilter = filter;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: isActive ? const Color(0xFF1976D2) : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          '${filter[0].toUpperCase()}${filter.substring(1)}${filter != 'all' ? ' ($count)' : ''}',
                          style: TextStyle(
                            fontSize: 14,
                            color: isActive ? const Color(0xFF1976D2) : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Summary Cards
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Text(
                          'Total Stays',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          totalStays.toString(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1976D2),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const Text(
                          'Total Spent',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${totalSpent.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF7C4DFF),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const Text(
                          'Avg. Rating',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          averageRating > 0 ? averageRating.toStringAsFixed(1) : 'N/A',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFD97706),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Booking List
            Expanded(
              child: Container(
                color: Colors.white,
                child: filteredBookings.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 64,
                              color: Color(0xFFD1D5DB),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No bookings found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              activeFilter == 'all'
                                  ? "You haven't made any bookings yet"
                                  : 'No $activeFilter bookings found',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF9CA3AF),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: widget.onBookAgain,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1976D2),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                              child: const Text('Find Hostels'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredBookings.length,
                        itemBuilder: (context, index) {
                          final booking = filteredBookings[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
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
                                  children: [
                                    Container(
                                      width: 96,
                                      height: 96,
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          bottomLeft: Radius.circular(12),
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          bottomLeft: Radius.circular(12),
                                        ),
                                        child: Image.network(
                                          booking.image,
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
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        booking.hostelName,
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.w500,
                                                          color: Color(0xFF1E293B),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Row(
                                                        children: [
                                                          const Icon(
                                                            Icons.location_pin,
                                                            size: 12,
                                                            color: Color(0xFF64748B),
                                                          ),
                                                          const SizedBox(width: 4),
                                                          Text(
                                                            booking.location,
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
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: getStatusColor(booking.status).withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Text(
                                                    booking.status.toString().split('.').last[0].toUpperCase() +
                                                        booking.status.toString().split('.').last.substring(1),
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w500,
                                                      color: getStatusColor(booking.status),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.calendar_today,
                                                  size: 12,
                                                  color: Color(0xFF64748B),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  formatDateRange(booking.checkIn, booking.checkOut),
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFF64748B),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  '\$${booking.price}',
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w500,
                                                    color: Color(0xFF1976D2),
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    if (booking.status == BookingStatus.completed &&
                                                        !booking.hasReview)
                                                      OutlinedButton.icon(
                                                        onPressed: () {},
                                                        icon: const Icon(Icons.star, size: 14),
                                                        label: const Text('Review'),
                                                        style: OutlinedButton.styleFrom(
                                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                          textStyle: const TextStyle(fontSize: 12),
                                                        ),
                                                      ),
                                                    if (booking.status == BookingStatus.completed &&
                                                        booking.rating != null)
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                        decoration: BoxDecoration(
                                                          color: Colors.green[50],
                                                          borderRadius: BorderRadius.circular(8),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            const Icon(
                                                              Icons.star,
                                                              size: 12,
                                                              color: Colors.yellow,
                                                            ),
                                                            const SizedBox(width: 4),
                                                            Text(
                                                              '${booking.rating}',
                                                              style: const TextStyle(
                                                                fontSize: 10,
                                                                color: Colors.green,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    if (booking.status == BookingStatus.active ||
                                                        booking.status == BookingStatus.upcoming)
                                                      OutlinedButton.icon(
                                                        onPressed: widget.onChat,
                                                        icon: const Icon(Icons.message, size: 14),
                                                        label: const Text('Chat'),
                                                        style: OutlinedButton.styleFrom(
                                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                          textStyle: const TextStyle(fontSize: 12),
                                                        ),
                                                      ),
                                                    if (booking.status == BookingStatus.completed)
                                                      OutlinedButton.icon(
                                                        onPressed: widget.onBookAgain,
                                                        icon: const Icon(Icons.refresh, size: 14),
                                                        label: const Text('Book Again'),
                                                        style: OutlinedButton.styleFrom(
                                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                          textStyle: const TextStyle(fontSize: 12),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Booking ID: ${booking.id.toUpperCase()}',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                      TextButton.icon(
                                        onPressed: () {},
                                        icon: const Icon(Icons.download, size: 12),
                                        label: const Text('Receipt'),
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          textStyle: const TextStyle(fontSize: 10),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}