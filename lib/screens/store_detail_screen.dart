import 'package:flutter/material.dart';

/// A stateless screen displaying detailed information about a store.
/// This screen shows store details such as name, address, opening hours,
/// description and an image, along with a button to navigate back to the map.
class StoreDetailScreen extends StatelessWidget {
  /// The name of the store.
  final String name;
  /// The distance from the user to the store.
  final String distance;
  /// The address of the store.
  final String address;
  /// The asset path of the store's image.
  final String imageUrl;
  /// The opening hours of the store.
  final String hours;
  /// A description of the store.
  final String description;
  /// Optional map image URL, used when returning to the map.
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
      // Set a light background colour for the screen.
      backgroundColor: const Color(0xFFFDF7FE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF7FE),
        scrolledUnderElevation: 0.0,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        centerTitle: true,
        // The app bar title is set to 'Store' (could be updated to include the store name if required).
        title: const Text(
          'Store',
          style: TextStyle(
            color: Color(0xFF1D2520),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      // The body is wrapped in a SingleChildScrollView to support scrolling on smaller devices.
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top container displaying basic store details.
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              color: const Color(0xFFFDF7FE),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Circular icon representing the store's location.
                  Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1ECF7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.place,
                      color: Color(0xFF1D2520),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Column containing the store name (with distance) and its address.
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
            // Display the store image.
            Image.asset(
              imageUrl,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 16),
            // Display the store name prominently.
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
            // Display the store's operating hours.
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
            // Display the store description.
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
            // Button to return to the map screen, passing relevant data.
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Pop the current screen and return the selected tab, map image URL, and store name.
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
