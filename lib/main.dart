import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'screens/map_screen.dart';
import 'screens/stores_screen.dart';
import 'screens/list_screen.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/header_widget.dart';
import 'theme/app_theme.dart';

/// The entry point of the application. This function initialises Firebase
/// and then runs the [MyApp] widget.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

/// The root widget of the application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: AppTheme.theme,
      home: const HomePage(),
    );
  }
}

/// The HomePage widget manages the main navigation of the app, including
/// the Map, Stores, and List screens. It fetches store data from Firestore,
/// obtains the user's location, and determines the default store to display.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Index for the currently selected bottom navigation item.
  int _selectedIndex = 0;

  // Initial list of shopping lists.
  final List<String> _shoppingLists = [
    'Aldi Shopping List',
    'Lidl Shopping List',
    'Sainsbury’s Shopping List',
    'Tesco Shopping List',
  ];

  // List of stores fetched from Firestore. Each store is represented as a map.
  List<Map<String, String>> _stores = [];

  // Screens to be displayed (Map, Stores and List). The first screen will be updated
  // with the default store data based on the user's location.
  late List<Map<String, dynamic>> _screens;

  // The user's current latitude and longitude.
  double _userLat = 0;
  double _userLon = 0;

  @override
  void initState() {
    super.initState();

    // Initialise the screens with default placeholders.
    _screens = [
      {
        'title': 'Map',
        'widget': const MapScreen(mapImageUrl: '', supermarket: 'Aldi Swansea'),
        'showAddButton': false,
      },
      {
        'title': 'Stores',
        'widget': StoresScreen(
          // Callback invoked when a store is selected to open the map.
          onMapOpen: (result) {
            setState(() {
              _selectedIndex = result['selectedTab'] as int;
              // Update the map screen with the new map image URL and selected store name.
              _screens[0] = {
                'title': 'Map (${result['storeName'] as String})',
                'widget': MapScreen(
                  key: const ValueKey('MapScreen'),
                  mapImageUrl: result['mapImageUrl'] as String,
                  supermarket: result['storeName'] as String,
                ),
                'showAddButton': false,
              };
            });
          },
        ),
        'showAddButton': false,
      },
      {
        'title': 'List',
        'widget': ListScreen(shoppingLists: _shoppingLists),
        'showAddButton': true,
      },
    ];

    // First, fetch the store data from Firestore. Once completed, obtain the user's location
    // and update the default map accordingly.
    _fetchStores().then((_) {
      _getUserLocationAndSetDefaultMap();
    });
  }

  /// Fetches the list of stores from the Firestore 'stores' collection.
  /// Each document is expected to contain fields such as 'name', 'address',
  /// 'imageAsset', 'mapImageAsset', 'hours', 'description', 'lat', and 'lon'.
  Future<void> _fetchStores() async {
    try {
      QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('stores').get();

      // Convert each document to a Map<String, String>
      List<Map<String, String>> fetchedStores = snapshot.docs.map((doc) {
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
        };
      }).toList();

      setState(() {
        _stores = fetchedStores;
      });
    } catch (e) {
      print('Error fetching stores: $e');
    }
  }

  /// Determines the supermarket to use based on the store name.
  /// Returns a default value if [storeName] is empty.
  String _getSupermarket(String storeName) {
    if (storeName.isEmpty) {
      return "Aldi Swansea";
    } else {
      return storeName;
    }
  }

  /// Obtains the user's current location and updates the default map screen based
  /// on the nearest store from the fetched list.
  Future<void> _getUserLocationAndSetDefaultMap() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Use fallback coordinates if location services are disabled.
        _userLat = 51.616753;
        _userLon = -3.944417;
      } else {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            _userLat = 51.616753;
            _userLon = -3.944417;
          }
        }
        if (permission == LocationPermission.deniedForever) {
          _userLat = 51.616753;
          _userLon = -3.944417;
        }
        if (permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse) {
          // Request the current position with high accuracy.
          Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );
          _userLat = position.latitude;
          _userLon = position.longitude;
        }
      }
    } catch (e) {
      // In case of an error, fallback to default coordinates.
      _userLat = 51.616753;
      _userLon = -3.944417;
    }

    // Create a copy of the fetched stores and sort them by distance from the user.
    List<Map<String, String>> sortedStores = List.from(_stores);
    sortedStores.sort((a, b) {
      double aLat = double.tryParse(a['lat']!) ?? 0;
      double aLon = double.tryParse(a['lon']!) ?? 0;
      double bLat = double.tryParse(b['lat']!) ?? 0;
      double bLon = double.tryParse(b['lon']!) ?? 0;
      double distanceA = _calculateDistance(_userLat, _userLon, aLat, aLon);
      double distanceB = _calculateDistance(_userLat, _userLon, bLat, bLon);
      return distanceA.compareTo(distanceB);
    });

    // Use the closest store to update the default map screen.
    String defaultMapImageUrl = sortedStores.isNotEmpty
        ? sortedStores.first['mapImageAsset'] ?? ''
        : '';
    String storeName =
    sortedStores.isNotEmpty ? sortedStores.first['name']! : 'Aldi';
    String supermarket = _getSupermarket(storeName);

    setState(() {
      _screens[0] = {
        'title': 'Map ($supermarket)',
        'widget': MapScreen(mapImageUrl: defaultMapImageUrl, supermarket: supermarket),
        'showAddButton': false,
      };
    });

    // Notify the user about the nearest store.
    String nearestStoreName =
    sortedStores.isNotEmpty ? sortedStores.first['name']! : 'Unknown';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Nearest Store Determined"),
          content: Text(
              "The nearest store is $nearestStoreName. The default map has been updated accordingly."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
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

  /// Handles bottom navigation item taps.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// Displays a dialog to add a new shopping list.
  void _onAddButtonPressed() {
    TextEditingController listController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New List'),
          content: TextField(
            controller: listController,
            decoration: const InputDecoration(hintText: 'Enter list name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (listController.text.isNotEmpty) {
                  setState(() {
                    _shoppingLists.add(listController.text);
                    // Update the ListScreen with the new shopping lists.
                    _screens[2]['widget'] =
                        ListScreen(shoppingLists: _shoppingLists);
                  });
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A4CAF),
                foregroundColor: Colors.white,
              ),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Display a custom header with the current screen title and add button if applicable.
      appBar: HeaderWidget(
        title: _screens[_selectedIndex]['title'],
        showAddButton: _screens[_selectedIndex]['showAddButton'],
        onAddPressed: _screens[_selectedIndex]['showAddButton']
            ? _onAddButtonPressed
            : null,
      ),
      // Display the currently selected screen (Map, Stores or List).
      body: _screens[_selectedIndex]['widget'],
      // Bottom navigation bar for switching between different screens.
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
