import 'package:cooki/app/constants/app_colors.dart';
import 'package:flutter/material.dart';

class SnackbarUtil {
  /// Returns the default circular check icon widget
  static Widget defaultCheckIcon() {
    return Container(
      width: 24,
      height: 24,
      decoration: const BoxDecoration(
        color: AppColors.primary400,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.check, color: Colors.white, size: 16),
    );
  }

  /// Returns the red error icon widget
  static Widget defaultErrorIcon() {
    return Container(
      width: 24,
      height: 24,
      decoration: const BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.close, color: Colors.white, size: 16),
    );
  }

  /// Returns the app logo icon from assets
  static Widget appLogoIcon() {
    return Image.asset(
      'assets/icons/cooki_logo_white_no_text.png',
      width: 24,
      height: 24,
      fit: BoxFit.contain,
    );
  }

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
      leadingIcon = customIcon ?? defaultCheckIcon();
    }

    messenger.showSnackBar(
      SnackBar(
        backgroundColor: AppColors.greyScale800,
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leadingIcon != null) ...[
              leadingIcon,
              const SizedBox(width: 10),
            ],
            Flexible(
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
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
