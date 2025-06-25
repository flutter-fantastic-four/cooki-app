import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/constants/app_colors.dart';
import '../../../../core/utils/general_util.dart';
import '../../../../core/utils/snackbar_util.dart';
import '../../../../domain/entity/recipe.dart';
import '../../../widgets/app_dialog.dart';
import '../recipe_edit_view_model.dart';

class BottomButtonsRow extends ConsumerWidget {
  final Recipe? recipe;
  final VoidCallback onSave;

  const BottomButtonsRow({
    super.key,
    required this.recipe,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSaving = ref.watch(
      recipeEditViewModelProvider(recipe).select((state) => state.isSaving),
    );

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      margin: const EdgeInsets.only(bottom: 33),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () async {
                log(recipe.toString());

                if (recipe == null) return;

                if (!context.mounted) return;
                AppDialog.show(
                  context: context,
                  title: strings(context).delete,
                  subText: strings(
                    context,
                  ).deleteConfirmMessage(recipe!.recipeName),
                  primaryButtonText: strings(context).delete,
                  secondaryButtonText: strings(context).cancel,
                  isDestructive: true,
                  onPrimaryButtonPressed: () async {
                    await ref
                        .read(recipeEditViewModelProvider(recipe).notifier)
                        .deleteRecipe();

                    if (!context.mounted) return;
                    SnackbarUtil.showSnackBar(
                      context,
                      strings(context).deleteSuccess,
                      showIcon: true,
                    );
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
              ),
              child: Text(
                strings(context).deleteRecipeButton,
                style: const TextStyle(color: AppColors.error),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: isSaving ? null : onSave,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child:
                  isSaving
                      ? const SizedBox(
                        width: 21,
                        height: 21,
                        child: CupertinoActivityIndicator(radius: 10),
                      )
                      : Text(strings(context).saveRecipeButton),
            ),
          ),
        ],
      ),
    );
  }
}
