import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/cart_repository.dart';
import '../../domain/cart_models.dart';
import '../../../products/domain/product.dart';
import '../../../auth/presentation/providers/mock_auth_providers.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final cartTotals = ref.watch(cartTotalsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping Cart (${cart.totalItems})'),
        actions: [
          if (cart.items.isNotEmpty)
            IconButton(
              icon: Icon(PhosphorIcons.trash()),
              onPressed: () => _showClearCartDialog(context, ref),
            ),
        ],
      ),
      body: cart.isEmpty ? _buildEmptyCart(context) : _buildCartContent(context, ref, cart, cartTotals),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PhosphorIcons.shoppingCart(),
            size: 64,
            color: AppColors.textLight,
          ),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some products to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/'),
            child: const Text('Continue Shopping'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent(BuildContext context, WidgetRef ref, Cart cart, Map<String, double> totals) {
    return Column(
      children: [
        // Cart Items
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cart.items.length,
            itemBuilder: (context, index) {
              final item = cart.items[index];
              return _buildCartItem(context, ref, item);
            },
          ),
        ),
        // Cart Summary
        _buildCartSummary(context, ref, totals),
      ],
    );
  }

  Widget _buildCartItem(BuildContext context, WidgetRef ref, CartItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildProductImage(item.product),
            ),
            
            const SizedBox(width: 12),
            
            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'by ${item.product.seller}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${item.unitPrice.toStringAsFixed(2)} TND',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Total: ${item.totalPrice.toStringAsFixed(2)} TND',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Quantity Controls
            Column(
              children: [
                // Quantity Controls
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: IconButton(
                            onPressed: () {
                              if (item.quantity > 1) {
                                ref.read(cartProvider.notifier).updateItemQuantity(item.id, item.quantity - 1);
                              } else {
                                ref.read(cartProvider.notifier).removeFromCart(item.id);
                              }
                            },
                            icon: Icon(
                              item.quantity > 1 ? PhosphorIcons.minus() : PhosphorIcons.trash(),
                              size: 16,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                        Container(
                          width: 30,
                          alignment: Alignment.center,
                          child: Text(
                            '${item.quantity}',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: IconButton(
                            onPressed: () {
                              ref.read(cartProvider.notifier).updateItemQuantity(item.id, item.quantity + 1);
                            },
                            icon: Icon(PhosphorIcons.plus(), size: 16),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartSummary(BuildContext context, WidgetRef ref, Map<String, double> totals) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Price Breakdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text('Subtotal:', style: Theme.of(context).textTheme.bodyMedium),
              ),
              Text('${totals['subtotal']!.toStringAsFixed(2)} TND', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text('Tax (10%):', style: Theme.of(context).textTheme.bodyMedium),
              ),
              Text('${totals['tax']!.toStringAsFixed(2)} TND', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text('Shipping:', style: Theme.of(context).textTheme.bodyMedium),
              ),
              Flexible(
                child: Text(
                  totals['shipping']! > 0 ? '${totals['shipping']!.toStringAsFixed(2)} TND' : 'FREE',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: totals['shipping']! > 0 ? null : Colors.green,
                  ),
                ),
              ),
            ],
          ),
          if (totals['shipping']! == 0.0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '🎉 Free shipping on orders over 100 TND',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.green,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Total:',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${totals['total']!.toStringAsFixed(2)} TND',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _showCheckoutModal(context, ref),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Proceed to Checkout'),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear Cart'),
          content: const Text('Are you sure you want to remove all items from your cart?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                ref.read(cartProvider.notifier).clearCart();
                Navigator.of(context).pop();
              },
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }

  void _showCheckoutModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CheckoutModal(),
    );
  }

  Widget _buildProductImage(Product product) {
    if (product.imageUrls.isEmpty) {
      return _buildPlaceholderImage();
    }

    final imageUrl = product.imageUrls.first;
    
    // Handle base64 data URLs (for locally added images)
    if (imageUrl.startsWith('data:image')) {
      try {
        final base64String = imageUrl.split(',')[1];
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
        );
      } catch (e) {
        return _buildPlaceholderImage();
      }
    }
    
    // Handle local file images (legacy support)
    if (imageUrl.startsWith('file://')) {
      final filePath = imageUrl.replaceFirst('file://', '').split('?').first;
      final file = File(filePath);
      
      if (file.existsSync()) {
        return Image.file(
          file,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
        );
      }
    }
    
    // Handle network images
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: 80,
      height: 80,
      fit: BoxFit.cover,
      placeholder: (context, url) => _buildLoadingImage(),
      errorWidget: (context, url, error) => _buildPlaceholderImage(),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 80,
      height: 80,
      color: AppColors.surface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PhosphorIcons.image(),
            color: AppColors.textLight,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            'No Image',
            style: TextStyle(
              color: AppColors.textLight,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingImage() {
    return Container(
      width: 80,
      height: 80,
      color: AppColors.surface,
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class CheckoutModal extends ConsumerStatefulWidget {
  @override
  ConsumerState<CheckoutModal> createState() => _CheckoutModalState();
}

class _CheckoutModalState extends ConsumerState<CheckoutModal> {
  PaymentMethod _selectedPayment = PaymentMethod.handToHand;
  final _notesController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final cartTotals = ref.watch(cartTotalsProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Checkout',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(PhosphorIcons.x()),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Payment Methods
                    Text(
                      'Payment Method',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...PaymentMethod.values.map((method) => _buildPaymentOption(method)),
                    
                    const SizedBox(height: 24),
                    
                    // Contact Information
                    Text(
                      'Contact Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Phone Number *',
                        hintText: 'Enter your phone number',
                        prefixIcon: Icon(PhosphorIcons.phone()),
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    if (_selectedPayment == PaymentMethod.handToHand) ...[
                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: 'Meeting Address',
                          hintText: 'Where would you like to meet?',
                          prefixIcon: Icon(PhosphorIcons.mapPin()),
                          border: const OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    TextFormField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        labelText: 'Additional Notes',
                        hintText: 'Any special requests or instructions...',
                        prefixIcon: Icon(PhosphorIcons.notepad()),
                        border: const OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Order Summary
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order Summary',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Items (${cart.totalItems}):'),
                              Text('${cartTotals['subtotal']!.toStringAsFixed(2)} TND'),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Tax:'),
                              Text('${cartTotals['tax']!.toStringAsFixed(2)} TND'),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Shipping:'),
                              Text(
                                cartTotals['shipping']! > 0
                                    ? '${cartTotals['shipping']!.toStringAsFixed(2)} TND'
                                    : 'FREE',
                                style: TextStyle(
                                  color: cartTotals['shipping']! > 0 ? null : Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total:',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${cartTotals['total']!.toStringAsFixed(2)} TND',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.accent,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    ElevatedButton(
                      onPressed: () => _placeOrder(context, ref),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text('Place Order'),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentOption(PaymentMethod method) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: RadioListTile<PaymentMethod>(
        value: method,
        groupValue: _selectedPayment,
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedPayment = value;
            });
          }
        },
        title: Row(
          children: [
            _getPaymentIcon(method),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    method.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getPaymentIcon(PaymentMethod method) {
    IconData iconData;
    Color iconColor = AppColors.primary;
    
    switch (method) {
      case PaymentMethod.handToHand:
        iconData = PhosphorIcons.handshake();
        iconColor = Colors.green;
        break;
      case PaymentMethod.creditCard:
        iconData = PhosphorIcons.creditCard();
        break;
      case PaymentMethod.paypal:
        iconData = PhosphorIcons.paypalLogo();
        iconColor = const Color(0xFF00457C);
        break;
      case PaymentMethod.bankTransfer:
        iconData = PhosphorIcons.bank();
        break;
    }
    
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 20,
      ),
    );
  }

  void _placeOrder(BuildContext context, WidgetRef ref) {
    if (_phoneController.text.trim().isEmpty) {
      _showErrorSnackBar(context, 'Please enter your phone number');
      return;
    }

    if (_selectedPayment == PaymentMethod.handToHand && _addressController.text.trim().isEmpty) {
      _showErrorSnackBar(context, 'Please enter a meeting address for hand-to-hand delivery');
      return;
    }

    try {
      final authState = ref.read(authStateProvider);
      final userId = authState.value?.uid ?? 'anonymous';
      
      final order = ref.read(ordersProvider.notifier).createOrder(
        userId: userId,
        paymentMethod: _selectedPayment,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        deliveryAddress: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        contactPhone: _phoneController.text.trim(),
      );
      
      Navigator.pop(context); // Close checkout modal
      
      _showOrderConfirmationDialog(context, order);
      
    } catch (e) {
      _showErrorSnackBar(context, 'Error placing order: $e');
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showOrderConfirmationDialog(BuildContext context, Order order) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                PhosphorIcons.checkCircle(),
                color: Colors.green,
                size: 32,
              ),
              const SizedBox(width: 12),
              const Text('Order Placed!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your order has been placed successfully.'),
              const SizedBox(height: 8),
              Text(
                'Order ID: ${order.id}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text('Payment: ${order.paymentMethod.displayName}'),
              if (order.paymentMethod == PaymentMethod.handToHand) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        PhosphorIcons.info(),
                        color: Colors.green,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'The seller will contact you to arrange the meeting and cash payment.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                context.go('/'); // Go to home
              },
              child: const Text('Continue Shopping'),
            ),
          ],
        );
      },
    );
  }
}
