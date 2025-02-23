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

  @override
  void initState() {
    super.initState();
    _loadItems(); // Load items when screen initializes
  }

  // Load items from SharedPreferences
  Future<void> _loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedItems = prefs.getString(widget.listName);
    if (savedItems != null) {
      setState(() {
        _items = List<Map<String, dynamic>>.from(jsonDecode(savedItems));
      });
    }
  }

  // Save items to SharedPreferences
  Future<void> _saveItems() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(widget.listName, jsonEncode(_items));
  }

  void _deleteItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
    _saveItems();
  }

  void _toggleItem(int index) {
    setState(() {
      _items[index]['checked'] = !_items[index]['checked'];
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
                    _items.add({'name': itemController.text, 'checked': false});
                  });
                  _saveItems(); // Save items after adding
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
          SearchBarWidget(controller: _searchController),
          Expanded(
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key(_items[index]['name']),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    color: const Color(0xFFF1ECF7),
                    child: const Padding(
                      padding: EdgeInsets.only(right: 16.0),
                      child: Icon(Icons.delete, color: Colors.black, size: 28),
                    ),
                  ),
                  onDismissed: (direction) => _deleteItem(index),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(
                      _items[index]['name'],
                      style: TextStyle(
                        color: _items[index]['checked'] ? Colors.black54 : Colors.black,
                        decoration: _items[index]['checked'] ? TextDecoration.lineThrough : TextDecoration.none,
                      ),
                    ),
                    trailing: GestureDetector(
                      onTap: () => _toggleItem(index),
                      child: Icon(
                        _items[index]['checked'] ? Icons.check_box : Icons.check_box_outline_blank,
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
