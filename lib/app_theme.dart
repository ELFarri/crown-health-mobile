import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Colors
  static const Color nearlyWhite = Color(0xFFFAFAFA);
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF2F3F8);
  static const Color nearlyDarkBlue = Color(0xFF2633C5);
  static const Color nearlyDarkBlue2 = Color(0xFF1B2E6F);

  static const Color nearlyBlack = Color(0xFF213333);
  static const Color gray = Color(0xFF3A5160);
  static const Color grey = Color(0xFF3A5160);
  static const Color dark_gray = Color(0xFF313A44);

  static const Color darkText = Color(0xFF253840);
  static const Color darkerText = Color(0xFF17262A);
  static const Color lightText = Color(0xFF4A6572);
  static const Color deactivatedText = Color(0xFF767676);
  static const Color dismissibleBackground = Color(0xFF364A54);
  static const Color spacer = Color(0xFFF2F2F2);
  static const String fontName = 'Roboto';

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [nearlyDarkBlue, Color(0xFF6A88E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // New Dark Theme Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkTextPrimary = Color(0xFFE1E1E1);

  static ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.light,
    scaffoldBackgroundColor: background,
    fontFamily: 'Outfit',
  );

  static ThemeData darkTheme = ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBackground,
    cardColor: darkSurface,
    fontFamily: 'Outfit',
    appBarTheme: AppBarTheme(backgroundColor: darkSurface),
  );
}
