import 'package:cooki/core/utils/general_util.dart';
import 'package:flutter/material.dart';
import '../../app/constants/app_colors.dart';

class AppDialog extends StatelessWidget {
  final String title;
  final String subText;
  final String primaryButtonText;
  final String? secondaryButtonText;
  final VoidCallback onPrimaryButtonPressed;
  final VoidCallback? onSecondaryButtonPressed;

  const AppDialog({
    super.key,
    required this.title,
    required this.subText,
    required this.primaryButtonText,
    required this.onPrimaryButtonPressed,
    this.secondaryButtonText,
    this.onSecondaryButtonPressed,
  });

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String subText,
    String? primaryButtonText,
    String? secondaryButtonText,
    VoidCallback? onPrimaryButtonPressed,
    VoidCallback? onSecondaryButtonPressed,
  }) {
    return showDialog<bool>(
      context: context,
      builder:
          (BuildContext context) => AppDialog(
            title: title,
            subText: subText,
            primaryButtonText: primaryButtonText ?? strings(context).confirm,
            secondaryButtonText: secondaryButtonText,
            onPrimaryButtonPressed: () {
              if (onPrimaryButtonPressed != null) {
                onPrimaryButtonPressed();
              }
              Navigator.of(context).pop(true);
            },
            onSecondaryButtonPressed:
                onSecondaryButtonPressed ??
                () => Navigator.of(context).pop(false),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.greyScale800,
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 4),
            Text(
              subText,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.greyScale700,
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 24),
            if (secondaryButtonText != null)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onSecondaryButtonPressed,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: const BorderSide(color: AppColors.primary),
                      ),
                      child: Text(
                        secondaryButtonText!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onPrimaryButtonPressed,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: AppColors.primary,
                      ),
                      child: Text(
                        primaryButtonText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else
              ElevatedButton(
                onPressed: onPrimaryButtonPressed,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: AppColors.primary,
                ),
                child: Text(
                  primaryButtonText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
