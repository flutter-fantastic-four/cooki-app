import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cooki/core/utils/snackbar_util.dart';
import 'package:cooki/presentation/widgets/app_cached_image.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
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
      final result = await DialogueUtil.showAppCupertinoDialog(
        context: context,
        showCancel: true,
        title: strings(context).editReviewTitle,
        content: strings(context).editReviewConfirmMessage,
      );
      if (result != AppDialogResult.confirm) return;
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
      DialogueUtil.showAppCupertinoDialog(
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

    final result = await DialogueUtil.showAppCupertinoDialog(
      context: context,
      title: strings(context).deleteReviewConfirmTitle,
      content: strings(context).deleteReviewConfirmMessage,
      showCancel: true,
    );
    if (result != AppDialogResult.confirm) return;

    await ref
        .read(writeReviewViewModelProvider(widget.review).notifier)
        .deleteReview(recipeId: widget.recipeId, reviewId: widget.review!.id);

    final state = ref.read(writeReviewViewModelProvider(widget.review));
    if (context.mounted && state.errorKey != null) {
      DialogueUtil.showAppCupertinoDialog(
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

  void _showImagePickerModal(BuildContext context) {
    final currentImageCount = ref.read(
      writeReviewViewModelProvider(
        widget.review,
      ).select((state) => state.selectedImages.length),
    );

    if (currentImageCount >= 5) {
      SnackbarUtil.showSnackBar(
        context,
        strings(context).tooManyImagesError,
        showIcon: true,
        customIcon: SnackbarUtil.appLogoIcon(),
      );
      return;
    }

    DialogueUtil.showImagePickerModal(
      context,
      onCamera: () => _pickImages(context, ImageSource.camera),
      onGallery: () => _pickImages(context, ImageSource.gallery),
    );
  }

  Future<void> _pickImages(BuildContext context, ImageSource source) async {
    final vm = ref.read(writeReviewViewModelProvider(widget.review).notifier);
    final ImagePicker picker = ImagePicker();

    if (source == ImageSource.camera) {
      final XFile? image = await picker.pickImage(
        source: source,
        maxHeight: 1080,
        maxWidth: 1080,
      );
      if (image != null) {
        vm.addImages([File(image.path)]);
      }
    } else {
      final List<XFile> images = await picker.pickMultiImage(
        maxHeight: 1080,
        maxWidth: 1080,
      );
      if (images.isNotEmpty) {
        final imageFiles = images.map((xFile) => File(xFile.path)).toList();
        vm.addImages(imageFiles);
      }

      final state = ref.read(writeReviewViewModelProvider(widget.review));
      if (context.mounted &&
          state.errorKey == WriteReviewErrorKey.tooManyImages) {
        SnackbarUtil.showSnackBar(
          context,
          strings(context).tooManyImagesError,
          showIcon: true,
          customIcon: SnackbarUtil.appLogoIcon(),
        );
        ref
            .read(writeReviewViewModelProvider(widget.review).notifier)
            .clearError();
        return;
      }
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
            elevation: 1,
            title: Text(
              isEditingMode
                  ? strings(context).editReviewTitle
                  : strings(context).writeReviewTitle,
            ),
            actions: isEditingMode ? [_buildDeleteActionButton(context)] : null,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
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
                  _buildPhotoUploadSection(context),
                  const SizedBox(height: 24),
                  _buildPhotoThumbnails(),
                  const SizedBox(height: 18),
                  _buildTextInputSection(context),
                  const SizedBox(height: 32),
                ],
              ),
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
              : InkWell(
                onTap: () => _deleteReview(context),
                highlightColor: Colors.grey,
                child: SvgPicture.asset(
                  'assets/icons/delete_icon_outline.svg',
                  width: 25,
                  height: 25,
                  colorFilter: const ColorFilter.mode(
                    AppColors.greyScale800,
                    BlendMode.srcIn,
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

  Widget _buildPhotoUploadSection(BuildContext context) {
    return GestureDetector(
      onTap: () => _showImagePickerModal(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt, color: Colors.black, size: 20),
            const SizedBox(width: 10),
            Text(
              strings(context).addPicture,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoThumbnails() {
    final images = ref.watch(
      writeReviewViewModelProvider(
        widget.review,
      ).select((state) => state.selectedImages),
    );

    if (images.isEmpty) return const SizedBox.shrink();

    final double imageDimension = 80;
    return SizedBox(
      height: imageDimension,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          final reviewImage = images[index];

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                ImageProvider imageProvider;
                if (reviewImage.isFile) {
                  imageProvider = FileImage(reviewImage.file!);
                } else {
                  imageProvider = CachedNetworkImageProvider(reviewImage.url!);
                }

                showImageViewer(
                  context,
                  imageProvider,
                  swipeDismissible: true,
                  doubleTapZoomable: true,
                  useSafeArea: true,
                );
              },
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child:
                        reviewImage.isFile
                            ? Image.file(
                              reviewImage.file!,
                              height: imageDimension,
                              width: imageDimension,
                              fit: BoxFit.cover,
                            )
                            : AppCachedImage(
                              imageUrl: reviewImage.url!,
                              height: imageDimension,
                              width: imageDimension,
                              fit: BoxFit.cover,
                            ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap:
                          () => ref
                              .read(
                                writeReviewViewModelProvider(
                                  widget.review,
                                ).notifier,
                              )
                              .removeImage(index),
                      child: Container(
                        padding: const EdgeInsets.all(0.5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.cancel,
                          size: 18,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextInputSection(BuildContext context) {
    return TextField(
      maxLines: 7,
      maxLength: 500,
      controller: _controller,
      decoration: getInputDecoration(strings(context).reviewTextHint).copyWith(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 33),
      child: SizedBox(
        width: double.infinity,
        height: 48,
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
      ),
    );
  }
}
