import 'package:flutter/material.dart';

import '../../domain/entity/app_user.dart';
import '../../presentation/pages/home/home_page.dart';

class NavigationUtil {
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

  static Future<T?> pushFromBottom<T>(BuildContext context, Widget page) {
    return Navigator.push<T>(
      context,
      PageRouteBuilder<T>(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0); // from bottom
          const end = Offset.zero;
          const curve = Curves.easeOut;

          final tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          final offsetAnimation = animation.drive(tween);

          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }
}
