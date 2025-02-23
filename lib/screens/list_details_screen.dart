import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../widgets/search_bar.dart';

class ListDetailsScreen extends StatefulWidget {
  final String listName;

  const ListDetailsScreen({super.key, required this.listName});

  @override
  State<ListDetailsScreen> createState() => _ListDetailsScreenState();
}

class _ListDetailsScreenState extends State<ListDetailsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedItems = prefs.getString(widget.listName);
    if (savedItems != null) {
      setState(() {
        _items = List<Map<String, dynamic>>.from(jsonDecode(savedItems));
        _filteredItems = _items;
      });
    }
  }

  Future<void> _saveItems() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(widget.listName, jsonEncode(_items));
  }

  void _deleteItem(int index) {
    setState(() {
      _items.removeAt(index);
      _filteredItems = _items;
    });
    _saveItems();
  }

  void _toggleItem(int index) {
    setState(() {
      _filteredItems[index]['checked'] = !_filteredItems[index]['checked'];
      int originalIndex = _items.indexWhere((item) => item['name'] == _filteredItems[index]['name']);
      if (originalIndex != -1) {
        _items[originalIndex]['checked'] = _filteredItems[index]['checked'];
      }
    });
    _saveItems();
  }

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
      body: Column(
        children: [
          SearchBarWidget(controller: _searchController, onSearchChanged: _onSearchChanged), // Updated widget call
          Expanded(
            child: ListView.builder(
              itemCount: _filteredItems.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key(_filteredItems[index]['name']),
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
                    int originalIndex = _items.indexWhere((item) => item['name'] == _filteredItems[index]['name']);
                    if (originalIndex != -1) {
                      _deleteItem(originalIndex);
                    }
                  },
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(
                      _filteredItems[index]['name'],
                      style: TextStyle(
                        color: _filteredItems[index]['checked'] ? Colors.black54 : Colors.black,
                        decoration: _filteredItems[index]['checked'] ? TextDecoration.lineThrough : TextDecoration.none,
                      ),
                    ),
                    trailing: GestureDetector(
                      onTap: () => _toggleItem(index),
                      child: Icon(
                        _filteredItems[index]['checked'] ? Icons.check_box : Icons.check_box_outline_blank,
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
