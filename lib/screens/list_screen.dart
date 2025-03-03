import 'package:flutter/material.dart';
import 'list_details_screen.dart';
import '../widgets/search_bar.dart';

/// A screen that displays a list of shopping lists and allows the user to search,
/// add, delete and select a specific shopping list.
class ListScreen extends StatefulWidget {
  /// The initial list of shopping list names.
  final List<String> shoppingLists;

  const ListScreen({
    super.key,
    required this.shoppingLists,
  });

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  // Local copy of shopping list names.
  late List<String> _shoppingLists;
  // List of shopping lists filtered by the search query.
  late List<String> _filteredLists;
  // Controller to manage the search field text.
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialise local list variables with the provided shopping lists.
    _shoppingLists = widget.shoppingLists;
    _filteredLists = _shoppingLists;
    // Add a listener to handle search queries.
    _searchController.addListener(_onSearchChanged);
  }

  /// Called whenever the search text changes.
  /// Filters the shopping lists to include only those containing the query.
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
  }

  /// Deletes a shopping list from the collection at the specified index.
  void _deleteList(int index) {
    setState(() {
      _shoppingLists.removeAt(index);
      // Update the filtered list to reflect deletion.
      _filteredLists = _shoppingLists;
    });
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

  @override
  void dispose() {
    // Remove the search listener and dispose of the controller.
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar widget at the top of the screen.
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
                // Unique key for each dismissible item.
                key: Key(_filteredLists[index]),
                // Allow swipe-to-delete from right to left.
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
                  // Find the original index in the full shopping list.
                  int originalIndex =
                  _shoppingLists.indexOf(_filteredLists[index]);
                  if (originalIndex != -1) {
                    _deleteList(originalIndex);
                  }
                },
                // GestureDetector to handle taps on a list item.
                child: GestureDetector(
                  onTap: () => _onListTap(_filteredLists[index]),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 16),
                    child: Row(
                      children: [
                        const Icon(Icons.list, color: Colors.black, size: 24),
                        const SizedBox(width: 12),
                        // Display the list name.
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
                        // Arrow icon to indicate that the item is tappable.
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
