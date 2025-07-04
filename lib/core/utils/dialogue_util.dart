import 'package:cooki/core/utils/general_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../app/constants/app_colors.dart';
import '../../app/constants/app_styles.dart';

class DialogueUtil {
  /// 앱 팝업 표시
  /// [showCancel]=true면 '네', '이니오' 버튼 2개 표시,
  /// false면 '확인' 버튼만 표시
  static Future<bool?> showAppDialog({
    required BuildContext context,
    required String title,
    required String content,
    bool showCancel = false,
    bool isDestructive = false,
    String? primaryButtonText,
    String? secondaryButtonText,
  }) {
    final confirmButtonText =
        primaryButtonText ??
        (showCancel ? strings(context).yes : strings(context).confirm);

    return showDialog<bool?>(
      context: context,
      barrierDismissible: !showCancel, // Only dismissible when no cancel button
      builder:
          (BuildContext context) => _AppCustomDialog(
            title: title,
            content: content,
            confirmButtonText: confirmButtonText,
            secondaryButtonText: secondaryButtonText,
            showCancel: showCancel,
            isDestructive: isDestructive,
          ),
    );
  }

  static void showCustomCupertinoActionSheet(
    BuildContext context, {
    required String title,
    required String option1Text,
    required String option2Text,
    required VoidCallback onOption1,
    required VoidCallback onOption2,
  }) {
    showCupertinoModalPopup(
      context: context,
      builder:
          (context) => CupertinoActionSheet(
            title: Text(title, style: AppStyles.cupertinoSheetTitle),
            actions: [
              CupertinoActionSheetAction(
                onPressed: () {
                  onOption1();
                  Navigator.pop(context);
                },
                child: Text(
                  option1Text,
                  style: AppStyles.cupertinoSheetActionText,
                ),
              ),
              CupertinoActionSheetAction(
                onPressed: () {
                  onOption2();
                  Navigator.pop(context);
                },
                child: Text(
                  option2Text,
                  style: AppStyles.cupertinoSheetActionText,
                ),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              onPressed: () => Navigator.pop(context),
              child: Text(
                strings(context).cancel,
                style: AppStyles.cupertinoSheetActionText,
              ),
            ),
          ),
    );
  }
}

class _AppCustomDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmButtonText;
  final String? secondaryButtonText;
  final bool showCancel;
  final bool isDestructive;

  const _AppCustomDialog({
    required this.title,
    required this.content,
    required this.confirmButtonText,
    this.secondaryButtonText,
    required this.showCancel,
    this.isDestructive = false,
  });

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
                fontFamily: 'Pretendard',
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 4),
            Text(
              content,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.greyScale700,
                fontFamily: 'Pretendard',
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 24),
            if (showCancel)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: const BorderSide(color: AppColors.primary),
                      ),
                      child: Text(
                        secondaryButtonText ?? strings(context).no,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child:
                        isDestructive
                            ? OutlinedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                side: BorderSide(color: AppColors.error),
                              ),
                              child: Text(
                                confirmButtonText,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.error,
                                  fontFamily: 'Pretendard',
                                ),
                              ),
                            )
                            : ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                backgroundColor: AppColors.primary,
                              ),
                              child: Text(
                                confirmButtonText,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  fontFamily: 'Pretendard',
                                ),
                              ),
                            ),
                  ),
                ],
              )
            else
              isDestructive
                  ? OutlinedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: BorderSide(color: AppColors.error),
                    ),
                    child: Text(
                      confirmButtonText,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                  )
                  : ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: AppColors.primary,
                    ),
                    child: Text(
                      confirmButtonText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
