import 'package:flutter/material.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final List<String> _shoppingLists = [
    'Aldi Shopping List',
    'Lidl Shopping List',
    'Sainsbury’s Shopping List',
    'Tesco Shopping List',
  ];

  void _deleteList(int index) {
    setState(() {
      _shoppingLists.removeAt(index);
    });
  }

  void _onListTap(String listName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tapped on $listName')),
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
                  const Icon(Icons.list, color: Colors.black, size: 24), // List icon
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
                  const Icon(Icons.arrow_forward_ios, color: Colors.black54, size: 18), // Forward arrow
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
