import 'package:cooki/app/constants/app_colors.dart';
import 'package:cooki/core/utils/general_util.dart';
import 'package:cooki/core/utils/navigation_util.dart';
import 'package:cooki/presentation/pages/login/guest_login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GuestRedirectLoginButton extends ConsumerWidget {
  const GuestRedirectLoginButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        NavigationUtil.pushFromBottom(context, GuestLoginPage());
      },
      child: Container(
        color: AppColors.greyScale50,
        child: Padding(
          padding: EdgeInsets.only(top: 25, bottom: 25, left: 20, right: 20),
          child: Row(
            children: [
              Text(strings(context).pleaseLogin, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              Spacer(),
              Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }
}
