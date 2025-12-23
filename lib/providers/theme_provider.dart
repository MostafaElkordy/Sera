import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../services/persistence_service.dart';

class ThemeProvider extends ChangeNotifier {
  final PersistenceService _persistence = PersistenceService();
  AppThemeType _currentTheme = AppThemeType.daylight;

  AppThemeType get currentTheme => _currentTheme;

  // عند التشغيل: تحميل السمة المحفوظة
  Future<void> loadTheme() async {
    final themeName = _persistence.getThemeMode();
    _currentTheme = _mapStringToTheme(themeName);
    notifyListeners();
  }

  // تغيير السمة وحفظها
  Future<void> setTheme(AppThemeType theme) async {
    _currentTheme = theme;
    await _persistence.saveThemeMode(theme.name);
    notifyListeners();
  }

  // الحصول على كائن ThemeData الحالي
  ThemeData get themeData => AppTheme.getTheme(_currentTheme);

  AppThemeType _mapStringToTheme(String name) {
    return AppThemeType.values.firstWhere(
      (e) => e.name == name,
      orElse: () => AppThemeType.daylight,
    );
  }
}
