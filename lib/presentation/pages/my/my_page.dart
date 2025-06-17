import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/constants/app_colors.dart';
import '../../../app/constants/app_styles.dart';
import '../../../core/utils/dialogue_util.dart';
import '../../../core/utils/snackbar_util.dart';
import '../../../data/repository/providers.dart';
import '../../user_global_view_model.dart';
import '../login/login_page.dart';

/// Settings page that allows users to configure app preferences.
class MyPage extends ConsumerWidget {
  const MyPage({super.key});

  /// Launches the default email client to contact the developer.
  ///
  /// Falls back to a browser-based email client if no email app is available.
  /// Shows an error message if both approaches fail.
  Future<void> _launchEmail(BuildContext context) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: 'penjan.eng@gmail.com', queryParameters: {'subject': 'ShareLingo앱 피드백'});

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri, mode: LaunchMode.externalApplication);
    } else {
      // If no email app, open browser-based mail client (Gmail)
      final fallbackUrl = Uri.parse(
        'https://mail.google.com/mail/?view=cm&fs=1'
        '&to=${'penjan.eng@gmail.com'}&su=${Uri.encodeComponent('ShareLingo앱 피드백')}',
      );
      if (await canLaunchUrl(fallbackUrl)) {
        await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
      }
    }
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    } else {
      if (!context.mounted) return;
      SnackbarUtil.showSnackBar(context, 'URL을 열 수 없습니다');
    }
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    try {
      final result = await DialogueUtil.showAppCupertinoDialog(context: context, title: '로그아웃할까요?', content: '정말 로그아웃하시겠습니까?', showCancel: true);
      if (result == AppDialogResult.confirm) {
        await ref.read(authRepositoryProvider).signOut();
        ref.read(userGlobalViewModelProvider.notifier).clearUser();

        // ignore: use_build_context_synchronously
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const LoginPage()), (route) => false);
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      SnackbarUtil.showSnackBar(context, '로그아웃 중 오류가 발생했습니다');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('설정'), centerTitle: false, titleSpacing: 5, backgroundColor: Colors.white),
      body: SettingsList(
        lightTheme: SettingsThemeData(settingsListBackground: AppColors.backgroundGrey),
        platform: DevicePlatform.iOS,
        sections: [
          SettingsSection(
            // margin: EdgeInsetsDirectional.only(start: 18, end: 18, top: 7, bottom: 7),
            title: Text('계정', style: AppStyles.mediumText),
            tiles: [SettingsTile(leading: const Icon(Icons.logout), title: Text('로그아웃'), onPressed: (context) => _logout(context, ref))],
          ),
          SettingsSection(
            // margin: EdgeInsetsDirectional.only(start: 18, end: 18, top: 7, bottom: 7),
            title: Text('정보', style: AppStyles.mediumText),
            tiles: [
              SettingsTile(leading: const Icon(Icons.article_outlined), title: Text('이용약관'), onPressed: (context) => _launchUrl(context, '')),
              SettingsTile(leading: const Icon(Icons.vpn_key), title: Text('개인정보처리방침'), onPressed: (context) => _launchUrl(context, '')),
              SettingsTile(leading: const Icon(Icons.email), title: Text('개발자들에게 문의'), onPressed: (context) => _launchEmail(context)),
              SettingsTile(leading: const Icon(Icons.info_outline), title: Text('버전'), value: Text('1.0.0'), onPressed: (_) {}),
            ],
          ),
        ],
      ),
    );
  }
}
