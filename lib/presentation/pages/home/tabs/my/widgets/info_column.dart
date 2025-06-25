import 'package:cooki/core/utils/general_util.dart';
import 'package:cooki/presentation/pages/home/tabs/my/widgets/info_item_row.dart';
import 'package:flutter/widgets.dart';

class InfoColumn extends StatelessWidget {
  const InfoColumn({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Text(strings(context).information, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),

          InfoItemRow(infoItem: InfoItem.termsOfService),
          InfoItemRow(infoItem: InfoItem.privacyPolicy),
          InfoItemRow(infoItem: InfoItem.contactTheDevelopersTeam),
          InfoItemRow(infoItem: InfoItem.version),
        ],
      ),
    );
  }
}
