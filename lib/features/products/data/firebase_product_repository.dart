import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/product.dart';

class FirebaseProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  static const String _productsCollection = 'products';
  static const String _categoriesCollection = 'categories';
  static const String _featuredCollection = 'featured_products';

  // CRUD Operations for Products
  
  Future<List<Product>> getProducts() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_productsCollection)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => Product.fromJson({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  Future<Product?> getProductById(String productId) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection(_productsCollection)
          .doc(productId)
          .get();
      
      if (doc.exists) {
        return Product.fromJson({
          ...doc.data() as Map<String, dynamic>,
          'id': doc.id,
        });
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch product: $e');
    }
  }

  Future<List<Product>> getProductsByCategory(String categoryId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_productsCollection)
          .where('category', isEqualTo: categoryId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => Product.fromJson({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch products by category: $e');
    }
  }

  Future<List<Product>> searchProducts(String query) async {
    try {
      final searchTerm = query.toLowerCase();
      
      // Firestore doesn't support full-text search, so we'll use array-contains for now
      // For production, consider using Algolia or similar search service
      final QuerySnapshot snapshot = await _firestore
          .collection(_productsCollection)
          .get();
      
      return snapshot.docs
          .map((doc) => Product.fromJson({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .where((product) =>
              product.name.toLowerCase().contains(searchTerm) ||
              product.description.toLowerCase().contains(searchTerm) ||
              product.category.toLowerCase().contains(searchTerm) ||
              product.seller.toLowerCase().contains(searchTerm))
          .toList();
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }

  Future<List<Product>> getFeaturedProducts() async {
    try {
      // Get featured product IDs
      final DocumentSnapshot featuredDoc = await _firestore
          .collection(_featuredCollection)
          .doc('list')
          .get();
      
      List<String> featuredIds = [];
      if (featuredDoc.exists) {
        final data = featuredDoc.data() as Map<String, dynamic>?;
        featuredIds = List<String>.from(data?['productIds'] ?? []);
      }

      if (featuredIds.isEmpty) {
        // Return latest products if no featured products configured
        return getLatestProducts(limit: 10);
      }

      // Get featured products
      final List<Product> featuredProducts = [];
      for (String productId in featuredIds) {
        final product = await getProductById(productId);
        if (product != null) {
          featuredProducts.add(product);
        }
      }

      return featuredProducts;
    } catch (e) {
      throw Exception('Failed to fetch featured products: $e');
    }
  }

  Future<List<Product>> getLatestProducts({int limit = 10}) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_productsCollection)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      
      return snapshot.docs
          .map((doc) => Product.fromJson({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch latest products: $e');
    }
  }

  Future<List<Product>> getProductsBySeller(String sellerId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_productsCollection)
          .where('seller', isEqualTo: sellerId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => Product.fromJson({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch products by seller: $e');
    }
  }

  Future<String> addProduct(Product product) async {
    try {
      // Handle image upload if product has base64 images
      final updatedImageUrls = await _uploadProductImages(product.imageUrls, product.id);
      
      // Create product with updated image URLs
      final productData = product.copyWith(
        imageUrls: updatedImageUrls,
        updatedAt: DateTime.now(),
      ).toJson();
      
      // Remove the ID from data since Firestore will generate it
      productData.remove('id');
      
      final DocumentReference docRef = await _firestore
          .collection(_productsCollection)
          .add(productData);
      
      // Add to featured products if it's user-created
      if (product.attributes?['isUserCreated'] == true) {
        await _addToFeaturedProducts(docRef.id);
      }
      
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add product: $e');
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      // Handle image upload if product has base64 images
      final updatedImageUrls = await _uploadProductImages(product.imageUrls, product.id);
      
      final productData = product.copyWith(
        imageUrls: updatedImageUrls,
        updatedAt: DateTime.now(),
      ).toJson();
      
      // Remove the ID from data since it's the document ID
      productData.remove('id');
      
      await _firestore
          .collection(_productsCollection)
          .doc(product.id)
          .update(productData);
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      // Delete product images from storage
      await _deleteProductImages(productId);
      
      // Remove from featured products
      await _removeFromFeaturedProducts(productId);
      
      // Delete product document
      await _firestore
          .collection(_productsCollection)
          .doc(productId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  // Categories operations
  
  Future<List<ProductCategory>> getCategories() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_categoriesCollection)
          .orderBy('name')
          .get();
      
      return snapshot.docs
          .map((doc) => ProductCategory.fromJson({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      // Return default categories if none exist in Firestore
      return _getDefaultCategories();
    }
  }

  // Private helper methods

  Future<List<String>> _uploadProductImages(List<String> imageUrls, String productId) async {
    final List<String> uploadedUrls = [];
    
    for (int i = 0; i < imageUrls.length; i++) {
      final imageUrl = imageUrls[i];
      
      if (imageUrl.startsWith('data:image/')) {
        // This is a base64 image, upload to Firebase Storage
        try {
          final uploadedUrl = await _uploadBase64Image(imageUrl, productId, i);
          uploadedUrls.add(uploadedUrl);
        } catch (e) {
          print('Failed to upload image $i for product $productId: $e');
          // Keep original base64 URL as fallback
          uploadedUrls.add(imageUrl);
        }
      } else {
        // This is already a URL (from Firebase Storage or external)
        uploadedUrls.add(imageUrl);
      }
    }
    
    return uploadedUrls;
  }

  Future<String> _uploadBase64Image(String base64Image, String productId, int index) async {
    try {
      // Extract base64 data
      final base64Data = base64Image.split(',')[1];
      final imageBytes = base64Decode(base64Data);
      
      // Create storage reference
      final storageRef = _storage
          .ref()
          .child('products')
          .child(productId)
          .child('image_$index.jpg');
      
      // Upload image
      final uploadTask = storageRef.putData(
        imageBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> _deleteProductImages(String productId) async {
    try {
      final storageRef = _storage.ref().child('products').child(productId);
      final listResult = await storageRef.listAll();
      
      for (final item in listResult.items) {
        await item.delete();
      }
    } catch (e) {
      print('Failed to delete product images: $e');
      // Don't throw error, as the product deletion should still proceed
    }
  }

  Future<void> _addToFeaturedProducts(String productId) async {
    try {
      final featuredRef = _firestore.collection(_featuredCollection).doc('list');
      
      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(featuredRef);
        
        List<String> productIds = [];
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>?;
          productIds = List<String>.from(data?['productIds'] ?? []);
        }
        
        if (!productIds.contains(productId)) {
          productIds.insert(0, productId); // Add to beginning
          transaction.set(featuredRef, {
            'productIds': productIds,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      print('Failed to add to featured products: $e');
    }
  }

  Future<void> _removeFromFeaturedProducts(String productId) async {
    try {
      final featuredRef = _firestore.collection(_featuredCollection).doc('list');
      
      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(featuredRef);
        
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>?;
          List<String> productIds = List<String>.from(data?['productIds'] ?? []);
          
          if (productIds.contains(productId)) {
            productIds.remove(productId);
            transaction.update(featuredRef, {
              'productIds': productIds,
              'updatedAt': FieldValue.serverTimestamp(),
            });
          }
        }
      });
    } catch (e) {
      print('Failed to remove from featured products: $e');
    }
  }

  List<ProductCategory> _getDefaultCategories() {
    return [
      ProductCategory(
        id: 'textiles',
        name: 'Textiles & Fabrics 🧵',
        description: 'Traditional Tunisian textiles and handwoven fabrics',
        iconUrl: 'https://via.placeholder.com/40x40?text=🧵',
        imageUrl: 'https://via.placeholder.com/200x150?text=Textiles',
        productCount: 0,
      ),
      ProductCategory(
        id: 'pottery',
        name: 'Pottery & Ceramics 🏺',
        description: 'Handcrafted pottery and ceramic pieces',
        iconUrl: 'https://via.placeholder.com/40x40?text=🏺',
        imageUrl: 'https://via.placeholder.com/200x150?text=Pottery',
        productCount: 0,
      ),
      ProductCategory(
        id: 'jewelry',
        name: 'Jewelry & Accessories 💎',
        description: 'Traditional and modern jewelry pieces',
        iconUrl: 'https://via.placeholder.com/40x40?text=💎',
        imageUrl: 'https://via.placeholder.com/200x150?text=Jewelry',
        productCount: 0,
      ),
      ProductCategory(
        id: 'food',
        name: 'Traditional Food 🌶️',
        description: 'Spices, preserved foods, and local delicacies',
        iconUrl: 'https://via.placeholder.com/40x40?text=🌶️',
        imageUrl: 'https://via.placeholder.com/200x150?text=Food',
        productCount: 0,
      ),
      ProductCategory(
        id: 'leather',
        name: 'Leather Goods 👜',
        description: 'Quality leather products and accessories',
        iconUrl: 'https://via.placeholder.com/40x40?text=👜',
        imageUrl: 'https://via.placeholder.com/200x150?text=Leather',
        productCount: 0,
      ),
      ProductCategory(
        id: 'art',
        name: 'Art & Crafts 🎨',
        description: 'Local art, paintings, and handmade crafts',
        iconUrl: 'https://via.placeholder.com/40x40?text=🎨',
        imageUrl: 'https://via.placeholder.com/200x150?text=Art',
        productCount: 0,
      ),
    ];
  }

  // Real-time streams for live data updates
  
  Stream<List<Product>> productsStream() {
    return _firestore
        .collection(_productsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromJson({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .toList());
  }

  Stream<List<Product>> featuredProductsStream() {
    return _firestore
        .collection(_featuredCollection)
        .doc('list')
        .snapshots()
        .asyncMap((doc) async {
      if (!doc.exists) return <Product>[];
      
      final data = doc.data() as Map<String, dynamic>?;
      final productIds = List<String>.from(data?['productIds'] ?? []);
      
      final List<Product> products = [];
      for (String productId in productIds) {
        final product = await getProductById(productId);
        if (product != null) {
          products.add(product);
        }
      }
      
      return products;
    });
  }
}

// Riverpod providers for Firebase repository
final firebaseProductRepositoryProvider = Provider<FirebaseProductRepository>((ref) {
  return FirebaseProductRepository();
});

// Stream providers for real-time data
final productsStreamProvider = StreamProvider<List<Product>>((ref) {
  final repository = ref.watch(firebaseProductRepositoryProvider);
  return repository.productsStream();
});

final featuredProductsStreamProvider = StreamProvider<List<Product>>((ref) {
  final repository = ref.watch(firebaseProductRepositoryProvider);
  return repository.featuredProductsStream();
});
