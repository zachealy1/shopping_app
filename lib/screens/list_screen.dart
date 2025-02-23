import 'package:flutter/material.dart';
import 'list_details_screen.dart';
import '../widgets/search_bar.dart';

class ListScreen extends StatefulWidget {
  final List<String> shoppingLists;

  const ListScreen({
    super.key,
    required this.shoppingLists,
  });

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  late List<String> _shoppingLists;
  late List<String> _filteredLists;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _shoppingLists = widget.shoppingLists;
    _filteredLists = _shoppingLists;
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      final query = _searchController.text.toLowerCase();
      _filteredLists = _shoppingLists.where((list) {
        return list.toLowerCase().contains(query);
      }).toList();
    });
  }

  void addList(String listName) {
    setState(() {
      _shoppingLists.add(listName);
      _filteredLists = _shoppingLists;
    });
  }

  void _deleteList(int index) {
    setState(() {
      _shoppingLists.removeAt(index);
      _filteredLists = _shoppingLists;
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
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SearchBarWidget(
          controller: _searchController,
          onSearchChanged: _onSearchChanged,
        ),
        Expanded(
          child: ListView.separated(
            itemCount: _filteredLists.length,
            separatorBuilder: (context, index) => const Divider(color: Colors.black12, height: 0.5),
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
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
                        const Icon(Icons.arrow_forward_ios, color: Colors.black54, size: 18),
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
