import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'constants/app_colors.dart';

abstract class AppTheme {
  static ThemeData buildTheme({Brightness brightness = Brightness.light}) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        surface: Colors.white,
        brightness: brightness,
      ).copyWith(primary: AppColors.primary),
      highlightColor: Colors.grey,

      textTheme: const TextTheme(
        bodyMedium: TextStyle(fontSize: 16), // default for most Text
      ),

      // sets text style for all texts
      appBarTheme: AppBarTheme(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        centerTitle: true,
        // titleSpacing: 25,
        titleTextStyle: TextStyle(
          fontSize: 20,
          color: Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          foregroundColor: Colors.white,
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.inactiveButton,
          disabledForegroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          minimumSize: const Size(double.infinity, 52),
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
      ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            // backgroundColor: AppColors.buttonsBlue,
            foregroundColor: AppColors.primary,
            side: BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            minimumSize: const Size(double.infinity, 50),
            textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
          ),
        )
    );
  }

  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }
}
