import 'package:flutter/material.dart';

import '../../app/constants/app_colors.dart';

InputDecoration getInputDecoration(String? hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.grey),
    enabledBorder: _buildBorder(radius: 14, color: AppColors.borderGrey),
    focusedBorder: _buildBorder(radius: 12, color: AppColors.primary),
    errorBorder: _buildBorder(radius: 12, color: AppColors.error),
    focusedErrorBorder: _buildBorder(radius: 12, color: AppColors.error),
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
