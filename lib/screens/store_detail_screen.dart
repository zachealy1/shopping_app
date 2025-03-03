import 'package:flutter/material.dart';
import 'package:url_launcher/link.dart';

/// A stateless screen displaying detailed information about a store.
/// This screen shows store details such as name, address, operating hours, description,
/// an image, and now includes a website section that displays the store's website as a clickable link.
class StoreDetailScreen extends StatelessWidget {
  /// The name of the store.
  final String name;
  /// The distance from the user to the store.
  final String distance;
  /// The store's address.
  final String address;
  /// The asset path of the store's image.
  final String imageUrl;
  /// The operating hours of the store.
  final String hours;
  /// A description of the store.
  final String description;
  /// An optional map image URL to be used when returning to the map.
  final String? mapImageUrl;
  /// The store's website URL.
  final String websiteUrl;

  const StoreDetailScreen({
    super.key,
    required this.name,
    required this.distance,
    required this.address,
    required this.imageUrl,
    required this.hours,
    required this.description,
    this.mapImageUrl,
    required this.websiteUrl,
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
            // Top section with store details.
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
            // Store image.
            Image.asset(
              imageUrl,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 16),
            // Store name displayed prominently.
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
            // Display operating hours.
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
            // Display store description.
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
            const SizedBox(height: 16),
            // Website section: display the website as a clickable text link.
            if (websiteUrl.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Text(
                      'Visit Website: ',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    Link(
                      // Open the URL in a new browser tab.
                      target: LinkTarget.blank,
                      uri: Uri.parse(websiteUrl),
                      builder: (context, followLink) => GestureDetector(
                        onTap: followLink,
                        child: Text(
                          websiteUrl,
                          style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 32),
            // Button to return to the map screen, passing relevant data.
            Center(
              child: ElevatedButton(
                onPressed: () {
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
