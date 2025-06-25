import 'package:cooki/core/utils/dialogue_util.dart';
import 'package:cooki/core/utils/general_util.dart';
import 'package:cooki/core/utils/snackbar_util.dart';
import 'package:cooki/presentation/pages/home/tabs/my/widgets/account_action_button_view_model.dart';
import 'package:cooki/presentation/pages/login/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccountActionButton extends ConsumerWidget {
  const AccountActionButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(accountActionViewModelProvider.notifier);
    final state = ref.watch(accountActionViewModelProvider);

    // 에러가 있을 때 스낵바 표시
    ref.listen(accountActionViewModelProvider, (previous, next) {
      if (next.error != null) {
        SnackbarUtil.showSnackBar(context, next.error!);
        viewModel.clearError();
      }
    });

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: state.isLoading ? null : () => _handleLogout(context, viewModel),
            child: Text(strings(context).logout, style: TextStyle(color: Colors.grey[500])),
          ),
          Container(color: Colors.grey[300], height: 20, width: 2),
          TextButton(
            onPressed: state.isLoading ? null : () => _handleDeleteAccount(context, viewModel),
            child: Text(strings(context).deleteAccount, style: TextStyle(color: Colors.grey[500])),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context, AccountActionViewModel viewModel) async {
    final result = await DialogueUtil.showAppCupertinoDialog(
      context: context,
      title: strings(context).logoutDialogTitle,
      content: strings(context).logoutDialogSubTitle,
      showCancel: true,
    );

    if (result == AppDialogResult.confirm) {
      final success = await viewModel.logout();
      if (success) {
        // ignore: use_build_context_synchronously
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const LoginPage()), (route) => false);
      } else {
        // ignore: use_build_context_synchronously
        SnackbarUtil.showSnackBar(context, strings(context).logouterror);
      }
    }
  }

  Future<void> _handleDeleteAccount(BuildContext context, AccountActionViewModel viewModel) async {
    final result = await DialogueUtil.showAppCupertinoDialog(
      context: context,
      title: strings(context).deleteAccountDialogTitle,
      content: strings(context).deleteAccountDialogSubTitle,
      showCancel: true,
    );

    if (result == AppDialogResult.confirm) {
      final success = await viewModel.deleteAccount();
      if (success) {
        // ignore: use_build_context_synchronously
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const LoginPage()), (route) => false);
      } else {
        // ignore: use_build_context_synchronously
        SnackbarUtil.showSnackBar(context, strings(context).deleteAccountError);
      }
    }
  }
}
