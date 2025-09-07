import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../products/domain/product.dart';

part 'cart_models.g.dart';

@JsonSerializable()
class CartItem extends Equatable {
  final String id;
  final Product product;
  final int quantity;
  final double unitPrice;
  final DateTime addedAt;

  const CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.unitPrice,
    required this.addedAt,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) => _$CartItemFromJson(json);
  Map<String, dynamic> toJson() => _$CartItemToJson(this);

  double get totalPrice => unitPrice * quantity;

  CartItem copyWith({
    String? id,
    Product? product,
    int? quantity,
    double? unitPrice,
    DateTime? addedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  List<Object?> get props => [id, product, quantity, unitPrice, addedAt];
}

@JsonSerializable()
class Cart extends Equatable {
  final String id;
  final List<CartItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Cart({
    required this.id,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Cart.fromJson(Map<String, dynamic> json) => _$CartFromJson(json);
  Map<String, dynamic> toJson() => _$CartToJson(this);

  factory Cart.empty() {
    final now = DateTime.now();
    return Cart(
      id: now.millisecondsSinceEpoch.toString(),
      items: [],
      createdAt: now,
      updatedAt: now,
    );
  }

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.totalPrice);
  
  double get tax => subtotal * 0.1; // 10% tax
  
  double get shipping => subtotal > 100 ? 0.0 : 10.0; // Free shipping over 100 TND
  
  double get total => subtotal + tax + shipping;
  
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
  
  bool get isEmpty => items.isEmpty;

  Cart copyWith({
    String? id,
    List<CartItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Cart(
      id: id ?? this.id,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, items, createdAt, updatedAt];
}

enum PaymentMethod {
  handToHand,
  creditCard,
  paypal,
  bankTransfer,
}

extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.handToHand:
        return 'Hand-to-Hand (Cash on Delivery)';
      case PaymentMethod.creditCard:
        return 'Credit Card';
      case PaymentMethod.paypal:
        return 'PayPal';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
    }
  }

  String get description {
    switch (this) {
      case PaymentMethod.handToHand:
        return 'Pay cash when you meet the seller in person';
      case PaymentMethod.creditCard:
        return 'Pay securely with your credit or debit card';
      case PaymentMethod.paypal:
        return 'Pay using your PayPal account';
      case PaymentMethod.bankTransfer:
        return 'Transfer money directly to seller\'s bank account';
    }
  }

  String get iconPath {
    switch (this) {
      case PaymentMethod.handToHand:
        return 'handshake';
      case PaymentMethod.creditCard:
        return 'credit_card';
      case PaymentMethod.paypal:
        return 'paypal';
      case PaymentMethod.bankTransfer:
        return 'bank';
    }
  }
}

@JsonSerializable()
class Order extends Equatable {
  final String id;
  final String userId;
  final List<CartItem> items;
  final double subtotal;
  final double tax;
  final double shipping;
  final double total;
  final PaymentMethod paymentMethod;
  final OrderStatus status;
  final String? notes;
  final String? deliveryAddress;
  final String? contactPhone;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.shipping,
    required this.total,
    required this.paymentMethod,
    required this.status,
    this.notes,
    this.deliveryAddress,
    this.contactPhone,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
  Map<String, dynamic> toJson() => _$OrderToJson(this);

  factory Order.fromCart({
    required Cart cart,
    required String userId,
    required PaymentMethod paymentMethod,
    String? notes,
    String? deliveryAddress,
    String? contactPhone,
  }) {
    final now = DateTime.now();
    return Order(
      id: now.millisecondsSinceEpoch.toString(),
      userId: userId,
      items: cart.items,
      subtotal: cart.subtotal,
      tax: cart.tax,
      shipping: cart.shipping,
      total: cart.total,
      paymentMethod: paymentMethod,
      status: OrderStatus.pending,
      notes: notes,
      deliveryAddress: deliveryAddress,
      contactPhone: contactPhone,
      createdAt: now,
      updatedAt: now,
    );
  }

  Order copyWith({
    String? id,
    String? userId,
    List<CartItem>? items,
    double? subtotal,
    double? tax,
    double? shipping,
    double? total,
    PaymentMethod? paymentMethod,
    OrderStatus? status,
    String? notes,
    String? deliveryAddress,
    String? contactPhone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      shipping: shipping ?? this.shipping,
      total: total ?? this.total,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      contactPhone: contactPhone ?? this.contactPhone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        items,
        subtotal,
        tax,
        shipping,
        total,
        paymentMethod,
        status,
        notes,
        deliveryAddress,
        contactPhone,
        createdAt,
        updatedAt,
      ];
}

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  ready,
  delivered,
  cancelled,
}

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready for Pickup';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get description {
    switch (this) {
      case OrderStatus.pending:
        return 'Waiting for seller confirmation';
      case OrderStatus.confirmed:
        return 'Order confirmed by seller';
      case OrderStatus.preparing:
        return 'Seller is preparing your order';
      case OrderStatus.ready:
        return 'Order is ready for pickup/delivery';
      case OrderStatus.delivered:
        return 'Order has been delivered';
      case OrderStatus.cancelled:
        return 'Order was cancelled';
    }
  }
}
