import 'package:cooki/app/constants/app_colors.dart';
import 'package:cooki/core/utils/general_util.dart';
import 'package:cooki/core/utils/navigation_util.dart';
import 'package:cooki/domain/entity/app_user.dart';
import 'package:cooki/presentation/pages/generate/generate_recipe_page.dart';
import 'package:cooki/presentation/pages/home/home_view_model.dart';
import 'package:cooki/presentation/pages/login/guest_login_page.dart';
import 'package:cooki/presentation/user_global_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

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
        _emptyNotice(context, category),
        _actionByCategoryButton(context, userState, homeViewModel),
        SizedBox(height: 100),
      ],
    );
  }

  Widget _emptyNotice(BuildContext context, String category) {
    String message;
    String subMessage;

    if (category == strings(context).recipeTabAll) {
      message = strings(context).noRecipeNoticeemptyCategoryMessage;
      subMessage = strings(context).noRecipeNoticeemptyCategorySubMessage;
    } else if (category == strings(context).recipeTabCreated) {
      message = strings(context).noRecipeNoticeCreatedMessage;
      subMessage = strings(context).noRecipeNoticeCreatedSubMessage;
    } else if (category == strings(context).recipeTabSaved) {
      message = strings(context).noRecipeNoticeSavedMessage;
      subMessage = strings(context).noRecipeNoticeSavedSubMessage;
    } else if (category == strings(context).recipeTabShared) {
      message = strings(context).noRecipeNoticeSharedMessage;
      subMessage = strings(context).noRecipeNoticeSharedSubMessage;
    } else {
      message = strings(context).noRecipeNoticeemptyCategoryMessage;
      subMessage = '';
    }

    return Column(
      children: [
        Text(message, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        SizedBox(height: 8),
        Text(subMessage, style: TextStyle(fontSize: 12), textAlign: TextAlign.center),
        SizedBox(height: 24),
      ],
    );
  }

  Widget _actionByCategoryButton(BuildContext context, AppUser? userState, HomeViewModel homeViewModel) {
    if (category == strings(context).recipeTabAll || category == strings(context).recipeTabCreated) {
      return SizedBox(
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
      );
    } else {
      return SizedBox(
        height: 44,
        width: 280,
        child: ElevatedButton(
          onPressed: () {
            homeViewModel.onIndexChanged(1);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/name=community, size=24, state=Default.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(AppColors.white, BlendMode.srcIn),
              ),
              SizedBox(width: 4),
              Text(strings(context).goCommunity, style: TextStyle(color: AppColors.white, fontSize: 14)),
            ],
          ),
        ),
      );
    }
  }
}
