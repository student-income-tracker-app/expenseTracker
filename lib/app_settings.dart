import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  AppSettings._();

  static final AppSettings instance = AppSettings._();

  static const String _darkModeKey = 'dark_mode_enabled';
  static const String _notificationsKey = 'notifications_enabled';
  static const String _remindersKey = 'reminders_enabled';

  bool _darkModeEnabled = false;
  bool _notificationsEnabled = false;
  bool _remindersEnabled = false;

  bool get darkModeEnabled => _darkModeEnabled;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get remindersEnabled => _remindersEnabled;

  ThemeMode get themeMode =>
      _darkModeEnabled ? ThemeMode.dark : ThemeMode.light;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _darkModeEnabled = prefs.getBool(_darkModeKey) ?? false;
    _notificationsEnabled = prefs.getBool(_notificationsKey) ?? false;
    _remindersEnabled = prefs.getBool(_remindersKey) ?? false;
    notifyListeners();
  }

  Future<void> setDarkMode(bool enabled) async {
    _darkModeEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, enabled);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, enabled);
    notifyListeners();
  }

  Future<void> setRemindersEnabled(bool enabled) async {
    _remindersEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_remindersKey, enabled);
    notifyListeners();
  }
}
