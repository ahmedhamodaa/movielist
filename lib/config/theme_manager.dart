import 'package:flutter/material.dart';

import '../core/utils/app_colors.dart';
import '../core/utils/app_styles.dart';

abstract class CustomTheme {
  static ThemeData darkTheme() => ThemeData(
    fontFamily: 'Montserrat',
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      primary: AppColors.primaryColor,
      secondary: AppColors.green,
      surface: AppColors.darkColor,
      onPrimary: AppColors.white,
      onSecondary: AppColors.white,
      onSurface: AppColors.white,
    ),
    primaryColor: AppColors.primaryColor,
    highlightColor: AppColors.secondaryColor,
    scaffoldBackgroundColor: AppColors.scaffoldColor,
    // fontFamily: 'Montserrat',
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkColor,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: AppColors.strokeColor),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        borderSide: BorderSide(color: AppColors.strokeColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
      ),
      hintStyle: TextStyle(color: AppColors.lightGrey),
      prefixIconColor: AppColors.lightGrey,
    ),

    searchBarTheme: SearchBarThemeData(
      backgroundColor: WidgetStatePropertyAll(Colors.transparent),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: AppColors.strokeColor, width: 1),
        ),
      ),
      elevation: WidgetStatePropertyAll(0),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      type: BottomNavigationBarType.shifting,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      backgroundColor: AppColors.darkColor,
      selectedItemColor: AppColors.primaryColor,
      unselectedItemColor: AppColors.white,
    ),

    appBarTheme: AppBarTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.vertical(
          bottom: Radius.circular(24),
        ),
      ),
      titleTextStyle: AppStyles.s24,
      centerTitle: false,
      foregroundColor: AppColors.lightGrey,
      backgroundColor: AppColors.darkColor,
      surfaceTintColor: AppColors.darkColor,
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(14),
          ),
        ),
      ),
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.darkColor,
      elevation: 0,
    ),
  );
  // static ThemeData darkTheme() => ThemeData(
  //   primaryColor: AppColors.primaryColor,
  //   highlightColor: AppColors.secondaryColor,
  //   scaffoldBackgroundColor: AppColors.scaffoldColor,
  //   fontFamily: 'Montserrat',
  //   inputDecorationTheme: InputDecorationTheme(
  //     fillColor: AppColors.primaryLight,
  //     filled: true,
  //     labelStyle: AppStyles.s14,
  //     enabledBorder: OutlineInputBorder(
  //       borderSide: BorderSide(color: AppColors.darkGery),
  //     ),
  //     focusedBorder: OutlineInputBorder(
  //       borderSide: BorderSide(color: AppColors.primaryColor),
  //     ),
  //   ),
  // );
}
