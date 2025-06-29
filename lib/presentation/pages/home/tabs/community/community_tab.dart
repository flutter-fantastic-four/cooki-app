// ignore_for_file: unused_element_parameter

import 'package:cooki/core/utils/navigation_util.dart';
import 'package:cooki/presentation/pages/detailed_recipe/detailed_recipe_page.dart';
import 'package:cooki/presentation/pages/home/tabs/community/widget/photo_modal_style_card.dart';
import 'package:cooki/presentation/pages/login/guest_login_page.dart';
import 'package:cooki/presentation/user_global_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../app/constants/app_constants.dart';
import '../../../../../core/utils/sharing_util.dart';
import '../../../../../data/repository/providers.dart';
import '../../../../../domain/entity/recipe.dart';
import '../../../../../presentation/widgets/app_cached_image.dart';
import '../../../../../app/constants/app_colors.dart';
import '../../../../../core/utils/general_util.dart';
import '../../../../../core/utils/snackbar_util.dart';
import 'community_tab_view_model.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../../../presentation/settings_global_view_model.dart';

// Provider for calculating actual average rating from reviews
final actualAverageRatingProvider = FutureProvider.family
    .autoDispose<Map<String, dynamic>, String>((ref, recipeId) async {
      try {
        final reviewRepository = ref.read(reviewRepositoryProvider);
        final reviews = await reviewRepository.getReviewsByRecipeId(recipeId);

        if (reviews.isEmpty) {
          return {'average': 0.0, 'count': 0};
        }

        final totalRating = reviews.fold<int>(
          0,
          (sum, review) => sum + review.rating,
        );
        final average = totalRating / reviews.length;

        return {'average': average, 'count': reviews.length};
      } catch (e) {
        return {'average': 0.0, 'count': 0};
      }
    });

// Provider for checking if a recipe is saved by the current user
final isRecipeSavedProvider = FutureProvider.family.autoDispose<bool, String>((
  ref,
  recipeId,
) async {
  try {
    final currentUser = ref.read(userGlobalViewModelProvider);
    if (currentUser == null) return false;

    final recipeRepository = ref.read(recipeRepositoryProvider);
    final savedRecipeIds = await recipeRepository.getUserSavedRecipeIds(
      currentUser.id,
    );
    return savedRecipeIds.contains(recipeId);
  } catch (e) {
    return false;
  }
});

class CommunityPage extends ConsumerStatefulWidget {
  const CommunityPage({super.key});

  @override
  ConsumerState<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends ConsumerState<CommunityPage> {
  final TextEditingController _searchController = TextEditingController();
  late stt.SpeechToText _speech;
  bool _speechEnabled = false;
  bool _isListening = false;

  @override
  void dispose() {
    _searchController.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _speech = stt.SpeechToText();
    _initSpeech();
  }

  void _initSpeech() async {
    _speechEnabled = await _speech.initialize();
    setState(() {});
  }

  void _startVoiceSearch() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      return;
    }

    final currentLanguage = ref.read(settingsGlobalViewModelProvider).selectedLanguage;
    final localeId = currentLanguage == SupportedLanguage.korean ? 'ko_KR' : 'en_US';

    await _speech.listen(
      onResult: (result) {
        _searchController.text = result.recognizedWords;
        final viewModel = ref.read(communityViewModelProvider.notifier);
        viewModel.updateSearchQuery(result.recognizedWords);

        // Stop listening when speech is final
        if (result.finalResult) {
          setState(() => _isListening = false);
        }
      },
      localeId: localeId,
      listenFor: Duration(seconds: 5), // Auto-stop after 10 seconds
      pauseFor: Duration(seconds: 3),   // Stop if pause for 3 seconds
    );
    setState(() => _isListening = true);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(communityViewModelProvider);
    final viewModel = ref.read(communityViewModelProvider.notifier);

    // Show error snackbar if there's an error
    ref.listen(communityViewModelProvider, (previous, next) {
      if (next.error != null) {
        SnackbarUtil.showSnackBar(context, next.error!);
        viewModel.clearError();
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar:
          state.isSearchActive
              ? _buildSearchAppBar(context, state, viewModel)
              : _buildNormalAppBar(context, state, viewModel),
      body: Column(
        children: [
          // Active filters
          if (state.hasActiveFilters)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ...state.selectedCuisines.map(
                          (cuisine) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _FilterChip(
                              label: cuisine,
                              onDeleted: () async {
                                viewModel.removeCuisine(cuisine);
                                await viewModel.loadRecipes();
                              },
                              isModalChip: false,
                              isSelected: true,
                            ),
                          ),
                        ),
                        if (state.selectedSort.isNotEmpty)
                          _FilterChip(
                            label: state.selectedSort,
                            onDeleted: () async {
                              viewModel.clearSort();
                              await viewModel.loadRecipes();
                            },
                            isModalChip: false,
                            isSelected: true,
                          ),
                      ],
                    ),
                  ),
                ),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.greyScale200,
                ),
              ],
            ),
          // Recipe grid
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => viewModel.refreshRecipes(),
              color: AppColors.primary,
              backgroundColor: AppColors.white,
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final state = ref.watch(communityViewModelProvider);
    final viewModel = ref.read(communityViewModelProvider.notifier);

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.greyScale400,
            ),
            const SizedBox(height: 16),
            Text(
              strings(context).errorOccurred,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.greyScale600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              strings(context).checkNetworkConnection,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.greyScale500,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => viewModel.loadRecipes(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(strings(context).retryButton),
            ),
          ],
        ),
      );
    }

    final filteredRecipes = state.getFilteredRecipes(context);
    if (filteredRecipes.isEmpty) {
      if (state.hasActiveFilters) {
        // Show no filtered results
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cancel_outlined,
                size: 64,
                color: AppColors.greyScale400,
              ),
              const SizedBox(height: 16),
              Text(
                strings(context).noRecipes,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.greyScale600,
                ),
              ),
            ],
          ),
        );
      } else {
        // Show general empty state
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.restaurant_menu,
                size: 64,
                color: AppColors.greyScale400,
              ),
              const SizedBox(height: 16),
              Text(
                strings(context).noSharedRecipes,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.greyScale600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                strings(context).shareFirstRecipe,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.greyScale500,
                ),
              ),
            ],
          ),
        );
      }
    }

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 160 / 184, // 160x184 card size
              crossAxisSpacing: 15,
              mainAxisSpacing: 16,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final recipe = filteredRecipes[index];
              return _RecipeCard(
                recipe: recipe,
                onOptionsTap: () => _showOptionsModal(context, recipe),
              );
            }, childCount: filteredRecipes.length),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  void _showFilterModal(BuildContext context) {
    final state = ref.read(communityViewModelProvider);
    final viewModel = ref.read(communityViewModelProvider.notifier);

    String tempSort = state.selectedSort;
    List<String> tempCuisines = List.from(state.selectedCuisines);
    final cuisineCategories = AppConstants.recipeCategories(strings(context));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.greyScale50,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              width: double.infinity,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle
                      Center(
                        child: Container(
                          margin: const EdgeInsets.only(top: 8, bottom: 12),
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: AppColors.greyScale400,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      // Filter content
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Sort options
                            Text(
                              strings(context).sort,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Wrap(
                                alignment: WrapAlignment.start,
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _FilterChip(
                                    label: strings(context).sortByRating,
                                    isSelected:
                                        tempSort ==
                                        strings(context).sortByRating,
                                    onTap: () {
                                      setModalState(() {
                                        tempSort =
                                            tempSort ==
                                                    strings(
                                                      context,
                                                    ).sortByRating
                                                ? ''
                                                : strings(context).sortByRating;
                                      });
                                    },
                                    isModalChip: true,
                                  ),
                                  _FilterChip(
                                    label: strings(context).sortByCookTime,
                                    isSelected:
                                        tempSort ==
                                        strings(context).sortByCookTime,
                                    onTap: () {
                                      setModalState(() {
                                        tempSort =
                                            tempSort ==
                                                    strings(
                                                      context,
                                                    ).sortByCookTime
                                                ? ''
                                                : strings(
                                                  context,
                                                ).sortByCookTime;
                                      });
                                    },
                                    isModalChip: true,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Divider(
                              height: 1,
                              thickness: 1,
                              color: AppColors.greyScale200,
                            ),
                            const SizedBox(height: 20),
                            // Cuisine filters
                            Text(
                              strings(context).countryCategory,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              strings(context).maxCategorySelectionHint,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.greyScale500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Wrap(
                                alignment: WrapAlignment.start,
                                spacing: 8,
                                runSpacing: 8,
                                children:
                                    cuisineCategories.map((cuisine) {
                                      final isSelected = tempCuisines.contains(
                                        cuisine,
                                      );
                                      final isDisabled =
                                          !isSelected &&
                                          tempCuisines.length >= 3;
                                      return _FilterChip(
                                        label: cuisine,
                                        isSelected: isSelected,
                                        isDisabled: isDisabled,
                                        onTap: () {
                                          setModalState(() {
                                            if (isSelected) {
                                              tempCuisines.remove(cuisine);
                                            } else if (tempCuisines.length <
                                                3) {
                                              tempCuisines.add(cuisine);
                                            }
                                          });
                                        },
                                        isModalChip: true,
                                      );
                                    }).toList(),
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Action buttons
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () async {
                                      viewModel.resetFilters();
                                      await viewModel.loadRecipes();
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                      }
                                    },
                                    child: Text(strings(context).reset),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      viewModel.updateSelectedSort(tempSort);
                                      viewModel.updateSelectedCuisines(
                                        List.from(tempCuisines),
                                      );
                                      await viewModel.loadRecipes();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(strings(context).apply),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).viewInsets.bottom + 16,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  PreferredSizeWidget _buildNormalAppBar(
    BuildContext context,
    CommunityState state,
    CommunityViewModel viewModel,
  ) {
    return AppBar(
      titleSpacing: 20,
      title: Text(
        strings(context).communityTitle,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          icon: FilterIconWithDot(showDot: state.hasActiveFilters),
          onPressed: () => _showFilterModal(context),
        ),
        IconButton(
          icon: SvgPicture.asset(
            'assets/icons/name=search, size=24, state=Default.svg',
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
          ),
          onPressed: () => viewModel.toggleSearch(),
        ),
        const SizedBox(width: 8),
      ],
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
    );
  }

  PreferredSizeWidget _buildSearchAppBar(
    BuildContext context,
    CommunityState state,
    CommunityViewModel viewModel,
  ) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leadingWidth: 56,
      // 20 + 24 + 12
      leading: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.black, size: 24),
          onPressed: () {
            _searchController.clear();
            if (_isListening) {
              _speech.stop();
              setState(() => _isListening = false);
            }
            viewModel.clearSearch();
          },
        ),
      ),
      titleSpacing: 12,
      title: TextField(
        controller: _searchController,
        autofocus: true,
        onChanged: (query) => viewModel.updateSearchQuery(query),
        decoration: InputDecoration(
          hintText: strings(context).searchPlaceholder,
          hintStyle: TextStyle(color: AppColors.greyScale400, fontSize: 16),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        style: const TextStyle(color: Colors.black, fontSize: 16),
      ),
      actions: [
        if (state.searchQuery.isNotEmpty) ...[
          const SizedBox(width: 8),
          SizedBox.square(
            dimension: 24,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.cancel,
                color: AppColors.greyScale500,
                size: 18,
              ),
              onPressed: () {
                _searchController.clear();
                viewModel.updateSearchQuery('');
              },
            ),
          ),
        ] else
          const SizedBox(width: 28), // 8 + 20 when no clear button
        IconButton(
          icon: Icon(
            _isListening ? Icons.mic : Icons.mic_none,
            color: _isListening ? Colors.red : Colors.black,
            size: 22,
          ),
          onPressed: _speechEnabled ? _startVoiceSearch : null,
        ),
        const SizedBox(width: 20),
      ],
    );
  }

  void _showOptionsModal(BuildContext context, Recipe recipe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.greyScale50,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (BuildContext context) {
        return Consumer(
          builder: (context, ref, child) {
            final user = ref.read(userGlobalViewModelProvider);

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
                      color: AppColors.greyScale400,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: const EdgeInsets.only(bottom: 12),
                  ),

                  // Save option - only show for other users' recipes
                  if (user != null && user.id != recipe.userId)
                    Consumer(
                      builder: (context, ref, child) {
                        final isRecipeSavedAsync = ref.watch(
                          isRecipeSavedProvider(recipe.id),
                        );
                        return isRecipeSavedAsync.when(
                          data: (isSaved) {
                            return PhotoModalStyleCard(
                              text:
                                  isSaved
                                      ? strings(context).removeFromMyRecipes
                                      : strings(context).saveToMyRecipes,
                              customIcon: Icon(
                                isSaved
                                    ? Icons.bookmark_remove
                                    : Icons.bookmark_border,
                                size: 20,
                                color: Colors.black87,
                              ),
                              onTap: () async {
                                try {
                                  final recipeRepository = ref.read(
                                    recipeRepositoryProvider,
                                  );
                                  if (isSaved) {
                                    await recipeRepository
                                        .removeFromSavedRecipes(
                                          user.id,
                                          recipe.id,
                                        );
                                    ref.invalidate(
                                      isRecipeSavedProvider(recipe.id),
                                    );
                                    if (context.mounted) {
                                      SnackbarUtil.showSnackBar(
                                        context,
                                        strings(
                                          context,
                                        ).recipeRemovedSuccessfully,
                                        showIcon: true,
                                      );
                                    }
                                  } else {
                                    await recipeRepository.addToSavedRecipes(
                                      user.id,
                                      recipe.id,
                                    );
                                    ref.invalidate(
                                      isRecipeSavedProvider(recipe.id),
                                    );
                                    if (context.mounted) {
                                      SnackbarUtil.showSnackBar(
                                        context,
                                        strings(
                                          context,
                                        ).recipeSavedSuccessfully,
                                        showIcon: true,
                                      );
                                    }
                                  }
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    SnackbarUtil.showSnackBar(
                                      context,
                                      strings(context).errorOccurred,
                                    );
                                  }
                                }
                              },
                            );
                          },
                          loading:
                              () => PhotoModalStyleCard(
                                text: strings(context).saveToMyRecipes,
                                customIcon: Icon(
                                  Icons.bookmark_border,
                                  size: 20,
                                  color: Colors.black87,
                                ),
                                onTap: () {}, // Disable during loading
                              ),
                          error:
                              (error, stack) => PhotoModalStyleCard(
                                text: strings(context).saveToMyRecipes,
                                customIcon: Icon(
                                  Icons.bookmark_border,
                                  size: 20,
                                  color: Colors.black87,
                                ),
                                onTap: () {
                                  // Show error and close modal
                                  SnackbarUtil.showSnackBar(
                                    context,
                                    strings(context).errorOccurred,
                                  );
                                  Navigator.pop(context);
                                },
                              ),
                        );
                      },
                    ),

                  // Save option for non-logged in users - show login prompt
                  if (user == null)
                    PhotoModalStyleCard(
                      text: strings(context).saveToMyRecipes,
                      customIcon: Icon(
                        Icons.bookmark_border,
                        size: 20,
                        color: Colors.black87,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GuestLoginPage(),
                          ),
                        );
                      },
                    ),

                  PhotoModalStyleCard(
                    text: strings(context).share,
                    customIcon: Icon(
                      Icons.ios_share,
                      size: 20,
                      color: Colors.black87,
                    ),
                    onTap: () async {
                      await SharingUtil.shareRecipe(
                        context,
                        recipe,
                        ref.read(imageDownloadRepositoryProvider),
                      );
                      if (!context.mounted) return;
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 15),
                  PhotoModalStyleCard(
                    text: strings(context).close,
                    onTap: () => Navigator.pop(context),
                    isCenter: true,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _RecipeCard extends ConsumerWidget {
  final Recipe recipe;
  final VoidCallback onOptionsTap;

  const _RecipeCard({required this.recipe, required this.onOptionsTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        await NavigationUtil.pushFromBottom<bool>(
          context,
          DetailRecipePage(recipe: recipe),
        );
        // Always refresh the community tab when returning from detail page
        // This ensures any changes (like bookmarking) are reflected
        if (context.mounted) {
          ref.read(communityViewModelProvider.notifier).loadRecipes();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.greyScale200),
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 120,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
                child:
                    recipe.imageUrl != null
                        ? AppCachedImage(
                          imageUrl: recipe.imageUrl!,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        )
                        : Image.asset(
                          'assets/no_image.png',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
              ),
            ),
            SizedBox(
              height: 64,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 12.0,
                  right: 12.0,
                  top: 12.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Recipe title with three dots menu
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            recipe.recipeName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.greyScale800,
                              height: 1.2,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: onOptionsTap,
                          child: const Icon(
                            Icons.more_vert,
                            size: 20,
                            color: AppColors.black,
                          ),
                        ),
                      ],
                    ),
                    // User name and rating
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            recipe.userName,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.greyScale600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.star,
                          color: AppColors.secondary600,
                          size: 14,
                        ),
                        const SizedBox(width: 2),
                        Consumer(
                          builder: (context, ref, child) {
                            final averageRatingAsync = ref.watch(
                              actualAverageRatingProvider(recipe.id),
                            );
                            return averageRatingAsync.when(
                              data: (ratingData) {
                                final average = ratingData['average'] as double;
                                final count = ratingData['count'] as int;
                                return Text(
                                  '${strings(context).average} ${count == 0 ? '0' : average.toStringAsFixed(1)}${strings(context).score}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.greyScale600,
                                  ),
                                );
                              },
                              loading:
                                  () => Text(
                                    '${strings(context).average} ${recipe.ratingSum.toStringAsFixed(1)}${strings(context).score}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.greyScale600,
                                    ),
                                  ),
                              error:
                                  (error, stack) => Text(
                                    '${strings(context).average} 0${strings(context).score}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.greyScale600,
                                    ),
                                  ),
                            );
                          },
                        ),
                      ],
                    ),
                    // Row(
                    //   children: [
                    //     CircleAvatar(
                    //       radius: 10,
                    //       backgroundImage:
                    //           recipe.userProfileImage != null
                    //               ? NetworkImage(recipe.userProfileImage!)
                    //               : null,
                    //       backgroundColor: AppColors.greyScale200,
                    //       child:
                    //           recipe.userProfileImage == null
                    //               ? const Icon(
                    //                 Icons.person,
                    //                 size: 12,
                    //                 color: AppColors.greyScale600,
                    //               )
                    //               : null,
                    //     ),
                    //     const SizedBox(width: 8),
                    //     Expanded(
                    //       child: Text(
                    //         recipe.userName,
                    //         style: const TextStyle(
                    //           fontSize: 12,
                    //           color: AppColors.greyScale600,
                    //         ),
                    //         overflow: TextOverflow.ellipsis,
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final VoidCallback? onDeleted;
  final bool isSelected;
  final bool isModalChip;
  final bool isDisabled;

  const _FilterChip({
    required this.label,
    this.onTap,
    this.onDeleted,
    this.isSelected = false,
    this.isModalChip = false,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        height: 26,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color:
              isDisabled
                  ? AppColors.greyScale100
                  : isModalChip
                  ? (isSelected ? AppColors.primary700 : AppColors.white)
                  : (isSelected ? AppColors.primary50 : AppColors.primary50),
          borderRadius: BorderRadius.circular(13),
          border:
              isDisabled
                  ? null
                  : isModalChip
                  ? Border.all(
                    color: isSelected ? AppColors.primary800 : AppColors.white,
                    width: 1,
                  )
                  : Border.all(color: AppColors.primary700, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color:
                    isDisabled
                        ? AppColors.greyScale400
                        : isModalChip
                        ? (isSelected
                            ? AppColors.white
                            : AppColors.greyScale800)
                        : (isSelected ? AppColors.primary : AppColors.primary),
                fontSize: 12,
                height: 1.2,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            if (onDeleted != null) ...[
              const SizedBox(width: 2),
              GestureDetector(
                onTap: onDeleted,
                child: Icon(
                  Icons.close,
                  size: 12,
                  color: isModalChip ? AppColors.white : AppColors.primary700,
                ),
              ),
              const SizedBox(width: 2),
            ],
          ],
        ),
      ),
    );
  }
}

class FilterIconWithDot extends StatelessWidget {
  final bool showDot;

  const FilterIconWithDot({super.key, required this.showDot});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        SvgPicture.asset(
          'assets/icons/name=filter, size=24, state=Default.svg',
          width: 24,
          height: 24,
          colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
        ),
        if (showDot)
          Positioned(
            right: -2,
            top: 2,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}
