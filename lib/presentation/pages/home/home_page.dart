import 'package:cooki/presentation/pages/home/widgets/home_bottom_navigation_bar.dart';
import 'package:cooki/presentation/pages/my/my_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'home_view_model.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: HomeBottomNavigationBar(),
      body: Consumer(
        builder: (context, ref, child) {
          final currentIndex = ref.watch(homeViewModelProvider);
          return IndexedStack(
            index: currentIndex,
            children: [SizedBox(), SizedBox(), MyPage()],
          );
        },
      ),
    );
  }
}
