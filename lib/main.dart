import 'package:flutter/material.dart';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'screens/map_screen.dart';
import 'screens/stores_screen.dart';
import 'screens/list_screen.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/header_widget.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<String> _shoppingLists = [
    'Aldi Shopping List',
    'Lidl Shopping List',
    'Sainsbury’s Shopping List',
    'Tesco Shopping List',
  ];

  // Default store list with coordinates and map image assets.
  final List<Map<String, String>> _stores = [
    {
      'name': 'Aldi Swansea',
      'address': 'Unit 1, Parc Tawe, Swansea SA1 2AS',
      'imageAsset': 'assets/images/aldi.jpg',
      'mapImageAsset': 'assets/images/aldi-map.png',
      'hours': 'Monday to Saturday: 8:00 AM – 8:00 PM; Sunday: 10:00 AM – 4:00 PM.',
      'description': 'This store offers a range of groceries, fresh produce, and household essentials at low prices.',
      'lat': '51.621139',
      'lon': '-3.938108',
    },
    {
      'name': 'Tesco Extra',
      'address': 'Albert Row, Swansea SA1 3RA',
      'imageAsset': 'assets/images/tesco.jpg',
      'mapImageAsset': 'assets/images/tesco-map.png',
      'hours': 'Monday to Saturday: 6:00 AM – 10:00 PM; Sunday: 10:00 AM – 4:00 PM.',
      'description': 'Tesco Extra offers groceries, clothing, electronics, and home goods. Facilities include a café and cash machines.',
      'lat': '51.616753',
      'lon': '-3.944417',
    },
    {
      'name': 'Lidl Swansea',
      'address': 'Trinity Place, Swansea SA1 2DQ',
      'imageAsset': 'assets/images/lidl.jpg',
      'mapImageAsset': 'assets/images/lidl-map.png',
      'hours': 'Monday to Saturday: 8:00 AM – 10:00 PM; Sunday: 10:00 AM – 4:00 PM.',
      'description': 'Lidl Swansea provides fresh produce, bakery items, and quality household products at low prices.',
      'lat': '51.624111',
      'lon': '-3.939608',
    },
    {
      'name': 'Sainsbury\'s',
      'address': 'Quay Parade, Swansea SA1 8AJ',
      'imageAsset': 'assets/images/sainsburys.jpg',
      'mapImageAsset': 'assets/images/sainsburys-map.png',
      'hours': 'Monday to Saturday: 7:00 AM – 9:00 PM; Sunday: 10:00 AM – 4:00 PM.',
      'description': 'Sainsbury\'s offers groceries, clothing, electronics, and home essentials. Services include a café, pharmacy, and photo booth.',
      'lat': '51.620128',
      'lon': '-3.935925',
    },
  ];

  late List<Map<String, dynamic>> _screens;

  // User's real location.
  double _userLat = 0;
  double _userLon = 0;

  @override
  void initState() {
    super.initState();
    // Initially set MapScreen with an empty image URL to show a loading indicator.
    _screens = [
      {
        'title': 'Map',
        'widget': const MapScreen(mapImageUrl: ''),
        'showAddButton': false,
      },
      {
        'title': 'Stores',
        'widget': StoresScreen(
          onMapOpen: (result) {
            setState(() {
              _selectedIndex = result['selectedTab'] as int;
              _screens[0] = {
                'title': 'Map',
                'widget': MapScreen(mapImageUrl: result['mapImageUrl'] as String),
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

    _getUserLocationAndSetDefaultMap();
  }

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

    // Sort stores based on distance from the user.
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

    // Get the closest store's map image asset.
    String defaultMapImageUrl = sortedStores.isNotEmpty
        ? sortedStores.first['mapImageAsset'] ?? ''
        : '';

    setState(() {
      _screens[0] = {
        'title': 'Map',
        'widget': MapScreen(mapImageUrl: defaultMapImageUrl),
        'showAddButton': false,
      };
    });

    // Show an alert to notify the user of the nearest store.
    String nearestStoreName = sortedStores.isNotEmpty ? sortedStores.first['name']! : 'Unknown';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Nearest Store Determined"),
          content: Text("The nearest store is $nearestStoreName. The default map has been updated accordingly."),
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

  // Helper: convert degrees to radians.
  double _deg2rad(double deg) => deg * (pi / 180);

  // Helper: compute distance in km using the Haversine formula.
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // Earth's radius in km.
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

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
                    _screens[2]['widget'] = ListScreen(shoppingLists: _shoppingLists);
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
      appBar: HeaderWidget(
        title: _screens[_selectedIndex]['title'],
        showAddButton: _screens[_selectedIndex]['showAddButton'],
        onAddPressed: _screens[_selectedIndex]['showAddButton'] ? _onAddButtonPressed : null,
      ),
      body: _screens[_selectedIndex]['widget'],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
