import 'dart:developer';
import 'dart:io';

import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/constants/app_colors.dart';
import '../../../../core/utils/dialogue_util.dart';
import '../../../../core/utils/logger.dart';
import '../generate_recipe_view_model.dart';

class ImageSelector extends ConsumerWidget {
  final ImagePicker _imagePicker = ImagePicker();

  ImageSelector({super.key});

  void _showImageSourceActionSheet(
    BuildContext context,
    GenerateRecipeViewModel vm,
  ) {
    DialogueUtil.showImagePickerModal(
      context,
      onCamera: () => _pickImage(vm, ImageSource.camera),
      onGallery: () => _pickImage(vm, ImageSource.gallery),
    );
  }

  Future<void> _pickImage(
    GenerateRecipeViewModel vm,
    ImageSource source,
  ) async {
    try {
      vm.setImageLoading(true);
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 768,
        maxHeight: 768,
      );

      if (pickedFile != null) {
        final imageBytes = await File(pickedFile.path).readAsBytes();
        vm.setImageBytes(imageBytes);
      }
    } catch (e, stack) {
      log('Error picking image');
      logError(e, stack);
    } finally {
      vm.setImageLoading(false);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.read(generateRecipeViewModelProvider.notifier);
    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(generateRecipeViewModelProvider);

        return GestureDetector(
          onTap:
              state.hasImage
                  ? () {
                    final imageProvider = MemoryImage(
                      state.selectedImageBytes!,
                    );
                    showImageViewer(
                      context,
                      imageProvider,
                      swipeDismissible: true,
                      doubleTapZoomable: true,
                      useSafeArea: true,
                    );
                  }
                  : () => _showImageSourceActionSheet(context, vm),
          child: Container(
            height: 160,
            decoration: BoxDecoration(
              color: AppColors.greyScale50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child:
                state.isLoadingImage
                    ? const Center(
                      child: CupertinoActivityIndicator(radius: 20),
                    )
                    : state.hasImage
                    ? Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            state.selectedImageBytes!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: vm.removeImage,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                    : const Center(
                      child: Icon(
                        CupertinoIcons.photo_on_rectangle,
                        size: 48,
                        color: Colors.grey,
                      ),
                    ),
          ),
        );
      },
    );
  }
}
