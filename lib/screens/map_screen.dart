import 'package:flutter/material.dart';
import '../widgets/search_bar.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TransformationController _transformationController = TransformationController();

  // List of 25 popular items typically found in a shopping trolley.
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

  // List that holds the filtered items based on the search query.
  List<String> _filteredShoppingItems = [];

  @override
  void initState() {
    super.initState();
    // Initialize the filtered list with all items.
    _filteredShoppingItems = List.from(_shoppingItems);
    // Set the initial zoom level (3.0 is a good starting point, adjust as needed)
    _transformationController.value = Matrix4.identity()..scale(3.0);
  }

  // Filters the shopping items based on the current search text.
  void _filterItems() {
    String query = _searchController.text;
    setState(() {
      if (query.isEmpty) {
        _filteredShoppingItems = List.from(_shoppingItems);
      } else {
        _filteredShoppingItems = _shoppingItems
            .where((item) => item.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine if there is an active search query.
    final bool isSearching = _searchController.text.isNotEmpty;

    return Column(
      children: [
        // Search Bar
        SearchBarWidget(
          controller: _searchController,
          onSearchChanged: () {
            _filterItems();
          },
        ),
        // Expanded area for either search results or the map with a horizontal list.
        Expanded(
          child: isSearching
              ? ListView.builder(
            itemCount: _filteredShoppingItems.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_filteredShoppingItems[index]),
              );
            },
          )
              : Column(
            children: [
              // Scrollable and Zoomable Map
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return InteractiveViewer(
                      boundaryMargin: EdgeInsets.zero,
                      minScale: 1.0,
                      maxScale: 5.0,
                      panEnabled: true,
                      scaleEnabled: true,
                      constrained: true,
                      transformationController: _transformationController,
                      child: Image.asset(
                        'assets/images/tesco-map.png',
                        width: constraints.maxWidth,
                        fit: BoxFit.contain,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
