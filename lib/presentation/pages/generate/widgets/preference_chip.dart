import 'package:cooki/app/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
                SvgPicture.asset(
                  'assets/icons/name=plus, size=24, state=Default.svg',
                  width: 16,
                  height: 16,
                  colorFilter: ColorFilter.mode(
                    Color(0xFF757575),
                    BlendMode.srcIn,
                  ),
                )
              else
                SvgPicture.asset(
                  'assets/icons/name=check1, size=24, state=Default.svg',
                  width: 14,
                  height: 14,
                  colorFilter: ColorFilter.mode(
                    AppColors.greenTextColor,
                    BlendMode.srcIn,
                  ),
                ),
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
