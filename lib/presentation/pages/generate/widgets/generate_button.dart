import 'package:cooki/core/utils/general_util.dart';
import 'package:flutter/material.dart';

import '../../../../app/constants/app_colors.dart';

class GenerateButton extends StatelessWidget {
  final VoidCallback onTap;

  const GenerateButton({required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 33),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton.icon(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          icon: Icon(Icons.auto_awesome, size: 21, color: Colors.white),
          iconAlignment: IconAlignment.end,
          label: Text(
            strings(context).generateRecipe,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
