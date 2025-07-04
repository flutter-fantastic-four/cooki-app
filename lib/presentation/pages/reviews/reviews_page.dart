import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cooki/core/utils/date_time_util.dart';
import 'package:cooki/core/utils/dialogue_util.dart';
import 'package:cooki/core/utils/error_mappers.dart';
import 'package:cooki/presentation/pages/report_review/review_report_page.dart';
import 'package:cooki/presentation/pages/reviews/widgets/expandable_text.dart';
import 'package:cooki/presentation/widgets/app_cached_image.dart';
import 'package:cooki/presentation/widgets/feedback_layout.dart';
import 'package:cooki/presentation/widgets/star_rating.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/constants/app_colors.dart';
import '../../../core/utils/general_util.dart';
import '../../../core/utils/modal_util.dart';
import '../../../core/utils/snackbar_util.dart';
import '../../../domain/entity/review/review.dart';
import '../../../domain/entity/review/review_sort_type.dart';
import '../../settings_global_view_model.dart';
import '../../user_global_view_model.dart';
import '../detailed_recipe/recipe_detail_view_model.dart';
import '../write_review/write_review_page.dart';
import 'reviews_view_model.dart';

const double horizontalPadding = 20;

class ReviewsPage extends ConsumerWidget {
  final String recipeId;
  final String recipeName;

  const ReviewsPage({
    super.key,
    required this.recipeId,
    required this.recipeName,
  });

  void _showReviewOptionsModal(
    BuildContext context,
    WidgetRef ref,
    Review review,
  ) {
    final currentUser = ref.read(userGlobalViewModelProvider);
    final isMyReview = currentUser?.id == review.userId;
    final currentAppLanguage =
        ref.read(settingsGlobalViewModelProvider).selectedLanguage.code;
    final vm = ref.read(reviewsViewModelProvider(recipeId).notifier);
    final shouldShowTranslate = vm.shouldShowTranslate(
      review,
      currentAppLanguage,
    );
    final hasTranslation = vm.hasTranslation(review.id);
    log(review.language ?? 'lang null');

    final options = <ModalOption>[
      if (shouldShowTranslate && !hasTranslation)
        ModalOption(
          text: strings(context).translateReview,
          iconData: Icons.g_translate,
          onTap:
              () => _translateReview(context, ref, review, currentAppLanguage),
        ),
      if (hasTranslation)
        ModalOption(
          text: strings(context).undoTranslation,
          svgIconPath:
              'assets/icons/name=translate, size=24, state=Default.svg',
          onTap: () => vm.clearTranslation(review.id),
        ),
      if (isMyReview)
        ModalOption(
          text: strings(context).editReview,
          svgIconPath: 'assets/icons/name=edit, size=24, state=Default.svg',
          onTap:
              () => _navigateToWriteOrEditReview(context, ref, review: review),
        ),
      if (!isMyReview)
        ModalOption(
          text: strings(context).reportReview,
          svgIconPath: 'assets/icons/name=warning, size=24, state=Default.svg',
          isRed: true,
          onTap: () => _reportReview(context, review),
        ),
      if (isMyReview)
        ModalOption(
          text: strings(context).deleteReview,
          isRed: true,
          svgIconPath: 'assets/icons/name=delete, size=24, state=Default.svg',
          onTap: () => _deleteReview(context, ref, review),
        ),
    ];

    ModalUtil.showGenericModal(context, options: options);
  }

  Future<void> _translateReview(
    BuildContext context,
    WidgetRef ref,
    Review review,
    String currentAppLanguage,
  ) async {
    HapticFeedback.lightImpact();
    await ref
        .read(reviewsViewModelProvider(recipeId).notifier)
        .translateReview(review.id, currentAppLanguage);
    final state = ref.read(reviewsViewModelProvider(recipeId));
    if (context.mounted && state.errorKey != null) {
      _showErrorDialog(context, state.errorKey!, ref);
      return;
    }
  }

  void _reportReview(BuildContext context, Review review) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReviewReportPage(recipeId: recipeId, review: review),
      ),
    );
  }

  Future<void> _deleteReview(
    BuildContext context,
    WidgetRef ref,
    Review review,
  ) async {
    final result = await DialogueUtil.showAppDialog(
      context: context,
      title: strings(context).deleteReviewTitle,
      content: strings(context).deleteReviewConfirmation,
      showCancel: true,
    );
    if (result == true) {
      ref
          .read(reviewsViewModelProvider(recipeId).notifier)
          .deleteReview(review.id);

      final state = ref.read(reviewsViewModelProvider(recipeId));
      if (context.mounted && state.errorKey != null) {
        _showErrorDialog(context, state.errorKey!, ref);
        return;
      }

      if (context.mounted) {
        SnackbarUtil.showSnackBar(
          context,
          strings(context).reviewDeletedSuccessfully,
          showIcon: true,
        );

      }
    }
  }

  void _navigateToWriteOrEditReview(
    BuildContext context,
    WidgetRef ref, {
    Review? review,
  }) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder:
            (_) => WriteReviewPage(
              recipeId: recipeId,
              recipeName: recipeName,
              review: review,
            ),
      ),
    );

    if (result == true) {
      ref.read(reviewsViewModelProvider(recipeId).notifier).refreshReviews();
    }
  }

  void _showImageViewer(
    BuildContext context,
    List<String> imageUrls,
    int initialIndex,
  ) {
    final imageProviders =
        imageUrls.map((url) => CachedNetworkImageProvider(url)).toList();

    showImageViewerPager(
      context,
      MultiImageProvider(imageProviders, initialIndex: initialIndex),
      swipeDismissible: true,
      doubleTapZoomable: true,
      useSafeArea: true,
    );
  }

  void _showErrorDialog(
    BuildContext context,
    ReviewsErrorKey errorKey,
    WidgetRef ref,
  ) {
    DialogueUtil.showAppDialog(
      context: context,
      title: strings(context).genericErrorTitle,
      content: ErrorMapper.mapReviewsPageError(context, errorKey),
    );
    ref.read(reviewsViewModelProvider(recipeId).notifier).clearError();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reviewsViewModelProvider(recipeId));

    final userViewModel = ref.watch(userGlobalViewModelProvider);
    ref.listen<ReviewsState>(reviewsViewModelProvider(recipeId), (
      previous,
      next,
    ) {
      if (next.errorKey != null) {
        _showErrorDialog(context, next.errorKey!, ref);
        return;
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(strings(context).recipeReviews),
        actions: [
          userViewModel != null
              ? Padding(
                padding: const EdgeInsets.only(right: 4),
                child: IconButton(
                  tooltip: strings(context).writeReviewTitle,
                  onPressed: () async {
                    final existingReview = await ref
                        .read(reviewsViewModelProvider(recipeId).notifier)
                        .getUserReviewForRecipe(
                          ref.read(userGlobalViewModelProvider)!.id,
                        );
                    if (context.mounted) {
                      _navigateToWriteOrEditReview(
                        context,
                        ref,
                        review: existingReview,
                      );
                    }
                  },
                  icon: Image.asset(
                    'assets/icons/pencil_icon.png',
                    height: 22,
                    width: 22,
                  ),
                ),
              )
              : SizedBox(),
        ],
      ),
      body:
          state.isLoading && state.reviews.isEmpty
              ? const Center(child: CupertinoActivityIndicator(radius: 20))
              : Stack(
                children: [
                  RefreshIndicator(
                    onRefresh:
                        () =>
                            ref
                                .read(
                                  reviewsViewModelProvider(recipeId).notifier,
                                )
                                .refreshReviews(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (state.reviews.isEmpty && !state.isLoading)
                          Expanded(child: _buildEmptyLayout(context))
                        else if (state.reviews.isNotEmpty) ...[
                          _buildSortingChips(context, ref, state),
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(
                                horizontalPadding,
                                10,
                                0,
                                40,
                              ),
                              itemCount: state.reviews.length,
                              itemBuilder: (context, index) {
                                final review = state.reviews[index];
                                return _buildReviewItem(context, ref, review);
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (state.isLoading)
                    const Positioned.fill(
                      child: IgnorePointer(
                        child: Center(
                          child: CupertinoActivityIndicator(radius: 14),
                        ),
                      ),
                    ),
                ],
              ),
    );
  }

  Widget _buildEmptyLayout(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final usableHeight =
        MediaQuery.of(context).size.height - kToolbarHeight - statusBarHeight;
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: usableHeight,
        child: FeedbackLayout(
          title: strings(context).noReviewsTitle,
          illustration: Icon(
            Icons.rate_review_outlined,
            size: 90,
            color: AppColors.primary800,
          ),
          subTitle: strings(context).noReviewsSubtitle,
        ),
      ),
    );
  }

  Widget _buildSortingChips(
    BuildContext context,
    WidgetRef ref,
    ReviewsState state,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 12,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children:
              ReviewSortType.values.map((sortType) {
                final isActive = state.currentSortType == sortType;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap:
                        () => ref
                            .read(reviewsViewModelProvider(recipeId).notifier)
                            .changeSortType(sortType),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.primary : Colors.white,
                        border: Border.all(
                          color:
                              isActive ? AppColors.primary : Colors.grey[400]!,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        sortType.getLabel(strings(context)),
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              isActive ? Colors.white : AppColors.greyScale800,
                          fontWeight:
                              isActive ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildReviewItem(BuildContext context, WidgetRef ref, Review review) {
    final vm = ref.read(reviewsViewModelProvider(recipeId).notifier);
    final translatedText = ref.watch(
      reviewsViewModelProvider(
        recipeId,
      ).select((state) => state.translatedTexts[review.id]),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReviewHeader(context, ref, review),
          const SizedBox(height: 10),
          StarRating(
            currentRating: review.rating,
            iconSize: 16,
            horizontalPadding: 0,
            setRating: null,
            alignment: MainAxisAlignment.start,
          ),
          if (review.imageUrls.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildReviewImages(context, review),
          ],
          if (review.reviewText?.isNotEmpty == true) ...[
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.only(right: horizontalPadding),
              child: ExpandableText(
                text: translatedText ?? review.reviewText!,
                isExpanded: vm.isReviewExpanded(review.id),
                onToggle:
                    () => ref
                        .read(reviewsViewModelProvider(recipeId).notifier)
                        .toggleReviewExpansion(review.id),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewHeader(
    BuildContext context,
    WidgetRef ref,
    Review review,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: horizontalPadding),
      child: Row(
        children: [
          _buildUserAvatar(review),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  review.userName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  DateTimeUtil.formatCompactDateTime(review.createdAt, context),
                  style: TextStyle(fontSize: 12, color: AppColors.greyScale500),
                ),
              ],
            ),
          ),
          _buildOverflowMenu(context, ref, review),
        ],
      ),
    );
  }

  Widget _buildUserAvatar(Review review) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: Colors.grey[300],
      backgroundImage:
          review.userImageUrl != null
              ? CachedNetworkImageProvider(review.userImageUrl!)
              : null,
      child:
          review.userImageUrl == null
              ? Icon(Icons.person, size: 20, color: Colors.grey[600])
              : null,
    );
  }

  Widget _buildOverflowMenu(
    BuildContext context,
    WidgetRef ref,
    Review review,
  ) {
    final isTranslating = ref.watch(
      reviewsViewModelProvider(
        recipeId,
      ).select((state) => state.translatingReviews.contains(review.id)),
    );

    return SizedBox.square(
      dimension: 30,
      child:
          isTranslating
              ? CupertinoActivityIndicator(radius: 10)
              : IconButton(
                padding: EdgeInsets.zero,
                onPressed: () => _showReviewOptionsModal(context, ref, review),
                icon: const Icon(
                  CupertinoIcons.ellipsis,
                  color: AppColors.greyScale600,
                  size: 22,
                ),
              ),
    );
  }

  Widget _buildReviewImages(BuildContext context, Review review) {
    final double imageDimension = 123;
    return SizedBox(
      height: imageDimension,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: review.imageUrls.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
              right: index == review.imageUrls.length - 1 ? 0 : 8,
            ),
            child: GestureDetector(
              onTap: () => _showImageViewer(context, review.imageUrls, index),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AppCachedImage(
                  imageUrl: review.imageUrls[index],
                  width: imageDimension,
                  height: imageDimension,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
