import 'package:cooki/presentation/settings_global_view_model.dart';
import 'package:cooki/presentation/widgets/big_title_widget.dart';
import 'package:cooki/presentation/widgets/selectable_option_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/utils/general_util.dart';
import '../../../../../../core/utils/snackbar_util.dart';

class LanguageSelectionPage extends ConsumerStatefulWidget {
  const LanguageSelectionPage({super.key});

  @override
  ConsumerState<LanguageSelectionPage> createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends ConsumerState<LanguageSelectionPage> {
  late SupportedLanguage _selectedLanguage;

  @override
  void initState() {
    super.initState();
    // Initialize with current global language setting
    _selectedLanguage = ref.read(settingsGlobalViewModelProvider.notifier).getCurrentLanguage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(strings(context).languageSettings)),
      backgroundColor: Colors.white,
      bottomNavigationBar: _buildSubmitButton(context),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            BigTitleWidget(title: strings(context).selectLanguageTitle),
            const SizedBox(height: 40),
            ...SupportedLanguage.values.map((language) {
              return Column(
                children: [
                  SelectableOptionRow(
                    text: language.displayName,
                    isSelected: _selectedLanguage == language,
                    horizontalPadding: 0,
                    isTwoOptions: true,
                    onTap: () {
                      setState(() {
                        _selectedLanguage = language;
                      });
                    },
                  ),
                  if (language != SupportedLanguage.values.last) const SizedBox(height: 16),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 33),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: _applyLanguageChange,
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16)),
          child: Text(strings(context).configure),
        ),
      ),
    );
  }

  Future<void> _applyLanguageChange() async {
    try {
      await ref.read(settingsGlobalViewModelProvider.notifier).changeLanguage(_selectedLanguage);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        SnackbarUtil.showSnackBar(context, strings(context).languageChangedSuccessfully, showIcon: true);
        Navigator.of(context).pop();
      });
    } catch (e) {
      if (!mounted) return;
      SnackbarUtil.showSnackBar(context, strings(context).languageChangeFailedError, showIcon: true);
    }
  }
}
