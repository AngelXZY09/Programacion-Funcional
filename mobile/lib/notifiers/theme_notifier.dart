import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';
  ThemeMode _themeMode = ThemeMode.light; // Default theme

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeNotifier() {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final savedThemeMode = prefs.getString(_themeModeKey);
    if (savedThemeMode != null) {
      if (savedThemeMode == 'dark') {
        _themeMode = ThemeMode.dark;
      } else if (savedThemeMode == 'light') {
        _themeMode = ThemeMode.light;
      } else {
        _themeMode = ThemeMode.system; // O light, si prefieres un default específico
      }
    } else {
      _themeMode = ThemeMode.light; // Default si no hay nada guardado
    }
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _themeMode = (_themeMode == ThemeMode.dark) ? ThemeMode.light : ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, _themeMode == ThemeMode.dark ? 'dark' : 'light');
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    String modeString = 'light';
    if (mode == ThemeMode.dark) modeString = 'dark';
    if (mode == ThemeMode.system) modeString = 'system';
    await prefs.setString(_themeModeKey, modeString);
    notifyListeners();
  }
} 