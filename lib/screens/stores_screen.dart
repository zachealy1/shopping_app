import 'package:flutter/material.dart';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'store_detail_screen.dart';
import '../widgets/search_bar.dart';

class StoresScreen extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>>? onMapOpen;

  const StoresScreen({super.key, this.onMapOpen});

  @override
  State<StoresScreen> createState() => _StoresScreenState();
}

class _StoresScreenState extends State<StoresScreen> {
  double _userLat = 0;
  double _userLon = 0;

  final List<Map<String, String>> _stores = [
    {
      'name': 'Aldi Swansea',
      'address': 'Unit 1, Parc Tawe, Swansea SA1 2AS',
      'imageAsset': 'assets/images/aldi.jpg',
      'mapImageAsset': 'assets/images/aldi-map.png',
      'hours': 'Monday to Saturday: 8:00 AM – 8:00 PM; Sunday: 10:00 AM – 4:00 PM.',
      'description':
      'This store offers a range of groceries, fresh produce, and household essentials at low prices.',
      'lat': '51.621139',
      'lon': '-3.938108',
    },
    {
      'name': 'Tesco Extra',
      'address': 'Albert Row, Swansea SA1 3RA',
      'imageAsset': 'assets/images/tesco.jpg',
      'mapImageAsset': 'assets/images/tesco-map.png',
      'hours': 'Monday to Saturday: 6:00 AM – 10:00 PM; Sunday: 10:00 AM – 4:00 PM.',
      'description':
      'Tesco Extra offers groceries, clothing, electronics, and home goods. Facilities include a café and cash machines.',
      'lat': '51.616753',
      'lon': '-3.944417',
    },
    {
      'name': 'Lidl Swansea',
      'address': 'Trinity Place, Swansea SA1 2DQ',
      'imageAsset': 'assets/images/lidl.jpg',
      'mapImageAsset': 'assets/images/lidl-map.png',
      'hours': 'Monday to Saturday: 8:00 AM – 10:00 PM; Sunday: 10:00 AM – 4:00 PM.',
      'description':
      'Lidl Swansea provides fresh produce, bakery items, and quality household products at low prices.',
      'lat': '51.624111',
      'lon': '-3.939608',
    },
    {
      'name': 'Sainsbury\'s',
      'address': 'Quay Parade, Swansea SA1 8AJ',
      'imageAsset': 'assets/images/sainsburys.jpg',
      'mapImageAsset': 'assets/images/sainsburys-map.png',
      'hours': 'Monday to Saturday: 7:00 AM – 9:00 PM; Sunday: 10:00 AM – 4:00 PM.',
      'description':
      'Sainsbury\'s offers groceries, clothing, electronics, and home essentials. Services include a café, pharmacy, and photo booth.',
      'lat': '51.620128',
      'lon': '-3.935925',
    },
  ];

  List<Map<String, String>> _filteredStores = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredStores = List.from(_stores);
    _searchController.addListener(_onSearchChanged);
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Fallback to default coordinates.
        setState(() {
          _userLat = 51.616753;
          _userLon = -3.944417;
        });
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _userLat = 51.616753;
            _userLon = -3.944417;
          });
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _userLat = 51.616753;
          _userLon = -3.944417;
        });
        return;
      }
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        return Position(
          latitude: 51.616753,
          longitude: -3.944417,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );
      });
      setState(() {
        _userLat = position.latitude;
        _userLon = position.longitude;
      });
    } catch (e) {
      setState(() {
        _userLat = 51.616753;
        _userLon = -3.944417;
      });
    }
  }

  void _onSearchChanged() {
    setState(() {
      final query = _searchController.text.toLowerCase();
      _filteredStores = _stores.where((store) {
        return store['name']!.toLowerCase().contains(query) ||
            store['address']!.toLowerCase().contains(query);
      }).toList();
    });
  }

  double _deg2rad(double deg) => deg * (pi / 180);

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const R = 6371;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  void _onStoreTap(Map<String, String> store) async {
    final storeLat = double.tryParse(store['lat'] ?? '') ?? 0;
    final storeLon = double.tryParse(store['lon'] ?? '') ?? 0;
    final distanceKm =
    _calculateDistance(_userLat, _userLon, storeLat, storeLon);
    final distanceStr = '${distanceKm.toStringAsFixed(2)} km';
    final mapImageUrl = store['mapImageAsset'] ?? '';

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoreDetailScreen(
          name: store['name'] ?? 'No Name Available',
          distance: distanceStr,
          address: store['address'] ?? 'No Address Available',
          imageUrl: store['imageAsset'] ?? '',
          hours: store['hours'] ?? '',
          description: store['description'] ?? '',
          mapImageUrl: mapImageUrl,
        ),
      ),
    );

    if (result != null && result is Map) {
      if (widget.onMapOpen != null) {
        widget.onMapOpen!(result as Map<String, dynamic>);
      } else {
        Navigator.of(context).pop(result);
      }
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_userLat == 0 && _userLon == 0) {
      return const Center(child: CircularProgressIndicator());
    }

    final sortedStores = List<Map<String, String>>.from(_filteredStores);
    sortedStores.sort((a, b) {
      final aLat = double.tryParse(a['lat']!) ?? 0;
      final aLon = double.tryParse(a['lon']!) ?? 0;
      final bLat = double.tryParse(b['lat']!) ?? 0;
      final bLon = double.tryParse(b['lon']!) ?? 0;
      final distanceA = _calculateDistance(_userLat, _userLon, aLat, aLon);
      final distanceB = _calculateDistance(_userLat, _userLon, bLat, bLon);
      return distanceA.compareTo(distanceB);
    });

    return Column(
      children: [
        SearchBarWidget(
          controller: _searchController,
          onSearchChanged: _onSearchChanged,
        ),
        Expanded(
          child: ListView.builder(
            itemCount: sortedStores.length,
            itemBuilder: (context, index) {
              final store = sortedStores[index];
              final storeLat = double.tryParse(store['lat'] ?? '') ?? 0;
              final storeLon = double.tryParse(store['lon'] ?? '') ?? 0;
              final distanceKm =
              _calculateDistance(_userLat, _userLon, storeLat, storeLon);
              return GestureDetector(
                onTap: () => _onStoreTap(store),
                child: _buildStoreItem(
                  name: store['name']!,
                  distance: '${distanceKm.toStringAsFixed(2)} km',
                  address: store['address']!,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStoreItem({
    required String name,
    required String distance,
    required String address,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12)),
      ),
      child: Row(
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
          const Icon(Icons.arrow_forward_ios, color: Colors.black54, size: 20),
        ],
      ),
    );
  }
}
