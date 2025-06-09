import 'package:cooki/app/enum/sign_in_method.dart';
import 'package:cooki/presentation/pages/login/widget/login_button.dart';
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/icons/cookilogo-green.png", width: 225, height: 225),
                  Text('맛있는 그 순간, cooki와 함께'),
                  const SizedBox(height: 100),
                  LoginButton(signInMethod: SignInMethod.kakao),
                  const SizedBox(height: 16),
                  LoginButton(signInMethod: SignInMethod.apple),
                  const SizedBox(height: 16),
                  LoginButton(signInMethod: SignInMethod.google),
                  const SizedBox(height: 30),
                  // _termsAgreementText(),
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
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('회원가입 시 Cooki의 ', style: TextStyle(color: Colors.grey[500], fontSize: 15)),
            GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.only(bottom: 1), // 약간만 여백 주기
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[500]!, width: 1))),
                child: Text(
                  '서비스 이용 약관',
                  style: TextStyle(height: 1.0, color: Colors.grey[500], fontSize: 15),
                  textAlign: TextAlign.center,
                  textHeightBehavior: TextHeightBehavior(applyHeightToFirstAscent: false),
                ),
              ),
            ),
            Text('과', style: TextStyle(color: Colors.grey[500], fontSize: 15)),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.only(bottom: 1), // 약간만 여백 주기
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[500]!, width: 1))),
                child: Text(
                  '개인정보 보호 정책',
                  style: TextStyle(height: 1.0, color: Colors.grey[500], fontSize: 15),
                  textAlign: TextAlign.center,
                  textHeightBehavior: TextHeightBehavior(applyHeightToFirstAscent: false),
                ),
              ),
            ),

            Text('에 동의하게 됩니다.', style: TextStyle(color: Colors.grey[500], fontSize: 15)),
          ],
        ),
      ],
    );
  }
}
