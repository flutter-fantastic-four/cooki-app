import 'package:cooki/app/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: AppColors.greyScale50,
        borderRadius: BorderRadius.circular(8),
      ),
      height: 34,
      alignment: Alignment.center,
      child: SizedBox(
        width: isMinutes ? 33 : 50,
        child: TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          maxLength: isMinutes ? 3 : 4,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            isCollapsed: true,
            counterText: '',
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
