import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/product_repository.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: categories.when(
        data: (categoryList) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: categoryList.length,
          itemBuilder: (context, index) {
            final category = categoryList[index];
            return Card(
              child: ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      _getCategoryEmoji(category.id),
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                title: Text(category.name),
                subtitle: Text(category.description),
                trailing: Text('${category.productCount} items'),
                onTap: () {
                  // TODO: Navigate to category products
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('View ${category.name} products'),
                    ),
                  );
                },
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('Error loading categories: $error'),
        ),
      ),
    );
  }

  String _getCategoryEmoji(String categoryId) {
    switch (categoryId) {
      case 'textiles':
        return '🧵';
      case 'pottery':
        return '🏺';
      case 'jewelry':
        return '💎';
      case 'food':
        return '🌶️';
      case 'leather':
        return '👜';
      case 'art':
        return '🎨';
      default:
        return '🛍️';
    }
  }
}
