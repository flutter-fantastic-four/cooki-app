import 'package:cooki/core/utils/general_util.dart';
import 'package:cooki/presentation/pages/my/widgets/account_action_button.dart';
import 'package:cooki/presentation/pages/my/widgets/info_column.dart';
import 'package:cooki/presentation/pages/my/widgets/language_settings_page.dart';
import 'package:cooki/presentation/pages/my/widgets/nick_name_row.dart';
import 'package:cooki/presentation/pages/my/widgets/profile_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyPage extends ConsumerWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        actionsPadding: EdgeInsets.only(right: 20),
        title: Text(strings(context).myPage),
        centerTitle: false,
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LanguageSelectionPage(),
                ),
              );
            },
            child: Text(
              strings(context).language,
              style: TextStyle(fontSize: 16.4, color: Colors.black, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          ProfileImage(),
          const SizedBox(height: 16),
          NickNameRow(),
          const SizedBox(height: 24),
          InfoColumn(),
          Spacer(),
          AccountActionButton(),
        ],
      ),
    );
  }
}
