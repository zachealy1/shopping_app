import 'package:flutter/material.dart';

/// A custom BottomNavigationBar widget that displays navigation items for the app.
/// This widget allows the user to switch between different screens by tapping on the icons.
class BottomNavBar extends StatelessWidget {
  /// The index of the currently selected navigation item.
  final int currentIndex;

  /// Callback function that is invoked when a navigation item is tapped.
  /// The tapped index is passed as a parameter.
  final Function(int) onTap;

  const BottomNavBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      // Set the background colour of the bottom navigation bar.
      backgroundColor: const Color(0xFFF1ECF7),
      // Colour for the selected navigation item.
      selectedItemColor: const Color(0xFF1D2520),
      // Colour for unselected navigation items.
      unselectedItemColor: Colors.black45,
      // Indicates which navigation item is currently selected.
      currentIndex: currentIndex,
      // Callback when a navigation item is tapped.
      onTap: onTap,
      // Define the navigation items.
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.place),
          label: 'Map',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Stores',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.check_box),
          label: 'List',
        ),
      ],
    );
  }
}
