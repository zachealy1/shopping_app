import 'package:flutter/material.dart';
import 'screens/map_screen.dart';
import 'screens/stores_screen.dart';
import 'screens/list_screen.dart';
import 'widgets/search_bar.dart';
import 'widgets/bottom_nav_bar.dart';
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
    {'title': 'Map', 'widget': MapScreen()},
    {'title': 'Stores', 'widget': StoresScreen()},
    {'title': 'List', 'widget': Text('List Page', style: TextStyle(fontSize: 24))},
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF7FE),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        centerTitle: true,
        title: Text(
          _screens[_selectedIndex]['title'],
          style: const TextStyle(
            color: Color(0xFF1D2520),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
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
