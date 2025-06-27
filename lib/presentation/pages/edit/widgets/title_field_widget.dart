import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/constants/app_colors.dart';
import '../../../../core/ui_validators/recipe_validator.dart';
import '../../../../core/utils/error_mappers.dart';
import '../../../../core/utils/general_util.dart';
import '../../../../domain/entity/recipe.dart';
import '../../../widgets/recipe_page_widgets.dart';
import '../recipe_edit_view_model.dart';

// final titleLengthProvider = StateProvider.autoDispose<int>((ref) => 0);

class TitleFieldWidget extends ConsumerWidget {
  final Recipe? recipe;
  final TextEditingController titleController;

  const TitleFieldWidget({
    super.key,
    required this.recipe,
    required this.titleController,
  });

  void _confirmTitleEdit(RecipeEditViewModel vm) {
    final error = RecipeValidator.validateTitle(titleController.text);
    if (error == null) {
      vm.confirmTitleEdit(titleController.text);
    }
  }

  void _cancelTitleEdit(RecipeEditViewModel vm, String? confirmedTitle) {
    titleController.text = confirmedTitle ?? '';
    vm.cancelTitleEdit();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.read(recipeEditViewModelProvider(recipe).notifier);
    final isEditingTitle = ref.watch(
      recipeEditViewModelProvider(
        recipe,
      ).select((state) => state.isEditingTitle),
    );

    // ref.read(titleLengthProvider.notifier).state = titleController.text.length;

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
                maxLength: RecipePageWidgets.titleMaxLength,
                textInputAction: TextInputAction.done,
                style: TextStyle(
                  fontSize: 20,
                  color: AppColors.greyScale800,
                  fontWeight: FontWeight.bold,
                ),
                minLines: 1,
                maxLines: 2,
                autofocus: true,
                validator: (value) {
                  final error = RecipeValidator.validateTitle(value);
                  return error != null
                      ? ErrorMapper.mapRecipeValidationError(context, error)
                      : null;
                },
                onFieldSubmitted: (_) => _confirmTitleEdit(vm),
                // onChanged: (text) {
                //   ref.read(titleLengthProvider.notifier).state = text.length;
                // },
                decoration: InputDecoration(
                  // counterText: ref.watch(titleLengthProvider) > 33 ? null : '',
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
          color: AppColors.greyScale500,
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
        Flexible(
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
              icon: Image.asset(
                'assets/icons/pencil_icon.png',
                height: 19,
                width: 19,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
