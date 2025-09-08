import '../../products/domain/product.dart';

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
  refunded,
}

enum PaymentStatus {
  pending,
  paid,
  failed,
  refunded,
}

class Order {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final double subtotal;
  final double tax;
  final double shipping;
  final double total;
  final Address shippingAddress;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deliveredAt;
  final String? notes;
  final String? trackingNumber;

  const Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.status,
    required this.paymentStatus,
    required this.subtotal,
    required this.tax,
    required this.shipping,
    required this.total,
    required this.shippingAddress,
    required this.createdAt,
    this.updatedAt,
    this.deliveredAt,
    this.notes,
    this.trackingNumber,
  });
}

class OrderItem {
  final String id;
  final Product product;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  const OrderItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });
}

class Address {
  final String fullName;
  final String street;
  final String city;
  final String postalCode;
  final String country;
  final String? phoneNumber;

  const Address({
    required this.fullName,
    required this.street,
    required this.city,
    required this.postalCode,
    required this.country,
    this.phoneNumber,
  });
}
