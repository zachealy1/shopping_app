import 'package:flutter/material.dart';
import '../widgets/search_bar.dart';

class MapScreen extends StatefulWidget {
  final String mapImageUrl;
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
  final TextEditingController _searchController = TextEditingController();
  final TransformationController _transformationController =
  TransformationController();

  // Use the supermarket-specific mapping of items to locations.
  // These coordinates should be in the same coordinate system as your image's natural size.
  final Map<String, Map<String, Offset>> supermarketItemLocations = {
    'Lidl Swansea': {
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
    },
    'Aldi Swansea': {
      "Milk": const Offset(-10, 120),
      "Bread": const Offset(50, 82),
      "Eggs": const Offset(-10, 120),
      "Cheese": const Offset(-10, 120),
      "Butter": const Offset(-10, 120),
      "Apples": const Offset(300, 180),
      "Bananas": const Offset(300, 180),
      "Chicken Breast": const Offset(0, 185),
      "Ground Beef": const Offset(0, 185),
      "Carrots": const Offset(300, 180),
      "Broccoli": const Offset(300, 180),
      "Lettuce": const Offset(300, 180),
      "Tomatoes": const Offset(300, 180),
      "Potatoes": const Offset(300, 180),
      "Pasta": const Offset(50, 82),
      "Rice": const Offset(50, 82),
      "Cereal": const Offset(100, 50),
      "Yogurt": const Offset(-10, 120),
      "Orange Juice": const Offset(-10, 50),
      "Coffee": const Offset(100, 50),
      "Tea": const Offset(100, 50),
      "Frozen Vegetables": const Offset(228, 50),
      "Snack Bars": const Offset(-10, 80),
      "Chips": const Offset(228, 50),
      "Soda": const Offset(228, 10),
    },
    'Tesco Extra': {
      "Milk": const Offset(165, 20),
      "Bread": const Offset(233, 50),
      "Eggs": const Offset(165, 20),
      "Cheese": const Offset(195, 50),
      "Butter": const Offset(165, 20),
      "Apples": const Offset(103, 152),
      "Bananas": const Offset(103, 152),
      "Chicken Breast": const Offset(72, 10),
      "Ground Beef": const Offset(72, 10),
      "Carrots": const Offset(103, 152),
      "Broccoli": const Offset(103, 152),
      "Lettuce": const Offset(103, 152),
      "Tomatoes": const Offset(103, 152),
      "Potatoes": const Offset(103, 152),
      "Pasta": const Offset(233, 50),
      "Rice": const Offset(233, 50),
      "Cereal": const Offset(264, 50),
      "Yogurt": const Offset(165, 20),
      "Orange Juice": const Offset(300, 50),
      "Coffee": const Offset(264, 50),
      "Tea": const Offset(264, 50),
      "Frozen Vegetables": const Offset(300, 150),
      "Snack Bars": const Offset(195, 50),
      "Chips": const Offset(300, 150),
      "Soda": const Offset(300, 50),
    },
    'Sainsbury\'s': {
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
    },
  };

  late final Map<String, Offset> _itemLocations;
  late final List<String> _items;
  List<String> _filteredItems = [];
  String? _selectedItem;

  static const double kSearchBarHeight = 60.0;

  @override
  void initState() {
    super.initState();
    _itemLocations = supermarketItemLocations[widget.supermarket] ?? {};
    _items = _itemLocations.keys.toList();
    _filteredItems = List.from(_items);
    // Use the original transformation (scale 1.0) to match previous zoom level.
    _transformationController.value = Matrix4.identity()..scale(1.0);
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
          // The map (and marker) are shown below the search bar.
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
                  // alignment: Alignment.center,
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
          // The search bar remains fixed at the top.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
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
