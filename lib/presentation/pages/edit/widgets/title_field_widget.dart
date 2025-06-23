import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/constants/app_colors.dart';
import '../../../../core/ui_validators/recipe_validator.dart';
import '../../../../core/utils/error_mappers.dart';
import '../../../../core/utils/general_util.dart';
import '../../../../domain/entity/recipe.dart';

class TitleFieldWidget extends ConsumerWidget {
  final Recipe? recipe;
  final TextEditingController titleController;

  const TitleFieldWidget({
    super.key,
    required this.recipe,
    required this.titleController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.read(recipeEditViewModelProvider(recipe).notifier);
    final isEditingTitle = ref.watch(
      recipeEditViewModelProvider(
        recipe,
      ).select((state) => state.isEditingTitle),
    );

    if (isEditingTitle) {
      return _buildTextFieldRow(context, vm, ref);
    } else {
      return _buildTextRow(context, vm);
    }
  }

  Widget _buildTextFieldRow(
    BuildContext context,
    RecipeEditViewModel vm,
    WidgetRef ref,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: IntrinsicWidth(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width - 100,
              ),
              child: TextFormField(
                controller: titleController,
                // maxLength: RecipePageWidgets.titleMaxLength,
                style: TextStyle(
                  fontSize: 20,
                  color: AppColors.greyScale800,
                  fontWeight: FontWeight.bold,
                ),
                autofocus: true,
                validator: (value) {
                  final error = RecipeValidator.validateTitle(value);
                  return error != null
                      ? ErrorMapper.mapRecipeValidationError(context, error)
                      : null;
                },
                onFieldSubmitted: (_) => _confirmTitleEdit(vm),
                decoration: InputDecoration(
                  hintText: strings(context).recipeTitleHint,
                  hintStyle: const TextStyle(color: Colors.grey),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 14,
                  ),
                  filled: true,
                  fillColor: AppColors.appBarGrey,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        _buildTitleActionButton(
          onPressed: () => _confirmTitleEdit(vm),
          icon: Icons.check,
          color: AppColors.primary,
        ),
        _buildTitleActionButton(
          onPressed: () {
            final confirmedTitle =
                ref.read(recipeEditViewModelProvider(recipe)).currentTitle;
            _cancelTitleEdit(vm, confirmedTitle);
          },
          icon: Icons.close,
          color: AppColors.greyScale500,
        ),
      ],
    );
  }

  Widget _buildTitleActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: SizedBox.square(
        dimension: 27,
        child: IconButton(
          padding: EdgeInsets.zero,
          onPressed: onPressed,
          icon: Icon(icon, color: color, size: 18),
        ),
      ),
    );
  }

  Widget _buildTextRow(BuildContext context, RecipeEditViewModel vm) {
    return Row(
      children: [
        Expanded(
          child: Text(
            titleController.text.isNotEmpty
                ? titleController.text
                : strings(context).recipeTitleHint,
            style: RecipePageWidgets.sectionTitleStyle.copyWith(
              color:
                  titleController.text.isNotEmpty ? Colors.black : Colors.grey,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: SizedBox.square(
            dimension: 30,
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () => vm.startTitleEdit(),
              icon: const Icon(Icons.edit, size: 15),
            ),
          ),
        ),
      ],
    );
  }
}
