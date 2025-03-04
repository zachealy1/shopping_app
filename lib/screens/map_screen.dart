import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/search_bar.dart';

/// A screen that displays a map image with item markers for a specified supermarket.
/// This screen fetches item locations from the 'items' collection and closing times from
/// the 'stores' collection, then alerts the user if the store is nearing its closing time
/// (using separate times for Sundays and weekdays).
class MapScreen extends StatefulWidget {
  /// The URL of the map image to display.
  final String mapImageUrl;
  /// The name of the supermarket (e.g. 'Aldi Swansea') for which data is fetched.
  final String supermarket;

  const MapScreen({
    super.key,
    required this.mapImageUrl,
    required this.supermarket,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Controller for managing the search input text.
  final TextEditingController _searchController = TextEditingController();
  // Controller for handling map zooming and panning.
  final TransformationController _transformationController = TransformationController();

  // A map of item names to their corresponding locations (offsets) on the map.
  Map<String, Offset> _itemLocations = {};
  // List of all item names fetched from Firestore.
  List<String> _items = [];
  // List of item names filtered based on the user's search query.
  List<String> _filteredItems = [];
  // The currently selected item, if any.
  String? _selectedItem;

  // Store closing times fetched from the 'stores' collection.
  int? _weekdayClosingHour;
  int? _weekdayClosingMinute;
  int? _sundayClosingHour;
  int? _sundayClosingMinute;

  // Flag to ensure the closing alert is only shown once per session.
  bool _alertShown = false;

  // Height reserved for the search bar widget.
  static const double kSearchBarHeight = 60.0;

  @override
  void initState() {
    super.initState();
    // Initialise the transformation controller.
    _transformationController.value = Matrix4.identity()..scale(1.0);
    // Listen to changes in the search field.
    _searchController.addListener(_filterItems);
    // Fetch both closing times (from 'stores') and item locations (from 'items'),
    // then check if the store is close to closing.
    _fetchData().then((_) {
      _checkIfStoreCloseToClosing();
    });
  }


  /// Maps the supermarket name to its corresponding Firestore document ID.
  /// Assumes document IDs are in lowercase (e.g. 'aldi', 'lidl', 'tesco', 'sainsburys').
  String _getDocumentId(String supermarket) {
    final lower = supermarket.toLowerCase();
    if (lower.contains('aldi')) return 'aldi';
    if (lower.contains('lidl')) return 'lidl';
    if (lower.contains('tesco')) return 'tesco';
    if (lower.contains('sainsbury')) return 'sainsburys';
    return '';
  }

  /// Fetches both closing times (from the 'stores' collection) and item locations (from the 'items' collection)
  /// for the current supermarket.
  Future<void> _fetchData() async {
    try {
      final docId = _getDocumentId(widget.supermarket);

      // Fetch closing times from the 'stores' collection.
      DocumentSnapshot storeDoc = await FirebaseFirestore.instance
          .collection('stores')
          .doc(docId)
          .get();
      print("${storeDoc.data()}");
      if (storeDoc.exists) {
        Map<String, dynamic>? storeData = storeDoc.data() as Map<String, dynamic>?;
        if (storeData != null) {
          final int weekdayHour = int.tryParse(storeData['weekdayClosingHour']?.toString() ?? '20') ?? 20;
          final int weekdayMinute = int.tryParse(storeData['weekdayClosingMinute']?.toString() ?? '0') ?? 0;
          final int sundayHour = int.tryParse(storeData['sundayClosingHour']?.toString() ?? '16') ?? 16;
          final int sundayMinute = int.tryParse(storeData['sundayClosingMinute']?.toString() ?? '0') ?? 0;
          setState(() {
            _weekdayClosingHour = weekdayHour;
            _weekdayClosingMinute = weekdayMinute;
            _sundayClosingHour = sundayHour;
            _sundayClosingMinute = sundayMinute;
          });
        }
      } else {
        print("No document found in stores for ${widget.supermarket}");
      }

      // Fetch item locations from the 'items' collection.
      DocumentSnapshot itemsDoc = await FirebaseFirestore.instance
          .collection('items')
          .doc(docId)
          .get();
      print("Fetched document for $docId from items: ${itemsDoc.data()}");
      if (itemsDoc.exists) {
        Map<String, dynamic>? itemsData = itemsDoc.data() as Map<String, dynamic>?;
        if (itemsData != null) {
          Map<String, dynamic> locationsMap = itemsData.containsKey('itemLocations')
              ? itemsData['itemLocations'] as Map<String, dynamic>
              : itemsData;
          Map<String, Offset> fetchedLocations = {};
          locationsMap.forEach((key, value) {
            if (value is Map<String, dynamic>) {
              final double x = (value['x'] as num?)?.toDouble() ?? 0.0;
              final double y = (value['y'] as num?)?.toDouble() ?? 0.0;
              fetchedLocations[key] = Offset(x, y);
            }
          });
          setState(() {
            _itemLocations = fetchedLocations;
            _items = _itemLocations.keys.toList();
            _filteredItems = List.from(_items);
          });
        }
      } else {
        print("No document found in items for ${widget.supermarket}");
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  /// Filters the list of items based on the current search query.
  void _filterItems() {
    setState(() {
      final query = _searchController.text.toLowerCase();
      if (query.isEmpty) {
        _filteredItems = List.from(_items);
      } else {
        _filteredItems = _items.where((item) => item.toLowerCase().contains(query)).toList();
      }
    });
  }

  /// Converts degrees to radians.
  double _deg2rad(double deg) => deg * (pi / 180);

  /// Checks if the store is close to its closing time and shows an alert if so.
  /// Considers different closing times for Sundays and weekdays.
  void _checkIfStoreCloseToClosing() {
    if (_alertShown) return;
    // Determine if today is Sunday.
    bool isSunday = DateTime.now().weekday == DateTime.sunday; // Sunday is represented as 7.
    // Select the appropriate closing times.
    int? closingHour = isSunday ? _sundayClosingHour : _weekdayClosingHour;
    int? closingMinute = isSunday ? _sundayClosingMinute : _weekdayClosingMinute;

    if (closingHour != null && closingMinute != null) {
      final closingTimeMinutes = closingHour * 60 + closingMinute;
      final now = TimeOfDay.now();
      final nowMinutes = now.hour * 60 + now.minute;
      // If the store is within 60 minutes of closing (and it is not already closed), display an alert.
      if (closingTimeMinutes - nowMinutes <= 60 && closingTimeMinutes - nowMinutes > 0) {
        _alertShown = true;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Store Closing Soon'),
            content: Text(
                '${widget.supermarket} is close to closing at ${TimeOfDay(hour: closingHour, minute: closingMinute).format(context)}. Please hurry up!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    // Clean up controllers and remove listeners.
    _searchController.removeListener(_filterItems);
    _searchController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If the map image URL is empty, display a loading spinner.
    if (widget.mapImageUrl.isEmpty) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Determine if the user is performing a search.
    final bool isSearching = _searchController.text.isNotEmpty;

    return Scaffold(
      body: Stack(
        children: [
          // The map view with interactive item markers is displayed below the search bar.
          Positioned.fill(
            top: kSearchBarHeight,
            child: isSearching
                ? ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _filteredItems.length,
              itemBuilder: (context, index) {
                final item = _filteredItems[index];
                return ListTile(
                  title: Text(item),
                  onTap: () {
                    setState(() {
                      _selectedItem = item;
                      _searchController.clear();
                    });
                  },
                );
              },
            )
                : LayoutBuilder(
              builder: (context, constraints) {
                return InteractiveViewer(
                  clipBehavior: Clip.none,
                  boundaryMargin: EdgeInsets.zero,
                  minScale: 1.0,
                  maxScale: 5.0,
                  panEnabled: true,
                  scaleEnabled: true,
                  constrained: true,
                  transformationController: _transformationController,
                  child: Container(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    alignment: Alignment.center,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Display the map image.
                        Image.asset(
                          widget.mapImageUrl,
                          fit: BoxFit.contain,
                        ),
                        // If an item is selected, place its marker on the map.
                        if (_selectedItem != null && _itemLocations.containsKey(_selectedItem))
                          Positioned(
                            left: _itemLocations[_selectedItem]!.dx,
                            top: _itemLocations[_selectedItem]!.dy,
                            child: const Icon(
                              Icons.location_on,
                              color: Color(0xFF1d1b20),
                              size: 30,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // The search bar remains fixed at the top.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: kSearchBarHeight,
              child: SearchBarWidget(
                controller: _searchController,
                onSearchChanged: _filterItems,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
