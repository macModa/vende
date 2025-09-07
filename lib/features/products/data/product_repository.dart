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
    
    // Ensure we have products and featured IDs
    if (_products == null || _featuredProductIds == null) {
      return [];
    }
    
    final featuredProducts = _products!
        .where((product) => _featuredProductIds!.contains(product.id))
        .toList();
    
    // Sort to show user-created products first, then by newest
    featuredProducts.sort((a, b) {
      final aIsUserCreated = a.attributes != null && a.attributes!['isUserCreated'] == true;
      final bIsUserCreated = b.attributes != null && b.attributes!['isUserCreated'] == true;
      
      if (aIsUserCreated && !bIsUserCreated) return -1;
      if (!aIsUserCreated && bIsUserCreated) return 1;
      
      // If both are user-created or both are not, sort by creation date (newest first)
      return b.createdAt.compareTo(a.createdAt);
    });
    
    return featuredProducts;
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
      
      // Parse categories with fallback
      _categories = data.containsKey('categories') && data['categories'] is List
          ? (data['categories'] as List)
              .map((categoryJson) => ProductCategory.fromJson(categoryJson))
              .toList()
          : <ProductCategory>[];
      
      // Parse products with fallback
      _products = data.containsKey('products') && data['products'] is List
          ? (data['products'] as List)
              .map((productJson) => Product.fromJson(productJson))
              .toList()
          : <Product>[];
      
      // Parse featured product IDs with fallback
      _featuredProductIds = data.containsKey('featured_products') && data['featured_products'] is List
          ? (data['featured_products'] as List).cast<String>()
          : <String>[];
      
    } catch (e) {
      // Initialize with empty lists if loading fails
      _products = <Product>[];
      _categories = <ProductCategory>[];
      _featuredProductIds = <String>[];
      print('Warning: Failed to load product data, using empty lists: $e');
    }
  }

  // Add new product
  Future<void> addProduct(Product product) async {
    if (_products == null) await _loadData();
    _products!.add(product);
    
    // Automatically add user-created products to featured list
    if (product.attributes != null && 
        product.attributes!['isUserCreated'] == true && 
        _featuredProductIds != null) {
      _featuredProductIds!.add(product.id);
    }
  }

  // Update existing product
  Future<void> updateProduct(Product product) async {
    if (_products == null) await _loadData();
    final index = _products!.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products![index] = product;
    }
  }

  // Delete product
  Future<void> deleteProduct(String productId) async {
    if (_products == null) await _loadData();
    _products!.removeWhere((p) => p.id == productId);
  }

  // Get products by seller
  Future<List<Product>> getProductsBySeller(String sellerId) async {
    if (_products == null) await _loadData();
    return _products!.where((product) => product.seller == sellerId).toList();
  }

  // Get latest products (newest first)
  Future<List<Product>> getLatestProducts({int limit = 10}) async {
    if (_products == null) await _loadData();
    final sortedProducts = List<Product>.from(_products!);
    sortedProducts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedProducts.take(limit).toList();
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

final productsBySellerProvider = FutureProvider.family<List<Product>, String>((ref, sellerId) {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getProductsBySeller(sellerId);
});

final latestProductsProvider = FutureProvider<List<Product>>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getLatestProducts(limit: 6);
});

// StateProvider for managing product operations
final productOperationsProvider = StateNotifierProvider<ProductOperationsNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return ProductOperationsNotifier(repository, ref);
});

class ProductOperationsNotifier extends StateNotifier<AsyncValue<void>> {
  final ProductRepository _repository;
  final Ref _ref;

  ProductOperationsNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<void> addProduct(Product product) async {
    state = const AsyncValue.loading();
    try {
      await _repository.addProduct(product);
      // Invalidate related providers to refresh data
      _ref.invalidate(productsProvider);
      _ref.invalidate(featuredProductsProvider);
      _ref.invalidate(productsByCategoryProvider);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateProduct(Product product) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateProduct(product);
      // Invalidate related providers to refresh data
      _ref.invalidate(productsProvider);
      _ref.invalidate(featuredProductsProvider);
      _ref.invalidate(productsByCategoryProvider);
      _ref.invalidate(productByIdProvider(product.id));
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteProduct(String productId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteProduct(productId);
      // Invalidate related providers to refresh data
      _ref.invalidate(productsProvider);
      _ref.invalidate(featuredProductsProvider);
      _ref.invalidate(productsByCategoryProvider);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
