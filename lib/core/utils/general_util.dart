import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../../gen/l10n/app_localizations.dart';
import 'dialogue_util.dart';

AppLocalizations strings(BuildContext context) {
  return AppLocalizations.of(context)!;
}

class GeneralUtil {
  static Future<Uint8List?> compressImageBytes(
    Uint8List? imageBytes, {
    int quality = 85,
    CompressFormat format = CompressFormat.jpeg,
  }) async {
    return imageBytes != null
        ? await FlutterImageCompress.compressWithList(
          imageBytes,
          quality: quality,
          format: format,
        )
        : null;
  }

  static Future<File> compressImageFile(
    File imageFile, {
    int quality = 70,
    CompressFormat format = CompressFormat.jpeg,
  }) async {
    final dir = imageFile.parent;
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final targetPath = '${dir.path}/compressed_$timestamp.jpg';

    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      imageFile.absolute.path,
      targetPath,
      quality: quality,
      format: format,
    );

    return compressedFile != null ? File(compressedFile.path) : imageFile;
  }

  static Widget buildUnsavedChangesPopScope({
    required BuildContext context,
    required Widget child,
    required bool Function() hasUnsavedChanges,
  }) {
    return PopScope(
      canPop: false, // Always intercept pop attempts
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (!didPop) {
          if (hasUnsavedChanges()) {
            final confirm = await DialogueUtil.showAppDialog(
              context: context,
              title: strings(context).stopWritingConfirmTitle,
              content: strings(context).stopWritingConfirmMessage,
              showCancel: true,
            );

            if (confirm == true) {
              if (!context.mounted) return;
              Navigator.of(context).pop();
            }
          } else {
            // No changes made, allow direct exit
            if (!context.mounted) return;
            Navigator.of(context).pop();
          }
        }
      },
      child: child,
    );
  }
}
