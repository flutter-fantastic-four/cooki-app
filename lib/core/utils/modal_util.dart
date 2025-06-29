import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/constants/app_colors.dart';
import 'general_util.dart';

class ModalUtil {
  static Future<String?> showStringSelectionModal(
    BuildContext context, {
    required List<String> options,
    VoidCallback? onClose,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.greyScale50,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) {
        final height = MediaQuery.of(context).size.height * 0.5;

        return Container(
          height: height,
          padding: const EdgeInsets.only(
            top: 12,
            bottom: 30,
            left: 20,
            right: 20,
          ),
          child: Column(
            children: [
              _buildModalTopHandle(),

              // Scrollable list of options
              Expanded(
                child: ListView.builder(
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options[index];
                    return SimpleOptionCard(
                      text: option,
                      onTap: () => Navigator.pop(context, option),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

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
              _buildModalTopHandle(),
              ...(options?.map(
                    (option) => _ModalOptionCard(
                      text: option.text,
                      icon: option.iconData,
                      svgIconPath: option.svgIconPath,
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

  static Widget _buildModalTopHandle() {
    return Container(
      width: 44,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[400],
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.only(bottom: 17),
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
          svgIconPath: 'assets/icons/name=camera, size=24, state=Default.svg',
          onTap: onCamera,
        ),
        ModalOption(
          text: strings(context).chooseInGallery,
          svgIconPath: 'assets/icons/name=album, size=24, state=Default.svg',
          onTap: onGallery,
        ),
      ],
      onClose: onClose,
    );
  }
}

class ModalOption {
  final String text;
  final IconData? iconData;
  final String? svgIconPath;
  final VoidCallback onTap;
  final bool isRed;

  const ModalOption({
    required this.text,
    this.iconData,
    this.svgIconPath,
    required this.onTap,
    this.isRed = false,
  }) : assert(
         iconData != null || svgIconPath != null,
         'Either iconData or svgIconPath must be provided',
       );
}

class SimpleOptionCard extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const SimpleOptionCard({required this.text, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: AppColors.greyScale100, width: 1),
      ),
      elevation: 0,
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.greyScale800,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _ModalOptionCard extends StatelessWidget {
  final String text;
  final IconData? icon;
  final String? svgIconPath;
  final VoidCallback onTap;
  final bool isCenter;
  final bool isRed;

  const _ModalOptionCard({
    required this.text,
    this.icon,
    this.svgIconPath,
    required this.onTap,
    this.isCenter = false,
    this.isRed = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget? leadingWidget;

    if (!isCenter) {
      if (svgIconPath != null) {
        leadingWidget = SvgPicture.asset(
          svgIconPath!,
          width: 20,
          height: 20,
          colorFilter:
              isRed ? ColorFilter.mode(AppColors.error, BlendMode.srcIn) : null,
        );
      } else if (icon != null) {
        leadingWidget = Icon(
          icon,
          color: isRed ? AppColors.error : Colors.black87,
          size: 20,
        );
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.greyScale100, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
            child: Row(
              children: [
                if (leadingWidget != null) ...[
                  leadingWidget,
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      color: isRed ? AppColors.error : Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: isCenter ? TextAlign.center : TextAlign.left,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
