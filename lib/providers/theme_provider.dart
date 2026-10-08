import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode;
  bool _changed = false;
  bool _disposed = false;
  ThemeProvider({bool? initialDarkMode})
    : _isDarkMode = initialDarkMode ?? false {
    unawaited(_restore());
  }
  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;
  Future<void> _restore() async {
    try {
      final saved = (await SharedPreferences.getInstance()).getBool(
        'lumen.darkMode',
      );
      if (!_disposed && !_changed && saved != null && saved != _isDarkMode) {
        _isDarkMode = saved;
        notifyListeners();
      }
    } catch (_) {
      /* Storage may be unavailable in a private browser session. */
    }
  }

  void toggleTheme() => setDarkMode(!_isDarkMode);
  void setDarkMode(bool value) {
    _changed = true;
    _isDarkMode = value;
    notifyListeners();
    unawaited(_persist(value));
  }

  Future<void> _persist(bool value) async {
    try {
      await (await SharedPreferences.getInstance()).setBool(
        'lumen.darkMode',
        value,
      );
    } catch (_) {
      /* A storage failure must not block changing the theme. */
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
