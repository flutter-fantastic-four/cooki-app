import 'package:flutter/material.dart';

import '../../app/constants/app_colors.dart';

class SelectableOptionRow extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;
  final double horizontalPadding;
  final bool showCheckOnUnselected;

  const SelectableOptionRow({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onTap,
    this.horizontalPadding = 10,
    this.showCheckOnUnselected = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 7,
          horizontal: horizontalPadding,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: const TextStyle(fontSize: 17, color: Colors.black),
            ),
            RadioCircle(
              isSelected: isSelected,
              showCheckOnUnselected: showCheckOnUnselected,
            ),
          ],
        ),
      ),
    );
  }
}

class RadioCircle extends StatelessWidget {
  final bool isSelected;
  final bool showCheckOnUnselected;

  const RadioCircle({
    super.key,
    required this.isSelected,
    this.showCheckOnUnselected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? AppColors.primary400 : Colors.transparent,
        border: isSelected ? null : Border.all(color: Colors.grey, width: 1.0),
      ),
      child:
          isSelected
              ? const Icon(Icons.check, color: Colors.white, size: 18)
              : showCheckOnUnselected
              ? const Icon(Icons.check, color: Colors.grey, size: 18)
              : null,
    );
  }
}
