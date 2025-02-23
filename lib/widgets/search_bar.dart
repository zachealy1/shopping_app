import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSearchChanged;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: TextField(
        controller: controller,
        onChanged: (value) => onSearchChanged(),
        decoration: const InputDecoration(
          hintText: 'Search...',
          prefixIcon: Icon(Icons.search, color: Color(0xFF1D2520), size: 28),
          filled: true,
          fillColor: Color(0xFFF1ECF7),
          border: OutlineInputBorder(borderSide: BorderSide.none),
          contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        ),
        style: const TextStyle(fontSize: 18),
      ),
    );
  }
}
