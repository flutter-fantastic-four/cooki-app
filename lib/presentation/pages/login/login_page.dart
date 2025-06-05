import 'package:cooki/presentation/pages/login/widget/login_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'login_view_model.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginState = ref.watch(loginViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  LoginButton(signInMethod: SignInMethod.google),
                  SizedBox(height: 16),
                  LoginButton(signInMethod: SignInMethod.apple),
                  SizedBox(height: 16),
                  LoginButton(signInMethod: SignInMethod.kakao),
                  const SizedBox(height: 30),
                  _termsAgreementText(),
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

  Widget _termsAgreementText() {
    return Text.rich(
      TextSpan(
        style: const TextStyle(color: Colors.black, height: 1.4),
        children: [
          const TextSpan(text: '회원가입 시 Cooki의 '),
          TextSpan(
            text: '서비스 이용 약관',
            style: const TextStyle(decoration: TextDecoration.underline, decorationColor: Colors.black, decorationThickness: 0.5),
          ),
          const TextSpan(text: '과\n'),
          TextSpan(
            text: '개인정보 보호 정책',
            style: const TextStyle(decoration: TextDecoration.underline, decorationColor: Colors.black, decorationThickness: 0.5),
          ),
          const TextSpan(text: '에 동의하게 됩니다.'),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
