import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFFF1ECF7),
      selectedItemColor: const Color(0xFF1D2520),
      unselectedItemColor: Colors.black45,
      currentIndex: currentIndex,
      onTap: onTap,
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
