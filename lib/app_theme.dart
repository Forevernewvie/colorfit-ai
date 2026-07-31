import 'package:flutter/material.dart';

class AppTheme {
  static const Color defaultSeedColor = Color(0xFFEC4899);

  static const Map<String, Color> seasonSeedColors = {
    'springWarm': Color(0xFFFF9A76),
    'summerCool': Color(0xFF7EB6D8),
    'autumnWarm': Color(0xFFD4955A),
    'winterCool': Color(0xFFA855F7),
  };

  static ThemeData buildTheme(Color seedColor) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF0B0F1A),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0B0F1A),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
