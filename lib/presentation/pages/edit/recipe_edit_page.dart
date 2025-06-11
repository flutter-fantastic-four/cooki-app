import 'dart:developer';
import 'dart:typed_data';

import 'package:cooki/presentation/pages/edit/widgets/number_input_box.dart';
import 'package:cooki/presentation/widgets/category_selection_dialog.dart';
import 'package:cooki/presentation/widgets/recipe_page_widgets.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';

import '../../../app/constants/app_colors.dart';
import '../../../core/utils/general_util.dart';
import '../../../domain/entity/generated_recipe.dart';

const servingsTitleStyle = TextStyle(fontSize: 17, fontWeight: FontWeight.bold);
const cookTimeAndKcalTextStyle = TextStyle(
  fontWeight: FontWeight.bold,
  fontSize: 16,
);

class RecipeEditPage extends StatefulWidget {
  final GeneratedRecipe? generatedRecipe;

  const RecipeEditPage({super.key, this.generatedRecipe});

  @override
  State<RecipeEditPage> createState() => _RecipeEditPageState();
}

class _RecipeEditPageState extends State<RecipeEditPage> {
  final _titleController = TextEditingController();
  final _ingredientsControllers = <TextEditingController>[];
  final _stepsControllers = <TextEditingController>[];
  final _cookTimeController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _tagsController = TextEditingController();

  String? _selectedCategory;
  bool _isPublic = true;
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    final generatedRecipe = widget.generatedRecipe;

    if (generatedRecipe != null) {
      _titleController.text = generatedRecipe.recipeName;

      _ingredientsControllers.addAll(
        generatedRecipe.ingredients
            .map((ingredient) => TextEditingController(text: ingredient))
            .toList(),
      );
      _stepsControllers.addAll(
        generatedRecipe.steps
            .map((step) => TextEditingController(text: step))
            .toList(),
      );

      _cookTimeController.text = generatedRecipe.cookTime.toString();
      _caloriesController.text = generatedRecipe.calories.toString();
      _tagsController.text = (generatedRecipe.tags).join(', ');
      _selectedCategory = generatedRecipe.category;
      _imageBytes = generatedRecipe.imageBytes;
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
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    if (_imageBytes != null) ...[
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
                              SizedBox(width: 7),
                              SizedBox.square(
                                dimension: 20,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () {},
                                  icon: Icon(Icons.edit, size: 15),
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
                          if (widget.generatedRecipe != null)
                            _buildTagChips(widget.generatedRecipe!.tags),

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
                                style: servingsTitleStyle,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          RecipePageWidgets.divider,
                          _buildIngredientsList(),

                          const SizedBox(height: 24),
                          Text(
                            strings(context).stepsLabel,
                            style: RecipePageWidgets.sectionTitleStyle,
                          ),
                          const SizedBox(height: 8),

                          // _buildTextField(
                          //   _stepsController,
                          //   hint: strings(context).stepsHint,
                          //   maxLines: 8,
                          // ),
                          const SizedBox(height: 24),
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

  Widget _buildIngredientsList() {
    final ingredients = widget.generatedRecipe?.ingredients ?? [];

    return Column(
      children: List.generate(ingredients.length, (index) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: _buildTextField(
                _ingredientsControllers[index],
                hint: strings(context).ingredientsHint,
                maxLines: 1,
              ),
            ),
            if (index < ingredients.length - 1) RecipePageWidgets.divider,
          ],
        );
      }),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, {
    String? hint,
    int maxLines = 1,
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade600),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 16,
        ),
        filled: true,
        fillColor: AppColors.appBarGrey,
        border: WidgetStateInputBorder.resolveWith((_) {
          return OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(12),
          );
        }),
        suffixIcon: IconButton(
          padding: EdgeInsets.zero,
          icon: Icon(
            Icons.delete,
            size: 20,
            color: AppColors.greyScale500,
          ),
          onPressed: () {
            controller.clear();
          },
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return GestureDetector(
      onTap: () async {
        // ignore: unused_local_variable
        final selectedCategory = await showCategorySelectionDialog(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.appBarGrey,
          borderRadius: BorderRadius.circular(8),
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

  Widget _buildTagChips(List<String> tags) {
    return Wrap(
      spacing: 6,
      runSpacing: 8,
      children:
          tags.map((tag) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: AppColors.greyScale400),
                  borderRadius: BorderRadius.circular(18),
                ),
                color: Colors.white,
              ),
              child: DefaultTextStyle(
                style: TextStyle(color: Colors.black, fontSize: 13),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [Text(tag)],
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildImageSelector() {
    return GestureDetector(
      onTap: () {
        final imageProvider = MemoryImage(_imageBytes!);
        showImageViewer(
          context,
          imageProvider,
          swipeDismissible: true,
          doubleTapZoomable: true,
          useSafeArea: true,
        );
      },
      child: Image.memory(
        _imageBytes!,
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
          value: _isPublic,
          onChanged: (val) => setState(() => _isPublic = val),
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
            child: OutlinedButton.icon(
              onPressed: () {
                log(widget.generatedRecipe.toString());
              },
              icon: const Icon(Icons.delete, color: Colors.red),
              label: Text(
                strings(context).deleteRecipeButton,
                style: TextStyle(color: Colors.red),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // handle save later
              },
              icon: const Icon(Icons.check),
              label: Text(strings(context).saveRecipeButton),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1D8163),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
