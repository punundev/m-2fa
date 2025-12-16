import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  Color _primaryColor = Colors.deepPurple;
  Color get primaryColor => _primaryColor;

  Locale? _locale;
  Locale? get locale => _locale;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final modeString = prefs.getString('themeMode') ?? 'system';
    _themeMode = ThemeMode.values.firstWhere(
      (e) => e.toString() == 'ThemeMode.$modeString',
    );

    final colorValue = prefs.getInt('primaryColor') ?? Colors.deepPurple.value;
    _primaryColor = Color(colorValue);

    final langCode = prefs.getString('languageCode');
    if (langCode != null) {
      _locale = Locale(langCode);
    }

    notifyListeners();
  }

  void setThemeMode(ThemeMode newMode) async {
    if (_themeMode != newMode) {
      _themeMode = newMode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('themeMode', newMode.name);
      notifyListeners();
    }
  }

  void setPrimaryColor(Color newColor) async {
    if (_primaryColor != newColor) {
      _primaryColor = newColor;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('primaryColor', newColor.value);
      notifyListeners();
    }
  }

  void setLocale(String langCode) async {
    if (_locale?.languageCode != langCode) {
      _locale = Locale(langCode);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('languageCode', langCode);
      notifyListeners();
    }
  }
}
