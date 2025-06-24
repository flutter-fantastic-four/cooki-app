import 'package:cooki/app/constants/app_colors.dart';
import 'package:cooki/core/utils/general_util.dart';
import 'package:cooki/presentation/pages/home/home_page.dart';
import 'package:flutter/material.dart';

class LoginSkipButton extends StatelessWidget {
  const LoginSkipButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage())),
      child: Container(
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black, width: 0.5))),
        child: Text(strings(context).skipLogin, style: TextStyle(color: AppColors.greyScale500, fontSize: 14)),
      ),
    );
  }
}
