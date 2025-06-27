import 'package:cooki/core/utils/general_util.dart';
import 'package:cooki/presentation/pages/home/tabs/my/widgets/account_action_button.dart';
import 'package:cooki/presentation/pages/home/tabs/my/widgets/guest_redirect_login_button.dart';
import 'package:cooki/presentation/pages/home/tabs/my/widgets/info_column.dart';
import 'package:cooki/presentation/pages/home/tabs/my/widgets/language_settings_page.dart';
import 'package:cooki/presentation/pages/home/tabs/my/widgets/nick_name_row.dart';
import 'package:cooki/presentation/pages/home/tabs/my/widgets/profile_image.dart';
import 'package:cooki/presentation/user_global_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyPage extends ConsumerWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.read(userGlobalViewModelProvider);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        actionsPadding: EdgeInsets.only(right: 20),
        title: Text(strings(context).myPage),
        centerTitle: false,
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => LanguageSelectionPage()));
            },
            child: Text(strings(context).languageSettings, style: TextStyle(fontSize: 16.4, color: Colors.black, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  vm == null ? GuestRedirectLoginButton() : Column(children: [ProfileImage(), const SizedBox(height: 16), NickNameRow()]),
                  const SizedBox(height: 24),
                  InfoColumn(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          if (vm != null) AccountActionButton(),
        ],
      ),
    );
  }
}
