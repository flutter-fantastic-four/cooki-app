import 'package:cooki/app/constants/app_colors.dart';
import 'package:flutter/material.dart';

class SnackbarUtil {
  static void showSnackBar(
    BuildContext context,
    String text, {
    bool showIcon = false,
    Widget? customIcon,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    Widget? leadingIcon;
    if (showIcon) {
      leadingIcon =
          customIcon ??
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: AppColors.primary400,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 16),
          );
    }

    messenger.showSnackBar(
      SnackBar(
        backgroundColor: Colors.black,
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leadingIcon != null) ...[leadingIcon, const SizedBox(width: 10)],
            Flexible(
              child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        showCloseIcon: true,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
