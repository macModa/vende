import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../../../../core/theme/app_theme.dart';
import '../../domain/product.dart';
import '../../data/product_repository.dart';
import '../../../auth/presentation/providers/mock_auth_providers.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _sellerController = TextEditingController();

  String _selectedCategory = 'textiles';
  List<String> _imageUrls = [];
  List<File> _localImages = [];
  bool _inStock = true;
  final ImagePicker _picker = ImagePicker();
  
  // Store base64 encoded images for persistence
  List<String> _base64Images = [];

  final Map<String, String> _categories = {
    'textiles': 'Textiles & Fabrics 🧵',
    'pottery': 'Pottery & Ceramics 🏺',
    'jewelry': 'Jewelry & Accessories 💎',
    'food': 'Traditional Food 🌶️',
    'leather': 'Leather Goods 👜',
    'art': 'Art & Crafts 🎨',
  };

  @override
  void initState() {
    super.initState();
    // Initialize seller name with current user
    final authState = ref.read(authStateProvider);
    if (authState.hasValue && authState.value != null) {
      _sellerController.text = authState.value!.displayName ?? 'Anonymous Seller';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _sellerController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        await _processImage(File(image.path));
      }
    } catch (e) {
      _showErrorSnackBar('Error picking image: $e');
    }
  }

  Future<void> _takePicture() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        await _processImage(File(image.path));
      }
    } catch (e) {
      _showErrorSnackBar('Error taking picture: $e');
    }
  }

  Future<void> _processImage(File imageFile) async {
    try {
      // Read the image file as bytes
      final bytes = await imageFile.readAsBytes();
      
      // Convert to base64 for storage
      final base64String = base64Encode(bytes);
      
      // Generate a unique ID for this image
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final imageId = 'local_${timestamp}_${_imageUrls.length}';
      
      setState(() {
        _localImages.add(imageFile);
        _base64Images.add(base64String);
        _imageUrls.add('data:image/jpeg;base64,$base64String');
      });
    } catch (e) {
      _showErrorSnackBar('Error processing image: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      if (index < _localImages.length) {
        _localImages.removeAt(index);
      }
      if (index < _base64Images.length) {
        _base64Images.removeAt(index);
      }
      if (index < _imageUrls.length) {
        _imageUrls.removeAt(index);
      }
    });
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Add Product Image',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ImagePickerOption(
                      icon: PhosphorIcons.camera(),
                      label: 'Camera',
                      onTap: () {
                        Navigator.pop(context);
                        _takePicture();
                      },
                    ),
                    _ImagePickerOption(
                      icon: PhosphorIcons.image(),
                      label: 'Gallery',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_imageUrls.isEmpty) {
      _showErrorSnackBar('Please add at least one product image');
      return;
    }

    try {
      final product = Product(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        category: _selectedCategory,
        imageUrls: _imageUrls,
        seller: _sellerController.text.trim(),
        rating: 0.0,
        reviewCount: 0,
        inStock: _inStock,
        attributes: {
          'isUserCreated': true,
          'createdBy': ref.read(authStateProvider).value?.uid ?? 'anonymous',
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await ref.read(productOperationsProvider.notifier).addProduct(product);

      _showSuccessSnackBar('Product added successfully!');
      
      // Clear form
      _nameController.clear();
      _descriptionController.clear();
      _priceController.clear();
      setState(() {
        _selectedCategory = 'textiles';
        _imageUrls.clear();
        _localImages.clear();
        _base64Images.clear();
        _inStock = true;
      });

      // Navigate back or to product list
      context.go('/');

    } catch (e) {
      _showErrorSnackBar('Error adding product: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final productOperations = ref.watch(productOperationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
        leading: IconButton(
          icon: Icon(PhosphorIcons.arrowLeft()),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Product Images Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(PhosphorIcons.image(), color: AppColors.primary),
                        const SizedBox(width: 8),
                        const Text(
                          'Product Images',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 120,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          // Add Image Button
                          GestureDetector(
                            onTap: _showImagePickerOptions,
                            child: Container(
                              width: 100,
                              height: 100,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.primary.withOpacity(0.3),
                                  width: 2,
                                  style: BorderStyle.solid,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    PhosphorIcons.plus(),
                                    color: AppColors.primary,
                                    size: 24,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Add Image',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Display selected images
                          ...List.generate(_localImages.length, (index) {
                            return Container(
                              width: 100,
                              height: 100,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(
                                  image: FileImage(_localImages[index]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () => _removeImage(index),
                                      child: Container(
                                        width: 24,
                                        height: 24,
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          PhosphorIcons.x(),
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Product Details Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(PhosphorIcons.info(), color: AppColors.primary),
                        const SizedBox(width: 8),
                        const Text(
                          'Product Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Product Name
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Product Name *',
                        hintText: 'Enter product name',
                        prefixIcon: Icon(PhosphorIcons.tag()),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Product name is required';
                        }
                        if (value.trim().length < 3) {
                          return 'Product name must be at least 3 characters';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Product Description
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Description *',
                        hintText: 'Enter product description',
                        prefixIcon: Icon(PhosphorIcons.notepad()),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Product description is required';
                        }
                        if (value.trim().length < 10) {
                          return 'Description must be at least 10 characters';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Price and Category Row
                    Row(
                      children: [
                        // Price Field
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _priceController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                            ],
                            decoration: InputDecoration(
                              labelText: 'Price (TND) *',
                              hintText: '0.00',
                              prefixIcon: Icon(PhosphorIcons.currencyDollar()),
                              border: const OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Price is required';
                              }
                              final price = double.tryParse(value.trim());
                              if (price == null || price <= 0) {
                                return 'Enter a valid price';
                              }
                              return null;
                            },
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Category Dropdown
                        Expanded(
                          flex: 3,
                          child: DropdownButtonFormField<String>(
                            value: _selectedCategory,
                            decoration: InputDecoration(
                              labelText: 'Category *',
                              prefixIcon: Icon(PhosphorIcons.gridFour()),
                              border: const OutlineInputBorder(),
                            ),
                            items: _categories.entries
                                .map((entry) => DropdownMenuItem(
                                      value: entry.key,
                                      child: Text(entry.value),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedCategory = value;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Seller Name
                    TextFormField(
                      controller: _sellerController,
                      decoration: InputDecoration(
                        labelText: 'Seller Name *',
                        hintText: 'Enter seller name',
                        prefixIcon: Icon(PhosphorIcons.user()),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Seller name is required';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // In Stock Switch
                    Row(
                      children: [
                        Icon(PhosphorIcons.package(), color: AppColors.primary),
                        const SizedBox(width: 8),
                        const Text('In Stock'),
                        const Spacer(),
                        Switch(
                          value: _inStock,
                          onChanged: (value) {
                            setState(() {
                              _inStock = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: productOperations.isLoading ? null : _submitForm,
                child: productOperations.isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Add Product'),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _ImagePickerOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ImagePickerOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
