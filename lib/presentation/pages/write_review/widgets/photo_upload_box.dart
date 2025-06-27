import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/utils/error_mappers.dart';
import '../../../../core/utils/general_util.dart';
import '../../../../core/utils/modal_util.dart';
import '../../../../core/utils/snackbar_util.dart';
import '../../../../domain/entity/review.dart';
import '../write_review_view_model.dart';

class PhotoUploadBox extends ConsumerWidget {
  final Review? review;

  const PhotoUploadBox(this.review, {super.key});

  void _showImagePickerModal(BuildContext context, WidgetRef ref) {
    final currentImageCount = ref.read(
      writeReviewViewModelProvider(
        review,
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

    ModalUtil.showImagePickerModal(
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
    final vm = ref.read(writeReviewViewModelProvider(review).notifier);
    final picker = ImagePicker();

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

      final state = ref.read(writeReviewViewModelProvider(review));
      if (context.mounted &&
          state.errorKey == WriteReviewErrorKey.tooManyImages) {
        SnackbarUtil.showSnackBar(
          context,
          strings(context).tooManyImagesError,
          showIcon: true,
          customIcon: SnackbarUtil.appLogoIcon(),
        );
        ref.read(writeReviewViewModelProvider(review).notifier).clearError();
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
}
