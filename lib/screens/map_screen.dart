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
  final TransformationController _transformationController = TransformationController();

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

  @override
  void initState() {
    super.initState();
    _filteredShoppingItems = List.from(_shoppingItems);
    _transformationController.value = Matrix4.identity()..scale(1.0);
  }

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
    // If no map image URL is provided, show a loading indicator.
    if (widget.mapImageUrl.isEmpty) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final bool isSearching = _searchController.text.isNotEmpty;

    return Scaffold(
      body: Column(
        children: [
          SearchBarWidget(
            controller: _searchController,
            onSearchChanged: () {
              _filterItems();
            },
          ),
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
                          widget.mapImageUrl,
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
      ),
    );
  }
}