import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'dart:typed_data';

import '../domain/user_profile.dart';
import '../domain/order.dart' as domain_order;

class FirebaseProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  static const String _usersCollection = 'users';
  static const String _ordersCollection = 'orders';

  // User Profile operations
  
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .get();
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return UserProfile.fromJson({
          ...data,
          'id': doc.id,
        });
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  Future<UserProfile> getCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user');
    }

    UserProfile? profile = await getUserProfile(user.uid);
    
    if (profile == null) {
      // Create default profile for new user
      profile = UserProfile(
        id: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? 'Anonymous User',
        phoneNumber: user.phoneNumber,
        photoURL: user.photoURL,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await updateUserProfile(profile);
    }
    
    return profile;
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    try {
      final profileData = profile.toJson();
      profileData.remove('id'); // Remove ID since it's the document ID
      
      await _firestore
          .collection(_usersCollection)
          .doc(profile.id)
          .set(profileData, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  Future<String> uploadProfilePhoto(String userId, String base64Image) async {
    try {
      // Extract base64 data
      final base64Data = base64Image.split(',')[1];
      final imageBytes = base64Decode(base64Data);
      
      // Create storage reference
      final storageRef = _storage
          .ref()
          .child('users')
          .child(userId)
          .child('profile.jpg');
      
      // Upload image
      final uploadTask = storageRef.putData(
        imageBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload profile photo: $e');
    }
  }

  Future<void> deleteProfilePhoto(String userId) async {
    try {
      final storageRef = _storage
          .ref()
          .child('users')
          .child(userId)
          .child('profile.jpg');
      
      await storageRef.delete();
    } catch (e) {
      // Don't throw error if file doesn't exist
      print('Failed to delete profile photo: $e');
    }
  }

  // Favorites operations
  
  Future<void> addToFavorites(String userId, String productId) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .update({
        'favoriteProductIds': FieldValue.arrayUnion([productId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add to favorites: $e');
    }
  }

  Future<void> removeFromFavorites(String userId, String productId) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .update({
        'favoriteProductIds': FieldValue.arrayRemove([productId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to remove from favorites: $e');
    }
  }

  Future<List<String>> getFavoriteProductIds(String userId) async {
    try {
      final profile = await getUserProfile(userId);
      return profile?.favoriteProductIds ?? [];
    } catch (e) {
      throw Exception('Failed to fetch favorites: $e');
    }
  }

  // Address operations
  
  Future<void> addAddress(String userId, Address address) async {
    try {
      final userRef = _firestore.collection(_usersCollection).doc(userId);
      
      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(userRef);
        
        List<Map<String, dynamic>> addresses = [];
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>?;
          addresses = List<Map<String, dynamic>>.from(
            data?['addresses']?.map((addr) => Map<String, dynamic>.from(addr)) ?? []
          );
        }
        
        // If this is set as default, make sure no other address is default
        if (address.isDefault) {
          for (var addr in addresses) {
            addr['isDefault'] = false;
          }
        }
        
        addresses.add(address.toJson());
        
        transaction.set(userRef, {
          'addresses': addresses,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      });
    } catch (e) {
      throw Exception('Failed to add address: $e');
    }
  }

  Future<void> updateAddress(String userId, Address address) async {
    try {
      final userRef = _firestore.collection(_usersCollection).doc(userId);
      
      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(userRef);
        
        if (!doc.exists) {
          throw Exception('User profile not found');
        }
        
        final data = doc.data() as Map<String, dynamic>;
        List<Map<String, dynamic>> addresses = List<Map<String, dynamic>>.from(
          data['addresses']?.map((addr) => Map<String, dynamic>.from(addr)) ?? []
        );
        
        // Find and update the address
        final index = addresses.indexWhere((addr) => addr['id'] == address.id);
        if (index == -1) {
          throw Exception('Address not found');
        }
        
        // If this is set as default, make sure no other address is default
        if (address.isDefault) {
          for (int i = 0; i < addresses.length; i++) {
            addresses[i]['isDefault'] = i == index;
          }
        }
        
        addresses[index] = address.toJson();
        
        transaction.update(userRef, {
          'addresses': addresses,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      throw Exception('Failed to update address: $e');
    }
  }

  Future<void> deleteAddress(String userId, String addressId) async {
    try {
      final userRef = _firestore.collection(_usersCollection).doc(userId);
      
      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(userRef);
        
        if (!doc.exists) {
          throw Exception('User profile not found');
        }
        
        final data = doc.data() as Map<String, dynamic>;
        List<Map<String, dynamic>> addresses = List<Map<String, dynamic>>.from(
          data['addresses']?.map((addr) => Map<String, dynamic>.from(addr)) ?? []
        );
        
        addresses.removeWhere((addr) => addr['id'] == addressId);
        
        transaction.update(userRef, {
          'addresses': addresses,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      throw Exception('Failed to delete address: $e');
    }
  }

  // Order operations
  
  Future<List<domain_order.Order>> getUserOrders(String userId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_ordersCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => domain_order.Order.fromJson({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch user orders: $e');
    }
  }

  Future<domain_order.Order?> getOrderById(String orderId) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection(_ordersCollection)
          .doc(orderId)
          .get();
      
      if (doc.exists) {
        return domain_order.Order.fromJson({
          ...doc.data() as Map<String, dynamic>,
          'id': doc.id,
        });
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch order: $e');
    }
  }

  Future<String> createOrder(domain_order.Order order) async {
    try {
      final orderData = order.toJson();
      orderData.remove('id'); // Remove ID since Firestore will generate it
      
      final DocumentReference docRef = await _firestore
          .collection(_ordersCollection)
          .add(orderData);
      
      // Update user order stats
      await _updateUserOrderStats(order.userId);
      
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  Future<void> updateOrderStatus(String orderId, domain_order.OrderStatus status) async {
    try {
      await _firestore
          .collection(_ordersCollection)
          .doc(orderId)
          .update({
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // If order is delivered, update delivered timestamp
      if (status == domain_order.OrderStatus.delivered) {
        await _firestore
            .collection(_ordersCollection)
            .doc(orderId)
            .update({
          'deliveredAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  Future<void> _updateUserOrderStats(String userId) async {
    try {
      final orders = await getUserOrders(userId);
      
      final totalOrders = orders.length;
      final totalSpent = orders.fold<double>(0.0, (sum, order) => sum + order.total);
      final completedOrders = orders
          .where((order) => order.status == domain_order.OrderStatus.delivered)
          .length;
      final pendingOrders = orders
          .where((order) => [
            domain_order.OrderStatus.pending,
            domain_order.OrderStatus.confirmed,
            domain_order.OrderStatus.preparing,
            domain_order.OrderStatus.ready,
          ].contains(order.status))
          .length;
      
      final orderStats = OrderStats(
        totalOrders: totalOrders,
        totalSpent: totalSpent,
        completedOrders: completedOrders,
        pendingOrders: pendingOrders,
      );
      
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .update({
        'orderStats': orderStats.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Failed to update user order stats: $e');
      // Don't throw error, as this is not critical
    }
  }

  // Preferences operations
  
  Future<void> updateUserPreferences(String userId, UserPreferences preferences) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .update({
        'preferences': preferences.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update user preferences: $e');
    }
  }

  // Real-time streams
  
  Stream<UserProfile?> userProfileStream(String userId) {
    return _firestore
        .collection(_usersCollection)
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return UserProfile.fromJson({
          ...doc.data() as Map<String, dynamic>,
          'id': doc.id,
        });
      }
      return null;
    });
  }

  Stream<List<domain_order.Order>> userOrdersStream(String userId) {
    return _firestore
        .collection(_ordersCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => domain_order.Order.fromJson({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .toList());
  }
}

// Riverpod providers
final firebaseProfileRepositoryProvider = Provider<FirebaseProfileRepository>((ref) {
  return FirebaseProfileRepository();
});

final currentUserProfileProvider = FutureProvider<UserProfile>((ref) async {
  final repository = ref.watch(firebaseProfileRepositoryProvider);
  return repository.getCurrentUserProfile();
});

final currentUserProfileStreamProvider = StreamProvider<UserProfile?>((ref) {
  final repository = ref.watch(firebaseProfileRepositoryProvider);
  final user = FirebaseAuth.instance.currentUser;
  
  if (user == null) {
    return Stream.value(null);
  }
  
  return repository.userProfileStream(user.uid);
});

final userOrdersStreamProvider = StreamProvider<List<domain_order.Order>>((ref) {
  final repository = ref.watch(firebaseProfileRepositoryProvider);
  final user = FirebaseAuth.instance.currentUser;
  
  if (user == null) {
    return Stream.value([]);
  }
  
  return repository.userOrdersStream(user.uid);
});
