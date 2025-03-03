import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../widgets/search_bar.dart';

/// Screen to display the details of a particular list (e.g. shopping list).
class ListDetailsScreen extends StatefulWidget {
  /// The name of the list, which is also used as the key for stored items.
  final String listName;

  const ListDetailsScreen({super.key, required this.listName});

  @override
  State<ListDetailsScreen> createState() => _ListDetailsScreenState();
}

class _ListDetailsScreenState extends State<ListDetailsScreen> {
  // Controller for managing the search field text.
  final TextEditingController _searchController = TextEditingController();

  // List of all items in the list.
  List<Map<String, dynamic>> _items = [];

  // Filtered list of items based on search query.
  List<Map<String, dynamic>> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    // Load the stored items from SharedPreferences when the screen initialises.
    _loadItems();
  }

  /// Loads the list items from SharedPreferences using the list name as the key.
  Future<void> _loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedItems = prefs.getString(widget.listName);
    if (savedItems != null) {
      setState(() {
        // Decode the JSON string and convert it to a List of maps.
        _items = List<Map<String, dynamic>>.from(jsonDecode(savedItems));
        _filteredItems = _items;
      });
    }
  }

  /// Saves the current list of items to SharedPreferences.
  Future<void> _saveItems() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(widget.listName, jsonEncode(_items));
  }

  /// Deletes an item at the specified index from the list.
  void _deleteItem(int index) {
    setState(() {
      _items.removeAt(index);
      // Update the filtered list to reflect changes.
      _filteredItems = _items;
    });
    _saveItems();
  }

  /// Toggles the checked state of an item and updates both the original
  /// and filtered lists to remain consistent. After toggling, it checks if all
  /// items are ticked off and shows a congratulatory message if so.
  void _toggleItem(int index) {
    setState(() {
      // Flip the 'checked' status.
      _filteredItems[index]['checked'] = !_filteredItems[index]['checked'];
      // Find the corresponding item in the original list.
      int originalIndex = _items.indexWhere(
              (item) => item['name'] == _filteredItems[index]['name']);
      if (originalIndex != -1) {
        _items[originalIndex]['checked'] = _filteredItems[index]['checked'];
      }
    });
    _saveItems();
    // Check if all items are completed.
    _checkAllItemsCompleted();
  }

  /// Checks whether every item in the list is marked as checked.
  /// If so, displays a congratulatory AlertDialog.
  void _checkAllItemsCompleted() {
    if (_items.isNotEmpty && _items.every((item) => item['checked'] == true)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Congratulations!'),
          content: const Text('You have completed your list!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  /// Opens a dialog to allow the user to add a new item to the list.
  void _addItem() {
    TextEditingController itemController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Item'),
          content: TextField(
            controller: itemController,
            decoration: const InputDecoration(hintText: 'Enter item name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (itemController.text.isNotEmpty) {
                  setState(() {
                    // Create a new item with an unchecked state.
                    final newItem = {'name': itemController.text, 'checked': false};
                    _items.add(newItem);
                    _filteredItems = _items;
                  });
                  _saveItems();
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

  /// Filters the list of items based on the user's search query.
  void _onSearchChanged() {
    setState(() {
      final query = _searchController.text.toLowerCase();
      _filteredItems = _items.where((item) {
        return item['name'].toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Custom app bar with the list name and an add button.
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          color: const Color(0xFFF1ECF7),
          child: AppBar(
            backgroundColor: const Color(0xFFF1ECF7),
            scrolledUnderElevation: 0.0,
            iconTheme: const IconThemeData(color: Colors.black),
            elevation: 0,
            centerTitle: true,
            title: Text(
              widget.listName,
              style: const TextStyle(
                color: Color(0xFF1D2520),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.add, color: Colors.black),
                onPressed: _addItem,
              ),
            ],
            flexibleSpace: const SizedBox.shrink(),
          ),
        ),
      ),
      // Main body containing the search bar and the list of items.
      body: Column(
        children: [
          // Custom search bar widget.
          SearchBarWidget(
            controller: _searchController,
            onSearchChanged: _onSearchChanged,
          ),
          // Expanded list view to display items.
          Expanded(
            child: ListView.builder(
              itemCount: _filteredItems.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key(_filteredItems[index]['name']),
                  // Swipe from right to left to dismiss an item.
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    color: const Color(0xFFF1ECF7),
                    child: const Padding(
                      padding: EdgeInsets.only(right: 16.0),
                      child: Icon(Icons.delete, color: Colors.black, size: 28),
                    ),
                  ),
                  // Remove the item when dismissed.
                  onDismissed: (direction) {
                    int originalIndex = _items.indexWhere(
                            (item) => item['name'] == _filteredItems[index]['name']);
                    if (originalIndex != -1) {
                      _deleteItem(originalIndex);
                    }
                  },
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    // Display the item name with styling based on its checked status.
                    title: Text(
                      _filteredItems[index]['name'],
                      style: TextStyle(
                        color: _filteredItems[index]['checked'] ? Colors.black54 : Colors.black,
                        decoration: _filteredItems[index]['checked']
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    // Checkbox icon to indicate whether the item is checked.
                    trailing: GestureDetector(
                      onTap: () => _toggleItem(index),
                      child: Icon(
                        _filteredItems[index]['checked']
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        color: const Color(0xFF6A4CAF),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
