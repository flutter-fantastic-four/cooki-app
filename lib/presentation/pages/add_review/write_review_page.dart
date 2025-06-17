import 'dart:developer';
import 'dart:io';
import 'package:cooki/core/utils/snackbar_util.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/utils/dialogue_util.dart';
import '../../../core/utils/error_mappers.dart';
import '../../../core/utils/general_util.dart';
import '../../user_global_view_model.dart';
import '../../widgets/input_decorations.dart';
import '../../widgets/star_rating.dart';
import 'write_review_view_model.dart';

class WriteReviewPage extends ConsumerWidget {
  final String recipeId;
  final String recipeName;

  const WriteReviewPage({
    super.key,
    required this.recipeId,
    required this.recipeName,
  });

  Future<void> _submitReview(WidgetRef ref, BuildContext context) async {
    final start = DateTime.now();
    await ref
        .read(writeReviewViewModelProvider.notifier)
        .saveReview(
          recipeId: recipeId,
          user: ref.read(userGlobalViewModelProvider)!,
        );
    log(
      'saveReview executed in ${DateTime.now().difference(start).inMilliseconds} ms',
    );

    final state = ref.read(writeReviewViewModelProvider);

    if (context.mounted && state.errorKey != null) {
      DialogueUtil.showAppCupertinoDialog(
        context: context,
        title: strings(context).reviewUploadFailedTitle,
        content: ErrorMapper.mapAddReviewError(context, state.errorKey!),
      );
      ref.read(writeReviewViewModelProvider.notifier).clearError();
      return;
    }

    if (context.mounted) {
      SnackbarUtil.showSnackBar(
        context,
        strings(context).reviewSavedSuccessfully,
        showIcon: true,
      );
      Navigator.of(context).pop(true); // Return true to indicate success
    }
  }

  void _showImagePickerModal(BuildContext context, WidgetRef ref) {
    final currentImageCount = ref.read(
      writeReviewViewModelProvider.select(
        (state) => state.selectedImages.length,
      ),
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
      onCamera: () => _pickImages(context, ref, ImageSource.camera),
      onGallery: () => _pickImages(context, ref, ImageSource.gallery),
    );
  }

  Future<void> _pickImages(
    BuildContext context,
    WidgetRef ref,
    ImageSource source,
  ) async {
    final vm = ref.read(writeReviewViewModelProvider.notifier);
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

      final state = ref.read(writeReviewViewModelProvider);
      if (context.mounted &&
          state.errorKey == AddReviewErrorKey.tooManyImages) {
        SnackbarUtil.showSnackBar(
          context,
          strings(context).tooManyImagesError,
          showIcon: true,
          customIcon: SnackbarUtil.appLogoIcon(),
        );
        ref.read(writeReviewViewModelProvider.notifier).clearError();
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        appBar: AppBar(
          elevation: 1,
          title: Text(strings(context).writeReviewTitle),
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
                    writeReviewViewModelProvider.select((state) => state.rating),
                  ),
                  iconSize: 32,
                  onPressed:
                      (selectedRating) => ref
                      .read(writeReviewViewModelProvider.notifier)
                      .setRating(selectedRating),
                ),
                const SizedBox(height: 32),
                _buildPhotoUploadSection(ref, context),
                const SizedBox(height: 24),
                _buildPhotoThumbnails(ref),
                const SizedBox(height: 18),
                _buildTextInputSection(context, ref),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildSubmitButton(context, ref),
      ),
    );
  }

  Widget _buildRecipeNameSection() {
    return Text(
      recipeName,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildPhotoUploadSection(WidgetRef ref, BuildContext context) {
    return GestureDetector(
      onTap: () => _showImagePickerModal(context, ref),
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

  Widget _buildPhotoThumbnails(WidgetRef ref) {
    final images = ref.watch(
      writeReviewViewModelProvider.select((state) => state.selectedImages),
    );

    if (images.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                final imageProvider = FileImage(images[index]);
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
                    child: Image.file(
                      images[index],
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 3,
                    right: 3,
                    child: GestureDetector(
                      onTap:
                          () => ref
                              .read(writeReviewViewModelProvider.notifier)
                              .removeImage(index),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade600,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.4),
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 15,
                          color: Colors.white,
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

  Widget _buildTextInputSection(BuildContext context, WidgetRef ref) {
    return TextField(
      maxLines: 7,
      maxLength: 500,
      onChanged:
          (text) => ref
              .read(writeReviewViewModelProvider.notifier)
              .updateReviewText(text),
      decoration: getInputDecoration(strings(context).reviewTextHint).copyWith(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context, WidgetRef ref) {
    final canSubmit = ref.watch(
      writeReviewViewModelProvider.select((state) => state.canSubmit),
    );
    final isSaving = ref.watch(
      writeReviewViewModelProvider.select((state) => state.isSaving),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 33),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: canSubmit ? () => _submitReview(ref, context) : null,
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
                  : Text(strings(context).saveReviewButtonText),
        ),
      ),
    );
  }
}
