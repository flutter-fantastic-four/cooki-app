import 'package:flutter/material.dart';

import '../../app/constants/app_colors.dart';

class RecipePageWidgets {
  static const divider = Divider(color: AppColors.greyScale800, thickness: 0.5);
  static const sectionTitleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static const servingsTitleStyle = TextStyle(fontSize: 17, fontWeight: FontWeight.bold);
}

class StepIndexLabel extends StatelessWidget {
  final int step;

  const StepIndexLabel(this.step, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      child: Align(
        alignment: Alignment.center,

        child: Padding(
          padding: const EdgeInsets.only(top: 10, right: 6),
          child: Text(
            '$step.',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
