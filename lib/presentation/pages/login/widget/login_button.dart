import 'package:cooki/core/utils/navigation_util.dart';
import 'package:cooki/presentation/pages/login/login_view_model.dart';
import 'package:cooki/presentation/user_global_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginButton extends ConsumerWidget {
  const LoginButton({super.key, required this.signInMethod});
  final SignInMethod signInMethod;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: SizedBox(
        width: 310,
        child: OutlinedButton(
          onPressed: () => _login(ref, context, signInMethod),
          style: ElevatedButton.styleFrom(
            // backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            side: BorderSide(color: Colors.grey[400]!),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              // side: const BorderSide(color: Colors.grey),
            ),
            minimumSize: const Size(double.infinity, 53),
          ),
          child: signInMethodText(signInMethod),
        ),
      ),
    );
  }

  void _login(WidgetRef ref, BuildContext context, SignInMethod signInmeethod) async {
    final loginViewModel = ref.read(loginViewModelProvider.notifier);
    final appUser = await loginViewModel.signIn(signInmeethod);

    if (appUser != null && appUser.id.isNotEmpty && context.mounted) {
      ref.read(userGlobalViewModelProvider.notifier).setUser(appUser);
      if (!context.mounted) return;
      NavigationUtil.navigateBasedOnProfile(context, appUser);
    }
  }

  Text signInMethodText(SignInMethod signInMethod) {
    String signInMethodText = '';

    switch (signInMethod) {
      case SignInMethod.google:
        signInMethodText = '구글';
      case SignInMethod.kakao:
        signInMethodText = '카카오';
      case SignInMethod.apple:
        signInMethodText = '애플';
    }
    return Text('$signInMethodText계정으로 시작하기', style: const TextStyle(fontSize: 16));
  }
}
