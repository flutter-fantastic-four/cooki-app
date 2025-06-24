import 'package:cooki/app/constants/app_colors.dart';
import 'package:cooki/presentation/pages/login/login_page.dart';
import 'package:flutter/material.dart';

class GuestRedirectLoginButton extends StatelessWidget {
  const GuestRedirectLoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          () => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          ),

      child: Container(
        color: AppColors.greyScale50,
        child: Padding(
          padding: EdgeInsets.only(top: 25, bottom: 25, left: 20, right: 20),
          child: Row(
            children: [
              Text(
                "로그인 해주세요",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              Spacer(),
              Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }
}
