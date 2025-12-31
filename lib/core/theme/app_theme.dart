import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color _defaultSecondary = Colors.orange;

  static ThemeData getTheme({
    required bool isDark,
    Color secondaryColor = _defaultSecondary,
  }) {
    final Brightness brightness = isDark ? Brightness.dark : Brightness.light;
    final Color background = isDark ? const Color(0xFF121212) : Colors.white;
    final Color onBackground = isDark ? Colors.white : Colors.black;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: onBackground, // High contrast B&W
        onPrimary: background,
        secondary: secondaryColor,
        onSecondary: Colors.white,
        error: Colors.red,
        onError: Colors.white,
        surface: background,
        onSurface: onBackground,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData(brightness: brightness).textTheme,
      ).apply(
        bodyColor: onBackground,
        displayColor: onBackground,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: onBackground.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: onBackground.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: secondaryColor),
        ),
      ),
      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: secondaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  static Color getSecondaryColorForSector(String sector) {
    final s = sector.toLowerCase();
    if (s.contains('agri') || s.contains('horti')) {
      return Colors.green;
    } else if (s.contains('aqua') || s.contains('marine')) {
      return Colors.blue;
    }
    return Colors.orange;
  }
}
