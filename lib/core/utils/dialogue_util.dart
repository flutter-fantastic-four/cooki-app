import 'package:cooki/app/constants/app_styles.dart';
import 'package:cooki/core/utils/general_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum AppDialogResult {
  confirm, // 확인 or 네
  cancel, // 아니오
}

class DialogueUtil {
  /// 앱 팝업 표시
  /// [showCancel]=true면 '네', '이니오' 버튼 2개 표시,
  /// false면 '확인' 버튼만 표시
  static Future<AppDialogResult?> showAppCupertinoDialog({
    required BuildContext context,
    required String title,
    required String content,
    bool showCancel = false,
  }) {
    final confirmButtonText = showCancel ? '네' : '확인';
    final Widget dialog = CupertinoAlertDialog(
      title: Text(title, style: const TextStyle(fontSize: 20)),
      content: Text(content, style: const TextStyle(fontSize: 15)),
      actions: [
        if (showCancel)
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context, AppDialogResult.cancel),
            child: Text(
              '아니오',
              style: TextStyle(color: Colors.red, fontSize: 17),
            ),
          ),
        CupertinoDialogAction(
          onPressed: () => Navigator.pop(context, AppDialogResult.confirm),
          child: Text(
            confirmButtonText,
            style: TextStyle(color: Colors.blue, fontSize: 17),
          ),
        ),
      ],
    );

    if (showCancel) {
      // 취소 버튼이 있을 때: 시스템 스타일의 CupertinoAlertDialog 사용 (외부 터치로 닫을 수 없음)
      return showCupertinoDialog<AppDialogResult?>(
        context: context,
        builder: (_) => dialog,
      );
    } else {
      // 취소 버튼이 없을 때: 외부 터치로 닫을 수 있는 Cupertino 스타일 팝업 사용
      return showCupertinoModalPopup<AppDialogResult?>(
        context: context,
        builder: (_) => dialog,
      );
    }
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
