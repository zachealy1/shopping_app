import 'package:flutter/material.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      boundaryMargin: EdgeInsets.zero, // No white space outside the container
      minScale: 1.0, // Minimum zoom scale (no zoom out smaller than full screen)
      maxScale: 5.0, // Maximum zoom scale
      panEnabled: true, // Enable panning
      scaleEnabled: true, // Enable zooming
      constrained: false, // Allow the content to exceed the screen bounds
      child: Container(
        width: MediaQuery.of(context).size.width * 2, // Allow horizontal scrolling
        height: MediaQuery.of(context).size.height * 2, // Allow vertical scrolling
        color: const Color(0xFFFDF7FE), // Background color matches the header
        child: Stack(
          children: [
            // Meat Sections
            Positioned(left: 100, top: 50, child: _buildSection('Meat', Colors.red, 100, 300)),
            Positioned(left: 220, top: 50, child: _buildSection('Meat', Colors.red, 100, 300)),

            // Dairy Sections
            Positioned(left: 500, top: 50, child: _buildSection('Dairy', Colors.blue, 100, 300)),
            Positioned(left: 620, top: 50, child: _buildSection('Dairy', Colors.blue, 100, 300)),

            // Fruit/Veg Sections
            Positioned(left: 50, top: 400, child: _buildSection('Fruit/Veg', Colors.green, 100, 400)),
            Positioned(left: 200, top: 400, child: _buildSection('Fruit/Veg', Colors.green, 100, 200)),
            Positioned(left: 320, top: 400, child: _buildSection('Fruit/Veg', Colors.green, 100, 200)),
            Positioned(left: 200, top: 620, child: _buildSection('Fruit/Veg', Colors.green, 100, 200)),
            Positioned(left: 320, top: 620, child: _buildSection('Fruit/Veg', Colors.green, 100, 200)),
            Positioned(left: 620, top: 400, child: _buildSection('Fruit/Veg', Colors.green, 100, 400)),

            // Entrance/Exit
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
    );
  }

  Widget _buildSection(String label, Color color, double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10), // Rounded corners
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
