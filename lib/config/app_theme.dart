import 'package:flutter/material.dart';

enum AppThemeType { midnight, daylight, highContrast }

class AppTheme {
  // --- Common Colors ---
  static const Color primaryRed = Color(0xFFEF4444);

  // --- Theme 1: Midnight (Dark - Default) ---
  static final ThemeData midnightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF1F2937),
    colorScheme: const ColorScheme.dark(
      primary: primaryRed,
      secondary: Color(0xFF3B82F6),
      surface: Color(0xFF374151),
      onSurface: Color(0xFFF9FAFB),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF111827),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
    ),
    // cardTheme removed to rely on Material 3 defaults and avoid type conflicts
    // ... we can duplicate other styles if needed or use defaults
  );

  // --- Theme 2: Daylight (Light - Clear) ---
  static final ThemeData daylightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF3F4F6), // رمادي فاتح جداً مريح
    colorScheme: const ColorScheme.light(
      primary: primaryRed,
      secondary: Color(0xFF2563EB), // أزرق أغمق للتباين
      surface: Colors.white,
      // background removed
      onSurface: Color(0xFF111827), // نص أسود تقريباً
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFF111827), // أيقونات سوداء
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
    ),
    // cardTheme removed
  );

  // --- Theme 3: High Contrast (Safety - Black/Yellow) ---
  static final ThemeData highContrastTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.black,
    primaryColor: Colors.yellow, // الأصفر هو لون التنبيه الأساسي هنا
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFFFD700), // Gold/Yellow
      secondary: Colors.white,
      surface: Color(0xFF121212),
      // background removed
      error: Color(0xFFFF5252),
      onPrimary: Colors.black, // نص أسود على أزرار صفراء (تباين مكسيمم)
      onSurface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Color(0xFFFFD700)),
      titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Color(0xFFFFD700),
          letterSpacing: 1.5),
    ),
    // cardTheme removed
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFFD700),
        foregroundColor: Colors.black, // نص أسود
        textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
      ),
    ),
  );

  static ThemeData getTheme(AppThemeType type) {
    switch (type) {
      case AppThemeType.midnight:
        return midnightTheme;
      case AppThemeType.daylight:
        return daylightTheme;
      case AppThemeType.highContrast:
        return highContrastTheme;
    }
  }
}
