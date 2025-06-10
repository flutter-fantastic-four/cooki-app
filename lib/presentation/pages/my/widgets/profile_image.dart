import 'package:cooki/app/constants/app_colors.dart';
import 'package:flutter/material.dart';

class ProfileImage extends StatelessWidget {
  const ProfileImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircleAvatar(
        radius: 60,
        backgroundColor: AppColors.defaultProfilebackground,
        child: const Icon(Icons.camera_alt, size: 24, color: AppColors.defaultProfileIcon),
      ),
    );
  }
}
