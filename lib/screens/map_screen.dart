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

  // Mapping of shopping items to coordinates on the map.
  // Adjust these values to match your map image's coordinate system.
  final Map<String, Offset> _itemLocations = {
    "Milk": const Offset(50, 50),
    "Bread": const Offset(100, 80),
    "Eggs": const Offset(150, 120),
    "Cheese": const Offset(200, 140),
    "Butter": const Offset(250, 180),
    "Apples": const Offset(300, 220),
    "Bananas": const Offset(350, 260),
    "Chicken Breast": const Offset(400, 300),
    "Ground Beef": const Offset(450, 340),
    "Carrots": const Offset(500, 380),
    "Broccoli": const Offset(550, 420),
    "Lettuce": const Offset(600, 460),
    "Tomatoes": const Offset(650, 500),
    "Potatoes": const Offset(700, 540),
    "Pasta": const Offset(750, 580),
    "Rice": const Offset(800, 620),
    "Cereal": const Offset(850, 660),
    "Yogurt": const Offset(900, 700),
    "Orange Juice": const Offset(950, 740),
    "Coffee": const Offset(1000, 780),
    "Tea": const Offset(1050, 820),
    "Frozen Vegetables": const Offset(1100, 860),
    "Snack Bars": const Offset(1150, 900),
    "Chips": const Offset(1200, 940),
    "Soda": const Offset(1250, 980),
  };

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
      body: Column(
        children: [
          SearchBarWidget(
            controller: _searchController,
            onSearchChanged: _filterItems,
          ),
          Expanded(
            child: isSearching
                ? ListView.builder(
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
                  // Remove any explicit alignment here; instead, wrap the child in a Container
                  // that fills the available space and centers its child.
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
        ],
      ),
    );
  }
}
