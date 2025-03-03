import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';
import '../widgets/search_bar.dart';

class MapScreen extends StatefulWidget {
  final String mapImageUrl;
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
  final TextEditingController _searchController = TextEditingController();
  final TransformationController _transformationController =
  TransformationController();

  // This will be populated from Firestore.
  Map<String, Offset> _itemLocations = {};
  List<String> _items = [];
  List<String> _filteredItems = [];
  String? _selectedItem;

  static const double kSearchBarHeight = 60.0;

  @override
  void initState() {
    super.initState();
    _fetchItemLocations();
    _searchController.addListener(_filterItems);
    _transformationController.value = Matrix4.identity()..scale(1.0);
  }

  /// Maps the supermarket name to its corresponding Firestore document ID.
  String _getDocumentId(String supermarket) {
    final lower = supermarket.toLowerCase();
    if (lower.contains('aldi')) return 'aldi';
    if (lower.contains('lidl')) return 'lidl';
    if (lower.contains('tesco')) return 'tesco';
    if (lower.contains('sainsbury')) return 'sainsbury';
    return '';
  }

  Future<void> _fetchItemLocations() async {
    try {
      final docId = _getDocumentId(widget.supermarket);
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('items')
          .doc(docId)
          .get();

      print("Fetched document for $docId: ${doc.data()}");

      if (doc.exists) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          // If your document has an "itemLocations" field, use that. Otherwise, use the data directly.
          Map<String, dynamic> locationsMap = data.containsKey('itemLocations')
              ? data['itemLocations'] as Map<String, dynamic>
              : data;

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

  @override
  void dispose() {
    _searchController.removeListener(_filterItems);
    _searchController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mapImageUrl.isEmpty) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final bool isSearching = _searchController.text.isNotEmpty;

    return Scaffold(
      body: Stack(
        children: [
          // Map view with markers.
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
                        Image.asset(
                          widget.mapImageUrl,
                          fit: BoxFit.contain,
                        ),
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
          // Fixed search bar.
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
