import 'package:cooki/core/utils/dialogue_util.dart';
import 'package:cooki/core/utils/general_util.dart';
import 'package:cooki/core/utils/snackbar_util.dart';
import 'package:cooki/data/repository/providers.dart';
import 'package:cooki/presentation/pages/login/login_page.dart';
import 'package:cooki/presentation/user_global_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccountActionButton extends ConsumerWidget {
  const AccountActionButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(onPressed: () => _logout(context, ref), child: Text(strings(context).logout, style: TextStyle(color: Colors.grey[500]))),
          Container(color: Colors.grey[300], height: 20, width: 2),
          TextButton(
            onPressed: () => _deleteAccount(context, ref),
            child: Text(strings(context).deleteAccount, style: TextStyle(color: Colors.grey[500])),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    try {
      final result = await DialogueUtil.showAppCupertinoDialog(
        context: context,
        title: strings(context).logoutDialogTitle,
        content: strings(context).logoutDialogSubTitle,
        showCancel: true,
      );
      if (result == AppDialogResult.confirm) {
        await ref.read(authRepositoryProvider).signOut();
        ref.read(userGlobalViewModelProvider.notifier).clearUser();

        // ignore: use_build_context_synchronously
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const LoginPage()), (route) => false);
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      SnackbarUtil.showSnackBar(context, strings(context).logouterror);
    }
  }

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    try {
      final result = await DialogueUtil.showAppCupertinoDialog(
        context: context,
        title: strings(context).logoutDialogTitle,
        content: strings(context).logoutDialogSubTitle,
        showCancel: true,
      );
      if (result == AppDialogResult.confirm) {
        await ref.read(authRepositoryProvider).signOut();
        ref.read(userGlobalViewModelProvider.notifier).clearUser();

        // ignore: use_build_context_synchronously
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const LoginPage()), (route) => false);
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      SnackbarUtil.showSnackBar(context, strings(context).logouterror);
    }
  }
}
