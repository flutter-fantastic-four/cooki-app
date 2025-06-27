import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/constants/app_colors.dart';
import '../settings_global_view_model.dart';

class SelectableOptionRow extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;
  final double horizontalPadding;
  final bool isTwoOptions;
  final bool useCheckbox;

  const SelectableOptionRow({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onTap,
    this.horizontalPadding = 10,
    this.isTwoOptions = false,
    this.useCheckbox = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final isKorean =
            ref.read(settingsGlobalViewModelProvider).selectedLanguage ==
            SupportedLanguage.korean;
        final minHeight = isKorean ? 0.0 : 62.0;

        return InkWell(
          onTap: onTap,
          child: Container(
            constraints: BoxConstraints(
              minHeight: isTwoOptions ? 0 : minHeight,
            ),
            padding: EdgeInsets.symmetric(
              vertical: 7,
              horizontal: horizontalPadding,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    text,
                    maxLines: 2,
                    style: TextStyle(fontSize: 17, color: Colors.black),
                  ),
                ),
                const SizedBox(width: 22),
                useCheckbox
                    ? CheckboxWidget(isSelected: isSelected)
                    : RadioCircle(
                      isSelected: isSelected,
                      showCheckOnUnselected: isTwoOptions,
                    ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class RadioCircle extends StatelessWidget {
  final bool isSelected;
  final bool showCheckOnUnselected;
  final double dimension;

  const RadioCircle({
    super.key,
    required this.isSelected,
    this.showCheckOnUnselected = false,
    this.dimension = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: dimension,
      height: dimension,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? AppColors.primary400 : Colors.transparent,
        border: isSelected ? null : Border.all(color: Colors.grey, width: 1.0),
      ),
      child:
          isSelected
              ? const Icon(Icons.check, color: Colors.white, size: 18)
              : showCheckOnUnselected
              ? const Icon(Icons.check, color: Colors.grey, size: 18)
              : null,
    );
  }
}

class CheckboxWidget extends StatelessWidget {
  final bool isSelected;
  final double dimension;

  const CheckboxWidget({
    super.key,
    required this.isSelected,
    this.dimension = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: dimension,
      height: dimension,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? AppColors.primary400 : Colors.transparent,
        border: isSelected ? null : Border.all(color: Colors.grey, width: 1.0),
      ),
      child:
          isSelected
              ? const Icon(Icons.check, color: Colors.white, size: 18)
              : null,
    );
  }
}
