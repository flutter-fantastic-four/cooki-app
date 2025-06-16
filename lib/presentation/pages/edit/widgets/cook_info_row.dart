import 'package:flutter/material.dart';

import '../../../../core/utils/general_util.dart';
import 'number_input_box.dart';

class CookInfoRowWidget extends StatelessWidget {
  final TextEditingController cookTimeController;
  final TextEditingController caloriesController;

  const CookInfoRowWidget({
    super.key,
    required this.cookTimeController,
    required this.caloriesController,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCookLabel(strings(context).beforeMinutesLabel),
        NumberInputBox(controller: cookTimeController),
        _buildCookLabel(strings(context).afterMinutesLabel),
        const SizedBox(width: 24),
        NumberInputBox(controller: caloriesController, isMinutes: false),
        _buildCookLabel(strings(context).caloriesUnitAfter),
      ],
    );
  }

  Widget _buildCookLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}
