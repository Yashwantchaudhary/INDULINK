import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class InteractiveMapView extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback? onBookNow;

  const InteractiveMapView({super.key, required this.onBack, this.onBookNow});

  @override
  State<InteractiveMapView> createState() => _InteractiveMapViewState();
}

class HostelMarker {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final int price;
  final double rating;
  final String distance;
  final String image;
  final bool available;
  final String type;

  HostelMarker({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.price,
    required this.rating,
    required this.distance,
    required this.image,
    required this.available,
    required this.type,
  });
}

class _InteractiveMapViewState extends State<InteractiveMapView> {
  String? selectedHostel;
  bool showFilters = false;
  String searchQuery = '';
  late GoogleMapController mapController;
  Set<Marker> markers = {};
  Set<Circle> circles = {}; // For highlighting Kathmandu area

  final List<HostelMarker> hostels = [
    // Kathmandu City Hostels - Real locations around Kathmandu
    HostelMarker(
      id: '1',
      name: 'Thamel Modern Hostel',
      latitude: 27.7154,  // Thamel area, Kathmandu
      longitude: 85.3108,
      price: 8000,
      rating: 4.8,
      distance: '0.5 km from Thamel',
      image: 'https://images.unsplash.com/photo-1697603899008-a4027a95fd95?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxob3N0ZWwlMjByb29tJTIwaW50ZXJpb3J8ZW58MXx8fHwxNzU4NTI0MjQ1fDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
      available: true,
      type: 'hostel',
    ),
    HostelMarker(
      id: '2',
      name: ' Boudha Deluxe PG',
      latitude: 27.7214,  // Boudha area, Kathmandu
      longitude: 85.3622,
      price: 9500,
      rating: 4.6,
      distance: '1.2 km from Boudha Stupa',
      image: 'https://images.unsplash.com/photo-1582719388123-e03e25d06d51?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxob3N0ZWwlMjBidWlsZGluZyUyMGFjY29tbW9kYXRpb258ZW58MXx8fHwxNzU4NTIzOTgyfDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
      available: true,
      type: 'pg',
    ),
    HostelMarker(
      id: '3',
      name: 'Patan Campus Lodge',
      latitude: 27.6730,  // Patan area, near Kathmandu
      longitude: 85.3188,
      price: 7500,
      rating: 4.4,
      distance: '2.1 km from Patan Durbar',
      image: 'https://images.unsplash.com/photo-1623334663819-1bb79f9f03f8?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtb2Rlcm4lMjBob3N0ZWwlMjBpbnRlcmlvcnxlbnwxfHx8fDE3NTg1MjAwMDZ8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
      available: false,
      type: 'hostel',
    ),
    HostelMarker(
      id: '4',
      name: 'Swayambhu Student Home',
      latitude: 27.7148,  // Swayambhunath area, Kathmandu
      longitude: 85.2882,
      price: 6500,
      rating: 4.7,
      distance: '1.8 km from Swayambhunath',
      image: 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxzdHVkZW50JTIwZG9ybWl0b3J5fGVufDF8fHx8MTc1ODUyNDI0NXww&ixlib=rb-4.1.0&q=80&w=1080',
      available: true,
      type: 'hostel',
    ),
    HostelMarker(
      id: '5',
      name: 'New Baneshwor PG',
      latitude: 27.6930,  // New Baneshwor area, Kathmandu
      longitude: 85.3368,
      price: 8500,
      rating: 4.5,
      distance: '0.8 km from New Baneshwor',
      image: 'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxwZyUyMGFjY29tbW9kYXRpb258ZW58MXx8fHwxNzU4NTI0MjQ1fDA&ixlib=rb-4.1.0&q=80&w=1080',
      available: true,
      type: 'pg',
    ),
    HostelMarker(
      id: '6',
      name: 'Kathmandu University Lodge',
      latitude: 27.6190,  // Near Kathmandu University, Dhulikhel
      longitude: 85.5428,
      price: 7000,
      rating: 4.3,
      distance: '3.2 km from KU Gate',
      image: 'https://images.unsplash.com/photo-1598300042247-d088f8ab3a91?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx1bml2ZXJzaXR5JTIwZG9ybWl0b3J5fGVufDF8fHx8MTc1ODUyNDI0NXww&ixlib=rb-4.1.0&q=80&w=1080',
      available: true,
      type: 'hostel',
    ),
  ];

  HostelMarker? get selectedHostelData => hostels.firstWhere(
        (h) => h.id == selectedHostel,
        orElse: () => HostelMarker(
          id: '',
          name: '',
          latitude: 0,
          longitude: 0,
          price: 0,
          rating: 0,
          distance: '',
          image: '',
          available: false,
          type: '',
        ),
      );

  @override
  void initState() {
    super.initState();
    selectedHostel = '1';
    _loadMarkers();
  }

  void _loadMarkers() {
    markers.clear();
    circles.clear();

    // Add Kathmandu city center marker
    final kathmanduCenterMarker = Marker(
      markerId: const MarkerId('kathmandu_center'),
      position: const LatLng(27.7172, 85.3240), // Kathmandu city center
      onTap: () {
        setState(() => selectedHostel = null); // Deselect any hostel
        _animateToKathmanduCenter();
      },
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: const InfoWindow(
        title: 'Kathmandu City Center',
        snippet: 'Capital of Nepal',
      ),
    );
    markers.add(kathmanduCenterMarker);

    // Add hostel markers
    for (var hostel in hostels) {
      final markerId = MarkerId(hostel.id);
      final marker = Marker(
        markerId: markerId,
        position: LatLng(hostel.latitude, hostel.longitude),
        onTap: () {
          setState(() => selectedHostel = hostel.id);
          _animateToLocation(hostel.latitude, hostel.longitude);
        },
        icon: BitmapDescriptor.defaultMarkerWithHue(
          hostel.available ? BitmapDescriptor.hueBlue : BitmapDescriptor.hueRed,
        ),
        infoWindow: InfoWindow(
          title: hostel.name,
          snippet: '₹${hostel.price}/mo • ${hostel.distance}',
        ),
      );
      markers.add(marker);
    }

    // Add a circle to highlight Kathmandu metropolitan area
    final kathmanduCircle = Circle(
      circleId: const CircleId('kathmandu_area'),
      center: const LatLng(27.7172, 85.3240),
      radius: 15000, // 15km radius
      fillColor: const Color(0xFF1976D2).withValues(alpha: 0.1),
      strokeColor: const Color(0xFF1976D2).withValues(alpha: 0.3),
      strokeWidth: 2,
    );
    circles.add(kathmanduCircle);
  }

  void _animateToLocation(double latitude, double longitude) {
    mapController.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(latitude, longitude), 16.0),
    );
  }

  void _animateToKathmanduCenter() {
    // Animate to Kathmandu city center
    _animateToLocation(27.7172, 85.3240);
  }

  void _animateToCurrentLocation() {
    // For demo purposes, animate to Kathmandu city center
    // In a real app, you'd get the user's current location using geolocator
    _animateToKathmanduCenter();
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

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
            // Top Controls
            TweenAnimationBuilder<double>(
              tween: Tween(begin: -20.0, end: 0.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, value),
                  child: Opacity(
                    opacity: 1.0 + (value / 20.0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: widget.onBack,
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.search, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: TextEditingController(text: searchQuery),
                                      onChanged: (value) => setState(() => searchQuery = value),
                                      decoration: const InputDecoration(
                                        hintText: 'Search area, landmark...',
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () => setState(() => showFilters = !showFilters),
                            icon: const Icon(Icons.tune, color: Colors.white),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // Filters Panel
            if (showFilters)
              TweenAnimationBuilder<double>(
                tween: Tween(begin: -20.0, end: 0.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, value),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildFilterChip('Price: ₹5K-10K'),
                          _buildFilterChip('Rating: 4+'),
                          _buildFilterChip('Distance: <2km'),
                          _buildFilterChip('Available Now'),
                        ],
                      ),
                    ),
                  );
                },
              ),

            // Map Container
            Expanded(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Stack(
                      children: [
                        GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: LatLng(27.7172, 85.3240), // Center of Kathmandu city
                            zoom: 12.0, // Zoom level to show Kathmandu city area
                          ),
                          markers: markers,
                          circles: circles,
                          onMapCreated: (GoogleMapController controller) {
                            mapController = controller;
                            // After map is created, animate to Kathmandu city center first
                            Future.delayed(const Duration(milliseconds: 500), () {
                              _animateToKathmanduCenter();
                            });
                          },
                          onTap: (LatLng position) {
                            // Handle map tap if needed
                          },
                          mapType: MapType.normal,
                          myLocationEnabled: false, // Disable for now, can be enabled with proper permissions
                          myLocationButtonEnabled: false,
                          zoomControlsEnabled: true,
                          zoomGesturesEnabled: true,
                          scrollGesturesEnabled: true,
                          tiltGesturesEnabled: true,
                          rotateGesturesEnabled: true,
                        ),

                        // Map Controls
                        Positioned(
                          bottom: selectedHostelData!.id.isNotEmpty ? 200 : 100,
                          right: 16,
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 20.0, end: 0.0),
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeOut,
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(value, 0),
                                child: Column(
                                  children: [
                                    _buildMapControlButton(Icons.location_city, () {
                                      // Go to Kathmandu city center
                                      _animateToKathmanduCenter();
                                      setState(() => selectedHostel = null);
                                    }),
                                    const SizedBox(height: 8),
                                    _buildMapControlButton(Icons.navigation, () {
                                      if (selectedHostelData!.id.isNotEmpty) {
                                        _animateToLocation(selectedHostelData!.latitude, selectedHostelData!.longitude);
                                      }
                                    }),
                                    const SizedBox(height: 8),
                                    _buildMapControlButton(Icons.gps_fixed, _animateToCurrentLocation),
                                    const SizedBox(height: 8),
                                    _buildMapControlButton(Icons.refresh, () {
                                      setState(() {
                                        _loadMarkers();
                                      });
                                    }),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Sheet - Hostel Details
            if (selectedHostelData!.id.isNotEmpty)
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 100.0, end: 0.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, value),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: NetworkImage(selectedHostelData!.image),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          selectedHostelData!.name,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {},
                                          icon: const Icon(Icons.favorite_border),
                                          iconSize: 20,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.star, size: 16, color: Colors.yellow),
                                        const SizedBox(width: 4),
                                        Text('${selectedHostelData!.rating}'),
                                        const SizedBox(width: 12),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: selectedHostelData!.type == 'hostel'
                                                ? const Color(0xFF1976D2).withValues(alpha: 0.1)
                                                : const Color(0xFF7C4DFF).withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            selectedHostelData!.type.toUpperCase(),
                                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '₹${selectedHostelData!.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}/mo',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF1976D2),
                                              ),
                                            ),
                                            Text(
                                              selectedHostelData!.distance,
                                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                        if (!selectedHostelData!.available)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.red.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: const Text(
                                              'Occupied',
                                              style: TextStyle(fontSize: 10, color: Colors.red),
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
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.directions),
                                  label: const Text('Get Directions'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: selectedHostelData!.available ? widget.onBookNow : null,
                                  icon: const Icon(Icons.calendar_today),
                                  label: Text(selectedHostelData!.available ? 'View Details' : 'Unavailable'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1976D2),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

            // Location Controls Bar
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 50.0, end: 0.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, value),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {
                            _animateToKathmanduCenter();
                            setState(() => selectedHostel = null);
                          },
                          icon: const Icon(Icons.location_city),
                          label: const Text('Kathmandu Center'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: _animateToCurrentLocation,
                          icon: const Icon(Icons.my_location),
                          label: const Text('Current Location'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _loadMarkers();
                            });
                          },
                          icon: const Icon(Icons.refresh),
                          tooltip: 'Refresh Map',
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
    );
  }

  Widget _buildFilterChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF1976D2)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF1976D2),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }


  Widget _buildMapControlButton(IconData icon, VoidCallback onPressed) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 20, color: Colors.grey),
        padding: EdgeInsets.zero,
      ),
    );
  }
}