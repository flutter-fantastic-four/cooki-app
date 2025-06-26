import 'package:cooki/presentation/pages/home/tabs/community/widget/photo_modal_style_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/constants/app_colors.dart';
import '../../core/utils/general_util.dart';
import '../../core/utils/navigation_util.dart';
import '../../core/utils/sharing_util.dart';
import '../../core/utils/snackbar_util.dart';
import '../../data/repository/providers.dart';
import '../../domain/entity/recipe.dart';
import '../pages/edit/recipe_edit_page.dart';
import '../user_global_view_model.dart';
import 'app_dialog.dart';

class RecipeOptionsModal extends ConsumerWidget {
  final Recipe recipe;
  final VoidCallback? onRecipeDeleted;
  final VoidCallback? onRecipeUpdated;
  final bool isDetail;

  const RecipeOptionsModal({
    super.key,
    required this.recipe,
    this.onRecipeDeleted,
    this.onRecipeUpdated,
    this.isDetail = false,
  });

  static void show({
    required BuildContext context,
    required WidgetRef ref,
    required Recipe recipe,
    VoidCallback? onRecipeDeleted,
    VoidCallback? onRecipeUpdated,
    bool? isDetail,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.greyScale50,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (BuildContext context) {
        return RecipeOptionsModal(
          recipe: recipe,
          onRecipeDeleted: onRecipeDeleted,
          onRecipeUpdated: onRecipeUpdated,
          isDetail: isDetail == null ? false : true,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.read(userGlobalViewModelProvider);
    final isOwner = user?.id == recipe.userId;
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 30, left: 15, right: 15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildModalHandle(),

          // Post to community option (owner-only)
          if (isOwner)
            PhotoModalStyleCard(
              text:
                  recipe.isPublic
                      ? strings(context).communityUnpost
                      : strings(context).communityPost,
              icon: recipe.isPublic ? Icons.public_off : Icons.public,
              onTap: () => _toggleCommunityPost(context, ref),
            ),

          // Share option (always available)
          PhotoModalStyleCard(
            text: strings(context).share,
            icon: Icons.share_outlined,
            onTap: () => _shareRecipe(context, ref),
          ),

          // Edit and delete options (owner-only)
          if (isOwner) ...[
            isDetail
                ? SizedBox()
                : PhotoModalStyleCard(
                  text: strings(context).edit,
                  icon: Icons.edit_outlined,
                  onTap: () => _editRecipe(context),
                ),
            PhotoModalStyleCard(
              text: strings(context).delete,
              icon: Icons.delete_outline,
              iconColor: AppColors.error,
              textColor: AppColors.error,
              onTap: () => _deleteRecipe(context, ref),
            ),
          ],

          const SizedBox(height: 15),
          PhotoModalStyleCard(
            text: strings(context).close,
            onTap: () => Navigator.pop(context),
            isCenter: true,
          ),
        ],
      ),
    );
  }

  Widget _buildModalHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 8, bottom: 8),
        width: 36.0,
        height: 4.0,
        decoration: BoxDecoration(
          color: AppColors.greyScale200,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  void _toggleCommunityPost(BuildContext context, WidgetRef ref) async {
    Navigator.pop(context);
    try {
      final recipeRepository = ref.read(recipeRepositoryProvider);
      await recipeRepository.toggleRecipeShare(recipe.id, !recipe.isPublic);
      if (context.mounted) {
        SnackbarUtil.showSnackBar(
          context,
          recipe.isPublic
              ? strings(context).unpostSuccess
              : strings(context).postSuccess,
          showIcon: true,
        );
        onRecipeUpdated?.call();
      }
    } catch (e) {
      if (context.mounted) {
        SnackbarUtil.showSnackBar(context, strings(context).postError);
      }
    }
  }

  void _editRecipe(BuildContext context) {
    Navigator.pop(context);
    NavigationUtil.pushFromBottom(context, RecipeEditPage(recipe: recipe));
  }

  void _shareRecipe(BuildContext context, WidgetRef ref) async {
    await SharingUtil.shareRecipe(
      context,
      recipe,
      ref.read(imageDownloadRepositoryProvider),
    );
    if (!context.mounted) return;
    Navigator.pop(context);
  }

  void _deleteRecipe(BuildContext context, WidgetRef ref) {
    Navigator.pop(context);
    _showDeleteConfirmation(context, ref);
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    if (recipe.id.isEmpty) {
      SnackbarUtil.showSnackBar(context, strings(context).deleteError);
      return;
    }

    // Capture the repository reference before showing the dialog
    final recipeRepository = ref.read(recipeRepositoryProvider);

    AppDialog.show(
      context: context,
      title: strings(context).delete,
      subText: strings(context).deleteConfirmMessage(recipe.recipeName),
      primaryButtonText: strings(context).delete,
      secondaryButtonText: strings(context).cancel,
      isDestructive: true,
      onPrimaryButtonPressed: () => _performDelete(context, recipeRepository),
    );
  }

  void _performDelete(BuildContext context, recipeRepository) async {
    try {
      await recipeRepository.deleteRecipe(recipe.id);
      onRecipeDeleted?.call();
    } catch (e) {
      if (context.mounted) {
        SnackbarUtil.showSnackBar(context, strings(context).deleteError);
      }
    }
  }
}
