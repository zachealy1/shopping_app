import 'package:flutter/material.dart';

/// A custom search bar widget for the application.
///
/// This widget displays a text field with a search icon prefix and customised styling.
/// It notifies its parent when the search text changes.
class SearchBarWidget extends StatelessWidget {
  /// Controller for managing the text in the search field.
  final TextEditingController controller;

  /// Callback invoked whenever the search text is changed.
  final VoidCallback onSearchChanged;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // Fixed height for the search bar.
      height: 60,
      child: TextField(
        controller: controller,
        // Trigger the search callback when the text changes.
        onChanged: (value) => onSearchChanged(),
        decoration: const InputDecoration(
          // Placeholder text when the field is empty.
          hintText: 'Search...',
          // Icon displayed at the start of the text field.
          prefixIcon: Icon(Icons.search, color: Color(0xFF1D2520), size: 28),
          // Enable the filled background.
          filled: true,
          // Set the fill colour.
          fillColor: Color(0xFFF1ECF7),
          // Remove the default border.
          border: OutlineInputBorder(borderSide: BorderSide.none),
          // Padding within the text field.
          contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        ),
        // Text style for the search input.
        style: const TextStyle(fontSize: 18),
      ),
    );
  }
}
