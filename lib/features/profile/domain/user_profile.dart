class UserProfile {
  final String id;
  final String email;
  final String displayName;
  final String? phoneNumber;
  final String? photoURL;
  final List<Address> addresses;
  final List<String> favoriteProductIds;
  final UserPreferences preferences;
  final OrderStats orderStats;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    this.phoneNumber,
    this.photoURL,
    this.addresses = const [],
    this.favoriteProductIds = const [],
    this.preferences = const UserPreferences(),
    this.orderStats = const OrderStats(),
    this.createdAt,
    this.updatedAt,
  });

  UserProfile copyWith({
    String? id,
    String? email,
    String? displayName,
    String? phoneNumber,
    String? photoURL,
    List<Address>? addresses,
    List<String>? favoriteProductIds,
    UserPreferences? preferences,
    OrderStats? orderStats,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoURL: photoURL ?? this.photoURL,
      addresses: addresses ?? this.addresses,
      favoriteProductIds: favoriteProductIds ?? this.favoriteProductIds,
      preferences: preferences ?? this.preferences,
      orderStats: orderStats ?? this.orderStats,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class Address {
  final String id;
  final String title;
  final String fullName;
  final String street;
  final String city;
  final String postalCode;
  final String country;
  final String? phoneNumber;
  final bool isDefault;

  const Address({
    required this.id,
    required this.title,
    required this.fullName,
    required this.street,
    required this.city,
    required this.postalCode,
    required this.country,
    this.phoneNumber,
    this.isDefault = false,
  });
}

class UserPreferences {
  final String language;
  final bool notifications;
  final bool emailMarketing;
  final bool darkMode;
  final String currency;

  const UserPreferences({
    this.language = 'en',
    this.notifications = true,
    this.emailMarketing = true,
    this.darkMode = false,
    this.currency = 'TND',
  });
}

class OrderStats {
  final int totalOrders;
  final double totalSpent;
  final int completedOrders;
  final int pendingOrders;

  const OrderStats({
    this.totalOrders = 0,
    this.totalSpent = 0.0,
    this.completedOrders = 0,
    this.pendingOrders = 0,
  });
}
