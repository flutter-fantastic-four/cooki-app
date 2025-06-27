import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../app/constants/app_colors.dart';

class CustomShimmer extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const CustomShimmer({
    super.key,
    required this.width,
    required this.height,
    this.radius = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.greyScale100,
      highlightColor: AppColors.greyScale50,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.greyScale100,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
