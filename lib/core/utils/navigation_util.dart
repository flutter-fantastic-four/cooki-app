import 'package:flutter/material.dart';

import '../../domain/entity/app_user.dart';
import '../../presentation/pages/home/home_page.dart';

abstract class NavigationUtil {
  static void navigateBasedOnProfile(BuildContext context, AppUser? appUser) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
    // final isProfileCompleted = appUser?.nativeLanguage != null;

    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(
    //     builder:
    //         (_) => isProfileCompleted ? const HomePage() : WelcomePage(),
    //   ),
    // );
  }
}
