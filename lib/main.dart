import 'package:flutter/material.dart';
import 'screens/map_screen.dart';
import 'screens/stores_screen.dart';
import 'screens/list_screen.dart';
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
  int _selectedIndex = 0;

  final List<String> _shoppingLists = [
    'Aldi Shopping List',
    'Lidl Shopping List',
    'Sainsbury’s Shopping List',
    'Tesco Shopping List',
  ];

  late List<Map<String, dynamic>> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      {
        'title': 'Map',
        'widget': const MapScreen(),
        'showAddButton': false,
      },
      {
        'title': 'Stores',
        'widget': const StoresScreen(),
        'showAddButton': false,
      },
      {
        'title': 'List',
        'widget': ListScreen(shoppingLists: _shoppingLists),
        'showAddButton': true,
      },
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onAddButtonPressed() {
    TextEditingController listController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New List'),
          content: TextField(
            controller: listController,
            decoration: const InputDecoration(hintText: 'Enter list name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (listController.text.isNotEmpty) {
                  setState(() {
                    _shoppingLists.add(listController.text);
                    _screens[2]['widget'] = ListScreen(shoppingLists: _shoppingLists);
                  });
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A4CAF),
                foregroundColor: Colors.white,
              ),
              child: const Text('Add'),
            ),
          ],
        );
      },
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
      body: _screens[_selectedIndex]['widget'],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
