import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemePrefrences {
  static const String _themeMode = 'themeMode';

  Future<ThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeMode = prefs.getString(_themeMode);
    if (themeMode == null) {
      return ThemeMode.system;
    }
    return ThemeMode.values.firstWhere((e) => e.toString() == themeMode);
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeMode, themeMode.toString());
  }

  Future<bool> isDarkMode() async {
    final themeMode = await getThemeMode();
    switch (themeMode) {
      case ThemeMode.system:
        return WidgetsBinding.instance.window.platformBrightness ==
            Brightness.dark;
      case ThemeMode.dark:
        return true;
      case ThemeMode.light:
        return false;
    }
  }

  Future<void> setDarkMode(bool isDarkMode) async {
    if (isDarkMode) {
      await setThemeMode(ThemeMode.dark);
    } else {
      await setThemeMode(ThemeMode.light);
    }
  }
}
