import 'package:flutter/material.dart';

import '../../../../core/utils/general_util.dart';
import '../../../widgets/big_title_widget.dart';
import '../../../widgets/selectable_option_row.dart';

class LanguageSelectionPage extends StatefulWidget {
  const LanguageSelectionPage({super.key});

  @override
  State<LanguageSelectionPage> createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage> {
  String _selectedLanguage = '한국어';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('언어설정'),
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: _buildSubmitButton(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            const BigTitleWidget(title: '쿠키에서\n사용할 언어를 선택하세요'),
            const SizedBox(height: 40),
            SelectableOptionRow(
              text: '한국어',
              isSelected: _selectedLanguage == '한국어',
              horizontalPadding: 0,
              showCheckOnUnselected: true,
              onTap: () {
                setState(() {
                  _selectedLanguage = '한국어';
                });
              },
            ),
            const SizedBox(height: 16),
            SelectableOptionRow(
              text: 'English',
              isSelected: _selectedLanguage == 'English',
              horizontalPadding: 0,
              showCheckOnUnselected: true,
              onTap: () {
                setState(() {
                  _selectedLanguage = 'English';
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 33),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          child: Text(
            strings(context).configure,
          ),
        ),
      ),
    );
  }


}