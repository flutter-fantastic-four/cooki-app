import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/entity/review.dart';
import '../../../widgets/app_cached_image.dart';
import '../write_review_view_model.dart';

class PhotosThumbnailsRow extends ConsumerWidget {
  final Review? review;

  const PhotosThumbnailsRow(this.review, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final images = ref.watch(
      writeReviewViewModelProvider(
        review,
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
                                writeReviewViewModelProvider(review).notifier,
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
}
