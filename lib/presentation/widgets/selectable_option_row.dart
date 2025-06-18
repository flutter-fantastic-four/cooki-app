import 'package:flutter/material.dart';

import '../../app/constants/app_colors.dart';

class SelectableOptionRow extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const SelectableOptionRow({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: const TextStyle(fontSize: 17, color: Colors.black),
            ),
            RadioCircle(isSelected: isSelected),
          ],
        ),
      ),
    );
  }
}

class RadioCircle extends StatelessWidget {
  final bool isSelected;

  const RadioCircle({super.key, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? AppColors.primary400 : Colors.transparent,
        border:
            isSelected
                ? null
                : Border.all(color: AppColors.greyScale500, width: 1.3),
      ),
      child:
          isSelected
              ? const Icon(Icons.check, color: Colors.white, size: 18)
              : null,
    );
  }
}
