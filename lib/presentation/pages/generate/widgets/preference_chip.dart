import 'package:cooki/app/constants/app_colors.dart';
import 'package:flutter/material.dart';

class PreferenceChip extends StatelessWidget {
  final String label;

  const PreferenceChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 9),
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: AppColors.borderGrey, width: 0.7),
            ),
            color: Colors.transparent,
          ),
          child: Text(
            label,
            style: const TextStyle(color: Colors.black, fontSize: 14),
          ),
        ),
      ),
    );
  }
}
