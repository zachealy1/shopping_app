import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'list_details_screen.dart';
import '../widgets/search_bar.dart';

/// A screen that displays a list of shopping lists and allows the user to search,
/// add, delete and select a specific shopping list. The user's lists are persisted
/// locally using SharedPreferences.
class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  ListScreenState createState() => ListScreenState();
}

class ListScreenState extends State<ListScreen> {
  // List of shopping list names.
  List<String> _shoppingLists = [];
  // List of shopping lists filtered by the search query.
  List<String> _filteredLists = [];
  // Controller to manage the search field text.
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLists();
    _searchController.addListener(_onSearchChanged);
  }

  /// Loads the shopping lists from SharedPreferences using the key 'shoppingLists'.
  Future<void> _loadLists() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedLists = prefs.getString('shoppingLists');
    setState(() {
      if (savedLists != null) {
        _shoppingLists = List<String>.from(jsonDecode(savedLists));
      } else {
        _shoppingLists = [];
      }
      _filteredLists = _shoppingLists;
    });
  }

  /// Saves the current shopping lists to SharedPreferences.
  Future<void> _saveLists() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('shoppingLists', jsonEncode(_shoppingLists));
  }

  /// Called whenever the search text changes.
  void _onSearchChanged() {
    setState(() {
      final query = _searchController.text.toLowerCase();
      _filteredLists = _shoppingLists.where((list) {
        return list.toLowerCase().contains(query);
      }).toList();
    });
  }

  /// Adds a new shopping list with the given name.
  void addList(String listName) {
    setState(() {
      _shoppingLists.add(listName);
      // Reset filtered list to include the new item.
      _filteredLists = _shoppingLists;
    });
    _saveLists();
  }

  /// Deletes a shopping list at the given index.
  void _deleteList(int index) {
    setState(() {
      _shoppingLists.removeAt(index);
      _filteredLists = _shoppingLists;
    });
    _saveLists();
  }

  /// Navigates to the list details screen for the selected shopping list.
  void _onListTap(String listName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListDetailsScreen(listName: listName),
      ),
    );
  }

  /// Displays a dialog to add a new shopping list.
  void showAddListDialog() {
    final TextEditingController listController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add New List"),
          content: TextField(
            controller: listController,
            decoration: const InputDecoration(hintText: "Enter list name"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A4CAF),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                String newListName = listController.text.trim();
                if (newListName.isNotEmpty) {
                  bool exists = _shoppingLists.any(
                        (list) => list.toLowerCase() == newListName.toLowerCase(),
                  );
                  if (exists) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Error"),
                          content: const Text("A list with this name already exists."),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("OK"),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    addList(newListName);
                    Navigator.pop(context);
                  }
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Return only the content so that the header from main.dart is the only header.
    return Column(
      children: [
        // Search bar widget.
        SearchBarWidget(
          controller: _searchController,
          onSearchChanged: _onSearchChanged,
        ),
        // Expanded list view to display the shopping lists.
        Expanded(
          child: ListView.separated(
            itemCount: _filteredLists.length,
            separatorBuilder: (context, index) => const Divider(
              color: Colors.black12,
              height: 0.5,
            ),
            itemBuilder: (context, index) {
              return Dismissible(
                key: Key(_filteredLists[index]),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  color: const Color(0xFFF1ECF7),
                  child: const Padding(
                    padding: EdgeInsets.only(right: 16.0),
                    child: Icon(Icons.delete, color: Colors.black, size: 28),
                  ),
                ),
                onDismissed: (direction) {
                  int originalIndex = _shoppingLists.indexOf(_filteredLists[index]);
                  if (originalIndex != -1) {
                    _deleteList(originalIndex);
                  }
                },
                child: GestureDetector(
                  onTap: () => _onListTap(_filteredLists[index]),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 16),
                    child: Row(
                      children: [
                        const Icon(Icons.list, color: Colors.black, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _filteredLists[index],
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios,
                            color: Colors.black54, size: 18),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
