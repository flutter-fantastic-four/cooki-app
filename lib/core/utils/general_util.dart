import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../../gen/l10n/app_localizations.dart';

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
}
