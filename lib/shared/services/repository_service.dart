import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../features/products/data/product_repository.dart';
import '../../features/products/data/firebase_product_repository.dart';
import '../../features/cart/data/cart_repository.dart';
import '../../features/cart/data/firebase_cart_repository.dart';
import '../../features/profile/data/firebase_profile_repository.dart';
import '../../features/products/domain/product.dart';
import '../../features/cart/domain/cart_models.dart';
import '../../features/profile/domain/user_profile.dart';
import '../../features/profile/domain/order.dart' as domain_order;

/// Configuration for repository services
enum RepositoryMode {
  mock,     // Use mock/local data for development/testing
  firebase, // Use Firebase for production
}

class RepositoryConfig {
  static const RepositoryMode mode = RepositoryMode.firebase; // Switch this for different modes
  static const bool useFirebaseAuth = true;
}

/// Unified Product Repository Interface
abstract class IProductRepository {
  Future<List<Product>> getProducts();
  Future<Product?> getProductById(String productId);
  Future<List<Product>> getProductsByCategory(String categoryId);
  Future<List<Product>> searchProducts(String query);
  Future<List<Product>> getFeaturedProducts();
  Future<List<Product>> getLatestProducts({int limit = 10});
  Future<List<Product>> getProductsBySeller(String sellerId);
  Future<String> addProduct(Product product);
  Future<void> updateProduct(Product product);
  Future<void> deleteProduct(String productId);
  Future<List<ProductCategory>> getCategories();
  
  // Stream methods for real-time updates
  Stream<List<Product>>? productsStream();
  Stream<List<Product>>? featuredProductsStream();
}

/// Unified Cart Repository Interface  
abstract class ICartRepository {
  Future<Cart> getCurrentUserCart();
  Future<void> addToCart(CartItem item);
  Future<void> removeFromCart(String productId);
  Future<void> updateCartItemQuantity(String productId, int quantity);
  Future<void> clearCart();
  Future<String> createOrderFromCart({
    required PaymentMethod paymentMethod,
    String? notes,
    String? deliveryAddress,
    String? contactPhone,
  });
  Future<List<Order>> getUserOrders();
  Future<Order?> getOrderById(String orderId);
  
  // Stream methods for real-time updates
  Stream<Cart>? currentUserCartStream();
  Stream<List<Order>>? currentUserOrdersStream();
}

/// Mock Product Repository Adapter
class MockProductRepositoryAdapter implements IProductRepository {
  final ProductRepository _repository = ProductRepository();

  @override
  Future<List<Product>> getProducts() => _repository.getProducts();
  
  @override
  Future<Product?> getProductById(String productId) => _repository.getProductById(productId);
  
  @override
  Future<List<Product>> getProductsByCategory(String categoryId) => 
      _repository.getProductsByCategory(categoryId);
  
  @override
  Future<List<Product>> searchProducts(String query) => _repository.searchProducts(query);
  
  @override
  Future<List<Product>> getFeaturedProducts() => _repository.getFeaturedProducts();
  
  @override
  Future<List<Product>> getLatestProducts({int limit = 10}) => 
      _repository.getLatestProducts(limit: limit);
  
  @override
  Future<List<Product>> getProductsBySeller(String sellerId) => 
      _repository.getProductsBySeller(sellerId);
  
  @override
  Future<String> addProduct(Product product) async {
    await _repository.addProduct(product);
    return product.id; // Mock repository doesn't return ID
  }
  
  @override
  Future<void> updateProduct(Product product) => _repository.updateProduct(product);
  
  @override
  Future<void> deleteProduct(String productId) => _repository.deleteProduct(productId);
  
  @override
  Future<List<ProductCategory>> getCategories() => _repository.getCategories();
  
  @override
  Stream<List<Product>>? productsStream() => null; // Mock doesn't support streams
  
  @override
  Stream<List<Product>>? featuredProductsStream() => null; // Mock doesn't support streams
}

/// Firebase Product Repository Adapter
class FirebaseProductRepositoryAdapter implements IProductRepository {
  final FirebaseProductRepository _repository = FirebaseProductRepository();

  @override
  Future<List<Product>> getProducts() => _repository.getProducts();
  
  @override
  Future<Product?> getProductById(String productId) => _repository.getProductById(productId);
  
  @override
  Future<List<Product>> getProductsByCategory(String categoryId) => 
      _repository.getProductsByCategory(categoryId);
  
  @override
  Future<List<Product>> searchProducts(String query) => _repository.searchProducts(query);
  
  @override
  Future<List<Product>> getFeaturedProducts() => _repository.getFeaturedProducts();
  
  @override
  Future<List<Product>> getLatestProducts({int limit = 10}) => 
      _repository.getLatestProducts(limit: limit);
  
  @override
  Future<List<Product>> getProductsBySeller(String sellerId) => 
      _repository.getProductsBySeller(sellerId);
  
  @override
  Future<String> addProduct(Product product) => _repository.addProduct(product);
  
  @override
  Future<void> updateProduct(Product product) => _repository.updateProduct(product);
  
  @override
  Future<void> deleteProduct(String productId) => _repository.deleteProduct(productId);
  
  @override
  Future<List<ProductCategory>> getCategories() => _repository.getCategories();
  
  @override
  Stream<List<Product>>? productsStream() => _repository.productsStream();
  
  @override
  Stream<List<Product>>? featuredProductsStream() => _repository.featuredProductsStream();
}

/// Mock Cart Repository Adapter
class MockCartRepositoryAdapter implements ICartRepository {
  // This would need to be implemented if you have a mock cart repository
  // For now, we'll throw an error to indicate it's not implemented
  
  @override
  Future<Cart> getCurrentUserCart() {
    throw UnimplementedError('Mock cart repository not implemented');
  }
  
  @override
  Future<void> addToCart(CartItem item) {
    throw UnimplementedError('Mock cart repository not implemented');
  }
  
  @override
  Future<void> removeFromCart(String productId) {
    throw UnimplementedError('Mock cart repository not implemented');
  }
  
  @override
  Future<void> updateCartItemQuantity(String productId, int quantity) {
    throw UnimplementedError('Mock cart repository not implemented');
  }
  
  @override
  Future<void> clearCart() {
    throw UnimplementedError('Mock cart repository not implemented');
  }
  
  @override
  Future<String> createOrderFromCart({
    required PaymentMethod paymentMethod,
    String? notes,
    String? deliveryAddress,
    String? contactPhone,
  }) {
    throw UnimplementedError('Mock cart repository not implemented');
  }
  
  @override
  Future<List<Order>> getUserOrders() {
    throw UnimplementedError('Mock cart repository not implemented');
  }
  
  @override
  Future<Order?> getOrderById(String orderId) {
    throw UnimplementedError('Mock cart repository not implemented');
  }
  
  @override
  Stream<Cart>? currentUserCartStream() => null;
  
  @override
  Stream<List<Order>>? currentUserOrdersStream() => null;
}

/// Firebase Cart Repository Adapter
class FirebaseCartRepositoryAdapter implements ICartRepository {
  final FirebaseCartRepository _repository = FirebaseCartRepository();

  @override
  Future<Cart> getCurrentUserCart() => _repository.getCurrentUserCart();
  
  @override
  Future<void> addToCart(CartItem item) => _repository.addToCart(item);
  
  @override
  Future<void> removeFromCart(String productId) => _repository.removeFromCart(productId);
  
  @override
  Future<void> updateCartItemQuantity(String productId, int quantity) => 
      _repository.updateCartItemQuantity(productId, quantity);
  
  @override
  Future<void> clearCart() => _repository.clearCart();
  
  @override
  Future<String> createOrderFromCart({
    required PaymentMethod paymentMethod,
    String? notes,
    String? deliveryAddress,
    String? contactPhone,
  }) => _repository.createOrderFromCart(
    paymentMethod: paymentMethod,
    notes: notes,
    deliveryAddress: deliveryAddress,
    contactPhone: contactPhone,
  );
  
  @override
  Future<List<Order>> getUserOrders() => _repository.getUserOrders();
  
  @override
  Future<Order?> getOrderById(String orderId) => _repository.getOrderById(orderId);
  
  @override
  Stream<Cart>? currentUserCartStream() => _repository.currentUserCartStream();
  
  @override
  Stream<List<Order>>? currentUserOrdersStream() => _repository.currentUserOrdersStream();
}

/// Repository Service Providers
final productRepositoryServiceProvider = Provider<IProductRepository>((ref) {
  switch (RepositoryConfig.mode) {
    case RepositoryMode.mock:
      return MockProductRepositoryAdapter();
    case RepositoryMode.firebase:
      return FirebaseProductRepositoryAdapter();
  }
});

final cartRepositoryServiceProvider = Provider<ICartRepository>((ref) {
  switch (RepositoryConfig.mode) {
    case RepositoryMode.mock:
      return MockCartRepositoryAdapter();
    case RepositoryMode.firebase:
      return FirebaseCartRepositoryAdapter();
  }
});

/// Unified providers that work with both mock and Firebase
final unifiedProductsProvider = FutureProvider<List<Product>>((ref) {
  final repository = ref.watch(productRepositoryServiceProvider);
  return repository.getProducts();
});

final unifiedFeaturedProductsProvider = FutureProvider<List<Product>>((ref) {
  final repository = ref.watch(productRepositoryServiceProvider);
  return repository.getFeaturedProducts();
});

final unifiedCategoriesProvider = FutureProvider<List<ProductCategory>>((ref) {
  final repository = ref.watch(productRepositoryServiceProvider);
  return repository.getCategories();
});

final unifiedProductByIdProvider = FutureProvider.family<Product?, String>((ref, productId) {
  final repository = ref.watch(productRepositoryServiceProvider);
  return repository.getProductById(productId);
});

final unifiedSearchProductsProvider = FutureProvider.family<List<Product>, String>((ref, query) {
  final repository = ref.watch(productRepositoryServiceProvider);
  return repository.searchProducts(query);
});

final unifiedProductsByCategoryProvider = FutureProvider.family<List<Product>, String>((ref, categoryId) {
  final repository = ref.watch(productRepositoryServiceProvider);
  return repository.getProductsByCategory(categoryId);
});

final unifiedLatestProductsProvider = FutureProvider<List<Product>>((ref) {
  final repository = ref.watch(productRepositoryServiceProvider);
  return repository.getLatestProducts(limit: 6);
});

/// Stream providers (only work with Firebase mode)
final unifiedProductsStreamProvider = StreamProvider<List<Product>?>((ref) {
  final repository = ref.watch(productRepositoryServiceProvider);
  final stream = repository.productsStream();
  return stream ?? Stream.value(null);
});

final unifiedFeaturedProductsStreamProvider = StreamProvider<List<Product>?>((ref) {
  final repository = ref.watch(productRepositoryServiceProvider);
  final stream = repository.featuredProductsStream();
  return stream ?? Stream.value(null);
});

final unifiedCurrentUserCartProvider = FutureProvider<Cart>((ref) {
  final repository = ref.watch(cartRepositoryServiceProvider);
  return repository.getCurrentUserCart();
});

final unifiedCurrentUserCartStreamProvider = StreamProvider<Cart?>((ref) {
  final repository = ref.watch(cartRepositoryServiceProvider);
  final stream = repository.currentUserCartStream();
  return stream ?? Stream.value(null);
});

final unifiedCurrentUserOrdersStreamProvider = StreamProvider<List<Order>?>((ref) {
  final repository = ref.watch(cartRepositoryServiceProvider);
  final stream = repository.currentUserOrdersStream();
  return stream ?? Stream.value(null);
});

/// Unified operations providers
final unifiedProductOperationsProvider = StateNotifierProvider<UnifiedProductOperationsNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(productRepositoryServiceProvider);
  return UnifiedProductOperationsNotifier(repository, ref);
});

final unifiedCartOperationsProvider = StateNotifierProvider<UnifiedCartOperationsNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(cartRepositoryServiceProvider);
  return UnifiedCartOperationsNotifier(repository, ref);
});

/// Unified Product Operations Notifier
class UnifiedProductOperationsNotifier extends StateNotifier<AsyncValue<void>> {
  final IProductRepository _repository;
  final Ref _ref;

  UnifiedProductOperationsNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<void> addProduct(Product product) async {
    state = const AsyncValue.loading();
    try {
      await _repository.addProduct(product);
      // Invalidate relevant providers
      _ref.invalidate(unifiedProductsProvider);
      _ref.invalidate(unifiedFeaturedProductsProvider);
      _ref.invalidate(unifiedProductsByCategoryProvider);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateProduct(Product product) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateProduct(product);
      // Invalidate relevant providers
      _ref.invalidate(unifiedProductsProvider);
      _ref.invalidate(unifiedFeaturedProductsProvider);
      _ref.invalidate(unifiedProductByIdProvider(product.id));
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteProduct(String productId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteProduct(productId);
      // Invalidate relevant providers
      _ref.invalidate(unifiedProductsProvider);
      _ref.invalidate(unifiedFeaturedProductsProvider);
      _ref.invalidate(unifiedProductsByCategoryProvider);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

/// Unified Cart Operations Notifier
class UnifiedCartOperationsNotifier extends StateNotifier<AsyncValue<void>> {
  final ICartRepository _repository;
  final Ref _ref;

  UnifiedCartOperationsNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<void> addToCart(CartItem item) async {
    state = const AsyncValue.loading();
    try {
      await _repository.addToCart(item);
      state = const AsyncValue.data(null);
      // Stream providers will automatically update
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> removeFromCart(String productId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.removeFromCart(productId);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateCartItemQuantity(productId, quantity);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> clearCart() async {
    state = const AsyncValue.loading();
    try {
      await _repository.clearCart();
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<String> createOrder({
    required PaymentMethod paymentMethod,
    String? notes,
    String? deliveryAddress,
    String? contactPhone,
  }) async {
    state = const AsyncValue.loading();
    try {
      final orderId = await _repository.createOrderFromCart(
        paymentMethod: paymentMethod,
        notes: notes,
        deliveryAddress: deliveryAddress,
        contactPhone: contactPhone,
      );
      state = const AsyncValue.data(null);
      return orderId;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
}
