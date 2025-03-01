import 'package:flutter/material.dart';

class StoreDetailScreen extends StatelessWidget {
  final String name;
  final String distance;
  final String address;
  final String imageUrl;
  final String hours;
  final String description;
  final String? mapImageUrl;

  const StoreDetailScreen({
    super.key,
    required this.name,
    required this.distance,
    required this.address,
    required this.imageUrl,
    required this.hours,
    required this.description,
    this.mapImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7FE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF7FE),
        scrolledUnderElevation: 0.0,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Store',
          style: TextStyle(
            color: Color(0xFF1D2520),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              color: const Color(0xFFFDF7FE),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1ECF7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.place, color: Color(0xFF1D2520), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$name ($distance)',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1D2520),
                          ),
                        ),
                        Text(
                          address,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Image.asset(
              imageUrl,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                hours,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                description,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Return the selected tab, map image URL, and store name to the caller.
                  Navigator.of(context).pop({
                    'selectedTab': 0,
                    'mapImageUrl': mapImageUrl ?? imageUrl,
                    'storeName': name,
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A4CAF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  elevation: 0,
                ),
                child: const Text(
                  'Open Map',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
