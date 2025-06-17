import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../data/repository/providers.dart';
import '../../../../../domain/entity/recipe.dart';
import '../../../../../presentation/widgets/app_cached_image.dart';

// Provider for community recipes
final communityRecipesProvider = FutureProvider<List<Recipe>>((ref) async {
  final repository = ref.watch(recipeRepositoryProvider);
  return await repository.getCommunityRecipes();
});

class CommunityPage extends ConsumerWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipesAsync = ref.watch(communityRecipesProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(communityRecipesProvider);
      },
      child: recipesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (recipes) => _buildRecipeList(context, recipes),
      ),
    );
  }

  Widget _buildRecipeList(BuildContext context, List<Recipe> recipes) {
    if (recipes.isEmpty) {
      return const Center(child: Text('커뮤니티 레시피가 없습니다.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (recipe.imageUrl != null)
                SizedBox(
                  width: double.infinity,
                  height: 200,
                  child: AppCachedImage(
                    imageUrl: recipe.imageUrl!,
                    fit: BoxFit.cover,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.recipeName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(recipe.category),
                        const SizedBox(width: 8),
                        Text('${recipe.cookTime}분'),
                        const SizedBox(width: 8),
                        Text('${recipe.calories}kcal'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundImage:
                              recipe.userProfileImage != null
                                  ? NetworkImage(recipe.userProfileImage!)
                                  : null,
                          child:
                              recipe.userProfileImage == null
                                  ? Text(recipe.userName[0])
                                  : null,
                        ),
                        const SizedBox(width: 8),
                        Text(recipe.userName),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
