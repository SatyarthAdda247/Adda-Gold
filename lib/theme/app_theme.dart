import 'package:flutter/material.dart';

class AppTheme {
  static const Color gold = Color(0xFFF5C542);
  static const Color goldDark = Color(0xFFC9981A);
  static const Color navy = Color(0xFF1A2433);
  static const Color slate = Color(0xFF2D3648);
  static const Color green = Color(0xFF2ECC71);
  static const Color red = Color(0xFFE74C3C);
  static const Color addaRed = Color(0xFFDC143C);
  static const Color addaRedDark = Color(0xFFB71C1C);
  static const Color gray100 = Color(0xFFF7F8FA);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray900 = Color(0xFF111827);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: addaRed,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: const ColorScheme.light(
        primary: addaRed,
        secondary: addaRedDark,
        surface: Colors.white,
        background: Colors.white,
        error: Color(0xFFC85A5A), // More subtle red for light theme
        outline: gray300,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: gray900,
        onBackground: gray900,
        onError: Colors.white,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: gray900),
        displayMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: gray900),
        bodyLarge: TextStyle(fontSize: 16, color: gray900),
        bodyMedium: TextStyle(fontSize: 14, color: gray600),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: gray200, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: gray900,
        elevation: 0,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: gold,
      scaffoldBackgroundColor: gray900,
      colorScheme: const ColorScheme.dark(
        primary: gold,
        secondary: goldDark,
        surface: slate,
        background: gray900,
        error: Color(0xFFFF6B6B),
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: Colors.white,
        onBackground: Colors.white,
        onError: Colors.white,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
        displayMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        bodyLarge: TextStyle(fontSize: 16, color: Colors.white),
        bodyMedium: TextStyle(fontSize: 14, color: Color(0xFFD1D5DB)),
      ),
      cardTheme: CardThemeData(
        color: slate,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}

