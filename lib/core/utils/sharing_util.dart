import 'dart:io';

import 'package:cooki/core/utils/logger.dart';
import 'package:cooki/core/utils/category_mapper.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/repository/image_download_repository.dart';
import '../../domain/entity/recipe.dart';
import 'general_util.dart';

class SharingUtil {
  static Future<void> shareRecipe(
    BuildContext context,
    Recipe recipe,
    ImageDownloadRepository imageDownloadRepository,
  ) async {
    XFile? imageFile;

    final shareText = _formatRecipeShareText(context, recipe);

    if (recipe.imageUrl?.isNotEmpty == true) {
      try {
        final bytes = await imageDownloadRepository.downloadImage(
          recipe.imageUrl!,
        );
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/shared_recipe_image.jpg');
        await file.writeAsBytes(bytes);
        imageFile = XFile(file.path);
      } catch (e, stack) {
        logError(e, stack, reason: 'Image download failed');
      }
    }

    if (!context.mounted) return;
    await SharePlus.instance.share(
      ShareParams(
        text: shareText,
        subject:
            '${recipe.recipeName} ${strings(context).shareRecipeSubjectSuffix}',
        files: imageFile != null ? [imageFile] : null,
        previewThumbnail: imageFile,
      ),
    );
  }

  static String _formatRecipeShareText(BuildContext context, Recipe recipe) {
    final s = strings(context);

    final buffer = StringBuffer();
    if (recipe.imageUrl?.isNotEmpty == true) {
      buffer.writeln();
      buffer.writeln();
    }
    buffer.writeln('${recipe.recipeName} ${s.recipe}');
    buffer.writeln();
    buffer.writeln(
      '📂 ${s.categoryLabel}: ${CategoryMapper.translateCategoryToAppLanguage(context, recipe.category)}',
    );
    buffer.writeln('⏱️ ${s.cookTimeLabel}: ${recipe.cookTime}${s.minutes}');
    buffer.writeln('🔥 ${s.caloriesLabel}: ${recipe.calories}kcal');
    if (recipe.tags.isNotEmpty) {
      buffer.writeln('🏷️ ${s.tagsLabel}: ${recipe.tags.join(', ')}');
    }

    buffer.writeln();
    buffer.writeln('▶ ${s.ingredientsLabel}');
    for (final ingredient in recipe.ingredients) {
      buffer.writeln('• $ingredient');
    }

    buffer.writeln();
    buffer.writeln('▶ ${s.stepsLabel}');
    for (int i = 0; i < recipe.steps.length; i++) {
      buffer.writeln('${i + 1}. ${recipe.steps[i]}');
    }

    return buffer.toString();
  }
}
