import 'dart:developer';

import 'package:cooki/core/utils/error_mappers.dart';
import 'package:cooki/core/utils/general_util.dart';
import 'package:cooki/presentation/pages/edit/recipe_edit_page.dart';
import 'package:cooki/presentation/pages/generate/widgets/generate_button.dart';
import 'package:cooki/presentation/pages/generate/widgets/image_selector.dart';
import 'package:cooki/presentation/pages/generate/widgets/preference_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/constants/app_constants.dart';
import '../../user_global_view_model.dart';
import '../../widgets/input_decorations.dart';
import '../../widgets/app_dialog.dart';
import '../detailed_recipe/detailed_recipe_page.dart';
import 'generate_recipe_view_model.dart';

class GenerateRecipePage extends ConsumerWidget {
  const GenerateRecipePage({super.key});

  Future<void> _generateRecipe(WidgetRef ref, BuildContext context) async {
    final start = DateTime.now();
    final savedRecipe = await ref
        .read(generateRecipeViewModelProvider.notifier)
        .generateAndSaveRecipe(
          textOnlyRecipePromptPath: strings(context).textOnlyRecipePromptPath,
          imageRecipePromptPath: strings(context).imageRecipePromptPath,
          user: ref.read(userGlobalViewModelProvider)!,
        );
    log(
      'generateAndSaveRecipe executed in ${DateTime.now().difference(start).inMilliseconds} ms',
    );

    final state = ref.read(generateRecipeViewModelProvider);

    if (context.mounted && state.errorKey != null) {
      AppDialog.show(
        context: context,
        title: strings(context).generationFailedTitle,
        subText: ErrorMapper.mapGenerateRecipeError(context, state.errorKey!),
      );
      ref.read(generateRecipeViewModelProvider.notifier).clearError();
      return;
    }

    if (savedRecipe != null) {
      if (!context.mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => RecipeEditPage(recipe: savedRecipe)),
      );
    }
  }

  bool _hasUnsavedChanges(GenerateRecipeState state) {
    // Check if text input has content
    final hasTextInput = state.textInput.trim().isNotEmpty;
    // Check if image has been selected
    final hasImageSelected = state.selectedImageBytes != null;
    // Check if preferences have been selected
    final hasPreferencesSelected = state.selectedPreferences.isNotEmpty;
    return hasTextInput || hasImageSelected || hasPreferencesSelected;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GeneralUtil.buildUnsavedChangesPopScope(
      context: context,
      hasUnsavedChanges: () {
        final state = ref.read(generateRecipeViewModelProvider);
        return _hasUnsavedChanges(state);
      },
      child: GestureDetector(
        onTap: FocusScope.of(context).unfocus,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 1,
            leading: IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.close, size: 27),
            ),
            title: Text(
              strings(context).generateRecipeAppBarTitle,
              style: const TextStyle(color: Colors.black),
            ),
          ),
          bottomNavigationBar: Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              final state = ref.watch(generateRecipeViewModelProvider);
              return GenerateButton(
                onTap:
                    state.canGenerate
                        ? () => _generateRecipe(ref, context)
                        : null,
                isLoading: state.isGeneratingAndSaving,
              );
            },
          ),
          body: SelectionArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              child: _buildLayout(context, ref),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLayout(BuildContext context, WidgetRef ref) {
    return ListView(
      children: [
        const SizedBox(height: 10),
        Text(
          strings(context).generatePageMainTitle,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E1E1E),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          strings(context).generatePageSubtitle,
          style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.5),
        ),

        const SizedBox(height: 22),
        ImageSelector(),

        const SizedBox(height: 22),
        Text(
          strings(context).aiTextInputLabel,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        TextField(
          maxLines: 4,
          maxLength: 300,
          onChanged:
              (text) => ref
                  .read(generateRecipeViewModelProvider.notifier)
                  .updateTextInput(text.trim()),
          decoration: getInputDecoration(
            strings(context).generateTextFieldHint,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 36,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Consumer(
              builder: (context, ref, child) {
                final selectedPreferences = ref.watch(
                  generateRecipeViewModelProvider.select(
                    (state) => state.selectedPreferences,
                  ),
                );
                return Row(
                  children:
                      AppConstants.recipePreferences(context)
                          .map(
                            (label) => PreferenceChip(
                              label: label,
                              isSelected: selectedPreferences.contains(label),
                              onTap:
                                  () => ref
                                      .read(
                                        generateRecipeViewModelProvider
                                            .notifier,
                                      )
                                      .togglePreference(label),
                            ),
                          )
                          .toList(),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Center(
            child: Text(
              strings(context).recipeGenerationTip,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700], fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }
}
