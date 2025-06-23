import 'package:flutter/material.dart';

abstract class AppColors {
  static const primary = Color(0XFF1D8163);
  static const cardGrey = Color(0XFFF4F4F4);
  static const lightGrey = Color(0XFFF1F2F1);
  static const appBarGrey = Color(0xFFF8F9FA);
  static final widgetBackgroundGreen = Color(0XFFe2f3e9).withValues(alpha: 0.6);
  static final widgetBackgroundBlue = Colors.blue.withValues(alpha: 0.05);
  static final greenTextColor = Color(0XFF3BBC7A);
  static final borderGrey = Colors.grey[400]!;
  static const backgroundGrey = Color(0xFFF2F2F7);
  static const textFieldBackgroundGrey = Color(0XFFFAFAF8);

  static const defaultProfileIcon = Color(0XFF7B7B7B);
  static const defaultProfilebackground = Color(0XFFD9D9D9);

  static const inactiveButton = AppColors.greyScale200;

  static const kakaoLoginBackground = Color(0xFFFEE500);

  // From Figma design

  // Primary Colors
  static const primary50 = Color(0xFFE1F3EF);
  static const primary100 = Color(0xFFB6E2D6);
  static const primary200 = Color(0xFF87D0BD);
  static const primary300 = Color(0xFF5ABDA3);
  static const primary400 = Color(0xFF3AAE90);
  static const primary500 = Color(0xFF269F7E);
  static const primary600 = Color(0xFF229172);
  static const primary700 = Color(0xFF1D8163);
  static const primary800 = Color(0xFF167155);
  static const primary900 = Color(0xFF0C553A);

  // Secondary Colors
  static const secondary50 = Color(0xFFFDF3E1);
  static const secondary100 = Color(0xFFFBDFB3);
  static const secondary200 = Color(0xFFF9CB83);
  static const secondary300 = Color(0xFFF7B652);
  static const secondary400 = Color(0xFFF5A72F);
  static const secondary500 = Color(0xFFF49816);
  static const secondary600 = Color(0xFFF08D13);
  static const secondary700 = Color(0xFFEA7D10);
  static const secondary800 = Color(0xFFE36E0D);
  static const secondary900 = Color(0xFFDA560B);

  // Grayscale Colors
  static const greyScale50 = Color(0xFFF5F5F5);
  static const greyScale100 = Color(0xFFE9E9E9);
  static const greyScale200 = Color(0xFFD9D9D9);
  static const greyScale300 = Color(0xFFC4C4C4);
  static const greyScale400 = Color(0xFF9D9D9D);
  static const greyScale500 = Color(0xFF7B7B7B);
  static const greyScale600 = Color(0xFF555555);
  static const greyScale700 = Color(0xFF434343);
  static const greyScale800 = Color(0xFF262626);
  static const black = Color(0xFF000000);
  static const white = Color(0xFFFFFFFF);
}
