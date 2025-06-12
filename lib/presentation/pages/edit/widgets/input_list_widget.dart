import 'package:flutter/material.dart';
import 'package:cooki/presentation/pages/edit/recipe_edit_view_model.dart';
import 'package:cooki/presentation/widgets/recipe_page_widgets.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../core/ui_validators/recipe_validator.dart';
import '../../../../core/utils/error_mappers.dart';

/// A single widget to render either Ingredients or Steps list.
/// If [isSteps] is true, it shows “1.”, “2.” etc. on the left.
/// Always shows a cancel‐circle on the right (disabled if there is only 1 item),
/// and a trailing “Add” button if we are under the max.
class InputListWidget extends StatelessWidget {
  final List<TextEditingController> controllers;
  final bool isSteps;
  final String hintText;
  final VoidCallback onAdd;
  final void Function(int) onRemove;

  const InputListWidget({
    super.key,
    required this.controllers,
    this.isSteps = false,
    required this.hintText,
    required this.onAdd,
    required this.onRemove,
  });

  String? _validate(BuildContext context, String? value) {
    final error =
        isSteps
            ? RecipeValidator.validateStep(value)
            : RecipeValidator.validateIngredient(value);
    return ErrorMapper.mapRecipeValidationError(context, error);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...List.generate(controllers.length, (index) {
          final canRemove = controllers.length > 1;

          return Column(
            children: [
              RecipePageWidgets.divider,
              Padding(
                padding: EdgeInsets.only(
                  top: 4,
                  bottom: 4,
                  left: isSteps ? 1 : 14,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isSteps) StepIndexLabel(index + 1),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: controllers[index],
                              minLines: 1,
                              maxLines: isSteps ? 3 : 1,
                              validator: (value) => _validate(context, value),
                              decoration: InputDecoration(
                                hintText: hintText,
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade600,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 14,
                                ),
                                filled: true,
                                fillColor: AppColors.appBarGrey,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                // errorBorder: OutlineInputBorder(
                                //   borderRadius: BorderRadius.circular(12),
                                //   borderSide: const BorderSide(color: Colors.red),
                                // ),
                                errorStyle: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          SizedBox.square(
                            dimension: 27,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                Icons.cancel,
                                size: 18,
                                color:
                                    canRemove
                                        ? AppColors.greyScale500
                                        : Colors.grey.shade300,
                              ),
                              onPressed:
                                  canRemove ? () => onRemove(index) : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
        // Add button
        if (controllers.length < recipeListMaxItems)
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: SizedBox.square(
              dimension: 46,
              child: IconButton(
                padding: EdgeInsets.zero,
                color: AppColors.primary700,
                onPressed: onAdd,
                icon: const Icon(Icons.add_circle_outline, size: 34),
              ),
            ),
          ),
      ],
    );
  }
}
