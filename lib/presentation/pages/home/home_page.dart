import 'package:cooki/presentation/pages/home/widgets/home_bottom_navigation_bar.dart';
import 'package:cooki/presentation/pages/my/my_page.dart';
import 'package:cooki/presentation/pages/home/tabs/saved_recipes/saved_recipes_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'home_view_model.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: HomeBottomNavigationBar(),
      body: IndexedStack(
        index: currentIndex,
        children: [SizedBox(), SizedBox(), MyPage()],
      ),
      floatingActionButton:
          currentIndex == 0 || currentIndex == 1
              ? FloatingActionButton(
                backgroundColor: AppColors.primary,
                child: Icon(Icons.auto_awesome, size: 26, color: Colors.white),
                onPressed: () {
                  NavigationUtil.pushFromBottom(context, GenerateRecipePage());
                },
              )
              : null,
    );
  }
}
