import 'package:flutter/material.dart';
import 'Home.dart';
import 'Account.dart';
import 'Charts.dart';
import 'Report.dart';
import 'SideBar.dart';
import 'app_palette.dart';

class NavBarPage extends StatefulWidget {
  const NavBarPage({super.key});

  @override
  State<NavBarPage> createState() => _NavBarPageState();
}

class _NavBarPageState extends State<NavBarPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;

  void _openDrawer() => _scaffoldKey.currentState?.openDrawer();

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final pages = [
      HomePage(onMenuTap: _openDrawer),
      const AccountPage(),
      const ChartsPage(),
      const ReportPage(),
    ];

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: palette.background,
      drawer: SideBarDrawer(
        onHomeTap: () => setState(() => _currentIndex = 0),
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: pages,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFB7C1DE),
        selectedItemColor: palette.primary,
        unselectedItemColor: const Color(0xFF6F7AA0),
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), label: 'Account'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), label: 'Charts'),
          BottomNavigationBarItem(icon: Icon(Icons.description_outlined), label: 'Report'),
        ],
      ),
    );
  }
}

