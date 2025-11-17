import 'package:flutter/material.dart';
import '../services/firebase_api_service.dart';
import '../services/analytics_service.dart';
import '../services/performance_service.dart';

class ListingsScreen extends StatefulWidget {
  final VoidCallback onBack;

  const ListingsScreen({super.key, required this.onBack});

  @override
  State<ListingsScreen> createState() => _ListingsScreenState();
}

class _ListingsScreenState extends State<ListingsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _listings = [];
  String _searchQuery = '';
  String _selectedCity = 'All';
  double? _minPrice;
  double? _maxPrice;

  final List<String> _cities = ['All', 'Kathmandu', 'Pokhara', 'Lalitpur', 'Bhaktapur'];

  @override
  void initState() {
    super.initState();
    // Track screen view
    AnalyticsService().logScreenView(screenName: 'Listings Screen');
    // Track screen loading performance
    PerformanceService().trackScreenLoad('listings', _loadListings);
  }

  Future<void> _loadListings() async {
    setState(() => _isLoading = true);

    try {
      final result = await FirebaseApiService.getListings(
        page: 1,
        limit: 50,
        city: _selectedCity != 'All' ? _selectedCity : null,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
      );

      if (result['success'] == true) {
        setState(() {
          _listings = List<Map<String, dynamic>>.from(result['data'] ?? []);
        });
      } else {
        // Show error instead of fallback data
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Failed to load listings')),
        );
        setState(() {
          _listings = [];
        });
      }
    } catch (e) {
      debugPrint('Error loading listings: $e');
      // Show error instead of fallback data
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load listings. Please check your connection.')),
      );
      setState(() {
        _listings = [];
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }


  void _filterListings() {
    _loadListings();
  }

  Widget _buildListingCard(Map<String, dynamic> listing, {required bool isDesktop}) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width >= 600 && screenSize.width < 1024;

    return Card(
      margin: EdgeInsets.zero,
      elevation: isDesktop ? 10 : isTablet ? 6 : 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isDesktop ? 20 : isTablet ? 16 : 12),
      ),
      child: Column(
        children: [
          // Image
          Container(
            height: isDesktop ? 280 : isTablet ? 240 : 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(isDesktop ? 20 : isTablet ? 16 : 12),
              ),
            ),
            child: listing['images'] != null && (listing['images'] as List).isNotEmpty
                ? Image.network(
                    listing['images'][0],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.home,
                          size: isDesktop ? 70 : isTablet ? 60 : 50,
                          color: Colors.grey,
                        ),
                      );
                    },
                  )
                : Container(
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.home,
                      size: isDesktop ? 70 : isTablet ? 60 : 50,
                      color: Colors.grey,
                    ),
                  ),
          ),

          // Details
          Padding(
            padding: EdgeInsets.all(isDesktop ? 32 : isTablet ? 24 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        listing['title'] ?? 'Unknown Hostel',
                        style: TextStyle(
                          fontSize: isDesktop ? 24 : isTablet ? 20 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (listing['verificationStatus'] == 'live')
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? 16 : isTablet ? 12 : 8,
                          vertical: isDesktop ? 8 : isTablet ? 6 : 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(isDesktop ? 20 : isTablet ? 16 : 12),
                        ),
                        child: Text(
                          'Verified',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: isDesktop ? 16 : isTablet ? 14 : 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: isDesktop ? 16 : isTablet ? 12 : 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: isDesktop ? 20 : isTablet ? 18 : 16,
                      color: Colors.grey
                    ),
                    SizedBox(width: isDesktop ? 10 : isTablet ? 8 : 4),
                    Text(
                      listing['location'] ?? 'Unknown Location',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: isDesktop ? 16 : isTablet ? 14 : 12,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isDesktop ? 16 : isTablet ? 12 : 8),
                Text(
                  listing['priceRange'] != null
                      ? '₹${listing['priceRange']['min']}-${listing['priceRange']['max']}/month'
                      : 'Price not available',
                  style: TextStyle(
                    fontSize: isDesktop ? 20 : isTablet ? 18 : 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: isDesktop ? 16 : isTablet ? 12 : 8),
                Wrap(
                  spacing: isDesktop ? 16 : isTablet ? 12 : 8,
                  runSpacing: isDesktop ? 10 : 8,
                  children: (listing['amenities'] as List<dynamic>? ?? []).map((amenity) {
                    return Chip(
                      label: Text(
                        amenity.toString(),
                        style: TextStyle(
                          fontSize: isDesktop ? 14 : isTablet ? 12 : 10,
                        ),
                      ),
                      backgroundColor: Colors.grey[200],
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 16 : isTablet ? 12 : 8,
                        vertical: isDesktop ? 8 : isTablet ? 6 : 4,
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: isDesktop ? 24 : isTablet ? 20 : 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // Navigate to listing details screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('View details for ${listing['title']}')),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: isDesktop ? 18 : isTablet ? 16 : 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(isDesktop ? 14 : isTablet ? 12 : 8),
                          ),
                        ),
                        child: Text(
                          'View Details',
                          style: TextStyle(
                            fontSize: isDesktop ? 16 : isTablet ? 14 : 12,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: isDesktop ? 16 : isTablet ? 12 : 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate to booking flow
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Book ${listing['title']}')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1976D2),
                          padding: EdgeInsets.symmetric(
                            vertical: isDesktop ? 18 : isTablet ? 16 : 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(isDesktop ? 14 : isTablet ? 12 : 8),
                          ),
                        ),
                        child: Text(
                          'Book Now',
                          style: TextStyle(
                            fontSize: isDesktop ? 16 : isTablet ? 14 : 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width >= 600 && screenSize.width < 1024;
    final isDesktop = screenSize.width >= 1024;

    // Enhanced responsive dimensions
    final maxWidth = isDesktop ? 1600.0 : isTablet ? 900.0 : double.infinity;
    final horizontalPadding = isDesktop ? 64.0 : isTablet ? 48.0 : 20.0;
    final searchBarWidth = isDesktop ? 700.0 : isTablet ? 500.0 : double.infinity;
    final filterWidth = isDesktop ? 350.0 : isTablet ? 250.0 : double.infinity;
    final buttonWidth = isDesktop ? 180.0 : isTablet ? 140.0 : 120.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Find Hostels',
          style: TextStyle(
            fontSize: isDesktop ? 28 : isTablet ? 24 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            size: isDesktop ? 32 : isTablet ? 28 : 24,
          ),
          onPressed: widget.onBack,
        ),
        toolbarHeight: isDesktop ? 90 : isTablet ? 70 : 56,
        elevation: isDesktop ? 2 : 1,
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: EdgeInsets.all(horizontalPadding),
            color: Colors.white,
            child: Column(
              children: [
                // Search Bar
                SizedBox(
                  width: searchBarWidth,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search hostels...',
                      hintStyle: TextStyle(
                        fontSize: isDesktop ? 18 : isTablet ? 16 : 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        size: isDesktop ? 26 : isTablet ? 24 : 20,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(isDesktop ? 14 : isTablet ? 12 : 8),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 28 : isTablet ? 24 : 16,
                        vertical: isDesktop ? 22 : isTablet ? 20 : 14,
                      ),
                    ),
                    style: TextStyle(
                      fontSize: isDesktop ? 18 : isTablet ? 16 : 14,
                    ),
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                    onSubmitted: (_) => _filterListings(),
                  ),
                ),
                SizedBox(height: isDesktop ? 32 : isTablet ? 24 : 16),
                // Filters
                Wrap(
                  spacing: isDesktop ? 32 : isTablet ? 24 : 16,
                  runSpacing: isDesktop ? 16 : 12,
                  alignment: WrapAlignment.center,
                  children: [
                    SizedBox(
                      width: filterWidth,
                      child: DropdownButtonFormField<String>(
                        value: _selectedCity,
                        decoration: InputDecoration(
                          labelText: 'City',
                          labelStyle: TextStyle(
                            fontSize: isDesktop ? 18 : isTablet ? 16 : 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(isDesktop ? 14 : isTablet ? 12 : 8),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? 28 : isTablet ? 24 : 16,
                            vertical: isDesktop ? 22 : isTablet ? 20 : 14,
                          ),
                        ),
                        style: TextStyle(
                          fontSize: isDesktop ? 18 : isTablet ? 16 : 14,
                        ),
                        items: _cities.map((city) {
                          return DropdownMenuItem(
                            value: city,
                            child: Text(city),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedCity = value!);
                          _filterListings();
                        },
                      ),
                    ),
                    SizedBox(
                      width: buttonWidth,
                      height: isDesktop ? 60 : isTablet ? 56 : 48,
                      child: ElevatedButton(
                        onPressed: _filterListings,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1976D2),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(isDesktop ? 14 : isTablet ? 12 : 8),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? 28 : isTablet ? 24 : 16,
                          ),
                        ),
                        child: Text(
                          'Filter',
                          style: TextStyle(
                            fontSize: isDesktop ? 18 : isTablet ? 16 : 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Listings List
          Expanded(
            child: Container(
              constraints: BoxConstraints(maxWidth: maxWidth),
              margin: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 0),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _listings.isEmpty
                      ? Center(
                          child: Text(
                            'No listings found',
                            style: TextStyle(
                              fontSize: isDesktop ? 20 : isTablet ? 18 : 16,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : isDesktop
                          ? GridView.builder(
                              padding: EdgeInsets.all(horizontalPadding),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 32,
                                mainAxisSpacing: 32,
                                childAspectRatio: 0.7,
                              ),
                              itemCount: _listings.length,
                              itemBuilder: (context, index) {
                                final listing = _listings[index];
                                return _buildListingCard(listing, isDesktop: true);
                              },
                            )
                          : isTablet
                              ? GridView.builder(
                                  padding: EdgeInsets.all(horizontalPadding),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 24,
                                    mainAxisSpacing: 24,
                                    childAspectRatio: 0.75,
                                  ),
                                  itemCount: _listings.length,
                                  itemBuilder: (context, index) {
                                    final listing = _listings[index];
                                    return _buildListingCard(listing, isDesktop: false);
                                  },
                                )
                              : ListView.builder(
                                  padding: EdgeInsets.all(horizontalPadding),
                                  itemCount: _listings.length,
                                  itemBuilder: (context, index) {
                                    final listing = _listings[index];
                                    return _buildListingCard(listing, isDesktop: false);
                                  },
                                ),
            ),
          ),
        ],
      ),
    );
  }
}