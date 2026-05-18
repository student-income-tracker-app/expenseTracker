import 'package:flutter/material.dart';
import 'ResetPassword2.dart';
import 'Profile.dart';
import 'AIChatbot.dart';
import 'notifications_helper.dart';
import 'app_settings.dart';
import 'app_palette.dart';
import 'CurrentLocation.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _remindersEnabled = false;
  bool _darkModeEnabled = false;
  bool _notificationEnabled = false;

  @override
  void initState() {
    super.initState();
    final settings = AppSettings.instance;
    _remindersEnabled = settings.remindersEnabled;
    _darkModeEnabled = settings.darkModeEnabled;
    _notificationEnabled = settings.notificationsEnabled;
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: palette.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: palette.cardFill,
                child: Icon(Icons.settings, color: palette.primary, size: 32),
              ),
              const SizedBox(height: 10),
              Text(
                'Settings',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: palette.primary),
              ),
              const SizedBox(height: 20),
              _buildTile(
                icon: Icons.person_outline,
                title: 'Profile',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfilePage()),
                  );
                },
              ),
              _buildSwitchTile(
                icon: Icons.calendar_today_outlined,
                title: 'Set Reminders',
                value: _remindersEnabled,
                onChanged: (value) async {
                  if (value && !_notificationEnabled) {
                    await _setNotifications(true);
                  }
                  setState(() => _remindersEnabled = value);
                  await AppSettings.instance.setRemindersEnabled(value);
                  if (value) {
                    await NotificationHelper.scheduleDailyReminder(
                      title: 'SmartSpend Reminder',
                      body: 'Don’t forget to log your expenses today!',
                    );
                  } else {
                    await NotificationHelper.cancelNotification(1);
                  }
                },
              ),
              _buildTile(
                icon: Icons.lock_reset_outlined,
                title: 'Reset Password',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ResetPasswordPage()),
                  );
                },
              ),
              _buildSwitchTile(
                icon: Icons.dark_mode_outlined,
                title: 'Dark Mode',
                value: _darkModeEnabled,
                onChanged: (value) async {
                  setState(() => _darkModeEnabled = value);
                  await AppSettings.instance.setDarkMode(value);
                },
              ),
              _buildSwitchTile(
                icon: Icons.notifications_outlined,
                title: 'Notification',
                value: _notificationEnabled,
                onChanged: (value) async {
                  await _setNotifications(value);
                },
              ),
              _buildTile(
                icon: Icons.smart_toy_outlined,
                title: 'AI Chatbot',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AIChatbotPage()),
                  );
                },
              ),
              _buildTile(
                icon: Icons.location_on_outlined,
                title: 'Current Location',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CurrentLocationPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final palette = AppPalette.of(context);
    return ListTile(
      leading: Icon(icon, color: palette.primary),
      title: Text(
        title,
        style: TextStyle(color: palette.primary, fontWeight: FontWeight.w600),
      ),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final palette = AppPalette.of(context);
    return SwitchListTile(
      secondary: Icon(icon, color: palette.primary),
      title: Text(
        title,
        style: TextStyle(color: palette.primary, fontWeight: FontWeight.w600),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: palette.primary,
    );
  }

  Future<void> _setNotifications(bool enabled) async {
    setState(() => _notificationEnabled = enabled);
    await AppSettings.instance.setNotificationsEnabled(enabled);

    if (enabled) {
      await NotificationHelper.requestPermissions();
      await NotificationHelper.showNotification(
        title: 'Notifications Enabled',
        body: 'You will receive updates and reminders.',
      );
    } else {
      setState(() => _remindersEnabled = false);
      await AppSettings.instance.setRemindersEnabled(false);
      await NotificationHelper.cancelAll();
    }
  }
}

