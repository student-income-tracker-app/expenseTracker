import 'package:flutter/material.dart';

class AppPalette {
  final Color background;
  final Color primary;
  final Color cardBorder;
  final Color cardFill;
  final Color drawerBackground;
  final Color inputFill;
  final Color bubbleFill;
  final Color buttonFill;

  const AppPalette({
    required this.background,
    required this.primary,
    required this.cardBorder,
    required this.cardFill,
    required this.drawerBackground,
    required this.inputFill,
    required this.bubbleFill,
    required this.buttonFill,
  });

  static AppPalette of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return const AppPalette(
        background: Color(0xFF0F1220),
        primary: Color(0xFFFFFFFF),
        cardBorder: Color(0xFF4C5A8A),
        cardFill: Color(0xFF1A2033),
        drawerBackground: Color(0xFF161C2C),
        inputFill: Color(0xFF1F2640),
        bubbleFill: Color(0xFF1F2640),
        buttonFill: Color(0xFF6C7BB8),
      );
    }

    return const AppPalette(
      background: Color(0xFFE8EAFF),
      primary: Color(0xFF293282),
      cardBorder: Color(0xFF4A5AA6),
      cardFill: Color(0xFFDDE1F5),
      drawerBackground: Color(0xFF9AA7C8),
      inputFill: Color(0xFFDDE1F5),
      bubbleFill: Color(0xFFDDE1F5),
      buttonFill: Color(0xFF7C8BB5),
    );
  }
}


