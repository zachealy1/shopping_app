import 'package:flutter/material.dart';

/// A custom header widget that displays an AppBar with a title and,
/// optionally, an add button. This widget implements [PreferredSizeWidget]
/// to specify its preferred height.
class HeaderWidget extends StatelessWidget implements PreferredSizeWidget {
  /// The title to display in the header.
  final String title;

  /// Whether to display the add button in the header.
  final bool showAddButton;

  /// Callback to be invoked when the add button is pressed.
  final VoidCallback? onAddPressed;

  const HeaderWidget({
    super.key,
    required this.title,
    this.showAddButton = false,
    this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // Set the background colour for the header.
      backgroundColor: const Color(0xFFF1ECF7),
      // No elevation when the AppBar is scrolled under.
      scrolledUnderElevation: 0.0,
      // Define the icon theme for any icons in the AppBar.
      iconTheme: const IconThemeData(color: Colors.black),
      elevation: 0,
      // Centre the title for a balanced look.
      centerTitle: true,
      // Display the header title with custom styling.
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF1D2520),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      // Conditionally display the add button if enabled.
      actions: [
        if (showAddButton)
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: onAddPressed,
          ),
      ],
    );
  }

  @override
  // Define the preferred size for the header widget.
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
