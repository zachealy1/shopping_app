import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';
import '../widgets/search_bar.dart';

/// A screen that displays a map image with item markers for a specified supermarket.
/// This screen fetches both item locations and closing times from Firestore, and will alert the user
/// if the store is nearing its closing time (with separate times for Sundays and weekdays).
class MapScreen extends StatefulWidget {
  /// The URL of the map image to display.
  final String mapImageUrl;

  /// The name of the supermarket (e.g. 'Aldi Swansea') to display and use for data lookup.
  final String supermarket;

  const MapScreen({
    Key? key,
    required this.mapImageUrl,
    required this.supermarket,
  }) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Controller for managing the search input text.
  final TextEditingController _searchController = TextEditingController();

  // Controller for handling map zooming and panning.
  final TransformationController _transformationController =
  TransformationController();

  // A map of item names to their corresponding locations (offsets) on the map.
  Map<String, Offset> _itemLocations = {};

  // List of all item names fetched from Firestore.
  List<String> _items = [];

  // List of item names filtered according to the user's search query.
  List<String> _filteredItems = [];

  // The currently selected item, if any.
  String? _selectedItem;

  // Store closing times fetched from Firestore.
  // These represent the closing hours and minutes for weekdays and Sundays respectively.
  int? _weekdayClosingHour;
  int? _weekdayClosingMinute;
  int? _sundayClosingHour;
  int? _sundayClosingMinute;

  // Flag to ensure the closing alert is only displayed once per session.
  bool _alertShown = false;

  // Height reserved for the search bar widget.
  static const double kSearchBarHeight = 60.0;

  @override
  void initState() {
    super.initState();
    // Retrieve item locations and closing times from Firestore.
    _fetchItemLocations();
    // Listen to changes in the search field to update the filtered list.
    _searchController.addListener(_filterItems);
    // Initialise the transformation controller with an identity matrix.
    _transformationController.value = Matrix4.identity()..scale(1.0);

    // Once the first frame is rendered, check if the store is close to closing.
    WidgetsBinding.instance.addPostFrameCallback((_) {
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

  /// Fetches item locations and store closing times from Firestore.
  /// Expects the document to include closing times (weekday and Sunday) and an 'itemLocations' field.
  Future<void> _fetchItemLocations() async {
    try {
      final docId = _getDocumentId(widget.supermarket);
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('items')
          .doc(docId)
          .get();

      // Log the fetched document for debugging.
      print("Fetched document for $docId: ${doc.data()}");

      if (doc.exists) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          // Extract closing time details from the document.
          final int weekdayHour = int.tryParse(
              data['weekdayClosingHour']?.toString() ?? '20') ??
              20;
          final int weekdayMinute =
              int.tryParse(data['weekdayClosingMinute']?.toString() ?? '0') ?? 0;
          final int sundayHour = int.tryParse(
              data['sundayClosingHour']?.toString() ?? '16') ??
              16;
          final int sundayMinute =
              int.tryParse(data['sundayClosingMinute']?.toString() ?? '0') ?? 0;

          setState(() {
            _weekdayClosingHour = weekdayHour;
            _weekdayClosingMinute = weekdayMinute;
            _sundayClosingHour = sundayHour;
            _sundayClosingMinute = sundayMinute;
          });

          // Determine the map of item locations.
          // Use the 'itemLocations' field if present; otherwise, assume the document holds the locations directly.
          Map<String, dynamic> locationsMap = data.containsKey('itemLocations')
              ? data['itemLocations'] as Map<String, dynamic>
              : data;

          // Convert each entry into an Offset.
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
        print("No document found for supermarket ${widget.supermarket}");
      }
    } catch (e) {
      print("Error fetching item locations: $e");
    }
  }

  /// Filters the item list based on the current search query.
  void _filterItems() {
    String query = _searchController.text;
    setState(() {
      if (query.isEmpty) {
        _filteredItems = List.from(_items);
      } else {
        _filteredItems = _items
            .where((item) =>
            item.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

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

      // If the store is within 30 minutes of closing (and it is not already closed), display an alert.
      if (closingTimeMinutes - nowMinutes <= 30 &&
          closingTimeMinutes - nowMinutes > 0) {
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
    // Clean up the controllers and remove listeners.
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
          // The map view along with interactive item markers is displayed below the search bar.
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
                        if (_selectedItem != null &&
                            _itemLocations.containsKey(_selectedItem))
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
