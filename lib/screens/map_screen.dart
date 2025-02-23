import 'package:flutter/material.dart';
import '../widgets/search_bar.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final List<Map<String, dynamic>> _sections = [
    {'label': 'Meat', 'color': Colors.red, 'left': 100.0, 'top': 50.0},
    {'label': 'Meat', 'color': Colors.red, 'left': 220.0, 'top': 50.0},
    {'label': 'Dairy', 'color': Colors.blue, 'left': 500.0, 'top': 50.0},
    {'label': 'Dairy', 'color': Colors.blue, 'left': 620.0, 'top': 50.0},
    {'label': 'Fruit/Veg', 'color': Colors.green, 'left': 50.0, 'top': 400.0},
    {'label': 'Fruit/Veg', 'color': Colors.green, 'left': 200.0, 'top': 400.0},
    {'label': 'Fruit/Veg', 'color': Colors.green, 'left': 320.0, 'top': 400.0},
    {'label': 'Fruit/Veg', 'color': Colors.green, 'left': 200.0, 'top': 620.0},
    {'label': 'Fruit/Veg', 'color': Colors.green, 'left': 320.0, 'top': 620.0},
    {'label': 'Fruit/Veg', 'color': Colors.green, 'left': 620.0, 'top': 400.0},
  ];

  List<Map<String, dynamic>> _filteredSections = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredSections = _sections;
  }

  void _onSearchChanged(String query) {
    // Functionality to be implemented later
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SearchBarWidget(
          controller: _searchController,
          onSearchChanged: () {},
        ),

        Expanded(
          child: InteractiveViewer(
            boundaryMargin: EdgeInsets.zero,
            minScale: 1.0,
            maxScale: 5.0,
            panEnabled: true,
            scaleEnabled: true,
            constrained: false,
            child: Container(
              width: MediaQuery.of(context).size.width * 2,
              height: MediaQuery.of(context).size.height * 2,
              color: const Color(0xFFFDF7FE),
              child: Stack(
                children: [
                  for (var section in _filteredSections)
                    Positioned(
                      left: section['left'],
                      top: section['top'],
                      child: _buildSection(section['label'], section['color'], 100, 300),
                    ),

                  Positioned(
                    bottom: 20,
                    left: MediaQuery.of(context).size.width / 2 - 100,
                    child: Container(
                      width: 200,
                      height: 20,
                      color: Colors.grey.shade800,
                      child: const Center(
                        child: Text(
                          'Entrance/Exit',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String label, Color color, double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: RotatedBox(
          quarterTurns: 1,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
