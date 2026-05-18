import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'Login.dart';
import 'Settings.dart';
import 'AboutApp.dart';
import 'app_palette.dart';

class SideBarDrawer extends StatefulWidget {
  final VoidCallback? onHomeTap;

  const SideBarDrawer({super.key, this.onHomeTap});

  @override
  State<SideBarDrawer> createState() => _SideBarDrawerState();
}

class _SideBarDrawerState extends State<SideBarDrawer> {
  StreamSubscription<DatabaseEvent>? _userSub;
  String _userName = 'Guest';

  @override
  void initState() {
    super.initState();
    _listenToUserName();
  }

  void _listenToUserName() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _userName = 'Guest';
      return;
    }

    final ref = FirebaseDatabase.instance.ref('users/${user.uid}');
    _userSub = ref.onValue.listen((event) {
      String name = user.email ?? 'User';
      final value = event.snapshot.value;
      if (value is Map) {
        final data = Map<String, dynamic>.from(value);
        name = (data['fullName'] ?? name).toString();
      }
      if (mounted) {
        setState(() => _userName = name);
      }
    });
  }

  @override
  void dispose() {
    _userSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Drawer(
      backgroundColor: palette.drawerBackground,
      child: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: Icon(Icons.close, color: palette.primary),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(height: 8),
            const CircleAvatar(
              radius: 36,
              backgroundColor: Color(0xFF8593B6),
              child: Icon(Icons.person_outline, size: 36, color: Color(0xFF2C356E)),
            ),
            const SizedBox(height: 10),
            Text(
              _userName,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: palette.primary),
            ),
            const SizedBox(height: 18),
            Divider(color: palette.primary.withOpacity(0.25), indent: 30, endIndent: 30),
            ListTile(
              leading: Icon(Icons.home_outlined, color: palette.primary),
              title: Text('Home', style: TextStyle(color: palette.primary, fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                widget.onHomeTap?.call();
              },
            ),
            ListTile(
              leading: Icon(Icons.info_outline, color: palette.primary),
              title: Text('About app', style: TextStyle(color: palette.primary, fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutAppPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings_outlined, color: palette.primary),
              title: Text('Settings', style: TextStyle(color: palette.primary, fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                );
              },
            ),
            Divider(color: palette.primary.withOpacity(0.25), indent: 30, endIndent: 30),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: SizedBox(
                width: 140,
                height: 40,
                child: ElevatedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (!context.mounted) return;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: palette.buttonFill,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 0,
                  ),
                  child: const Text('Logout', style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



