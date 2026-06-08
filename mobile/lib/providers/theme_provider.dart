import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const _key = 'maddenet_theme';

  ThemeProvider(SharedPreferences prefs) : _prefs = prefs {
    final stored = prefs.getString(_key);
    _isDark = stored != 'light';
  }

  final SharedPreferences _prefs;
  bool _isDark = true;

  bool get isDark => _isDark;
  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  void toggle() {
    _isDark = !_isDark;
    _prefs.setString(_key, _isDark ? 'dark' : 'light');
    notifyListeners();
  }
}
