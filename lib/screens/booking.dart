import 'package:flutter/material.dart';

class BookingScreen extends StatelessWidget {
  final VoidCallback onBack;

  const BookingScreen({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
      ),
      body: const Center(
        child: Text('Booking Screen - Coming Soon'),
      ),
    );
  }
}