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

/// The entry point of the application. This function initializes Firebase
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
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

/// The HomePage widget manages the main navigation of the app, including
/// the Map, Stores, and List screens.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Index for the currently selected bottom navigation item.
  int _selectedIndex = 0;

  // GlobalKey to access ListScreen's state.
  final GlobalKey<ListScreenState> _listScreenKey = GlobalKey<ListScreenState>();

  // List of stores fetched from Firestore.
  List<Map<String, String>> _stores = [];

  // Screens to be displayed (Map, Stores, and List).
  late List<Map<String, dynamic>> _screens;

  // The user's current latitude and longitude.
  double _userLat = 0;
  double _userLon = 0;

  @override
  void initState() {
    super.initState();

    // Initialize the screens.
    _screens = [
      {
        'title': 'Map',
        'widget': const MapScreen(mapImageUrl: '', supermarket: 'Aldi Swansea'),
        'showAddButton': false,
      },
      {
        'title': 'Stores',
        'widget': StoresScreen(
          onMapOpen: (result) {
            setState(() {
              _selectedIndex = result['selectedTab'] as int;
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
        // For the List tab, we use our self-contained ListScreen.
        'title': 'List',
        'widget': ListScreen(key: _listScreenKey),
        'showAddButton': true,
      },
    ];

    // Fetch store data and update the default map.
    _fetchStores().then((_) {
      _getUserLocationAndSetDefaultMap();
    });
  }

  /// Fetches the list of stores from Firestore.
  Future<void> _fetchStores() async {
    try {
      QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('stores').get();

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
  String _getSupermarket(String storeName) {
    return storeName.isEmpty ? "Aldi Swansea" : storeName;
  }

  /// Obtains the user's location and updates the default map screen based
  /// on the nearest store.
  Future<void> _getUserLocationAndSetDefaultMap() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
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
          Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );
          _userLat = position.latitude;
          _userLon = position.longitude;
        }
      }
    } catch (e) {
      _userLat = 51.616753;
      _userLon = -3.944417;
    }

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

    String defaultMapImageUrl = sortedStores.isNotEmpty
        ? sortedStores.first['mapImageAsset'] ?? ''
        : '';
    String storeName =
    sortedStores.isNotEmpty ? sortedStores.first['name']! : 'Aldi';
    String supermarket = _getSupermarket(storeName);

    setState(() {
      _screens[0] = {
        'title': 'Map ($supermarket)',
        'widget': MapScreen(
            mapImageUrl: defaultMapImageUrl, supermarket: supermarket),
        'showAddButton': false,
      };
    });

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

  double _deg2rad(double deg) => deg * (pi / 180);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HeaderWidget(
        title: _screens[_selectedIndex]['title'],
        showAddButton: _screens[_selectedIndex]['showAddButton'],
        onAddPressed: () {
          // For the List screen, delegate the add action to ListScreen.
          if (_selectedIndex == 2) {
            _listScreenKey.currentState?.showAddListDialog();
          }
          // Otherwise, you can handle add actions for other screens if needed.
        },
      ),
      body: _screens[_selectedIndex]['widget'],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
