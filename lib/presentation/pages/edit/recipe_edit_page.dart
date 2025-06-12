import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cooki/core/utils/snackbar_util.dart';
import 'package:cooki/domain/entity/app_user.dart';
import 'package:cooki/presentation/pages/edit/recipe_edit_view_model.dart';
import 'package:cooki/presentation/pages/edit/widgets/number_input_box.dart';
import 'package:cooki/presentation/pages/edit/widgets/input_list_widget.dart';
import 'package:cooki/presentation/widgets/app_cached_image.dart';
import 'package:cooki/presentation/widgets/category_selection_dialog.dart';
import 'package:cooki/presentation/widgets/recipe_page_widgets.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/constants/app_colors.dart';
import '../../../core/utils/dialogue_util.dart';
import '../../../core/utils/error_mappers.dart';
import '../../../core/utils/general_util.dart';
import '../../../domain/entity/recipe.dart';
import '../../user_global_view_model.dart';

class RecipeEditPage extends ConsumerStatefulWidget {
  final Recipe? recipe;

  const RecipeEditPage({super.key, this.recipe});

  @override
  ConsumerState<RecipeEditPage> createState() => _RecipeEditPageState();
}

class _RecipeEditPageState extends ConsumerState<RecipeEditPage> {
  Recipe? recipe;
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _ingredientsControllers = <TextEditingController>[];
  final _stepsControllers = <TextEditingController>[];
  final _cookTimeController = TextEditingController();
  final _caloriesController = TextEditingController();

  Future<void> _saveRecipe() async {
    if (_formKey.currentState!.validate()) {
      final vm = ref.read(recipeEditViewModelProvider(widget.recipe).notifier);
      AppUser? user;
      if (widget.recipe == null) {
        user = ref.read(userGlobalViewModelProvider)!;
      }

      await vm.saveRecipe(
        title: _titleController.text.trim(),
        ingredients: _ingredientsControllers.map((c) => c.text.trim()).toList(),
        steps: _stepsControllers.map((c) => c.text.trim()).toList(),
        cookTime: int.parse(_cookTimeController.text),
        calories: int.parse(_caloriesController.text),
        user: user,
      );

      final errorKey =
          ref.read(recipeEditViewModelProvider(widget.recipe)).errorKey;
      if (mounted && errorKey != null) {
        DialogueUtil.showAppCupertinoDialog(
          context: context,
          title: strings(context).recipeSavingFailedTitle,
          content: ErrorMapper.mapGenerateRecipeError(context, errorKey),
        );
        vm.clearError();
        return;
      }

      if (mounted) {
        SnackbarUtil.showSnackBar(
          context,
          strings(context).recipeSavedSuccessfully,
          showIcon: true,
        );
        // Navigator.of(context).pop();
      }
    }
  }

  void _addIngredient(RecipeEditViewModel vm) {
    vm.addIngredient();
    setState(() {
      _ingredientsControllers.add(TextEditingController());
    });
  }

  void _addStep(RecipeEditViewModel vm) {
    vm.addStep();
    setState(() {
      _stepsControllers.add(TextEditingController());
    });
  }

  void _removeIngredient(RecipeEditViewModel vm, int index) {
    vm.removeIngredient(index);
    setState(() {
      _ingredientsControllers.removeAt(index).dispose();
    });
  }

  void _removeStep(RecipeEditViewModel vm, int index) {
    vm.removeStep(index);
    setState(() {
      _stepsControllers.removeAt(index).dispose();
    });
  }

  @override
  void initState() {
    super.initState();
    recipe = widget.recipe;

    if (recipe != null) {
      _titleController.text = recipe!.recipeName;
      _ingredientsControllers.addAll(
        recipe!.ingredients.map(
          (ingredient) => TextEditingController(text: ingredient),
        ),
      );
      _stepsControllers.addAll(
        recipe!.steps.map((step) => TextEditingController(text: step)),
      );
      _cookTimeController.text = recipe!.cookTime.toString();
      _caloriesController.text = recipe!.calories.toString();
    }

    // Ensure at least one field
    if (_ingredientsControllers.isEmpty) {
      _ingredientsControllers.add(TextEditingController());
    }
    if (_stepsControllers.isEmpty) {
      _stepsControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (final controller in _ingredientsControllers) {
      controller.dispose();
    }
    for (final controller in _stepsControllers) {
      controller.dispose();
    }
    _cookTimeController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.read(recipeEditViewModelProvider(widget.recipe).notifier);
    // final state = ref.watch(recipeEditViewModelProvider(widget.recipe));

    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            strings(context).editRecipeTitle,
            style: const TextStyle(color: Colors.black),
          ),
        ),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      if (recipe?.imageUrl != null) ...[
                        _buildImageSelector(),
                        const SizedBox(height: 5),
                      ],
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 2),

                            // Title field
                            Row(
                              children: [
                                Text(
                                  _titleController.text,
                                  style: RecipePageWidgets.sectionTitleStyle,
                                ),
                                const SizedBox(width: 7),
                                SizedBox.square(
                                  dimension: 20,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () {},
                                    icon: const Icon(Icons.edit, size: 15),
                                  ),
                                ),
                              ],
                            ),

                            // TextFormField(
                            //   controller: _titleController,
                            //   validator: (value) {
                            //     final error = RecipeValidator.validateTitle(
                            //       value,
                            //     );
                            //     return error != null
                            //         ? ErrorMapper.mapRecipeValidationError(
                            //           context,
                            //           error,
                            //         )
                            //         : null;
                            //   },
                            //   decoration: InputDecoration(
                            //     labelText: strings(context).recipeTitleLabel,
                            //     hintText: strings(context).recipeTitleHint,
                            //     contentPadding: const EdgeInsets.symmetric(
                            //       vertical: 12,
                            //       horizontal: 14,
                            //     ),
                            //     filled: true,
                            //     fillColor: AppColors.appBarGrey,
                            //     border: OutlineInputBorder(
                            //       borderRadius: BorderRadius.circular(12),
                            //       borderSide: BorderSide.none,
                            //     ),
                            //     errorBorder: OutlineInputBorder(
                            //       borderRadius: BorderRadius.circular(12),
                            //       borderSide: const BorderSide(
                            //         color: Colors.red,
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildCookLabel(strings(context).beforeMinutesLabel),
                                NumberInputBox(controller: _cookTimeController),
                                _buildCookLabel(strings(context).afterMinutesLabel),
                                const SizedBox(width: 24),
                                NumberInputBox(
                                  controller: _caloriesController,
                                  isMinutes: false,
                                ),
                                _buildCookLabel(strings(context).caloriesUnitAfter),
                              ],
                            ),

                            const SizedBox(height: 20),
                            if (recipe != null) TagChips(recipe!.tags),

                            const SizedBox(height: 28),
                            Text(
                              strings(context).categoryLabel,
                              style: RecipePageWidgets.sectionTitleStyle,
                            ),
                            const SizedBox(height: 8),
                            _buildCategorySelector(),

                            const SizedBox(height: 28),
                            Row(
                              children: [
                                Text(
                                  strings(context).ingredientsLabel,
                                  style: RecipePageWidgets.sectionTitleStyle,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  strings(context).servingsLabel,
                                  style: RecipePageWidgets.servingsTitleStyle,
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),
                            InputListWidget(
                              controllers: _ingredientsControllers,
                              hintText: strings(context).ingredientsHint,
                              onAdd: () => _addIngredient(vm),
                              onRemove: (index) => _removeIngredient(vm, index),
                            ),

                            const SizedBox(height: 24),
                            Text(
                              strings(context).stepsLabel,
                              style: RecipePageWidgets.sectionTitleStyle,
                            ),

                            const SizedBox(height: 8),
                            InputListWidget(
                              controllers: _stepsControllers,
                              isSteps: true,
                              hintText: strings(context).stepsHint,
                              onAdd: () => _addStep(vm),
                              onRemove: (index) => _removeStep(vm, index),
                            ),

                            const SizedBox(height: 10),
                            Text(
                              strings(context).isPublicLabel,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            _buildPublicToggle(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _buildBottomActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCookLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildCategorySelector() {
    final vm = ref.read(recipeEditViewModelProvider(widget.recipe).notifier);
    final selectedCategory = ref.watch(
      recipeEditViewModelProvider(
        widget.recipe,
      ).select((state) => state.selectedCategory),
    );

    return GestureDetector(
      onTap: () async {
        final category = await showCategorySelectionDialog(context);
        if (category?.isNotEmpty == true) {
          vm.setCategory(category);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.appBarGrey,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedCategory ?? strings(context).categoryPlaceholder,
                style: TextStyle(
                  fontSize: 16,
                  color: selectedCategory == null ? Colors.grey : Colors.black,
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_outlined,
              color: Colors.black54,
              size: 23,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSelector() {
    return GestureDetector(
      onTap: () {
        final imageProvider = CachedNetworkImageProvider(recipe!.imageUrl!);
        showImageViewer(
          context,
          imageProvider,
          swipeDismissible: true,
          doubleTapZoomable: true,
          useSafeArea: true,
        );
      },
      child: AppCachedImage(
        imageUrl: recipe!.imageUrl!,
        fit: BoxFit.cover,
        height: 230,
        width: double.infinity,
      ),
    );
  }

  Widget _buildPublicToggle() {
    final vm = ref.read(recipeEditViewModelProvider(widget.recipe).notifier);
    final isPublic = ref.watch(
      recipeEditViewModelProvider(
        widget.recipe,
      ).select((state) => state.isPublic),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Switch.adaptive(
          activeColor: const Color(0xFF1D8163),
          value: isPublic,
          onChanged: (val) => vm.setIsPublic(val),
        ),
      ],
    );
  }

  Widget _buildBottomActions() {
    final isSaving = ref.watch(
      recipeEditViewModelProvider(
        widget.recipe,
      ).select((state) => state.isSaving),
    );

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                log(recipe.toString());
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
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
              onPressed: isSaving ? null : _saveRecipe,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1D8163),
                foregroundColor: Colors.white,
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
