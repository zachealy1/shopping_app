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

  @override
  void initState() {
    super.initState();
    // Set the initial zoom level (3.0 is a good starting point, adjust as needed)
    _transformationController.value = Matrix4.identity()..scale(3.0);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        SearchBarWidget(
          controller: _searchController,
          onSearchChanged: () {},
        ),

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
                transformationController: _transformationController, // Ensure zoom works
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
    );
  }
}
