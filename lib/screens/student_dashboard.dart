import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'dart:math' as math;
import '../services/firebase_api_service.dart';

class StudentDashboard extends StatefulWidget {
  final VoidCallback onLogout;
  final VoidCallback? onNavigateToSearch;
  final VoidCallback? onNavigateToBooking;
  final VoidCallback? onNavigateToChat;
  final VoidCallback? onNavigateToProfile;
  final VoidCallback? onNavigateToAI;
  final VoidCallback? onNavigateToMap;
  final VoidCallback? onNavigateToAccountPayments;
  final VoidCallback? onNavigateToWishlist;
  final VoidCallback? onNavigateToBookingHistory;

  const StudentDashboard({
    super.key,
    required this.onLogout,
    this.onNavigateToSearch,
    this.onNavigateToBooking,
    this.onNavigateToChat,
    this.onNavigateToProfile,
    this.onNavigateToAI,
    this.onNavigateToMap,
    this.onNavigateToAccountPayments,
    this.onNavigateToWishlist,
    this.onNavigateToBookingHistory,
  });

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  bool _isLoading = true;
  String _activeTab = 'hostels';
  List<Map<String, dynamic>> _filteredHostels = [];
  List<Map<String, dynamic>> _allHostels = [];

  // Map related variables
  GoogleMapController? _mapController;
  Position? _currentPosition;
  Set<Marker> _markers = {};
  bool _isMapLoading = true;
  static const LatLng _defaultLocation = LatLng(28.6139, 77.2090); // Delhi coordinates

  final List<Map<String, dynamic>> _stats = [
    {'label': 'Bookings', 'value': '0', 'icon': Icons.calendar_today},
    {'label': 'Wishlist', 'value': '0', 'icon': Icons.favorite},
    {'label': 'Reviews', 'value': '0', 'icon': Icons.star},
    {'label': 'Spent', 'value': '₹0', 'icon': Icons.home},
  ];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);

    try {
      // Load user data and listings
      await Future.wait([
        _loadUserStats(),
        _loadHostels(),
        _initializeMap(),
      ]);
    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _initializeMap() async {
    try {
      // Get current location
      _currentPosition = await _getCurrentLocation();

      // Create markers for hostels
      await _createHostelMarkers();

      setState(() => _isMapLoading = false);
    } catch (e) {
      debugPrint('Error initializing map: $e');
      // Use default location if GPS fails
      _currentPosition = Position(
        latitude: _defaultLocation.latitude,
        longitude: _defaultLocation.longitude,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );
      await _createHostelMarkers();
      setState(() => _isMapLoading = false);
    }
  }

  Future<void> _initializeMapAsync() async {
    // This method wraps the initialization to handle async errors in FutureBuilder
    await _initializeMap();
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> _createHostelMarkers() async {
    final markers = <Marker>{};

    for (final hostel in _allHostels) {
      // Try to get coordinates from hostel data, fallback to simulated coordinates
      double lat, lng;

      // Check if listing has coordinates (assuming they might be added to API later)
      if (hostel['coordinates'] != null) {
        final coords = hostel['coordinates'] as Map<String, dynamic>;
        lat = coords['latitude'] ?? _defaultLocation.latitude;
        lng = coords['longitude'] ?? _defaultLocation.longitude;
      } else {
        // Use simulated coordinates near current location for demo
        lat = (_currentPosition?.latitude ?? _defaultLocation.latitude) +
            (markers.length * 0.01);
        lng = (_currentPosition?.longitude ?? _defaultLocation.longitude) +
            (markers.length * 0.01);
      }

      final marker = Marker(
        markerId: MarkerId(hostel['id'].toString()),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(
          title: hostel['name'] as String,
          snippet: '${hostel['location']} • ${hostel['price']}',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          hostel['isFavorited'] == true ? BitmapDescriptor.hueRed : BitmapDescriptor.hueBlue,
        ),
        onTap: () {
          // Could navigate to hostel details or show bottom sheet
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tapped on ${hostel['name']}')),
          );
        },
      );

      markers.add(marker);
    }

    // Add current location marker
    if (_currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          infoWindow: const InfoWindow(title: 'Your Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
    }

    setState(() => _markers = markers);
  }

  Future<void> _loadUserStats() async {
    try {
      // Get dashboard stats from backend
      final dashboardResult = await FirebaseApiService.getStudentDashboard();
      if (dashboardResult['success'] == true) {
        final overview = dashboardResult['data']['overview'] as Map<String, dynamic>;
        setState(() {
          _stats[0]['value'] = overview['totalBookings']?.toString() ?? '0';
          _stats[2]['value'] = overview['reviewsCount']?.toString() ?? '0';
          _stats[3]['value'] = '₹${overview['totalSpent'] ?? 0}';
        });
      }

      // Get favorites count
      final favoritesResult = await FirebaseApiService.getUserFavorites(page: 1, limit: 1);
      if (favoritesResult['success'] == true) {
        final favoritesData = favoritesResult['data'] as Map<String, dynamic>;
        setState(() {
          _stats[1]['value'] = favoritesData['total']?.toString() ?? '0';
        });
      }

      // If dashboard failed, try basic stats
      if (dashboardResult['success'] != true) {
        final statsResult = await FirebaseApiService.getDashboardStats();
        if (statsResult['success'] == true) {
          final stats = statsResult['data'] as Map<String, dynamic>;
          setState(() {
            _stats[0]['value'] = stats['studentStats']?['totalBookings']?.toString() ?? '0';
            _stats[2]['value'] = stats['studentStats']?['reviewsCount']?.toString() ?? '0';
            _stats[3]['value'] = '₹${stats['studentStats']?['totalSpent'] ?? 0}';
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading user stats: $e');
      // Keep default values
    }
  }

  Future<void> _loadHostels() async {
    try {
      final result = await FirebaseApiService.getListings(limit: 20);
      if (result['success'] == true) {
        final listings = List<Map<String, dynamic>>.from(result['data'] ?? []);
        final hostelList = <Map<String, dynamic>>[];

        for (final listing in listings) {
          final hostelId = listing['id'] ?? listing['_id'];

          // Check favorite status for each listing
          bool isFavorited = false;
          try {
            final favoriteResult = await FirebaseApiService.checkFavoriteStatus(hostelId.toString());
            isFavorited = favoriteResult['success'] == true && favoriteResult['data']['isFavorited'] == true;
          } catch (e) {
            debugPrint('Error checking favorite status for $hostelId: $e');
          }

          hostelList.add({
            'id': hostelId,
            'name': listing['name'] ?? listing['title'] ?? 'Unknown Hostel',
            'location': listing['location'] ?? 'Unknown Location',
            'price': listing['price'] ?? 'Price not available',
            'rating': listing['rating']?.toDouble() ?? 0.0,
            'reviews': listing['reviews'] ?? 0,
            'amenities': List<String>.from(listing['amenities'] ?? []),
            'image': listing['image'] ?? 'https://via.placeholder.com/300x200?text=No+Image',
            'isFavorited': isFavorited,
          });
        }

        setState(() {
          _allHostels = hostelList;
          _filteredHostels = List.from(_allHostels);
        });
      } else {
        throw Exception(result['message'] ?? 'Failed to load listings');
      }
    } catch (e) {
      debugPrint('Error loading hostels: $e');
      // Fallback to sample data
      _setFallbackData();
    }
  }

  void _setFallbackData() {
    _allHostels = [
      {
        'id': 1,
        'name': 'Modern Hostel',
        'location': 'Near DU',
        'price': '₹8K/mo',
        'rating': 4.5,
        'reviews': 24,
        'amenities': ['WiFi', 'AC'],
        'image': 'https://images.unsplash.com/photo-1697603899008-a4027a95fd95?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxob3N0ZWwlMjByb29tJTIwaW50ZXJpb3J8ZW58MXx8fHwxNzU4NTI0MjQ1fDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
        'isFavorited': false,
      },
      {
        'id': 2,
        'name': 'Student Paradise',
        'location': 'Campus Area',
        'price': '₹6K/mo',
        'rating': 4.3,
        'reviews': 18,
        'amenities': ['WiFi', 'Meals'],
        'image': 'https://images.unsplash.com/photo-1582719388123-e03e25d06d51?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxob3N0ZWwlMjBidWlsZGluZyUyMGFjY29tbW9kYXRpb258ZW58MXx8fHwxNzU4NTIzOTgyfDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
        'isFavorited': false,
      }
    ];
    _filteredHostels = List.from(_allHostels);
  }

  void _filterHostels(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredHostels = List.from(_allHostels);
      } else {
        _filteredHostels = _allHostels.where((hostel) {
          final name = hostel['name'].toString().toLowerCase();
          final location = hostel['location'].toString().toLowerCase();
          final searchLower = query.toLowerCase();
          return name.contains(searchLower) || location.contains(searchLower);
        }).toList();
      }
    });
  }

  Future<void> _toggleFavorite(int hostelId) async {
    try {
      // Find the hostel in the list
      final hostelIndex = _allHostels.indexWhere((h) => h['id'] == hostelId);
      if (hostelIndex == -1) return;

      // Call backend API to toggle favorite
      final result = await FirebaseApiService.toggleFavorite(hostelId.toString());

      if (result['success'] == true) {
        final newStatus = result['data']['action'] == 'added';
        setState(() {
          _allHostels[hostelIndex]['isFavorited'] = newStatus;
          // Update filtered list as well
          final filteredIndex = _filteredHostels.indexWhere((h) => h['id'] == hostelId);
          if (filteredIndex != -1) {
            _filteredHostels[filteredIndex]['isFavorited'] = newStatus;
          }
        });

        // Show feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newStatus ? 'Added to favorites' : 'Removed from favorites'),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        throw Exception(result['message'] ?? 'Failed to update favorite');
      }
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error updating favorites'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _switchTab(String tab) {
    setState(() {
      _activeTab = tab;
      // In a real implementation, this would load different data based on tab
      // For now, just switch the active tab
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    // You can add additional map setup here
  }

  Future<void> _filterHostelsByLocation() async {
    try {
      final position = await _getCurrentLocation();
      setState(() {
        _currentPosition = position;
      });

      // Filter hostels within 5km radius of current location
      _filterHostelsByRadius(LatLng(position.latitude, position.longitude), 5.0);

      // Move camera to current location
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          14.0,
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Filtered hostels near your location')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    }
  }

  void _filterHostelsByMapLocation(LatLng tappedLocation) {
    // Filter hostels within 3km radius of tapped location
    _filterHostelsByRadius(tappedLocation, 3.0);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Filtered hostels near selected location')),
    );
  }

  void _filterHostelsByRadius(LatLng center, double radiusKm) {
    setState(() {
      _filteredHostels = _allHostels.where((hostel) {
        // For demo purposes, we'll simulate distances
        // In a real app, you'd calculate actual distance using coordinates
        final hostelLat = (_currentPosition?.latitude ?? _defaultLocation.latitude) +
            (_allHostels.indexOf(hostel) * 0.01);
        final hostelLng = (_currentPosition?.longitude ?? _defaultLocation.longitude) +
            (_allHostels.indexOf(hostel) * 0.01);

        final distance = _calculateDistance(
          center.latitude,
          center.longitude,
          hostelLat,
          hostelLng,
        );

        return distance <= radiusKm;
      }).toList();
    });
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) * math.cos(_degreesToRadians(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (3.141592653589793 / 180);
  }



  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width >= 600 && screenSize.width < 1024;
    final isDesktop = screenSize.width >= 1024;

    // Enhanced responsive dimensions
    final maxWidth = isDesktop ? 1600.0 : isTablet ? 900.0 : double.infinity;
    final horizontalMargin = isDesktop ? 48.0 : isTablet ? 32.0 : 0.0;
    final horizontalPadding = isDesktop ? 64.0 : isTablet ? 48.0 : 20.0;
    final verticalPadding = isDesktop ? 40.0 : isTablet ? 32.0 : 24.0;

    // Adaptive grid columns with better mobile layout
    final statsCrossAxisCount = isDesktop ? 4 : isTablet ? 2 : 2;
    final statsChildAspectRatio = isDesktop ? 1.4 : isTablet ? 1.2 : 1.0;
    final statsCrossAxisSpacing = isDesktop ? 24.0 : isTablet ? 16.0 : 12.0;
    final statsMainAxisSpacing = isDesktop ? 24.0 : isTablet ? 16.0 : 12.0;

    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF667EEA),
                const Color(0xFF764BA2),
                const Color(0xFFF093FB),
                const Color(0xFFF5576C),
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
        constraints: BoxConstraints(maxWidth: maxWidth),
        margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF667EEA),
              const Color(0xFF764BA2),
              const Color(0xFFF093FB),
              const Color(0xFFF5576C),
            ],
          ),
        ),
        child: Column(
          children: [
            // Header
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: -20.0, end: 0.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, value),
                  child: Opacity(
                    opacity: 1.0 + (value / 20),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: isDesktop ? 56 : 44,
                                height: isDesktop ? 56 : 44,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(isDesktop ? 28 : 22),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                  image: const DecorationImage(
                                    image: AssetImage('assets/images/logo.png'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(width: isDesktop ? 16 : 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome, ${_getUserName()}!',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isDesktop ? 20 : 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Text(
                                    'Profile: ${_getProfileCompletion()}% complete',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.8),
                                      fontSize: isDesktop ? 14 : 12,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Stack(
                            children: [
                              IconButton(
                                onPressed: widget.onNavigateToChat,
                                icon: Icon(
                                  Icons.notifications_outlined,
                                  color: Colors.white,
                                  size: isDesktop ? 24 : 20,
                                ),
                                padding: const EdgeInsets.all(8),
                              ),
                              Positioned(
                                top: 6,
                                right: 6,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFF4757),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0xFFFF4757),
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
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

            // Stats Cards
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 20.0, end: 0.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, value),
                  child: Opacity(
                    opacity: 1.0 - (value / 20),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
                      child: GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: statsCrossAxisCount,
                        crossAxisSpacing: statsCrossAxisSpacing,
                        mainAxisSpacing: statsMainAxisSpacing,
                        childAspectRatio: statsChildAspectRatio,
                        children: _stats.map((stat) {
                          return GestureDetector(
                            onTap: () {
                              if (stat['label'] == 'Bookings' && widget.onNavigateToBookingHistory != null) {
                                widget.onNavigateToBookingHistory!();
                              } else if (stat['label'] == 'Wishlist' && widget.onNavigateToWishlist != null) {
                                widget.onNavigateToWishlist!();
                              } else if (stat['label'] == 'Spent' && widget.onNavigateToAccountPayments != null) {
                                widget.onNavigateToAccountPayments!();
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.all(isDesktop ? 16 : isTablet ? 12 : 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
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
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    stat['icon'] as IconData,
                                    size: isDesktop ? 24 : isTablet ? 20 : 16,
                                    color: const Color(0xFF1976D2)
                                  ),
                                  SizedBox(height: isDesktop ? 12 : isTablet ? 8 : 4),
                                  Text(
                                    stat['value'] as String,
                                    style: TextStyle(
                                      fontSize: isDesktop ? 18 : isTablet ? 16 : 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    stat['label'] as String,
                                    style: TextStyle(
                                      fontSize: isDesktop ? 14 : isTablet ? 12 : 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                );
              },
            ),

            // Search Bar
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 20.0, end: 0.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, value),
                  child: Opacity(
                    opacity: 1.0 - (value / 20),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Wrap(
                        spacing: isDesktop ? 16 : 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          SizedBox(
                            width: isDesktop ? 500 : (isTablet ? 350 : double.infinity),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: isDesktop ? 16 : 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.search, size: isDesktop ? 20 : 16, color: Colors.grey),
                                  SizedBox(width: isDesktop ? 12 : 8),
                                  Expanded(
                                    child: TextField(
                                      onChanged: _filterHostels,
                                      decoration: InputDecoration(
                                        hintText: 'Search hostels...',
                                        border: InputBorder.none,
                                        hintStyle: TextStyle(
                                          color: Colors.grey,
                                          fontSize: isDesktop ? 16 : 14,
                                        ),
                                      ),
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: isDesktop ? 16 : 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (isDesktop || isTablet) ...[
                            IconButton(
                              onPressed: widget.onNavigateToAI,
                              icon: Icon(Icons.smart_toy, size: isDesktop ? 20 : 18),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: EdgeInsets.all(isDesktop ? 12 : 10),
                              ),
                            ),
                            IconButton(
                              onPressed: widget.onNavigateToMap,
                              icon: Icon(Icons.map, size: isDesktop ? 20 : 18),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: EdgeInsets.all(isDesktop ? 12 : 10),
                              ),
                            ),
                            IconButton(
                              onPressed: widget.onNavigateToSearch,
                              icon: Icon(Icons.gps_fixed, size: isDesktop ? 20 : 18),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: EdgeInsets.all(isDesktop ? 12 : 10),
                              ),
                            ),
                          ] else ...[
                            // Mobile: Stack buttons horizontally with responsive sizing
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: widget.onNavigateToAI,
                                  icon: const Icon(Icons.smart_toy, size: 18),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    padding: const EdgeInsets.all(10),
                                  ),
                                ),
                                IconButton(
                                  onPressed: widget.onNavigateToMap,
                                  icon: const Icon(Icons.map, size: 18),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    padding: const EdgeInsets.all(10),
                                  ),
                                ),
                                IconButton(
                                  onPressed: widget.onNavigateToSearch,
                                  icon: const Icon(Icons.gps_fixed, size: 18),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    padding: const EdgeInsets.all(10),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // Map View with Sliding Panel Overlay
            Expanded(
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 20.0, end: 0.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, value),
                    child: Opacity(
                      opacity: 1.0 - (value / 20),
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : horizontalPadding),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(isDesktop ? 20 : isTablet ? 16 : 12),
                        ),
                        child: Column(
                          children: [
                            // Map Background - takes remaining space
                            Expanded(
                              child: _isMapLoading
                                  ? const Center(child: CircularProgressIndicator())
                                  : FutureBuilder<void>(
                                      future: _initializeMapAsync(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return const Center(child: CircularProgressIndicator());
                                        } else if (snapshot.hasError) {
                                          return Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.map_outlined, size: 48, color: Colors.grey),
                                                const SizedBox(height: 16),
                                                const Text(
                                                  'Google Maps Unavailable',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  snapshot.error.toString().contains('ApiNotActivated')
                                                      ? 'Google Maps API is not enabled.\nPlease enable it in Google Cloud Console.'
                                                      : 'Map failed to load. Check your internet connection.',
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(color: Colors.grey),
                                                ),
                                                const SizedBox(height: 16),
                                                ElevatedButton(
                                                  onPressed: _initializeMap,
                                                  child: const Text('Retry'),
                                                ),
                                              ],
                                            ),
                                          );
                                        } else {
                                          return GoogleMap(
                                            initialCameraPosition: CameraPosition(
                                              target: _currentPosition != null
                                                  ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                                                  : _defaultLocation,
                                              zoom: 14.0,
                                            ),
                                            markers: _markers,
                                            myLocationEnabled: true,
                                            myLocationButtonEnabled: true,
                                            mapType: MapType.normal,
                                            onMapCreated: _onMapCreated,
                                            onTap: _filterHostelsByMapLocation,
                                          );
                                        }
                                      },
                                    ),
                            ),

                            // Sliding Panel Overlay
                            TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0.4, end: 0.4),
                              duration: const Duration(milliseconds: 600),
                              builder: (context, heightFactor, child) {
                                return SizedBox(
                                  height: MediaQuery.of(context).size.height * heightFactor,
                                  child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 10,
                                            offset: Offset(0, -5),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 4,
                                            margin: const EdgeInsets.symmetric(vertical: 8),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.withValues(alpha: 0.3),
                                              borderRadius: BorderRadius.circular(2),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 16),
                                            child: Row(
                                              children: [
                                                _buildTab('Hostels', Icons.home, _activeTab == 'hostels'),
                                                _buildTab('Food', Icons.restaurant, _activeTab == 'food'),
                                                _buildTab('Transport', Icons.directions_car, _activeTab == 'transport'),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: ListView.builder(
                                              padding: EdgeInsets.only(
                                                left: isDesktop ? 32 : isTablet ? 24 : horizontalPadding,
                                                right: isDesktop ? 32 : isTablet ? 24 : horizontalPadding,
                                                top: isDesktop ? 16 : isTablet ? 12 : 8,
                                                bottom: isDesktop ? 32 : isTablet ? 24 : horizontalPadding,
                                              ),
                                              itemCount: _filteredHostels.length,
                                              itemBuilder: (context, index) {
                                                final hostel = _filteredHostels[index];
                                                return Container(
                                                  margin: EdgeInsets.only(bottom: isDesktop ? 16 : 12),
                                                  padding: EdgeInsets.all(isDesktop ? 16 : isTablet ? 14 : 12),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
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
                                                        width: isDesktop ? 80 : isTablet ? 72 : 64,
                                                        height: isDesktop ? 80 : isTablet ? 72 : 64,
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
                                                          image: DecorationImage(
                                                            image: NetworkImage(hostel['image'] as String),
                                                            fit: BoxFit.cover,
                                                            onError: (exception, stackTrace) {
                                                              // Fallback to asset image if network fails
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: isDesktop ? 16 : 12),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                Text(
                                                                  hostel['name'] as String,
                                                                  style: TextStyle(
                                                                    fontSize: isDesktop ? 18 : isTablet ? 16 : 14,
                                                                    fontWeight: FontWeight.bold,
                                                                  ),
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Container(
                                                                      padding: EdgeInsets.symmetric(
                                                                        horizontal: isDesktop ? 8 : 6,
                                                                        vertical: isDesktop ? 4 : 2,
                                                                      ),
                                                                      decoration: BoxDecoration(
                                                                        color: Colors.green.withValues(alpha: 0.1),
                                                                        borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
                                                                      ),
                                                                      child: Text(
                                                                        '0.5km',
                                                                        style: TextStyle(
                                                                          fontSize: isDesktop ? 12 : 10,
                                                                          color: Colors.green
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    IconButton(
                                                                      onPressed: () => _toggleFavorite(hostel['id'] as int),
                                                                      icon: Icon(
                                                                        (hostel['isFavorited'] as bool) ? Icons.favorite : Icons.favorite_border,
                                                                        size: isDesktop ? 16 : 12,
                                                                        color: (hostel['isFavorited'] as bool) ? Colors.red : null,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(height: isDesktop ? 8 : 4),
                                                            Row(
                                                              children: [
                                                                Icon(Icons.location_on, size: isDesktop ? 14 : 10, color: Colors.grey),
                                                                SizedBox(width: isDesktop ? 6 : 4),
                                                                Text(
                                                                  '${hostel['location']} • ${hostel['price']}',
                                                                  style: TextStyle(
                                                                    fontSize: isDesktop ? 14 : isTablet ? 12 : 10,
                                                                    color: Colors.grey
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(height: isDesktop ? 6 : 4),
                                                            Row(
                                                              children: [
                                                                Icon(Icons.star, size: isDesktop ? 16 : 12, color: Colors.yellow),
                                                                SizedBox(width: isDesktop ? 4 : 2),
                                                                Text(
                                                                  '${hostel['rating']} (${hostel['reviews']})',
                                                                  style: TextStyle(
                                                                    fontSize: isDesktop ? 14 : isTablet ? 12 : 10,
                                                                    color: Colors.grey
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(height: isDesktop ? 8 : 6),
                                                            Wrap(
                                                              spacing: isDesktop ? 8 : 4,
                                                              children: (hostel['amenities'] as List<String>).map((amenity) {
                                                                return Container(
                                                                  padding: EdgeInsets.symmetric(
                                                                    horizontal: isDesktop ? 8 : 6,
                                                                    vertical: isDesktop ? 4 : 2,
                                                                  ),
                                                                  decoration: BoxDecoration(
                                                                    color: Colors.grey.withValues(alpha: 0.2),
                                                                    borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
                                                                  ),
                                                                  child: Text(
                                                                    amenity,
                                                                    style: TextStyle(
                                                                      fontSize: isDesktop ? 12 : isTablet ? 10 : 8
                                                                    ),
                                                                  ),
                                                                );
                                                              }).toList(),
                                                            ),
                                                            SizedBox(height: isDesktop ? 12 : 8),
                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                  child: OutlinedButton(
                                                                    onPressed: () {},
                                                                    style: OutlinedButton.styleFrom(
                                                                      padding: EdgeInsets.symmetric(vertical: isDesktop ? 12 : 8),
                                                                    ),
                                                                    child: Text(
                                                                      'Directions',
                                                                      style: TextStyle(fontSize: isDesktop ? 14 : isTablet ? 12 : 10)
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(width: isDesktop ? 12 : isTablet ? 8 : 4),
                                                                Expanded(
                                                                  child: OutlinedButton(
                                                                    onPressed: () {},
                                                                    style: OutlinedButton.styleFrom(
                                                                      padding: EdgeInsets.symmetric(vertical: isDesktop ? 12 : 8),
                                                                    ),
                                                                    child: Text(
                                                                      'Details',
                                                                      style: TextStyle(fontSize: isDesktop ? 14 : isTablet ? 12 : 10)
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(width: isDesktop ? 12 : isTablet ? 8 : 4),
                                                                Expanded(
                                                                  child: ElevatedButton(
                                                                    onPressed: widget.onNavigateToBooking,
                                                                    style: ElevatedButton.styleFrom(
                                                                      backgroundColor: const Color(0xFF1976D2),
                                                                      padding: EdgeInsets.symmetric(vertical: isDesktop ? 12 : 8),
                                                                    ),
                                                                    child: Text(
                                                                      'Book',
                                                                      style: TextStyle(fontSize: isDesktop ? 14 : isTablet ? 12 : 10)
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
                                              },
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
                  );
                },
              ),
            ),

            // Bottom Navigation
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 20.0, end: 0.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, value),
                  child: Opacity(
                    opacity: 1.0 - (value / 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildNavItem(Icons.home, 'Home', true, () {}),
                          _buildNavItem(Icons.favorite, 'Wishlist', false, widget.onNavigateToWishlist),
                          _buildNavItem(Icons.calendar_today, 'Bookings', false, widget.onNavigateToBookingHistory),
                          _buildNavItem(Icons.person, 'Profile', false, widget.onNavigateToProfile),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getUserName() {
    // Get user name from Firebase Auth or app state
    try {
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      return user?.displayName ?? user?.email?.split('@')[0] ?? 'User';
    } catch (e) {
      return 'User';
    }
  }

  String _getProfileCompletion() {
    // Calculate profile completion based on available user data
    try {
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      int completion = 0;

      if (user?.displayName?.isNotEmpty == true) completion += 25;
      if (user?.email?.isNotEmpty == true) completion += 25;
      if (user?.phoneNumber?.isNotEmpty == true) completion += 25;
      if (user?.photoURL?.isNotEmpty == true) completion += 25;

      return completion.toString();
    } catch (e) {
      return '0';
    }
  }

  Widget _buildTab(String label, IconData icon, bool isActive) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktopLocal = screenSize.width >= 1024;
    final isTabletLocal = screenSize.width >= 600 && screenSize.width < 1024;

    return Expanded(
      child: GestureDetector(
        onTap: () => _switchTab(label.toLowerCase()),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: isDesktopLocal ? 16 : isTabletLocal ? 12 : 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? const Color(0xFF1976D2) : Colors.transparent,
                width: isDesktopLocal ? 3 : 2,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: isDesktopLocal ? 18 : isTabletLocal ? 16 : 12,
                color: isActive ? const Color(0xFF1976D2) : Colors.grey
              ),
              SizedBox(width: isDesktopLocal ? 10 : isTabletLocal ? 8 : 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: isDesktopLocal ? 16 : isTabletLocal ? 14 : 12,
                  color: isActive ? const Color(0xFF1976D2) : Colors.grey,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, VoidCallback? onTap) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktopLocal = screenSize.width >= 1024;
    final isTabletLocal = screenSize.width >= 600 && screenSize.width < 1024;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? const Color(0xFF1976D2) : Colors.grey,
            size: isDesktopLocal ? 20 : isTabletLocal ? 18 : 16,
          ),
          SizedBox(height: isDesktopLocal ? 6 : 4),
          Text(
            label,
            style: TextStyle(
              fontSize: isDesktopLocal ? 12 : isTabletLocal ? 11 : 10,
              color: isActive ? const Color(0xFF1976D2) : Colors.grey,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
