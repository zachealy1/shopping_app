import 'package:flutter/material.dart';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'store_detail_screen.dart';
import '../widgets/search_bar.dart';

/// A screen that displays a list of stores fetched from Firestore.
/// Stores are sorted by their distance from the user, and users may tap on a store
/// to view its details on a separate screen. The store data now includes a website URL.
class StoresScreen extends StatefulWidget {
  /// Callback to notify when the user chooses to open the map, returning
  /// details such as the map image URL and the selected store name.
  final ValueChanged<Map<String, dynamic>>? onMapOpen;

  const StoresScreen({super.key, this.onMapOpen});

  @override
  State<StoresScreen> createState() => _StoresScreenState();
}

class _StoresScreenState extends State<StoresScreen> {
  // User's latitude and longitude. These are initialised with fallback defaults.
  double _userLat = 0;
  double _userLon = 0;

  // List of stores fetched from Firestore.
  List<Map<String, dynamic>> _stores = [];
  // List of stores filtered based on the user's search query.
  List<Map<String, dynamic>> _filteredStores = [];
  // Controller for managing the search text input.
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch store data from Firestore.
    _fetchStores();
    // Attach a listener to update the filtered list when the search text changes.
    _searchController.addListener(_onSearchChanged);
    // Obtain the user's current location.
    _getUserLocation();
  }

  /// Fetches the list of stores from the Firestore collection 'stores'.
  /// Each document is expected to contain fields such as name, address, imageAsset,
  /// mapImageAsset, hours, description, lat, lon and websiteUrl.
  Future<void> _fetchStores() async {
    try {
      QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('stores').get();

      // Convert each Firestore document into a Map<String, String>.
      List<Map<String, dynamic>> fetchedStores = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          'name': data['name']?.toString() ?? '',
          'address': data['address']?.toString() ?? '',
          'imageAsset': data['imageAsset']?.toString() ?? '',
          'mapImageAsset': data['mapImageAsset']?.toString() ?? '',
          'hours': data['hours']?.toString() ?? '',
          'description': data['description']?.toString() ?? '',
          'lat': data['lat']?.toString() ?? '',
          'lon': data['lon']?.toString() ?? '',
          'websiteUrl': data['websiteUrl']?.toString() ?? '',
        };
      }).toList();

      setState(() {
        _stores = fetchedStores;
        _filteredStores = List.from(fetchedStores);
      });
    } catch (e) {
      print("Error fetching stores: $e");
      // Optionally, you may show an error message to the user here.
    }
  }

  /// Obtains the user's current location using the Geolocator package.
  /// Falls back to default coordinates if location services are disabled or permission is denied.
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
      // Obtain the current position with high accuracy and a timeout.
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

  /// Filters the list of stores based on the user's search query.
  void _onSearchChanged() {
    setState(() {
      final query = _searchController.text.toLowerCase();
      _filteredStores = _stores.where((store) {
        return (store['name']?.toLowerCase().contains(query) ?? false) ||
            (store['address']?.toLowerCase().contains(query) ?? false);
      }).toList();
    });
  }

  /// Converts degrees to radians.
  double _deg2rad(double deg) => deg * (pi / 180);

  /// Calculates the distance between two geographical points using the Haversine formula.
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // Earth's radius in kilometres.
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  /// Handles the user tapping on a store.
  /// Calculates the distance to the store, then navigates to the [StoreDetailScreen]
  /// passing all relevant store data, including the website URL.
  void _onStoreTap(Map<String, dynamic> store) async {
    // Parse the latitude and longitude from the store data.
    final storeLat = double.tryParse(store['lat']?.toString() ?? '') ?? 0;
    final storeLon = double.tryParse(store['lon']?.toString() ?? '') ?? 0;
    // Calculate the distance from the user to the store.
    final distanceKm =
    _calculateDistance(_userLat, _userLon, storeLat, storeLon);
    final distanceStr = '${distanceKm.toStringAsFixed(2)} km';
    final mapImageUrl = store['mapImageAsset'] ?? '';

    // Navigate to the StoreDetailScreen with the store information,
    // including the new websiteUrl field.
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
          websiteUrl: store['websiteUrl'] ?? '',
        ),
      ),
    );

    // If the result is not null, notify the caller via the onMapOpen callback.
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
    // Remove the search listener and dispose of the controller to free up resources.
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If the user's location is not available yet, show a loading spinner.
    if (_userLat == 0 && _userLon == 0) {
      return const Center(child: CircularProgressIndicator());
    }

    // Create a copy of the filtered stores and sort them by distance from the user.
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
        // Display the search bar at the top.
        SearchBarWidget(
          controller: _searchController,
          onSearchChanged: _onSearchChanged,
        ),
        // Display the list of stores in an expanded list view.
        Expanded(
          child: ListView.builder(
            itemCount: sortedStores.length,
            itemBuilder: (context, index) {
              final store = sortedStores[index];
              final storeLat =
                  double.tryParse(store['lat']?.toString() ?? '') ?? 0;
              final storeLon =
                  double.tryParse(store['lon']?.toString() ?? '') ?? 0;
              final distanceKm =
              _calculateDistance(_userLat, _userLon, storeLat, storeLon);
              return GestureDetector(
                // Handle tap on the store item.
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

  /// Builds an individual store item widget for display in the list.
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
          // Circular icon representing the store location.
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
          // Display the store name with the distance and its address.
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
          // Arrow icon indicating the item is tappable.
          const Icon(
            Icons.arrow_forward_ios,
            color: Colors.black54,
            size: 20,
          ),
        ],
      ),
    );
  }
}
