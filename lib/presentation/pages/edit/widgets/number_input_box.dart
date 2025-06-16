import 'package:cooki/app/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/ui_validators/recipe_validator.dart';
import '../../../../core/utils/error_mappers.dart';
import '../../../widgets/recipe_page_widgets.dart';

class NumberInputBox extends StatelessWidget {
  final TextEditingController controller;
  final bool isMinutes;

  const NumberInputBox({
    super.key,
    required this.controller,
    this.isMinutes = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: SizedBox(
        width: isMinutes ? 50 : 65,
        child: TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          maxLength: isMinutes ? 3 : 4,
          validator: (value) {
            final error = RecipeValidator.validateGeneralNotEmpty(value);
            return ErrorMapper.mapRecipeValidationError(context, error);
          },
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            isCollapsed: true,
            counterText: '',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 6,
            ),
            filled: true,
            fillColor: AppColors.greyScale50,
            border: WidgetStateInputBorder.resolveWith((_) {
              return OutlineInputBorder(
                borderRadius: RecipePageWidgets.inputBorderRadius,
                borderSide: BorderSide.none,
              );
            }),
          ),
        ),
      ),
    );
  }
}
