import 'package:flutter/material.dart';
import '../widgets/search_bar.dart';

class MapScreen extends StatefulWidget {
  final String mapImageUrl;

  const MapScreen({super.key, required this.mapImageUrl});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TransformationController _transformationController =
  TransformationController();

  final List<String> _shoppingItems = [
    "Milk",
    "Bread",
    "Eggs",
    "Cheese",
    "Butter",
    "Apples",
    "Bananas",
    "Chicken Breast",
    "Ground Beef",
    "Carrots",
    "Broccoli",
    "Lettuce",
    "Tomatoes",
    "Potatoes",
    "Pasta",
    "Rice",
    "Cereal",
    "Yogurt",
    "Orange Juice",
    "Coffee",
    "Tea",
    "Frozen Vegetables",
    "Snack Bars",
    "Chips",
    "Soda"
  ];

  List<String> _filteredShoppingItems = [];
  String? _selectedItem;

  final Map<String, Offset> _itemLocations = {
    "Milk": const Offset(250, -20),
    "Bread": const Offset(130, 50),
    "Eggs": const Offset(250, -20),
    "Cheese": const Offset(175, -20),
    "Butter": const Offset(250, -20),
    "Apples": const Offset(300, 175),
    "Bananas": const Offset(300, 175),
    "Chicken Breast": const Offset(330, 10),
    "Ground Beef": const Offset(330, 10),
    "Carrots": const Offset(300, 175),
    "Broccoli": const Offset(300, 175),
    "Lettuce": const Offset(300, 175),
    "Tomatoes": const Offset(300, 175),
    "Potatoes": const Offset(300, 175),
    "Pasta": const Offset(130, 50),
    "Rice": const Offset(130, 50),
    "Cereal": const Offset(228, 50),
    "Yogurt": const Offset(250, -20),
    "Orange Juice": const Offset(-10, 50),
    "Coffee": const Offset(228, 50),
    "Tea": const Offset(228, 50),
    "Frozen Vegetables": const Offset(262, 150),
    "Snack Bars": const Offset(175, -20),
    "Chips": const Offset(262, 150),
    "Soda": const Offset(-10, 50),
  };

  // Define a constant for the search bar height.
  static const double kSearchBarHeight = 60.0;

  @override
  void initState() {
    super.initState();
    _filteredShoppingItems = List.from(_shoppingItems);
    // Start with an identity matrix.
    _transformationController.value = Matrix4.identity()..scale(1.0);
  }

  void _filterItems() {
    String query = _searchController.text;
    setState(() {
      if (query.isEmpty) {
        _filteredShoppingItems = List.from(_shoppingItems);
      } else {
        _filteredShoppingItems = _shoppingItems
            .where((item) =>
            item.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // If no map image URL is provided, show a loading indicator.
    if (widget.mapImageUrl.isEmpty) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final bool isSearching = _searchController.text.isNotEmpty;

    return Scaffold(
      body: Stack(
        children: [
          // Main content (map or list) positioned below the search bar.
          Positioned.fill(
            top: kSearchBarHeight,
            child: isSearching
                ? ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _filteredShoppingItems.length,
              itemBuilder: (context, index) {
                final item = _filteredShoppingItems[index];
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
                  clipBehavior: Clip.none, // Allow overflow for pointer.
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
                      clipBehavior: Clip.none, // Ensure pointer isn’t clipped.
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
                              color: Colors.red,
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
          // The search bar stays at the top of the screen.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SearchBarWidget(
              controller: _searchController,
              onSearchChanged: _filterItems,
            ),
          ),
        ],
      ),
    );
  }
}
