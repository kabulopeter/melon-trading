import 'package:flutter/material.dart';

class ThemeManager {
  // Singleton instance
  static final ThemeManager _instance = ThemeManager._internal();
  static ThemeManager get instance => _instance;

  ThemeManager._internal();

  // ValueNotifier for the theme mode
  final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(
    ThemeMode.system,
  );

  // Getter for current mode
  ThemeMode get currentMode => themeModeNotifier.value;

  // Toggle or Set Theme
  void toggleTheme(bool isDark) {
    themeModeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  void setTheme(ThemeMode mode) {
    themeModeNotifier.value = mode;
  }
}
