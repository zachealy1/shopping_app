import 'package:flutter/material.dart';
import 'screens/map_screen.dart';
import 'screens/stores_screen.dart';
import 'screens/list_screen.dart';
import 'widgets/search_bar.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/header_widget.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: AppTheme.theme,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0;

  static const List<Map<String, dynamic>> _screens = [
    {'title': 'Map', 'widget': MapScreen(), 'showAddButton': false},
    {'title': 'Stores', 'widget': StoresScreen(), 'showAddButton': false},
    {'title': 'List', 'widget': ListScreen(), 'showAddButton': true}, // Show add button on List screen
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onAddButtonPressed() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add button pressed')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HeaderWidget(
        title: _screens[_selectedIndex]['title'],
        showAddButton: _screens[_selectedIndex]['showAddButton'],
        onAddPressed: _screens[_selectedIndex]['showAddButton'] ? _onAddButtonPressed : null,
      ),
      body: Column(
        children: [
          SearchBarWidget(controller: _searchController),
          Expanded(child: _screens[_selectedIndex]['widget']),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
