import 'package:cooki/core/utils/general_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class GenerateButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isLoading;

  const GenerateButton({
    required this.onTap,
    this.isLoading = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 33),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton.icon(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          icon:
              isLoading
                  ? const SizedBox(
                    width: 21,
                    height: 21,
                    child: CupertinoActivityIndicator(radius: 10),
                  )
                  : const Icon(Icons.auto_awesome, size: 21),
          iconAlignment: IconAlignment.end,
          label: Text(
            isLoading
                ? strings(context).generateRecipeLoading
                : strings(context).generateRecipe,
          ),
        ),
      ),
    );
  }
}
