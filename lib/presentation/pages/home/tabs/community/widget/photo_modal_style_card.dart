import 'package:cooki/app/constants/app_colors.dart';
import 'package:flutter/material.dart';

class PhotoModalStyleCard extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Widget? customIcon;
  final VoidCallback onTap;
  final bool isCenter;
  final Color? textColor;
  final Color? iconColor;

  const PhotoModalStyleCard({
    super.key,
    required this.text,
    this.icon,
    this.customIcon,
    required this.onTap,
    this.isCenter = false,
    this.textColor,
    this.iconColor,
  }) : assert(
         icon != null || customIcon != null || isCenter,
         'Either icon or customIcon must be provided when not centered',
       );

  @override
  Widget build(BuildContext context) {
    Widget? leadingWidget;

    if (!isCenter) {
      if (customIcon != null) {
        leadingWidget = Padding(
          padding: const EdgeInsets.only(left: 24, right: 4),
          child: customIcon,
        );
      } else if (icon != null) {
        leadingWidget = Padding(
          padding: const EdgeInsets.only(left: 24, right: 4),
          child: Icon(icon, color: iconColor ?? Colors.black87),
        );
      }
    }

    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColors.white,
        border: Border.all(color: AppColors.greyScale100, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                if (leadingWidget != null) ...[
                  leadingWidget,
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      color: textColor ?? Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: isCenter ? TextAlign.center : TextAlign.left,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
