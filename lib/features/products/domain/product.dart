import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'product.g.dart';

@JsonSerializable()
class Product extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final List<String> imageUrls;
  final String seller;
  final double rating;
  final int reviewCount;
  final bool inStock;
  final Map<String, dynamic>? attributes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrls,
    required this.seller,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.inStock = true,
    this.attributes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
  
  Map<String, dynamic> toJson() => _$ProductToJson(this);

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? category,
    List<String>? imageUrls,
    String? seller,
    double? rating,
    int? reviewCount,
    bool? inStock,
    Map<String, dynamic>? attributes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      imageUrls: imageUrls ?? this.imageUrls,
      seller: seller ?? this.seller,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      inStock: inStock ?? this.inStock,
      attributes: attributes ?? this.attributes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        category,
        imageUrls,
        seller,
        rating,
        reviewCount,
        inStock,
        attributes,
        createdAt,
        updatedAt,
      ];
}

@JsonSerializable()
class ProductCategory extends Equatable {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final String imageUrl;
  final int productCount;

  const ProductCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.imageUrl,
    this.productCount = 0,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) => 
      _$ProductCategoryFromJson(json);
  
  Map<String, dynamic> toJson() => _$ProductCategoryToJson(this);

  @override
  List<Object?> get props => [id, name, description, iconUrl, imageUrl, productCount];
}
