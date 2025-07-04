import 'package:cooki/app/constants/app_colors.dart';
import 'package:cooki/app/enum/sign_in_method.dart';
import 'package:cooki/core/utils/general_util.dart';
import 'package:cooki/presentation/pages/home/home_page.dart';
import 'package:cooki/presentation/pages/home/home_view_model.dart';
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
        width: 350,
        child: ElevatedButton(
          onPressed: () => _login(ref, context),
          style: _getButtonStyle(),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: _signInMethodIcon(),
                ),
              ),
              _signInMethodText(context),
            ],
          ),
        ),
      ),
    );
  }

  void _login(WidgetRef ref, BuildContext context) async {
    final loginViewModel = ref.read(loginViewModelProvider.notifier);
    final homeViewModel = ref.read(homeViewModelProvider.notifier);
    final appUser = await loginViewModel.signIn(signInMethod);

    if (appUser != null && appUser.id.isNotEmpty && context.mounted) {
      ref.read(userGlobalViewModelProvider.notifier).setUser(appUser);
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomePage()),
        (route) => false,
      );
      homeViewModel.onIndexChanged(0);
    }
  }

  Text _signInMethodText(BuildContext context) {
    String signInMethodText = switch (signInMethod) {
      SignInMethod.google => strings(context).loginPageGoogleButton,
      SignInMethod.kakao => strings(context).loginPageKaKaoButton,
      SignInMethod.apple => strings(context).loginPageAppleButton,
    };
    return Text(signInMethodText, style: const TextStyle(fontSize: 16));
  }

  Image _signInMethodIcon() {
    String signInMethodText = switch (signInMethod) {
      SignInMethod.google => 'google',
      SignInMethod.kakao => 'kakao',
      SignInMethod.apple => 'apple',
    };
    return Image.asset('assets/icons/${signInMethodText}_login_logo.png');
  }

  ButtonStyle _getButtonStyle() {
    Color backgroundColor;
    Color textColor;
    Color? border;

    switch (signInMethod) {
      case SignInMethod.google:
        backgroundColor = AppColors.white;
        textColor = AppColors.black;
        border = AppColors.black;
        break;
      case SignInMethod.kakao:
        backgroundColor = AppColors.kakaoLoginBackground;
        textColor = AppColors.black;
        break;
      case SignInMethod.apple:
        backgroundColor = AppColors.black;
        textColor = AppColors.white;
        break;
    }

    return ElevatedButton.styleFrom(
      foregroundColor: textColor,
      backgroundColor: backgroundColor,
      side: BorderSide(color: border ?? backgroundColor),

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      minimumSize: const Size(double.infinity, 53),
    );
  }
}
