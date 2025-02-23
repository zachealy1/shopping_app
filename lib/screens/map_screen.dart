import 'package:flutter/material.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      boundaryMargin: EdgeInsets.zero,
      minScale: 1.0,
      maxScale: 5.0,
      panEnabled: true,
      scaleEnabled: true,
      constrained: false,
      child: Container(
        width: MediaQuery.of(context).size.width * 2,
        height: MediaQuery.of(context).size.height * 2,
        color: Colors.grey.shade300,
        child: const Center(
          child: Text(
            'Supermarket Map (Placeholder)\nScrollable and Zoomable',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 32, color: Colors.black54),
          ),
        ),
      ),
    );
  }
}
