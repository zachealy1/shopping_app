import 'package:flutter/material.dart';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  // Initially empty; will be populated from Firestore.
  List<Map<String, dynamic>> _stores = [];
  List<Map<String, dynamic>> _filteredStores = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchStores(); // Fetch stores from Firestore.
    _searchController.addListener(_onSearchChanged);
    _getUserLocation();
  }

  // Fetch the stores from the Firestore collection "stores"
  Future<void> _fetchStores() async {
    try {
      QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('stores').get();

      // Convert each document into a map.
      List<Map<String, dynamic>> fetchedStores = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      setState(() {
        _stores = fetchedStores;
        _filteredStores = List.from(fetchedStores);
      });
    } catch (e) {
      print("Error fetching stores: $e");
      // Optionally, you might show an error message to the user.
    }
  }

  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
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
        return (store['name']?.toLowerCase().contains(query) ?? false) ||
            (store['address']?.toLowerCase().contains(query) ?? false);
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

  void _onStoreTap(Map<String, dynamic> store) async {
    final storeLat = double.tryParse(store['lat']?.toString() ?? '') ?? 0;
    final storeLon = double.tryParse(store['lon']?.toString() ?? '') ?? 0;
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

    final sortedStores = List<Map<String, dynamic>>.from(_filteredStores);
    sortedStores.sort((a, b) {
      final aLat = double.tryParse(a['lat']?.toString() ?? '') ?? 0;
      final aLon = double.tryParse(a['lon']?.toString() ?? '') ?? 0;
      final bLat = double.tryParse(b['lat']?.toString() ?? '') ?? 0;
      final bLon = double.tryParse(b['lon']?.toString() ?? '') ?? 0;
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
              final storeLat = double.tryParse(store['lat']?.toString() ?? '') ?? 0;
              final storeLon = double.tryParse(store['lon']?.toString() ?? '') ?? 0;
              final distanceKm =
              _calculateDistance(_userLat, _userLon, storeLat, storeLon);
              return GestureDetector(
                onTap: () => _onStoreTap(store),
                child: _buildStoreItem(
                  name: store['name'] ?? '',
                  distance: '${distanceKm.toStringAsFixed(2)} km',
                  address: store['address'] ?? '',
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
            child:
            const Icon(Icons.place, color: Color(0xFF1D2520), size: 24),
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
          const Icon(Icons.arrow_forward_ios,
              color: Colors.black54, size: 20),
        ],
      ),
    );
  }
}
