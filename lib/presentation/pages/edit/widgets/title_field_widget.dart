import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/constants/app_colors.dart';
import '../../../../core/ui_validators/recipe_validator.dart';
import '../../../../core/utils/error_mappers.dart';
import '../../../../core/utils/general_util.dart';
import '../../../../domain/entity/recipe.dart';
import '../../../widgets/recipe_page_widgets.dart';

// final titleLengthProvider = StateProvider.autoDispose<int>((ref) => 0);

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
    return TextFormField(
      controller: titleController,
      style: TextStyle(
        fontSize: 20,
        color: AppColors.greyScale800,
        fontWeight: FontWeight.bold,
      ),
      minLines: 1,
      maxLines: 2,
      validator: (value) {
        final error = RecipeValidator.validateTitle(value);
        return error != null
            ? ErrorMapper.mapRecipeValidationError(context, error)
            : null;
      },
      maxLength: RecipePageWidgets.titleMaxLength,
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
        counterStyle: const TextStyle(
          fontSize: 12,
          color: AppColors.greyScale600,
        ),
      ),
    );
  }
}
