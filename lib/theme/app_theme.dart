import 'package:flutter/material.dart';

/// Provides the overall application theme configuration.
///
/// This class returns a [ThemeData] instance that is used across the app. It utilises
/// a seeded colour scheme based on a deep purple seed, adopts Material 3 design standards,
/// and customises the AppBar appearance.
class AppTheme {
  /// Returns the application's theme data.
  static ThemeData get theme {
    return ThemeData(
      // Generate a colour scheme using the provided seed colour.
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      // Enable Material 3 design specifications.
      useMaterial3: true,
      // Customise the appearance of AppBars in the app.
      appBarTheme: const AppBarTheme(
        // Set the background colour of the AppBar.
        backgroundColor: Color(0xFFFDF7FE),
        // Define the text style for the AppBar title.
        titleTextStyle: TextStyle(
          color: Color(0xFF1D2520), // Dark colour for the title text.
          fontSize: 20,           // Font size of 20.
          fontWeight: FontWeight.bold, // Bold weight for prominence.
        ),
      ),
    );
  }
}
