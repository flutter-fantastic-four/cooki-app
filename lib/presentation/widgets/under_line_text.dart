import 'package:cooki/app/constants/app_colors.dart';
import 'package:flutter/material.dart';

class UnderLineText extends StatelessWidget {
  const UnderLineText({
    super.key,
    required this.text,
    this.textColor = AppColors.greyScale500,
    this.underLineColor = AppColors.greyScale500,
    this.textSize = 20.0,
  });

  final String text;
  final Color textColor;
  final double textSize;
  final Color underLineColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: underLineColor, width: 0.5))),
      child: Text(text, style: TextStyle(color: textColor, fontSize: textSize)),
    );
  }
}
