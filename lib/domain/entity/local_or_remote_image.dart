import 'dart:io';

class LocalOrRemoteImage {
  final File? file;
  final String? url;

  const LocalOrRemoteImage.file(this.file) : url = null;
  const LocalOrRemoteImage.url(this.url) : file = null;

  bool get isFile => file != null;
  bool get isUrl => url != null;
}