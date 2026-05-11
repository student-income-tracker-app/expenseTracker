// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_app_2/Login.dart';
import 'package:flutter_firebase_app_2/Welcome.dart';
import 'NavBar.dart';
import 'Settings.dart';
import 'AboutApp.dart';
import 'Profile.dart';
import 'AIChatbot.dart';
import 'AddIncome.dart';
import 'AddExpense.dart';
import 'Recommendation.dart';
import 'CurrentLocation.dart';
import 'ResetPassword2.dart';
import 'notifications_helper.dart';
import 'user_register.dart';
import 'app_settings.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationHelper.initialize();
  await AppSettings.instance.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppSettings.instance,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Login & Register Demo',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
            useMaterial3: true,
          ),
          themeMode: AppSettings.instance.themeMode,

          // 🧭 Define routes here
          initialRoute: '/welcome', // Start with LoginPage
          routes: {
            '/login': (context) => const LoginPage(),
            '/register': (context) =>  UserRegister(),
            '/welcome': (context) =>  WelcomePage(),
            '/reset-password': (context) => const ResetPasswordPage(),
            '/home': (context) => const NavBarPage(),
            '/nav': (context) => const NavBarPage(),
            '/settings': (context) => const SettingsPage(),
            '/about': (context) => const AboutAppPage(),
            '/profile': (context) => const ProfilePage(),
            '/ai-chatbot': (context) => const AIChatbotPage(),
            '/add-income': (context) => const AddIncomePage(),
            '/add-expense': (context) => const AddExpensePage(),
            '/recommendation': (context) => const RecommendationPage(message: ''),
            '/current-location': (context) => const CurrentLocationPage(),
          },
        );
      },
    );
  }
}
