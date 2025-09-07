import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/user_profile.dart' as profile_models;
import '../domain/order.dart' as order_models;

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

final userProfileProvider = FutureProvider.family<profile_models.UserProfile?, String>((ref, userId) async {
  final repository = ref.read(profileRepositoryProvider);
  return repository.getUserProfile(userId);
});

final userOrdersProvider = FutureProvider.family<List<order_models.Order>, String>((ref, userId) async {
  final repository = ref.read(profileRepositoryProvider);
  return repository.getUserOrders(userId);
});

final favoriteProductsProvider = FutureProvider.family<List<String>, String>((ref, userId) async {
  final repository = ref.read(profileRepositoryProvider);
  final profile = await repository.getUserProfile(userId);
  return profile?.favoriteProductIds ?? [];
});

class ProfileRepository {
  // Mock user profile data
  static const String _mockUserId = 'user_123';
  
  static final profile_models.UserProfile _mockProfile = profile_models.UserProfile(
    id: _mockUserId,
    email: 'user@example.com',
    displayName: 'Ahmed Ben Ali',
    phoneNumber: '+216 20 123 456',
    addresses: [
      profile_models.Address(
        id: 'addr_1',
        title: 'Home',
        fullName: 'Ahmed Ben Ali',
        street: '15 Avenue Habib Bourguiba',
        city: 'Tunis',
        postalCode: '1001',
        country: 'Tunisia',
        phoneNumber: '+216 20 123 456',
        isDefault: true,
      ),
      profile_models.Address(
        id: 'addr_2',
        title: 'Work',
        fullName: 'Ahmed Ben Ali',
        street: '32 Rue de la Liberté',
        city: 'Sfax',
        postalCode: '3000',
        country: 'Tunisia',
        phoneNumber: '+216 20 123 456',
      ),
    ],
    favoriteProductIds: ['prod_1', 'prod_3', 'prod_5'],
    preferences: profile_models.UserPreferences(
      language: 'en',
      notifications: true,
      emailMarketing: false,
      currency: 'TND',
    ),
    orderStats: profile_models.OrderStats(
      totalOrders: 12,
      totalSpent: 890.50,
      completedOrders: 10,
      pendingOrders: 2,
    ),
    createdAt: DateTime.now().subtract(const Duration(days: 180)),
    updatedAt: DateTime.now(),
  );

  static final List<order_models.Order> _mockOrders = [
    order_models.Order(
      id: 'ord_001',
      userId: _mockUserId,
      items: [
        // Mock order items would be populated with actual products
      ],
      status: order_models.OrderStatus.delivered,
      paymentStatus: order_models.PaymentStatus.paid,
      subtotal: 85.00,
      tax: 8.50,
      shipping: 0.00,
      total: 93.50,
      shippingAddress: order_models.Address(
        fullName: 'Ahmed Ben Ali',
        street: '15 Avenue Habib Bourguiba',
        city: 'Tunis',
        postalCode: '1001',
        country: 'Tunisia',
        phoneNumber: '+216 20 123 456',
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      deliveredAt: DateTime.now().subtract(const Duration(days: 2)),
      trackingNumber: 'TN123456789',
    ),
    order_models.Order(
      id: 'ord_002',
      userId: _mockUserId,
      items: [],
      status: order_models.OrderStatus.processing,
      paymentStatus: order_models.PaymentStatus.paid,
      subtotal: 120.00,
      tax: 12.00,
      shipping: 5.00,
      total: 137.00,
      shippingAddress: order_models.Address(
        fullName: 'Ahmed Ben Ali',
        street: '15 Avenue Habib Bourguiba',
        city: 'Tunis',
        postalCode: '1001',
        country: 'Tunisia',
        phoneNumber: '+216 20 123 456',
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      trackingNumber: 'TN987654321',
    ),
  ];

  Future<profile_models.UserProfile?> getUserProfile(String userId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (userId == _mockUserId) {
      return _mockProfile;
    }
    return null;
  }

  Future<List<order_models.Order>> getUserOrders(String userId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    return _mockOrders.where((order) => order.userId == userId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<profile_models.UserProfile> updateProfile(profile_models.UserProfile profile) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // In a real app, this would update the profile on the server
    return profile.copyWith(updatedAt: DateTime.now());
  }

  Future<void> addAddress(String userId, profile_models.Address address) async {
    await Future.delayed(const Duration(milliseconds: 800));
    // In a real app, this would add the address to the user's profile
  }

  Future<void> updateAddress(String userId, profile_models.Address address) async {
    await Future.delayed(const Duration(milliseconds: 800));
    // In a real app, this would update the address
  }

  Future<void> deleteAddress(String userId, String addressId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // In a real app, this would delete the address
  }

  Future<void> addToFavorites(String userId, String productId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // In a real app, this would add the product to favorites
  }

  Future<void> removeFromFavorites(String userId, String productId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // In a real app, this would remove the product from favorites
  }

  Future<void> updatePreferences(String userId, profile_models.UserPreferences preferences) async {
    await Future.delayed(const Duration(milliseconds: 600));
    // In a real app, this would update user preferences
  }
}
