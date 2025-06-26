import 'package:cooki/app/constants/app_colors.dart';
import 'package:flutter/material.dart';

class PhotoModalStyleCard extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onTap;
  final bool isCenter;
  final Color? textColor;
  final Color? iconColor;

  const PhotoModalStyleCard({super.key, required this.text, this.icon, required this.onTap, this.isCenter = false, this.textColor, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0,
      color: AppColors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 1),
        leading:
            !isCenter ? Padding(padding: const EdgeInsets.only(left: 24, right: 4), child: Icon(icon, color: iconColor ?? Colors.black87)) : null,
        title: Text(
          text,
          style: TextStyle(fontSize: 16, color: textColor ?? Colors.black, fontWeight: FontWeight.w500),
          textAlign: isCenter ? TextAlign.center : null,
        ),
        onTap: onTap,
      ),
    );
  }
}
