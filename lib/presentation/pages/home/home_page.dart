import 'package:cooki/app/constants/app_colors.dart';
import 'package:cooki/presentation/pages/home/tabs/community/community_tab.dart';
import 'package:cooki/presentation/pages/home/widgets/home_bottom_navigation_bar.dart';
import 'package:cooki/presentation/pages/my/my_page.dart';
import 'package:cooki/presentation/pages/home/tabs/saved_recipes/saved_recipes_tab.dart';
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

    return Scaffold(
      bottomNavigationBar: HomeBottomNavigationBar(),
      body: IndexedStack(
        index: currentIndex,
        children: [MyRecipesPage(), CommunityPage(), MyPage()],
      ),
      floatingActionButton:
          currentIndex == 0 || currentIndex == 1
              ? Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    splashColor: AppColors.primary900,
                    highlightColor: AppColors.primary900.withValues(alpha: 0.2),
                    onTap: () {
                      NavigationUtil.pushFromBottom(
                        context,
                        GenerateRecipePage(),
                      );
                    },
                    child: Center(
                      child: Image.asset(
                        'assets/icons/cooki_logo_white_no_letters.png',
                        width: 28,
                        height: 28,
                      ),
                    ),
                  ),
                ),
              )
              : null,
    );
  }
}
