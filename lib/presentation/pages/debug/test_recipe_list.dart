import 'package:cooki/app/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/repository/providers.dart';
import '../../../domain/entity/recipe.dart';
import '../edit/recipe_edit_page.dart';
import '../../widgets/app_cached_image.dart';

// Provider for the recipe list
final recipeListProvider = FutureProvider<List<Recipe>>((ref) async {
  final repository = ref.watch(recipeRepositoryProvider);
  return await repository.getAllRecipes();
});

class RecipeDebugListPage extends ConsumerWidget {
  const RecipeDebugListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipesAsync = ref.watch(recipeListProvider);

    Widget body;
    if (recipesAsync.isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (recipesAsync.hasError) {
      throw recipesAsync.error!;
    } else if (recipesAsync.hasValue) {
      body = _buildRecipeList(context, recipesAsync.value!);
    } else {
      throw Exception('Unexpected state');
    }

    return Scaffold(
      appBar: AppBar(title: const Text('모든 레시피 디버그')),
      body: body,
    );
  }


  Widget _buildRecipeList(BuildContext context, List<Recipe> recipes) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: recipes.length,
      separatorBuilder: (_, __) => const Divider(height: 32, thickness: 1),
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecipeEditPage(recipe: recipe),
              ),
            );
          },
          child: Card(
            elevation: 2,
            color: AppColors.appBarGrey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recipe title
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    recipe.recipeName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Recipe image if available
                if (recipe.imageUrl != null)
                  SizedBox(
                    width: double.infinity,
                    height: 180,
                    child: AppCachedImage(
                      imageUrl: recipe.imageUrl!,
                      fit: BoxFit.cover,
                    ),
                  ),

                // Recipe details
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('카테고리', recipe.category),
                      _buildDetailRow('조리 시간', '${recipe.cookTime}분'),
                      _buildDetailRow('칼로리', '${recipe.calories}kcal'),
                      _buildDetailRow('공개 여부', recipe.isPublic ? '예' : '아니오'),
                      _buildDetailRow('사용자 이름', recipe.userName),
                      _buildDetailRow(
                        '생성일',
                        dateFormat.format(recipe.createdAt),
                      ),
                      if (recipe.updatedAt != null)
                        _buildDetailRow(
                          '수정일',
                          dateFormat.format(recipe.updatedAt!),
                        ),
                      const SizedBox(height: 8),
                      _buildListSection('재료', recipe.ingredients),
                      _buildListSection('조리 단계', recipe.steps),
                      _buildListSection('태그', recipe.tags),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildListSection(String title, List<String> items) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 2),
            child: Text('• $item'),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
