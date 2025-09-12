import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppTheme { system, light, dark }

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  AppTheme get currentAppTheme {
    switch (_themeMode) {
      case ThemeMode.light:
        return AppTheme.light;
      case ThemeMode.dark:
        return AppTheme.dark;
      case ThemeMode.system:
        return AppTheme.system;
    }
  }

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('appTheme');
    switch (saved) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      case 'system':
      default:
        _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  Future<void> setTheme(AppTheme theme) async {
    switch (theme) {
      case AppTheme.light:
        _themeMode = ThemeMode.light;
        break;
      case AppTheme.dark:
        _themeMode = ThemeMode.dark;
        break;
      case AppTheme.system:
        _themeMode = ThemeMode.system;
        break;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'appTheme',
      theme.name,
    ); // Save as string: 'light', 'dark', 'system'
    notifyListeners();
  }
}
