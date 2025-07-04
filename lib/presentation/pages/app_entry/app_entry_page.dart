import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/fcm_service.dart';
import '../../../core/utils/navigation_util.dart';
import '../../../data/repository/providers.dart';
import '../../user_global_view_model.dart';
import '../login/login_page.dart';
import 'app_entry_view_model.dart';

class AppEntryPage extends ConsumerStatefulWidget {
  const AppEntryPage({super.key});

  @override
  ConsumerState<AppEntryPage> createState() => _AppEntryPageState();
}

class _AppEntryPageState extends ConsumerState<AppEntryPage> {
  @override
  void initState() {
    super.initState();
    _initializeFCM();
  }

  Future<void> _initializeFCM() async {
    await FCMService.initialize(ref);
  }

  void _resolveAuthAndRoute(WidgetRef ref, BuildContext context) {
    ref.listen(authStateChangesProvider, (prev, next) {
      next.whenData((firebaseUserId) async {
        final splashViewModel = ref.read(appEntryViewModelProvider.notifier);
        if (firebaseUserId == null) {
          _navigateToLoginPage(context); // Not logged in → go to login page
        } else {
          // Logged in → check Firestore profile
          final userInFirestore = await splashViewModel.loadUser(
            firebaseUserId,
          );
          if (userInFirestore == null) {
            // User not in Firestore → log out and go to LoginPage again
            await splashViewModel.signOut();
            if (context.mounted) {
              _navigateToLoginPage(context);
            }
          } else {
            // User in Firestore. Check if profile completed and navigate
            // to ProfileEditPage or HomePage
            final userGlobalViewModel = ref.read(
              userGlobalViewModelProvider.notifier,
            );
            userGlobalViewModel.setUser(userInFirestore);
            if (context.mounted) {
              NavigationUtil.navigateBasedOnProfile(context, userInFirestore);
            }
          }
        }
      });
    });
  }

  void _navigateToLoginPage(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    _resolveAuthAndRoute(ref, context);

    return const Scaffold(
      body: Center(child: CupertinoActivityIndicator(radius: 20)),
    );
  }
}
