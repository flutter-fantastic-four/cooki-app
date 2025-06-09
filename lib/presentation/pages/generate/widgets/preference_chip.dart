import 'package:cooki/app/constants/app_colors.dart';
import 'package:flutter/material.dart';

class PreferenceChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const PreferenceChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(
                color: isSelected ? Colors.transparent : AppColors.borderGrey,
                width: isSelected ? 1.5 : 0.7,
              ),
            ),
            color:
                isSelected
                    ? AppColors.widgetBackgroundGreen
                    : Colors.transparent,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isSelected)
                Icon(Icons.add, size: 16, color: Colors.grey[600])
              else
                Icon(Icons.check, size: 14, color: AppColors.greenTextColor),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColors.greenTextColor : Colors.black,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
