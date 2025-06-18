import 'package:cached_network_image/cached_network_image.dart';
import 'package:cooki/app/constants/app_colors.dart';
import 'package:cooki/core/utils/general_util.dart';
import 'package:cooki/domain/entity/recipe.dart';
import 'package:cooki/presentation/widgets/app_cached_image.dart';
import 'package:cooki/presentation/widgets/recipe_page_widgets.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';

class DetailRecipePage extends StatefulWidget {
  const DetailRecipePage({super.key, required this.recipe, this.isShardRecipe = false});
  final Recipe recipe;
  final bool isShardRecipe;

  @override
  State<DetailRecipePage> createState() => _DetailRecipePageState();
}

class _DetailRecipePageState extends State<DetailRecipePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 1),
      body: ListView(
        children: [
          widget.recipe.imageUrl != null ? _buildImageSelector() : SizedBox(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(widget.recipe.recipeName, style: RecipePageWidgets.sectionTitleStyle),
                    Spacer(),
                    IconButton(onPressed: () {}, icon: Icon(Icons.bookmark_border)),
                    IconButton(onPressed: () {}, icon: Icon(Icons.more_vert)),
                  ],
                ),

                const SizedBox(height: 40),
                TagChips(widget.recipe.tags),

                const SizedBox(height: 24),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: Row(
                        children: [
                          Text(
                            '리뷰 ${widget.recipe.ratingCount > 999 ? '999+' : widget.recipe.ratingCount}개',
                            style: RecipePageWidgets.sectionTitleStyle,
                          ),

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

                const SizedBox(height: 24),
                Row(
                  children: [
                    Text(strings(context).ingredientsLabel, style: RecipePageWidgets.sectionTitleStyle),
                    const SizedBox(width: 3),
                    Text(strings(context).servingsLabel, style: RecipePageWidgets.servingsTitleStyle),
                  ],
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final item in widget.recipe.ingredients) ...[
                      RecipePageWidgets.divider,
                      Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), child: Text(item)),
                    ],
                  ],
                ),

                const SizedBox(height: 16),
                Text(strings(context).stepsLabel, style: RecipePageWidgets.sectionTitleStyle),

                const SizedBox(height: 16),

                Column(
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
                ),
              ],
            ),
          ),
        ],
      ),
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
      height: 120, // 카드 높이에 맞게 조정
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
          // 이미지 자리
          Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8))),
          const SizedBox(width: 12),
          // 별점 + 텍스트
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 별점 표시 (예: 4.0)
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
