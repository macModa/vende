import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/product.dart';

class ProductRepository {
  // Cache for loaded data
  List<Product>? _products;
  List<ProductCategory>? _categories;
  List<String>? _featuredProductIds;

  Future<List<Product>> getProducts() async {
    if (_products != null) return _products!;
    
    await _loadData();
    return _products!;
  }

  Future<List<ProductCategory>> getCategories() async {
    if (_categories != null) return _categories!;
    
    await _loadData();
    return _categories!;
  }

  Future<List<Product>> getFeaturedProducts() async {
    if (_products == null || _featuredProductIds == null) {
      await _loadData();
    }
    
    return _products!
        .where((product) => _featuredProductIds!.contains(product.id))
        .toList();
  }

  Future<List<Product>> getProductsByCategory(String categoryId) async {
    if (_products == null) await _loadData();
    
    return _products!
        .where((product) => product.category == categoryId)
        .toList();
  }

  Future<Product?> getProductById(String productId) async {
    if (_products == null) await _loadData();
    
    try {
      return _products!.firstWhere((product) => product.id == productId);
    } catch (e) {
      return null;
    }
  }

  Future<List<Product>> searchProducts(String query) async {
    if (_products == null) await _loadData();
    
    final searchQuery = query.toLowerCase();
    
    return _products!
        .where((product) =>
            product.name.toLowerCase().contains(searchQuery) ||
            product.description.toLowerCase().contains(searchQuery) ||
            product.category.toLowerCase().contains(searchQuery) ||
            product.seller.toLowerCase().contains(searchQuery))
        .toList();
  }

  Future<void> _loadData() async {
    try {
      final String response = await rootBundle.loadString('assets/data/mock_products.json');
      final Map<String, dynamic> data = json.decode(response);
      
      // Parse categories
      _categories = (data['categories'] as List)
          .map((categoryJson) => ProductCategory.fromJson(categoryJson))
          .toList();
      
      // Parse products
      _products = (data['products'] as List)
          .map((productJson) => Product.fromJson(productJson))
          .toList();
      
      // Parse featured product IDs
      _featuredProductIds = (data['featured_products'] as List)
          .cast<String>();
      
    } catch (e) {
      throw Exception('Failed to load product data: $e');
    }
  }

  // Clear cache (useful for testing or data refresh)
  void clearCache() {
    _products = null;
    _categories = null;
    _featuredProductIds = null;
  }
}

// Provider for the repository
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository();
});

// Providers for different data queries
final productsProvider = FutureProvider<List<Product>>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getProducts();
});

final categoriesProvider = FutureProvider<List<ProductCategory>>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getCategories();
});

final featuredProductsProvider = FutureProvider<List<Product>>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getFeaturedProducts();
});

final productsByCategoryProvider = FutureProvider.family<List<Product>, String>((ref, categoryId) {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getProductsByCategory(categoryId);
});

final productByIdProvider = FutureProvider.family<Product?, String>((ref, productId) {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getProductById(productId);
});

final searchProductsProvider = FutureProvider.family<List<Product>, String>((ref, query) {
  final repository = ref.watch(productRepositoryProvider);
  return repository.searchProducts(query);
});
