import 'package:flutter/material.dart';
import 'store_detail_screen.dart'; // Import StoreDetailScreen

class StoresScreen extends StatefulWidget {
  const StoresScreen({super.key});

  @override
  State<StoresScreen> createState() => _StoresScreenState();
}

class _StoresScreenState extends State<StoresScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, String>> _stores = [
    {
      'name': 'Aldi Swansea',
      'distance': '0.1 km',
      'address': 'Unit 1, Parc Tawe, Swansea SA1 2AS',
      'imageAsset': 'assets/images/aldi.jpg',
      'hours': 'Monday to Saturday: 8:00 AM – 8:00 PM; Sunday: 10:00 AM – 4:00 PM.',
      'description': 'This store offers a range of groceries, fresh produce, and household essentials at low prices.',
    },
    {
      'name': 'Tesco Extra',
      'distance': '0.5 km',
      'address': 'Albert Row, Swansea SA1 3RA',
      'imageAsset': 'assets/images/tesco.jpg',
      'hours': 'Monday to Saturday: 6:00 AM – 10:00 PM; Sunday: 10:00 AM – 4:00 PM.',
      'description': 'Tesco Extra offers groceries, clothing, electronics, and home goods. Facilities include a café and cash machines.',
    },
    {
      'name': 'Lidl Swansea',
      'distance': '1.0 km',
      'address': 'Trinity Place, Swansea SA1 2DQ',
      'imageAsset': 'assets/images/lidl.jpg',
      'hours': 'Monday to Saturday: 8:00 AM – 10:00 PM; Sunday: 10:00 AM – 4:00 PM.',
      'description': 'Lidl Swansea provides fresh produce, bakery items, and quality household products at low prices.',
    },
    {
      'name': 'Sainsbury\'s',
      'distance': '1.5 km',
      'address': 'Quay Parade, Swansea SA1 8AJ',
      'imageAsset': 'assets/images/sainsburys.jpg',
      'hours': 'Monday to Saturday: 7:00 AM – 9:00 PM; Sunday: 10:00 AM – 4:00 PM.',
      'description': 'Sainsbury\'s offers groceries, clothing, electronics, and home essentials. Services include a café, pharmacy, and photo booth.',
    },
  ];

  List<Map<String, String>> _filteredStores = [];

  @override
  void initState() {
    super.initState();
    _filteredStores = _stores;
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _filteredStores = _stores.where((store) {
        final query = _searchController.text.toLowerCase();
        return store['name']!.toLowerCase().contains(query) ||
            store['address']!.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _onStoreTap(Map<String, String> store) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoreDetailScreen(
          name: store['name'] ?? 'No Name Available',
          distance: store['distance'] ?? 'N/A',
          address: store['address'] ?? 'No Address Available',
          imageUrl: store['imageAsset'] ?? 'assets/images/default_image.jpg',
          hours: store['hours'] ?? 'No Hours Available',
          description: store['description'] ?? 'No Description Available',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        // Store List
        Expanded(
          child: ListView.builder(
            itemCount: _filteredStores.length,
            itemBuilder: (context, index) {
              final store = _filteredStores[index];
              return GestureDetector(
                onTap: () => _onStoreTap(store), // Navigate to StoreDetailScreen
                child: _buildStoreItem(
                  name: store['name']!,
                  distance: store['distance']!,
                  address: store['address']!,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStoreItem({required String name, required String distance, required String address}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        children: [
          // Icon
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

          // Store Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$name ($distance)',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D2520),
                  ),
                ),
                Text(
                  address,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Arrow Icon
          const Icon(Icons.arrow_forward_ios, color: Colors.black54, size: 20),
        ],
      ),
    );
  }
}
