import 'package:flutter/cupertino.dart';
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
              SizedBox(height: 5),

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

  static void showTwoOptionsModal(
    BuildContext context, {
    required String title,
    required String description,
    required String primaryButtonText,
    required String secondaryButtonText,
    required VoidCallback onPrimaryButtonPressed,
    required VoidCallback onSecondaryButtonPressed,
    bool isDestructive = false,
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
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.greyScale600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onSecondaryButtonPressed();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.greyScale100,
                        foregroundColor: AppColors.greyScale800,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                      ),
                      child: Text(secondaryButtonText),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onPrimaryButtonPressed();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isDestructive ? AppColors.error : AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                      ),
                      child: Text(primaryButtonText),
                    ),
                  ),
                ],
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
                      icon: option.icon,
                      customIcon: option.customIcon,
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
      margin: const EdgeInsets.only(bottom: 12),
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
          customIcon: SvgPicture.asset(
            'assets/icons/name=camera, size=24, state=Default.svg',
            width: 20,
            height: 20,
            colorFilter: const ColorFilter.mode(
              Colors.black87,
              BlendMode.srcIn,
            ),
          ),
          onTap: onCamera,
        ),
        ModalOption(
          text: strings(context).chooseInGallery,
          customIcon: SvgPicture.asset(
            'assets/icons/name=album, size=24, state=Default.svg',
            width: 20,
            height: 20,
            colorFilter: const ColorFilter.mode(
              Colors.black87,
              BlendMode.srcIn,
            ),
          ),
          onTap: onGallery,
        ),
      ],
      onClose: onClose,
    );
  }
}

class ModalOption {
  final String text;
  final IconData? icon;
  final Widget? customIcon;
  final VoidCallback onTap;
  final bool isRed;

  const ModalOption({
    required this.text,
    this.icon,
    this.customIcon,
    required this.onTap,
    this.isRed = false,
  }) : assert(
         icon != null || customIcon != null,
         'Either icon or customIcon must be provided',
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
  final Widget? customIcon;
  final VoidCallback onTap;
  final bool isCenter;
  final bool isRed;

  const _ModalOptionCard({
    required this.text,
    this.icon,
    this.customIcon,
    required this.onTap,
    this.isCenter = false,
    this.isRed = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget? leadingWidget;

    if (!isCenter) {
      if (customIcon != null) {
        leadingWidget = customIcon;
      } else if (icon != null) {
        leadingWidget = Icon(
          icon,
          color: isRed ? AppColors.error : Colors.black87,
          size: 20,
        );
      }
    }

    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        border: Border.all(color: AppColors.greyScale100, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                if (leadingWidget != null) ...[
                  leadingWidget!,
                  const SizedBox(width: 12),
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
