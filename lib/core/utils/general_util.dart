import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/constants/app_colors.dart';
import '../../domain/entity/generated_recipe.dart';
import '../../gen/l10n/app_localizations.dart';

AppLocalizations strings(BuildContext context) {
  return AppLocalizations.of(context)!;
}

class GeneralUtil {
  static Future<Uint8List?> compressImageBytes(
    Uint8List? imageBytes, {
    int quality = 85,
    CompressFormat format = CompressFormat.jpeg,
  }) async {
    return imageBytes != null
        ? await FlutterImageCompress.compressWithList(
          imageBytes,
          quality: quality,
          format: format,
        )
        : null;
  }
}

void showGeneratedRecipeDialogTemp({
  required GeneratedRecipe recipe,
  required BuildContext context,
  required WidgetRef ref,
}) {
  showDialog(
    context: context,
    builder:
        (context) => Dialog(
          child: Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        recipe.recipeName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRecipeSection('카테고리', recipe.category),

                        if (recipe.tags.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Text(
                            '태그',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children:
                                recipe.tags
                                    .map(
                                      (tag) => Chip(
                                        label: Text(
                                          tag,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    )
                                    .toList(),
                          ),
                        ],
                        const SizedBox(height: 16),

                        _buildRecipeSection('조리 시간', '${recipe.cookTime} 분'),
                        _buildRecipeSection('칼로리', '${recipe.calories} kcal'),

                        const Text(
                          '재료',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...recipe.ingredients.map(
                          (ingredient) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text('• $ingredient'),
                          ),
                        ),

                        const SizedBox(height: 16),
                        const Text(
                          '조리 방법',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...recipe.steps.asMap().entries.map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text('${entry.key + 1}. ${entry.value}'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // TODO: Navigate to recipe save/edit page
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      '레시피 저장',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
  );
}

Widget _buildRecipeSection(String title, String content) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 4),
      Text(content),
      const SizedBox(height: 12),
    ],
  );
}
