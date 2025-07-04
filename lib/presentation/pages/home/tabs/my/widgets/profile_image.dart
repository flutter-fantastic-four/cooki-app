import 'dart:io';

import 'package:cooki/core/utils/logger.dart';
import 'package:cooki/core/utils/modal_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cooki/presentation/user_global_view_model.dart';
import 'package:image_picker/image_picker.dart';

class ProfileImage extends ConsumerWidget {
  const ProfileImage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userGlobalViewModelProvider);
    final vm = ref.read(userGlobalViewModelProvider.notifier);

    return Stack(
      alignment: AlignmentDirectional.bottomEnd,
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: ClipOval(
            child:
                user?.profileImage != null && user!.profileImage!.isNotEmpty
                    ? Image.network(
                      user.profileImage!,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 120,
                          height: 120,
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.grey),
                          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey[200]),
                          child: Icon(Icons.person, size: 60, color: Colors.grey[400]),
                        );
                      },
                    )
                    : Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey[200]),
                      child: Icon(Icons.person, size: 60, color: Colors.grey[400]),
                    ),
          ),
        ),
        GestureDetector(
          onTap: () {
            ModalUtil.showImagePickerModal(
              context,
              onCamera: () => _pickImage(vm, ImageSource.camera),
              onGallery: () => _pickImage(vm, ImageSource.gallery),
            );
          },
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade400, width: 2)),
            child: Icon(Icons.camera_alt, color: Colors.black87, size: 24),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage(UserGlobalViewModel vm, ImageSource source) async {
    final ImagePicker imagePicker = ImagePicker();
    try {
      final XFile? pickedFile = await imagePicker.pickImage(source: source, maxWidth: 768, maxHeight: 768);

      if (pickedFile != null) {
        vm.setProfileImage(File(pickedFile.path));
        vm.saveUserToDatabase();
      }
    } catch (e, stack) {
      logError(e, stack, reason: 'Error picking image');
    }
  }
}
