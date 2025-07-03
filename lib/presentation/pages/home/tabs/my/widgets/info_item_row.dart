import 'package:cooki/core/utils/general_util.dart';
import 'package:cooki/core/utils/snackbar_util.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

enum InfoItem {
  termsOfService,
  privacyPolicy,
  contactTheDevelopersTeam,
  version,
}

class InfoItemRow extends StatefulWidget {
  final InfoItem infoItem;
  const InfoItemRow({super.key, required this.infoItem});

  @override
  State<InfoItemRow> createState() => _InfoItemRowState();
}

class _InfoItemRowState extends State<InfoItemRow> {
  String versionInfo = "";
  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    setState(() {
      versionInfo = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = switch (widget.infoItem) {
      InfoItem.termsOfService => strings(context).termsOfService,
      InfoItem.privacyPolicy => strings(context).privacyPolicy,
      InfoItem.contactTheDevelopersTeam =>
        strings(context).contactTheDevelopersTeam,
      InfoItem.version => strings(context).version,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            switch (widget.infoItem) {
              case InfoItem.termsOfService:
                _launchUrl(
                  context,
                  "https://flutter-fantastic-four.github.io/terms_of_service.html",
                );
                break;
              case InfoItem.privacyPolicy:
                _launchUrl(
                  context,
                  "https://flutter-fantastic-four.github.io/privacy_policy.html",
                );
                break;
              case InfoItem.contactTheDevelopersTeam:
                _launchUrl(
                  context,
                  "https://github.com/flutter-fantastic-four/cooki-app#-개발팀",
                );
                // _launchEmail();
                break;
              case InfoItem.version:
                _launchStore();
                break;
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                Text(title),
                widget.infoItem == InfoItem.version
                    ? Text(versionInfo)
                    : SizedBox(),
              ],
            ),
          ),
        ),
        const Divider(color: Colors.black),
      ],
    );
  }

  // Future<void> _launchEmail() async {
  //   final Uri emailUri = Uri(scheme: 'mailto', path: '@gmail.com', queryParameters: {'subject': 'Cooki app feedback'});
  //
  //   if (await canLaunchUrl(emailUri)) {
  //     await launchUrl(emailUri, mode: LaunchMode.externalApplication);
  //   } else {
  //     // If no email app, open browser-based mail client (Gmail)
  //     final fallbackUrl = Uri.parse(
  //       'https://mail.google.com/mail/?view=cm&fs=1'
  //       '&to=${'@gmail.com'}&su=${Uri.encodeComponent('Cooki app feedback')}',
  //     );
  //     if (await canLaunchUrl(fallbackUrl)) {
  //       await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
  //     }
  //   }
  // }

  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    } else {
      if (!context.mounted) return;
      SnackbarUtil.showSnackBar(context, 'URL을 열 수 없습니다');
    }
  }

  Future<void> _launchStore() async {
    Uri storeUrl = Uri.parse(
      'https://apps.apple.com/us/app/cooki/id6747327839',
    );
    if (await canLaunchUrl(storeUrl)) {
      await launchUrl(storeUrl);
    }
  }
}
