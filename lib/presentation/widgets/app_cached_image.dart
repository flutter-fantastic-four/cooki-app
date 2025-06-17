import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// 공통 네트워크 이미지 위젯
///
/// CachedNetworkImage를 래핑한 위젯으로, placeholder와 error 처리 포함됨.
class AppCachedImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit? fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;

  const AppCachedImage({
    super.key,
    required this.imageUrl,
    this.fit,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit ?? BoxFit.cover,
      width: width,
      height: height,
      placeholder:
          (context, url) =>
              placeholder ?? const Center(child: CircularProgressIndicator()),
      errorWidget:
          (context, url, error) =>
              errorWidget ?? const Center(child: Icon(Icons.error)),
    );
  }
}
