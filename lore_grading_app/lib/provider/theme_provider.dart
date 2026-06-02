import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    if (_themeMode == ThemeMode.dark) {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.dark;
    }
    notifyListeners();
  }

  // --- Light Pastel Theme ---
  ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFFAF9FF), // Soft lavender white
      cardColor: const Color(0xFFFFFFFF),

      colorScheme: const ColorScheme.light(
        primary: Color(0xFF8B5CF6), // Pastel purple/violet
        secondary: Color(0xFF10B981), // Pastel mint green
        tertiary: Color(0xFFEC4899),
        surface: Color(0xFFFFFFFF),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFF1F2937), // Deep slate gray
        surfaceContainerHighest: Color(0xFFF3F4F6), // Soft grey
        outline: Color(0xFFE5E7EB),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Color(0xFF1F2937),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: Color(0xFF1F2937)),
      ),

      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: Color(0xFF1F2937),
          fontSize: 28,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          color: Color(0xFF1F2937),
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        titleMedium: TextStyle(
          color: Color(0xFF1F2937),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(color: Color(0xFF4B5563), fontSize: 16),
        bodyMedium: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF3F4F6),
        labelStyle: const TextStyle(color: Color(0xFF6B7280)),
        floatingLabelStyle: const TextStyle(color: Color(0xFF8B5CF6)),
        prefixIconColor: const Color(0xFF6B7280),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF3F4F6),
        disabledColor: const Color(0xFFF3F4F6).withOpacity(0.5),
        selectedColor: const Color(0xFF8B5CF6).withOpacity(0.15),
        secondarySelectedColor: const Color(0xFF8B5CF6).withOpacity(0.15),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: const TextStyle(color: Color(0xFF1F2937)),
        secondaryLabelStyle: const TextStyle(color: Color(0xFF8B5CF6)),
        brightness: Brightness.light,
      ),
      dialogTheme: DialogThemeData(backgroundColor: const Color(0xFFFFFFFF)),
    );
  }

  // --- Dark Pastel Theme ---
  ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0F0F1B), // Deep pastel midnight
      cardColor: const Color(0xFF1E1E2F),

      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFC084FC), // Soft pastel purple/violet
        secondary: Color(0xFFA7F3D0), // Soft pastel teal/mint
        tertiary: Color(0xFFFBCFE8),
        surface: Color(0xFF1E1E2F),
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: Color(0xFFF8FAFC),
        surfaceContainerHighest: Color(0xFF2D2D44),
        outline: Color(0xFF3B3B52),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Color(0xFFF8FAFC),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: Color(0xFFF8FAFC)),
      ),

      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: Color(0xFFF8FAFC),
          fontSize: 28,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          color: Color(0xFFF8FAFC),
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        titleMedium: TextStyle(
          color: Color(0xFFF8FAFC),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(color: Color(0xFFE2E8F0), fontSize: 16),
        bodyMedium: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E1E2F),
        labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
        floatingLabelStyle: const TextStyle(color: Color(0xFFC084FC)),
        prefixIconColor: const Color(0xFF94A3B8),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF2D2D44)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFC084FC), width: 2),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF1E1E2F),
        disabledColor: const Color(0xFF1E1E2F).withOpacity(0.5),
        selectedColor: const Color(0xFFC084FC).withOpacity(0.2),
        secondarySelectedColor: const Color(0xFFC084FC).withOpacity(0.2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: const TextStyle(color: Color(0xFFF8FAFC)),
        secondaryLabelStyle: const TextStyle(color: Color(0xFFC084FC)),
        brightness: Brightness.dark,
      ),
      dialogTheme: DialogThemeData(backgroundColor: const Color(0xFF1E1E2F)),
    );
  }
}
