import 'package:cooki/app/constants/app_colors.dart';
import 'package:cooki/presentation/pages/home/tabs/community/community_tab.dart';
import 'package:cooki/presentation/pages/home/tabs/my/my_page.dart';
import 'package:cooki/presentation/pages/home/widgets/home_bottom_navigation_bar.dart';
import 'package:cooki/presentation/pages/home/tabs/saved_recipes/saved_recipes_tab.dart';
import 'package:cooki/presentation/user_global_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/navigation_util.dart';
import '../generate/generate_recipe_page.dart';
import 'home_view_model.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(homeViewModelProvider);

    final user = ref.read(userGlobalViewModelProvider);

    return Scaffold(
      bottomNavigationBar: HomeBottomNavigationBar(),
      body: IndexedStack(index: currentIndex, children: [MyRecipesPage(), CommunityPage(), MyPage()]),
      floatingActionButton:
          (currentIndex == 0 || currentIndex == 1) && user != null
              ? FloatingActionButton(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                backgroundColor: AppColors.primary,
                child: Image.asset('assets/icons/cooki_logo_white_no_text.png', width: 28, height: 28),
                onPressed: () {
                  NavigationUtil.pushFromBottom(context, GenerateRecipePage());
                },
              )
              : null,
    );
  }
}
