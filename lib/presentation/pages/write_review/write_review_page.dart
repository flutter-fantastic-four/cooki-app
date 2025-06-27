import 'dart:developer';
import 'package:cooki/core/utils/snackbar_util.dart';
import 'package:cooki/presentation/pages/write_review/widgets/photo_upload_box.dart';
import 'package:cooki/presentation/pages/write_review/widgets/photos_thumbnails_row.dart';
import 'package:cooki/presentation/widgets/bottom_button_wrapper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import '../../../app/constants/app_colors.dart';
import '../../../core/utils/dialogue_util.dart';
import '../../../core/utils/error_mappers.dart';
import '../../../core/utils/general_util.dart';
import '../../../domain/entity/review.dart';
import '../../user_global_view_model.dart';
import '../../widgets/input_decorations.dart';
import '../../widgets/star_rating.dart';
import 'write_review_view_model.dart';

class WriteReviewPage extends ConsumerStatefulWidget {
  final String recipeId;
  final String recipeName;
  final Review? review;

  const WriteReviewPage({
    super.key,
    required this.recipeId,
    required this.recipeName,
    this.review,
  });

  @override
  ConsumerState<WriteReviewPage> createState() => _WriteReviewPageState();
}

class _WriteReviewPageState extends ConsumerState<WriteReviewPage> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize controller with existing review text if editing
    if (widget.review?.reviewText != null) {
      _controller.text = widget.review!.reviewText!;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submitReview(BuildContext context) async {
    final isEditingMode = widget.review != null;

    // Show confirmation dialog for editing
    if (isEditingMode) {
      final result = await DialogueUtil.showAppDialog(
        context: context,
        showCancel: true,
        title: strings(context).editReviewDialogTitle,
        content: strings(context).editReviewConfirmMessage,
      );
      if (result != true) return;
    }

    final start = DateTime.now();
    await ref
        .read(writeReviewViewModelProvider(widget.review).notifier)
        .saveReview(
          recipeId: widget.recipeId,
          reviewText: _controller.text,
          user: ref.read(userGlobalViewModelProvider)!,
        );
    log(
      'saveReview executed in ${DateTime.now().difference(start).inMilliseconds} ms',
    );

    final state = ref.read(writeReviewViewModelProvider(widget.review));

    if (context.mounted && state.errorKey != null) {
      DialogueUtil.showAppDialog(
        context: context,
        title:
            isEditingMode
                ? strings(context).reviewEditFailedTitle
                : strings(context).reviewUploadFailedTitle,
        content: ErrorMapper.mapWriteReviewError(context, state.errorKey!),
      );
      ref
          .read(writeReviewViewModelProvider(widget.review).notifier)
          .clearError();
      return;
    }

    if (context.mounted) {
      SnackbarUtil.showSnackBar(
        context,
        isEditingMode
            ? strings(context).reviewEditedSuccessfully
            : strings(context).reviewSavedSuccessfully,
        showIcon: true,
      );
      Navigator.of(context).pop(true); // Return true to indicate success
    }
  }

  Future<void> _deleteReview(BuildContext context) async {
    if (widget.review == null) return;

    final result = await DialogueUtil.showAppDialog(
      context: context,
      title: strings(context).deleteReviewConfirmTitle,
      content: strings(context).deleteReviewConfirmMessage,
      showCancel: true,
    );
    if (result != true) return;

    await ref
        .read(writeReviewViewModelProvider(widget.review).notifier)
        .deleteReview(recipeId: widget.recipeId, reviewId: widget.review!.id);

    final state = ref.read(writeReviewViewModelProvider(widget.review));
    if (context.mounted && state.errorKey != null) {
      DialogueUtil.showAppDialog(
        context: context,
        title: strings(context).genericErrorTitle,
        content: ErrorMapper.mapWriteReviewError(context, state.errorKey!),
      );
      ref
          .read(writeReviewViewModelProvider(widget.review).notifier)
          .clearError();
      return;
    }

    if (context.mounted) {
      SnackbarUtil.showSnackBar(
        context,
        strings(context).reviewDeletedSuccessfully,
        showIcon: true,
      );
      Navigator.of(context).pop(true); // Return true to indicate success
    }
  }

  bool _hasUnsavedChanges() {
    final state = ref.read(writeReviewViewModelProvider(widget.review));
    // If editing, check if anything changed from original
    if (widget.review != null) {
      final originalReview = widget.review!;
      final textChanged =
          _controller.text.trim() != originalReview.reviewText?.trim();
      final ratingChanged = state.rating != originalReview.rating;
      final imagesChanged =
          state.selectedImages.length != originalReview.imageUrls.length ||
          state.selectedImages.any((img) => img.isFile); // Any new file images
      return textChanged || ratingChanged || imagesChanged;
    }
    // Check if text has changed
    final hasTextChanges = _controller.text.trim().isNotEmpty;
    // Check if rating has been set
    final hasRatingChanges = state.rating > 0;
    // Check if images have been added or modified
    final hasImageChanges = state.selectedImages.isNotEmpty;
    // For new reviews, check if any content has been added
    return hasTextChanges || hasRatingChanges || hasImageChanges;
  }

  @override
  Widget build(BuildContext context) {
    final isEditingMode = widget.review != null;

    return GeneralUtil.buildUnsavedChangesPopScope(
      context: context,
      hasUnsavedChanges: () => _hasUnsavedChanges(),
      child: GestureDetector(
        onTap: FocusScope.of(context).unfocus,
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            title: Text(
              isEditingMode
                  ? strings(context).editReviewTitle
                  : strings(context).writeReviewTitle,
              style: const TextStyle(color: Colors.black),
            ),
            iconTheme: const IconThemeData(color: Colors.black),
            actions: isEditingMode ? [_buildDeleteActionButton(context)] : null,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                const SizedBox(height: 24),
                _buildRecipeNameSection(),
                const SizedBox(height: 13),
                StarRating(
                  currentRating: ref.watch(
                    writeReviewViewModelProvider(
                      widget.review,
                    ).select((state) => state.rating),
                  ),
                  iconSize: 32,
                  setRating:
                      (selectedRating) => ref
                          .read(
                            writeReviewViewModelProvider(
                              widget.review,
                            ).notifier,
                          )
                          .setRating(selectedRating),
                ),
                const SizedBox(height: 32),
                PhotoUploadBox(widget.review),
                const SizedBox(height: 24),
                PhotosThumbnailsRow(widget.review),
                const SizedBox(height: 18),
                _buildTextInputSection(context),
                const SizedBox(height: 32),
              ],
            ),
          ),
          bottomNavigationBar: _buildSubmitButton(context),
        ),
      ),
    );
  }

  Widget _buildDeleteActionButton(BuildContext context) {
    final isDeleting = ref.watch(
      writeReviewViewModelProvider(
        widget.review,
      ).select((state) => state.isDeleting),
    );
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child:
          isDeleting
              ? CupertinoActivityIndicator(radius: 10)
              : Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _deleteReview(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: SvgPicture.asset(
                      'assets/icons/name=delete, size=24, state=Default.svg',
                      width: 25,
                      height: 25,
                      colorFilter: const ColorFilter.mode(
                        AppColors.greyScale800,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
    );
  }

  Widget _buildRecipeNameSection() {
    return Text(
      widget.recipeName,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildTextInputSection(BuildContext context) {
    return TextField(
      maxLines: 7,
      maxLength: 500,
      controller: _controller,
      style: TextStyle(fontSize: 16),
      decoration: getInputDecoration(
        strings(context).reviewTextHint,
        contentPadding: EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    final canSubmit = ref.watch(
      writeReviewViewModelProvider(
        widget.review,
      ).select((state) => state.canSubmit),
    );
    final isSaving = ref.watch(
      writeReviewViewModelProvider(
        widget.review,
      ).select((state) => state.isSaving),
    );
    final isEditingMode = widget.review != null;

    return BottomButtonWrapper(
      child: ElevatedButton(
        onPressed: canSubmit ? () => _submitReview(context) : null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child:
            isSaving
                ? const SizedBox(
                  width: 21,
                  height: 21,
                  child: CupertinoActivityIndicator(radius: 10),
                )
                : Text(
                  isEditingMode
                      ? strings(context).editReviewButtonText
                      : strings(context).saveReviewButtonText,
                ),
      ),
    );
  }
}
