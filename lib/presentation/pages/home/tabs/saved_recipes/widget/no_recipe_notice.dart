import 'package:cooki/app/constants/app_colors.dart';
import 'package:cooki/core/utils/general_util.dart';
import 'package:cooki/core/utils/navigation_util.dart';
import 'package:cooki/presentation/pages/generate/generate_recipe_page.dart';
import 'package:cooki/presentation/pages/home/home_view_model.dart';
import 'package:cooki/presentation/pages/login/guest_login_page.dart';
import 'package:cooki/presentation/user_global_view_model.dart';
import 'package:cooki/presentation/widgets/under_line_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NoRecipeNotice extends ConsumerWidget {
  const NoRecipeNotice({super.key, required this.category});

  final String category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeViewModel = ref.read(homeViewModelProvider.notifier);
    final userState = ref.read(userGlobalViewModelProvider);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset('assets/icons/cancel.png', width: 48, height: 48),
        SizedBox(height: 20),
        Text(strings(context).noRecipeNoticeemptyCategoryMessage, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        SizedBox(height: 8),
        Text(strings(context).noRecipeNoticeRecentFood, style: TextStyle(fontSize: 12)),
        Text(strings(context).noRecipeNoticeTakePhoto, style: TextStyle(fontSize: 12)),
        SizedBox(height: 24),
        SizedBox(
          height: 44,
          width: 280,
          child: ElevatedButton(
            onPressed: () {
              if (userState == null) {
                NavigationUtil.pushFromBottom(context, GuestLoginPage());
              } else {
                NavigationUtil.pushFromBottom(context, GenerateRecipePage());
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/icons/cooki_logo_white_no_text.png', width: 24, height: 24),
                SizedBox(width: 4),

                Text(strings(context).generateRecipe, style: TextStyle(color: AppColors.white, fontSize: 14)),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            homeViewModel.onIndexChanged(1);
          },
          child: Padding(
            padding: EdgeInsets.all(18),
            child: UnderLineText(text: strings(context).goCommunity, textSize: 14, width: 2, fontWeight: FontWeight.w600),
          ),
        ),
        SizedBox(height: 100),
      ],
    );
  }
}
