import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cooki/presentation/pages/edit/recipe_edit_view_model.dart';
import 'package:cooki/presentation/pages/edit/widgets/number_input_box.dart';
import 'package:cooki/presentation/pages/edit/widgets/recipe_list_input_widget.dart';
import 'package:cooki/presentation/widgets/app_cached_image.dart';
import 'package:cooki/presentation/widgets/category_selection_dialog.dart';
import 'package:cooki/presentation/widgets/recipe_page_widgets.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/constants/app_colors.dart';
import '../../../core/utils/general_util.dart';
import '../../../domain/entity/recipe.dart';

const cookTimeAndKcalTextStyle = TextStyle(
  fontWeight: FontWeight.bold,
  fontSize: 16,
);

class RecipeEditPage extends ConsumerStatefulWidget {
  final Recipe? recipe;

  const RecipeEditPage({super.key, this.recipe});

  @override
  ConsumerState<RecipeEditPage> createState() => _RecipeEditPageState();
}

class _RecipeEditPageState extends ConsumerState<RecipeEditPage> {
  Recipe? recipe;
  final _titleController = TextEditingController();
  final _ingredientsControllers = <TextEditingController>[];
  final _stepsControllers = <TextEditingController>[];
  final _cookTimeController = TextEditingController();
  final _caloriesController = TextEditingController();

  String? _selectedCategory;

  void _addIngredient(RecipeEditViewModel vm) {
    vm.addIngredient();
    setState(() {
      _ingredientsControllers.add(TextEditingController());
    });
  }

  void _removeIngredient(RecipeEditViewModel vm, int index) {
    vm.removeIngredient(index);
    setState(() {
      _ingredientsControllers.removeAt(index).dispose();
    });
  }

  void _addStep(RecipeEditViewModel vm) {
    vm.addStep();
    setState(() {
      _stepsControllers.add(TextEditingController());
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
      _selectedCategory = recipe!.category;
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
    // final state = ref.watch(
    //   recipeEditViewModelProvider(widget.generatedRecipe),
    // );
    final vm = ref.read(recipeEditViewModelProvider(widget.recipe).notifier);

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

                          // const SizedBox(height: 8),
                          // _buildTextField(
                          //   _titleController,
                          //   hint: strings(context).recipeTitleHint,
                          // ),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                strings(context).beforeMinutesLabel,
                                style: cookTimeAndKcalTextStyle,
                              ),
                              NumberInputBox(controller: _cookTimeController),
                              Text(
                                strings(context).afterMinutesLabel,
                                style: cookTimeAndKcalTextStyle,
                              ),
                              const SizedBox(width: 24),
                              NumberInputBox(
                                controller: _caloriesController,
                                isMinutes: false,
                              ),
                              Text(
                                strings(context).caloriesUnitAfter,
                                style: cookTimeAndKcalTextStyle,
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),
                          if (recipe != null)
                            TagChips(recipe!.tags),

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
              _buildBottomActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return GestureDetector(
      onTap: () async {
        final selectedCategory = await showCategorySelectionDialog(context);
        if (selectedCategory?.isNotEmpty == true) {
          setState(() {
            _selectedCategory = selectedCategory;
          });
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
                _selectedCategory ?? strings(context).categoryPlaceholder,
                style: TextStyle(
                  fontSize: 16,
                  color: _selectedCategory == null ? Colors.grey : Colors.black,
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
        final imageProvider = CachedNetworkImageProvider(
          recipe!.imageUrl!,
        );
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Switch.adaptive(
          activeColor: const Color(0xFF1D8163),
          value: recipe?.isPublic == true,
          onChanged:
              (val) => setState(() {
                setState(() {
                  recipe = recipe?.copyWith(isPublic: val);
                });
              }),
        ),
      ],
    );
  }

  Widget _buildBottomActions() {
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
              onPressed: () {
                // handle save later
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1D8163),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(strings(context).saveRecipeButton),
            ),
          ),
        ],
      ),
    );
  }
}
