import 'package:flutter/material.dart';

import '../../app/constants/app_colors.dart';

class RecipePageWidgets {
  // static const titleMaxLength = 17;
  static const divider = Divider(color: AppColors.greyScale800, thickness: 0.5);
  static const sectionTitleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );
  static get inputBorderRadius => BorderRadius.circular(8);

  static const servingsTitleStyle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.bold,
  );
}

class TagChips extends StatelessWidget {
  final List<String> tags;
  final double fontSize;
  final double verticalPadding;
  final double horizontalPadding;

  const TagChips(
    this.tags, {
    super.key,
    this.fontSize = 13,
    this.verticalPadding = 5,
    this.horizontalPadding = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 8,
      children:
          tags.map((tag) {
            return Container(
              padding: EdgeInsets.symmetric(
                vertical: verticalPadding,
                horizontal: horizontalPadding,
              ),
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: AppColors.greyScale400),
                  borderRadius: BorderRadius.circular(18),
                ),
                color: Colors.white,
              ),
              child: DefaultTextStyle(
                style: TextStyle(color: Colors.black, fontSize: fontSize),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [Text(tag)],
                ),
              ),
            );
          }).toList(),
    );
  }
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
