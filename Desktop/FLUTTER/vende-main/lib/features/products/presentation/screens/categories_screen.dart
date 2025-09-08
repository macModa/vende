import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/product_repository.dart';
import '../../domain/product.dart';

enum CategoryViewMode { list, grid }

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  CategoryViewMode _viewMode = CategoryViewMode.grid;
  String _searchQuery = '';
  String? _selectedGroup;

  // Category groups for better organization
  final Map<String, List<String>> _categoryGroups = {
    'Crafts & Arts': ['textiles', 'pottery', 'jewelry', 'art'],
    'Food & Spices': ['food'],
    'Fashion': ['leather'],
  };

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            icon: Icon(
              _viewMode == CategoryViewMode.grid
                  ? PhosphorIcons.list()
                  : PhosphorIcons.gridFour(),
            ),
            onPressed: () {
              setState(() {
                _viewMode = _viewMode == CategoryViewMode.grid
                    ? CategoryViewMode.list
                    : CategoryViewMode.grid;
              });
            },
          ),
        ],
      ),
      body: categories.when(
        data: (categoryList) => Column(
          children: [
            // Search and Filter Bar
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.surface,
              child: Column(
                children: [
                  // Search Bar
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search categories...',
                      prefixIcon: Icon(PhosphorIcons.magnifyingGlass()),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  // Category Groups Filter
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          label: const Text('All'),
                          selected: _selectedGroup == null,
                          onSelected: (selected) {
                            setState(() {
                              _selectedGroup = null;
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        ..._categoryGroups.keys.map((group) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(group),
                                selected: _selectedGroup == group,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedGroup = selected ? group : null;
                                  });
                                },
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Categories Content
            Expanded(
              child: _buildCategoriesContent(context, categoryList),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                PhosphorIcons.warning(),
                size: 64,
                color: AppColors.textLight,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading categories',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textLight,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesContent(BuildContext context, List<ProductCategory> categoryList) {
    // Filter categories based on search and group selection
    final filteredCategories = _filterCategories(categoryList);

    if (filteredCategories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIcons.magnifyingGlass(),
              size: 64,
              color: AppColors.textLight,
            ),
            const SizedBox(height: 16),
            Text(
              'No categories found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filter',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
      );
    }

    return _viewMode == CategoryViewMode.grid
        ? _buildGridView(context, filteredCategories)
        : _buildListView(context, filteredCategories);
  }

  List<ProductCategory> _filterCategories(List<ProductCategory> categories) {
    return categories.where((category) {
      // Filter by search query
      final matchesSearch = _searchQuery.isEmpty ||
          category.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          category.description.toLowerCase().contains(_searchQuery.toLowerCase());

      // Filter by selected group
      final matchesGroup = _selectedGroup == null ||
          _categoryGroups[_selectedGroup]?.contains(category.id) == true;

      return matchesSearch && matchesGroup;
    }).toList();
  }

  Widget _buildGridView(BuildContext context, List<ProductCategory> categories) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.0,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _buildCategoryGridCard(context, category);
      },
    );
  }

  Widget _buildListView(BuildContext context, List<ProductCategory> categories) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _buildCategoryListCard(context, category);
      },
    );
  }

  Widget _buildCategoryGridCard(BuildContext context, ProductCategory category) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _navigateToCategoryProducts(context, category),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: _getCategoryColor(category.id).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    _getCategoryEmoji(category.id),
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                category.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${category.productCount} items',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryListCard(BuildContext context, ProductCategory category) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: _getCategoryColor(category.id).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              _getCategoryEmoji(category.id),
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        title: Text(
          category.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(category.description),
            const SizedBox(height: 4),
            Text(
              '${category.productCount} items available',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: Icon(
          PhosphorIcons.caretRight(),
          color: AppColors.textSecondary,
        ),
        onTap: () => _navigateToCategoryProducts(context, category),
      ),
    );
  }

  Color _getCategoryColor(String categoryId) {
    switch (categoryId) {
      case 'textiles':
        return Colors.purple;
      case 'pottery':
        return Colors.brown;
      case 'jewelry':
        return Colors.pink;
      case 'food':
        return Colors.orange;
      case 'leather':
        return Colors.amber;
      case 'art':
        return Colors.indigo;
      default:
        return AppColors.primary;
    }
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

  void _navigateToCategoryProducts(BuildContext context, ProductCategory category) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigating to ${category.name} products'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            // TODO: Implement navigation to category products
          },
        ),
      ),
    );
  }
}
