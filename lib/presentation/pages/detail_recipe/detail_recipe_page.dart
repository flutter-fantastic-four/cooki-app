import 'package:cached_network_image/cached_network_image.dart';
import 'package:cooki/app/constants/app_colors.dart';
import 'package:cooki/core/utils/dialogue_util.dart';
import 'package:cooki/core/utils/general_util.dart';
import 'package:cooki/core/utils/navigation_util.dart';
import 'package:cooki/domain/entity/recipe.dart';
import 'package:cooki/presentation/pages/add_review/write_review_page.dart';
import 'package:cooki/presentation/pages/reviews/reviews_page.dart';
import 'package:cooki/presentation/widgets/app_cached_image.dart';
import 'package:cooki/presentation/widgets/recipe_page_widgets.dart';
import 'package:cooki/presentation/widgets/star_rating.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';

class DetailRecipePage extends StatefulWidget {
  const DetailRecipePage({super.key, required this.recipe, this.category});
  final Recipe recipe;
  final String? category;

  @override
  State<DetailRecipePage> createState() => _DetailRecipePageState();
}

class _DetailRecipePageState extends State<DetailRecipePage> {
  int currentRating = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        actionsPadding: EdgeInsets.only(right: 20),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [widget.recipe.isPublic ? SizedBox() : Icon(Icons.edit_outlined)],
      ),
      body: ListView(
        children: [
          widget.recipe.imageUrl != null ? _buildImageSelector() : SizedBox(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoChip(context),
                const SizedBox(height: 12),
                _title(),
                const SizedBox(height: 40),
                TagChips(widget.recipe.tags),
                const SizedBox(height: 24),
                _review(),
                const SizedBox(height: 24),
                _ingredientsLabel(context),
                const SizedBox(height: 16),
                _ingredientsColumn(),
                const SizedBox(height: 16),
                Text(strings(context).stepsLabel, style: RecipePageWidgets.sectionTitleStyle),
                const SizedBox(height: 16),
                _stepsColumn(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Row _ingredientsLabel(BuildContext context) {
    return Row(
      children: [
        Text(strings(context).ingredientsLabel, style: RecipePageWidgets.sectionTitleStyle),
        const SizedBox(width: 3),
        Text(strings(context).servingsLabel, style: RecipePageWidgets.servingsTitleStyle),
      ],
    );
  }

  Widget _review() {
    return widget.recipe.isPublic
        ? Column(
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    NavigationUtil.pushFromBottom(context, ReviewsPage(recipeId: widget.recipe.id, recipeName: widget.recipe.recipeName));
                  },
                  child: Row(
                    children: [
                      Text('리뷰 ${widget.recipe.ratingCount > 999 ? '999+' : widget.recipe.ratingCount}개', style: RecipePageWidgets.sectionTitleStyle),

                      Icon(Icons.arrow_forward_ios),
                    ],
                  ),
                ),
                Spacer(),
                Icon(Icons.star, color: AppColors.secondary600),
                Text('평균 ${widget.recipe.ratingSum == 0.0 ? '0' : widget.recipe.ratingSum}점', style: RecipePageWidgets.sectionTitleStyle),
              ],
            ),
            const SizedBox(height: 16),
            ReviewCardList(),
          ],
        )
        : SizedBox();
  }

  Column _ingredientsColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in widget.recipe.ingredients) ...[
          RecipePageWidgets.divider,
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), child: Text(item)),
        ],
      ],
    );
  }

  Column _stepsColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < widget.recipe.steps.length; i++) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StepIndexLabel(i + 1),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                  decoration: BoxDecoration(color: AppColors.appBarGrey, borderRadius: RecipePageWidgets.inputBorderRadius),
                  child: Text(widget.recipe.steps[i]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Row _title() {
    return Row(
      children: [
        Text(widget.recipe.recipeName, style: RecipePageWidgets.sectionTitleStyle),
        Spacer(),
        IconButton(onPressed: () {}, icon: Icon(Icons.bookmark_border)),
        IconButton(onPressed: () {}, icon: Icon(Icons.more_vert)),
      ],
    );
  }

  Row _infoChip(BuildContext context) {
    return Row(
      children: [
        widget.category != null
            ? Row(
              children: [
                Container(
                  height: 28,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 1, color: AppColors.greyScale300),
                      borderRadius: BorderRadius.circular(99999),
                    ),
                  ),
                  child: Text(widget.category!, style: TextStyle(fontSize: 12)),
                ),
                SizedBox(width: 8),
              ],
            )
            : SizedBox(),
        Container(
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(side: BorderSide(width: 1, color: AppColors.greyScale300), borderRadius: BorderRadius.circular(99999)),
          ),
          child: GestureDetector(
            onTap: () {
              int currentRating = 0;
              widget.recipe.isPublic
                  ? NavigationUtil.pushFromBottom(context, WriteReviewPage(recipeId: widget.recipe.id, recipeName: widget.recipe.recipeName))
                  : showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: AppColors.greyScale50,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
                    builder: (context) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 30, left: 15, right: 15),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Top handle
                            Container(
                              width: 40,
                              height: 5,
                              decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(10)),
                              margin: const EdgeInsets.only(bottom: 12),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 40),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 24,
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      spacing: 4,
                                      children: [
                                        Text(
                                          '레시피 평가하기',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 20,
                                            fontFamily: 'Pretendard',
                                            fontWeight: FontWeight.w700,
                                            height: 1.50,
                                          ),
                                        ),
                                        Text(
                                          '생성한 레시피에 대한 별점을 남겨보세요',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14,
                                            fontFamily: 'Pretendard',
                                            fontWeight: FontWeight.w400,
                                            height: 1.50,
                                            letterSpacing: -0.14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    spacing: 5,
                                    children: [],
                                  ),
                                ],
                              ),
                            ),

                            Padding(
                              padding: EdgeInsets.only(bottom: 40),
                              child: StarRating(
                                currentRating: currentRating,
                                setRating: (value) {
                                  setState(() {
                                    currentRating = value;
                                  });
                                },
                              ),
                            ),

                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(color: const Color(0xFFF5F5F5) /* Grayscale-50 */),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 8,
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      spacing: 8,
                                      children: [
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.pop(context);
                                            },
                                            child: Container(
                                              height: 54,
                                              padding: const EdgeInsets.all(8),
                                              decoration: ShapeDecoration(
                                                color: Colors.white /* Grayscale-White */,
                                                shape: RoundedRectangleBorder(
                                                  side: BorderSide(width: 1, color: const Color(0xFF1D8163) /* Primary-700 */),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                spacing: 8,
                                                children: [
                                                  Text(
                                                    '닫기',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: const Color(0xFF1D8163) /* Primary-700 */,
                                                      fontSize: 16,
                                                      fontFamily: 'Pretendard',
                                                      fontWeight: FontWeight.w600,
                                                      height: 1.50,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            height: 54,
                                            padding: const EdgeInsets.all(8),
                                            decoration: ShapeDecoration(
                                              color: const Color(0xFF1D8163) /* Primary-700 */,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              spacing: 8,
                                              children: [
                                                Text(
                                                  '완료',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors.white /* Grayscale-White */,
                                                    fontSize: 16,
                                                    fontFamily: 'Pretendard',
                                                    fontWeight: FontWeight.w600,
                                                    height: 1.50,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
            },
            child: Row(children: List.generate(5, (_) => Icon(Icons.star_border, size: 12, color: AppColors.greyScale800))),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSelector() {
    return GestureDetector(
      onTap: () {
        final imageProvider = CachedNetworkImageProvider(widget.recipe.imageUrl!);
        showImageViewer(context, imageProvider, swipeDismissible: true, doubleTapZoomable: true, useSafeArea: true);
      },
      child: AppCachedImage(imageUrl: widget.recipe.imageUrl!, fit: BoxFit.cover, height: 230, width: double.infinity),
    );
  }
}

class ReviewCardList extends StatelessWidget {
  const ReviewCardList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: List.generate(10, (index) => _buildReviewCard()))),
    );
  }

  Widget _buildReviewCard() {
    return Container(
      width: 160,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12), color: Colors.white),
      child: Row(
        children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(5, (i) {
                    return Icon(i < 4 ? Icons.star : Icons.star_border, size: 14, color: Colors.black);
                  }),
                ),
                const SizedBox(height: 4),
                const Text('community recipe review', style: TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
