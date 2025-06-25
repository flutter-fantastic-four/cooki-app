import 'package:cooki/core/utils/general_util.dart';
import 'package:cooki/presentation/pages/home/home_page.dart';
import 'package:cooki/presentation/widgets/under_line_text.dart';
import 'package:flutter/material.dart';

class LoginSkipButton extends StatelessWidget {
  const LoginSkipButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage())),
      child: UnderLineText(text: strings(context).skipLogin, textSize: 14),
    );
  }
}
