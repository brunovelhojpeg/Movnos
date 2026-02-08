import 'package:flutter/material.dart';

class AppTheme {
  static const stravaOrange = Color(0xFFFC4C02);
  static const bg = Color(0xFFF7F7F7);
  static const card = Colors.white;
  static const text = Color(0xFF111111);
  static const muted = Color(0xFF6B7280);

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: bg,
      colorScheme: base.colorScheme.copyWith(
        primary: stravaOrange,
        secondary: stravaOrange,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: text,
        elevation: 0,
        centerTitle: true,
      ),
      textTheme: base.textTheme.apply(bodyColor: text, displayColor: text),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
