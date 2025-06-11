import 'package:flutter/material.dart';

import '../../app/constants/app_colors.dart';

class RecipePageWidgets {
  static const divider = Divider(color: AppColors.greyScale800, thickness: 0.5);
  static const sectionTitleStyle = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
}

class StepIndexLabel extends StatelessWidget {
  final String text;
  final int elementsCount;

  const StepIndexLabel(this.text, {super.key, required this.elementsCount});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      child: Align(
        alignment: elementsCount >= 10
            ? Alignment.center
            : Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(top: 10, right: 6),
          child: Text(
            '$text.',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
