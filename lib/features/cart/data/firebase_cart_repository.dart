import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/cart_models.dart';

class FirebaseCartRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  static const String _cartsCollection = 'carts';
  static const String _ordersCollection = 'orders';

  // Cart operations
  
  Future<Cart> getCurrentUserCart() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user');
    }

    return getUserCart(user.uid);
  }

  Future<Cart> getUserCart(String userId) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection(_cartsCollection)
          .doc(userId)
          .get();
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return Cart.fromJson({
          ...data,
          'id': doc.id,
        });
      } else {
        // Create empty cart for new user
        final cart = Cart.empty().copyWith(id: userId);
        await _saveCart(cart);
        return cart;
      }
    } catch (e) {
      throw Exception('Failed to fetch cart: $e');
    }
  }

  Future<void> addToCart(CartItem item) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user');
    }

    try {
      final cart = await getCurrentUserCart();
      
      // Check if product already exists in cart
      final existingItemIndex = cart.items.indexWhere(
        (cartItem) => cartItem.product.id == item.product.id,
      );
      
      List<CartItem> updatedItems = List.from(cart.items);
      
      if (existingItemIndex != -1) {
        // Update existing item quantity
        final existingItem = updatedItems[existingItemIndex];
        updatedItems[existingItemIndex] = existingItem.copyWith(
          quantity: existingItem.quantity + item.quantity,
        );
      } else {
        // Add new item
        updatedItems.add(item);
      }
      
      final updatedCart = cart.copyWith(
        items: updatedItems,
        updatedAt: DateTime.now(),
      );
      
      await _saveCart(updatedCart);
    } catch (e) {
      throw Exception('Failed to add item to cart: $e');
    }
  }

  Future<void> removeFromCart(String productId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user');
    }

    try {
      final cart = await getCurrentUserCart();
      
      final updatedItems = cart.items
          .where((item) => item.product.id != productId)
          .toList();
      
      final updatedCart = cart.copyWith(
        items: updatedItems,
        updatedAt: DateTime.now(),
      );
      
      await _saveCart(updatedCart);
    } catch (e) {
      throw Exception('Failed to remove item from cart: $e');
    }
  }

  Future<void> updateCartItemQuantity(String productId, int quantity) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user');
    }

    try {
      final cart = await getCurrentUserCart();
      
      List<CartItem> updatedItems = List.from(cart.items);
      final itemIndex = updatedItems.indexWhere(
        (item) => item.product.id == productId,
      );
      
      if (itemIndex != -1) {
        if (quantity <= 0) {
          // Remove item if quantity is 0 or negative
          updatedItems.removeAt(itemIndex);
        } else {
          // Update quantity
          updatedItems[itemIndex] = updatedItems[itemIndex].copyWith(
            quantity: quantity,
          );
        }
        
        final updatedCart = cart.copyWith(
          items: updatedItems,
          updatedAt: DateTime.now(),
        );
        
        await _saveCart(updatedCart);
      }
    } catch (e) {
      throw Exception('Failed to update cart item quantity: $e');
    }
  }

  Future<void> clearCart() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user');
    }

    try {
      final cart = Cart.empty().copyWith(id: user.uid);
      await _saveCart(cart);
    } catch (e) {
      throw Exception('Failed to clear cart: $e');
    }
  }

  Future<void> _saveCart(Cart cart) async {
    try {
      final cartData = cart.toJson();
      cartData.remove('id'); // Remove ID since it's the document ID
      
      await _firestore
          .collection(_cartsCollection)
          .doc(cart.id)
          .set(cartData, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save cart: $e');
    }
  }

  // Order operations
  
  Future<String> createOrderFromCart({
    required PaymentMethod paymentMethod,
    String? notes,
    String? deliveryAddress,
    String? contactPhone,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user');
    }

    try {
      final cart = await getCurrentUserCart();
      
      if (cart.isEmpty) {
        throw Exception('Cart is empty');
      }
      
      final order = Order.fromCart(
        cart: cart,
        userId: user.uid,
        paymentMethod: paymentMethod,
        notes: notes,
        deliveryAddress: deliveryAddress,
        contactPhone: contactPhone,
      );
      
      final orderData = order.toJson();
      orderData.remove('id'); // Remove ID since Firestore will generate it
      
      final DocumentReference docRef = await _firestore
          .collection(_ordersCollection)
          .add(orderData);
      
      // Clear cart after successful order creation
      await clearCart();
      
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  Future<List<Order>> getUserOrders() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user');
    }

    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_ordersCollection)
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => Order.fromJson({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch orders: $e');
    }
  }

  Future<Order?> getOrderById(String orderId) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection(_ordersCollection)
          .doc(orderId)
          .get();
      
      if (doc.exists) {
        return Order.fromJson({
          ...doc.data() as Map<String, dynamic>,
          'id': doc.id,
        });
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch order: $e');
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      await _firestore
          .collection(_ordersCollection)
          .doc(orderId)
          .update({
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      await updateOrderStatus(orderId, OrderStatus.cancelled);
    } catch (e) {
      throw Exception('Failed to cancel order: $e');
    }
  }

  // Real-time streams
  
  Stream<Cart> currentUserCartStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value(Cart.empty());
    }
    
    return _firestore
        .collection(_cartsCollection)
        .doc(user.uid)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return Cart.fromJson({
          ...data,
          'id': doc.id,
        });
      } else {
        return Cart.empty().copyWith(id: user.uid);
      }
    });
  }

  Stream<List<Order>> currentUserOrdersStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }
    
    return _firestore
        .collection(_ordersCollection)
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Order.fromJson({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .toList());
  }

  // Cart item operations with optimistic updates
  
  Future<void> incrementItemQuantity(String productId) async {
    final cart = await getCurrentUserCart();
    final item = cart.items.firstWhere(
      (item) => item.product.id == productId,
      orElse: () => throw Exception('Item not found in cart'),
    );
    
    await updateCartItemQuantity(productId, item.quantity + 1);
  }

  Future<void> decrementItemQuantity(String productId) async {
    final cart = await getCurrentUserCart();
    final item = cart.items.firstWhere(
      (item) => item.product.id == productId,
      orElse: () => throw Exception('Item not found in cart'),
    );
    
    if (item.quantity <= 1) {
      await removeFromCart(productId);
    } else {
      await updateCartItemQuantity(productId, item.quantity - 1);
    }
  }
}

// Riverpod providers
final firebaseCartRepositoryProvider = Provider<FirebaseCartRepository>((ref) {
  return FirebaseCartRepository();
});

final currentUserCartProvider = FutureProvider<Cart>((ref) async {
  final repository = ref.watch(firebaseCartRepositoryProvider);
  return repository.getCurrentUserCart();
});

final currentUserCartStreamProvider = StreamProvider<Cart>((ref) {
  final repository = ref.watch(firebaseCartRepositoryProvider);
  return repository.currentUserCartStream();
});

final currentUserOrdersStreamProvider = StreamProvider<List<Order>>((ref) {
  final repository = ref.watch(firebaseCartRepositoryProvider);
  return repository.currentUserOrdersStream();
});

// StateProvider for managing cart operations
final cartOperationsProvider = StateNotifierProvider<CartOperationsNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(firebaseCartRepositoryProvider);
  return CartOperationsNotifier(repository, ref);
});

class CartOperationsNotifier extends StateNotifier<AsyncValue<void>> {
  final FirebaseCartRepository _repository;
  final Ref _ref;

  CartOperationsNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<void> addToCart(CartItem item) async {
    state = const AsyncValue.loading();
    try {
      await _repository.addToCart(item);
      state = const AsyncValue.data(null);
      // The stream provider will automatically update the UI
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
