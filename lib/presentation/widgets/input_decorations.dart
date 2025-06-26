import 'package:flutter/material.dart';

import '../../app/constants/app_colors.dart';

InputDecoration getInputDecoration(
  String? hint, {
  double radius = 12,
  EdgeInsetsGeometry? contentPadding,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.grey),
    contentPadding: contentPadding,
    enabledBorder: _buildBorder(
      radius: radius + 2,
      color: AppColors.borderGrey,
    ),
    focusedBorder: _buildBorder(radius: radius, color: AppColors.primary),
    errorBorder: _buildBorder(radius: radius, color: AppColors.error),
    focusedErrorBorder: _buildBorder(radius: radius, color: AppColors.error),
  );
}

OutlineInputBorder _buildBorder({
  required double radius,
  required Color color,
}) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(radius),
    borderSide: BorderSide(color: color),
  );
}
