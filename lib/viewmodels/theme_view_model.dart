import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeViewModel extends ChangeNotifier {
  static const _storageKey = 'theme_dark_mode_enabled';

  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_storageKey) ?? false;
    notifyListeners();
  }

  Future<void> setDarkMode(bool enabled) async {
    _isDarkMode = enabled;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_storageKey, enabled);
  }

  Future<void> toggle() => setDarkMode(!_isDarkMode);
}
