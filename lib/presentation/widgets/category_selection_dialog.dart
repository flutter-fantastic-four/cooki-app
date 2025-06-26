import 'package:cooki/app/constants/app_colors.dart';
import 'package:flutter/material.dart';
import '../../app/constants/app_constants.dart';
import '../../core/utils/general_util.dart';

Future<String?> showCategorySelectionDialog(BuildContext context) {
  final statusBarHeight = MediaQuery.of(context).padding.top;

  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Container(
        margin: EdgeInsets.only(top: statusBarHeight + 15),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: const CategorySelectionDialog(),
      );
    },
  );
}

class CategorySelectionDialog extends StatelessWidget {
  const CategorySelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = AppConstants.recipeCategories(context);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView(
            controller: controller,
            children: [
              const SizedBox(height: 12),
              _buildDragHandle(),
              const SizedBox(height: 18),
              Text(
                strings(context).categoryLabel,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ...categories.map(
                (category) => _buildCategoryTile(context, category),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDragHandle() {
    return const Center(
      child: SizedBox(
        width: 40,
        height: 5,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.all(Radius.circular(2.5)),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTile(BuildContext context, String category) {
    return InkWell(
      onTap: () {
        Navigator.pop(context, category);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.only(
          left: 20,
          right: 14,
          top: 11,
          bottom: 11,
        ),
        decoration: BoxDecoration(
          color: AppColors.cardGrey,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          category,
          style: const TextStyle(fontSize: 17, color: Colors.black),
        ),
      ),
    );
  }
}
