import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/general_util.dart';
import '../../../../domain/entity/recipe.dart';
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
              onPressed: () {
                log(recipe.toString());
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
              ),
              child: Text(
                strings(context).deleteRecipeButton,
                style: const TextStyle(color: Colors.red),
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
