import 'package:flutter/material.dart';
import 'list_details_screen.dart';

class ListScreen extends StatefulWidget {
  final List<String> shoppingLists;

  const ListScreen({super.key, required this.shoppingLists});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  late List<String> _shoppingLists;

  @override
  void initState() {
    super.initState();
    _shoppingLists = widget.shoppingLists;
  }

  void addList(String listName) {
    setState(() {
      _shoppingLists.add(listName);
    });
  }

  void _deleteList(int index) {
    setState(() {
      _shoppingLists.removeAt(index);
    });
  }

  void _onListTap(String listName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListDetailsScreen(listName: listName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: _shoppingLists.length,
      separatorBuilder: (context, index) => const Divider(color: Colors.black12, height: 0.5),
      itemBuilder: (context, index) {
        return Dismissible(
          key: Key(_shoppingLists[index]),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            color: const Color(0xFFF1ECF7),
            child: const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Icon(Icons.delete, color: Colors.black, size: 28),
            ),
          ),
          onDismissed: (direction) => _deleteList(index),
          child: GestureDetector(
            onTap: () => _onListTap(_shoppingLists[index]),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.list, color: Colors.black, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _shoppingLists[index],
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, color: Colors.black54, size: 18),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
