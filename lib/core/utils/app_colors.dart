import 'package:flutter/material.dart';

abstract class AppColors {
  // Background
  static Color white = const Color(0xFFEAEAEA);
  static Color lightColor = const Color(0xFFf8f4e9); // bgMain من الملف القديم
  static Color scaffoldColor = const Color(0xFF0d0d0d); // bgMain
  static Color appBarColor = Colors.white.withValues(alpha: 0.75);

  // Text Colors
  static Color darkGery = const Color(0xFF5C5C5C); // grayDark
  static Color lightGrey = const Color(0xFF8E8E8E); // lightGrey
  static Color darkColor = const Color(0xFF080808); // textDark
  static Color strokeColor = const Color(0xFF1F1F1F); // textDark

  // Primary Colors
  static Color primaryColor = const Color(0xFFF33F3F); // primary
  static Color primaryLight = const Color(0xFFE8E1D5); // TextLight, beige
  static Color secondaryColor = const Color(
    0xFF8E8E8E,
  ).withValues(alpha: 0.35); // primaryDark
  static const Color green = Color(0xFF7A9B76); // #7A9B76 1a1a1a
  static const Color footerColor = Color(0xFF1a1a1a); // #7A9B76 1a1a1a
}
