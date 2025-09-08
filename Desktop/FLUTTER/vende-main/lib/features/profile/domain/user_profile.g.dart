// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      photoURL: json['photoURL'] as String?,
      addresses: (json['addresses'] as List<dynamic>?)
              ?.map((e) => Address.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      favoriteProductIds: (json['favoriteProductIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      preferences: json['preferences'] == null
          ? const UserPreferences()
          : UserPreferences.fromJson(
              json['preferences'] as Map<String, dynamic>),
      orderStats: json['orderStats'] == null
          ? const OrderStats()
          : OrderStats.fromJson(json['orderStats'] as Map<String, dynamic>),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$UserProfileToJson(UserProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'displayName': instance.displayName,
      'phoneNumber': instance.phoneNumber,
      'photoURL': instance.photoURL,
      'addresses': instance.addresses,
      'favoriteProductIds': instance.favoriteProductIds,
      'preferences': instance.preferences,
      'orderStats': instance.orderStats,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

Address _$AddressFromJson(Map<String, dynamic> json) => Address(
      id: json['id'] as String,
      title: json['title'] as String,
      fullName: json['fullName'] as String,
      street: json['street'] as String,
      city: json['city'] as String,
      postalCode: json['postalCode'] as String,
      country: json['country'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      isDefault: json['isDefault'] as bool? ?? false,
    );

Map<String, dynamic> _$AddressToJson(Address instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'fullName': instance.fullName,
      'street': instance.street,
      'city': instance.city,
      'postalCode': instance.postalCode,
      'country': instance.country,
      'phoneNumber': instance.phoneNumber,
      'isDefault': instance.isDefault,
    };

UserPreferences _$UserPreferencesFromJson(Map<String, dynamic> json) =>
    UserPreferences(
      language: json['language'] as String? ?? 'en',
      notifications: json['notifications'] as bool? ?? true,
      emailMarketing: json['emailMarketing'] as bool? ?? true,
      darkMode: json['darkMode'] as bool? ?? false,
      currency: json['currency'] as String? ?? 'TND',
    );

Map<String, dynamic> _$UserPreferencesToJson(UserPreferences instance) =>
    <String, dynamic>{
      'language': instance.language,
      'notifications': instance.notifications,
      'emailMarketing': instance.emailMarketing,
      'darkMode': instance.darkMode,
      'currency': instance.currency,
    };

OrderStats _$OrderStatsFromJson(Map<String, dynamic> json) => OrderStats(
      totalOrders: (json['totalOrders'] as num?)?.toInt() ?? 0,
      totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0.0,
      completedOrders: (json['completedOrders'] as num?)?.toInt() ?? 0,
      pendingOrders: (json['pendingOrders'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$OrderStatsToJson(OrderStats instance) =>
    <String, dynamic>{
      'totalOrders': instance.totalOrders,
      'totalSpent': instance.totalSpent,
      'completedOrders': instance.completedOrders,
      'pendingOrders': instance.pendingOrders,
    };
