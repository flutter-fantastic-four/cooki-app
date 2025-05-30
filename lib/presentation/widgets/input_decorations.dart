import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../app/constants/app_colors.dart';

InputDecoration getInputDecoration(String? hint, {bool isDate = false}) {
  return InputDecoration(
    hintText: hint,
    suffixIcon: !isDate ? null : const Icon(CupertinoIcons.calendar),
    hintStyle: const TextStyle(color: Colors.grey),
    enabledBorder: _buildBorder(radius: 18, color: AppColors.borderGrey),
    focusedBorder: _buildBorder(radius: 12, color: AppColors.buttonsBlue),
    errorBorder: _buildBorder(radius: 12, color: Colors.red),
    focusedErrorBorder: _buildBorder(radius: 12, color: Colors.red),
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
