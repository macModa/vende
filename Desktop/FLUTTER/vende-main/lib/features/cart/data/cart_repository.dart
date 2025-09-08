import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/cart_models.dart';
import '../../products/domain/product.dart';

class CartRepository {
  Cart _cart = Cart.empty();
  List<Order> _orders = [];

  // Get current cart
  Cart getCart() {
    return _cart;
  }

  // Add item to cart
  void addToCart(Product product, {int quantity = 1}) {
    final existingItemIndex = _cart.items.indexWhere(
      (item) => item.product.id == product.id,
    );

    List<CartItem> updatedItems;
    
    if (existingItemIndex != -1) {
      // Update existing item quantity
      final existingItem = _cart.items[existingItemIndex];
      final updatedItem = existingItem.copyWith(
        quantity: existingItem.quantity + quantity,
      );
      
      updatedItems = List.from(_cart.items);
      updatedItems[existingItemIndex] = updatedItem;
    } else {
      // Add new item
      final newItem = CartItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        product: product,
        quantity: quantity,
        unitPrice: product.price,
        addedAt: DateTime.now(),
      );
      
      updatedItems = List.from(_cart.items)..add(newItem);
    }
    
    _cart = _cart.copyWith(items: updatedItems);
  }

  // Update item quantity
  void updateItemQuantity(String itemId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(itemId);
      return;
    }

    final updatedItems = _cart.items.map((item) {
      if (item.id == itemId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();

    _cart = _cart.copyWith(items: updatedItems);
  }

  // Remove item from cart
  void removeFromCart(String itemId) {
    final updatedItems = _cart.items.where((item) => item.id != itemId).toList();
    _cart = _cart.copyWith(items: updatedItems);
  }

  // Clear cart
  void clearCart() {
    _cart = Cart.empty();
  }

  // Get cart item by product ID
  CartItem? getCartItem(String productId) {
    try {
      return _cart.items.firstWhere((item) => item.product.id == productId);
    } catch (e) {
      return null;
    }
  }

  // Create order from cart
  Order createOrder({
    required String userId,
    required PaymentMethod paymentMethod,
    String? notes,
    String? deliveryAddress,
    String? contactPhone,
  }) {
    if (_cart.isEmpty) {
      throw Exception('Cannot create order from empty cart');
    }

    final order = Order.fromCart(
      cart: _cart,
      userId: userId,
      paymentMethod: paymentMethod,
      notes: notes,
      deliveryAddress: deliveryAddress,
      contactPhone: contactPhone,
    );

    _orders.add(order);
    clearCart(); // Clear cart after order creation

    return order;
  }

  // Get all orders
  List<Order> getOrders() {
    return List.unmodifiable(_orders);
  }

  // Get orders by user ID
  List<Order> getOrdersByUserId(String userId) {
    return _orders.where((order) => order.userId == userId).toList();
  }

  // Get order by ID
  Order? getOrderById(String orderId) {
    try {
      return _orders.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }

  // Update order status
  void updateOrderStatus(String orderId, OrderStatus status) {
    final orderIndex = _orders.indexWhere((order) => order.id == orderId);
    if (orderIndex != -1) {
      _orders[orderIndex] = _orders[orderIndex].copyWith(status: status);
    }
  }
}

// Repository provider
final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepository();
});

// Cart state provider
final cartProvider = StateNotifierProvider<CartNotifier, Cart>((ref) {
  final repository = ref.watch(cartRepositoryProvider);
  return CartNotifier(repository);
});

class CartNotifier extends StateNotifier<Cart> {
  final CartRepository _repository;

  CartNotifier(this._repository) : super(_repository.getCart());

  void addToCart(Product product, {int quantity = 1}) {
    _repository.addToCart(product, quantity: quantity);
    state = _repository.getCart();
  }

  void updateItemQuantity(String itemId, int quantity) {
    _repository.updateItemQuantity(itemId, quantity);
    state = _repository.getCart();
  }

  void removeFromCart(String itemId) {
    _repository.removeFromCart(itemId);
    state = _repository.getCart();
  }

  void clearCart() {
    _repository.clearCart();
    state = _repository.getCart();
  }

  CartItem? getCartItem(String productId) {
    return _repository.getCartItem(productId);
  }
}

// Orders provider
final ordersProvider = StateNotifierProvider<OrdersNotifier, List<Order>>((ref) {
  final repository = ref.watch(cartRepositoryProvider);
  return OrdersNotifier(repository);
});

class OrdersNotifier extends StateNotifier<List<Order>> {
  final CartRepository _repository;

  OrdersNotifier(this._repository) : super(_repository.getOrders());

  Order createOrder({
    required String userId,
    required PaymentMethod paymentMethod,
    String? notes,
    String? deliveryAddress,
    String? contactPhone,
  }) {
    final order = _repository.createOrder(
      userId: userId,
      paymentMethod: paymentMethod,
      notes: notes,
      deliveryAddress: deliveryAddress,
      contactPhone: contactPhone,
    );

    state = _repository.getOrders();
    return order;
  }

  void updateOrderStatus(String orderId, OrderStatus status) {
    _repository.updateOrderStatus(orderId, status);
    state = _repository.getOrders();
  }

  List<Order> getOrdersByUserId(String userId) {
    return _repository.getOrdersByUserId(userId);
  }

  Order? getOrderById(String orderId) {
    return _repository.getOrderById(orderId);
  }
}

// Provider for orders by user ID
final ordersByUserProvider = Provider.family<List<Order>, String>((ref, userId) {
  final orders = ref.watch(ordersProvider);
  return orders.where((order) => order.userId == userId).toList();
});

// Provider for specific order
final orderByIdProvider = Provider.family<Order?, String>((ref, orderId) {
  final orders = ref.watch(ordersProvider);
  try {
    return orders.firstWhere((order) => order.id == orderId);
  } catch (e) {
    return null;
  }
});

// Cart totals provider (computed)
final cartTotalsProvider = Provider<Map<String, double>>((ref) {
  final cart = ref.watch(cartProvider);
  return {
    'subtotal': cart.subtotal,
    'tax': cart.tax,
    'shipping': cart.shipping,
    'total': cart.total,
  };
});

// Cart item count provider
final cartItemCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.totalItems;
});
