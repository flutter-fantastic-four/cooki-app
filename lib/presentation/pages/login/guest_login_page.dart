import 'package:cooki/app/enum/sign_in_method.dart';
import 'package:cooki/core/utils/general_util.dart';
import 'package:cooki/presentation/pages/login/widget/login_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'login_view_model.dart';

class GuestLoginPage extends ConsumerWidget {
  const GuestLoginPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginState = ref.watch(loginViewModelProvider);

    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/icons/cooki_logo_green.png", width: 164),
                  Text(strings(context).guestSignUpPrompt, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
                  const SizedBox(height: 100),
                  LoginButton(signInMethod: SignInMethod.kakao),
                  const SizedBox(height: 16),
                  LoginButton(signInMethod: SignInMethod.apple),
                  const SizedBox(height: 16),
                  LoginButton(signInMethod: SignInMethod.google),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // 로딩 오버레이
          if (loginState.isLoading) Container(color: Colors.black.withValues(alpha: 0.3), child: const Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }
}
