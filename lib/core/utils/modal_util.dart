import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../app/constants/app_colors.dart';
import 'general_util.dart';

class ModalUtil {
  static void showGenericModal(
    BuildContext context, {
    List<ModalOption>? options,
    VoidCallback? onClose,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.greyScale50,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.only(
            top: 8,
            bottom: 30,
            left: 15,
            right: 15,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top handle
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.only(bottom: 12),
              ),

              // Dynamic
              ...(options?.map(
                    (option) => _ModalOptionCard(
                      text: option.text,
                      icon: option.icon,
                      isRed: option.isRed,
                      onTap: () {
                        Navigator.pop(context);
                        option.onTap();
                      },
                    ),
                  ) ??
                  []),

              const SizedBox(height: 15),
              // Fixed close button
              _ModalOptionCard(
                text: strings(context).close,
                isCenter: true,
                onTap: () {
                  Navigator.pop(context);
                  if (onClose != null) onClose();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static void showImagePickerModal(
    BuildContext context, {
    required VoidCallback onCamera,
    required VoidCallback onGallery,
    VoidCallback? onClose,
  }) {
    showGenericModal(
      context,
      options: [
        ModalOption(
          text: strings(context).takeWithCamera,
          icon: Icons.photo_camera,
          onTap: onCamera,
        ),
        ModalOption(
          text: strings(context).chooseInGallery,
          icon: CupertinoIcons.photo,
          onTap: onGallery,
        ),
      ],
      onClose: onClose,
    );
  }
}

class ModalOption {
  final String text;
  final IconData icon;
  final VoidCallback onTap;
  final bool isRed;

  const ModalOption({
    required this.text,
    required this.icon,
    required this.onTap,
    this.isRed = false,
  });
}

class _ModalOptionCard extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onTap;
  final bool isCenter;
  final bool isRed;

  const _ModalOptionCard({
    required this.text,
    this.icon,
    required this.onTap,
    this.isCenter = false,
    this.isRed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0,
      color: Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 1),
        leading:
            !isCenter
                ? Padding(
                  padding: const EdgeInsets.only(left: 24, right: 4),
                  child: Icon(
                    icon,
                    color: isRed ? AppColors.error : Colors.black87,
                  ),
                )
                : null,
        title: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: isRed ? AppColors.error : Colors.black,
            fontWeight: FontWeight.w500,
          ),
          textAlign: isCenter ? TextAlign.center : null,
        ),
        onTap: onTap,
      ),
    );
  }
}
