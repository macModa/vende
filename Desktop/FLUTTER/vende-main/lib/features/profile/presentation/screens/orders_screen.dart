import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/profile_repository.dart';
import '../../domain/order.dart' as order_models;

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mock user ID - in real app this would come from auth provider
    const userId = 'user_123';
    final ordersAsync = ref.watch(userOrdersProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
      ),
      body: ordersAsync.when(
        data: (orders) => orders.isEmpty
            ? _buildEmptyState(context)
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return _buildOrderCard(context, order);
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                PhosphorIcons.warning(),
                size: 64,
                color: AppColors.textLight,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading orders',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textLight,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PhosphorIcons.shoppingBag(),
            size: 64,
            color: AppColors.textLight,
          ),
          const SizedBox(height: 16),
          Text(
            'No orders yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your order history will appear here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
            child: const Text('Start Shopping'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, order_models.Order order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${order.id.substring(0, 8)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM dd, yyyy').format(order.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                _buildStatusChip(order.status),
              ],
            ),

            const SizedBox(height: 16),

            // Order Items Count
            Row(
              children: [
                Icon(
                  PhosphorIcons.package(),
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  '${order.items.length} item${order.items.length != 1 ? 's' : ''}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Shipping Address
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  PhosphorIcons.mapPin(),
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${order.shippingAddress.city}, ${order.shippingAddress.country}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),

            if (order.trackingNumber != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    PhosphorIcons.truck(),
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tracking: ${order.trackingNumber}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 16),

            // Order Total and Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${order.total.toStringAsFixed(2)} TND',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () => _showOrderDetails(context, order),
                      child: const Text('Details'),
                    ),
                    const SizedBox(width: 8),
                    if (order.status == order_models.OrderStatus.delivered)
                      ElevatedButton(
                        onPressed: () => _reorderItems(context, order),
                        child: const Text('Reorder'),
                      )
                    else if (order.status == order_models.OrderStatus.pending ||
                             order.status == order_models.OrderStatus.confirmed)
                      ElevatedButton(
                        onPressed: () => _cancelOrder(context, order),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                        ),
                        child: const Text('Cancel'),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(order_models.OrderStatus status) {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (status) {
      case order_models.OrderStatus.pending:
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        label = 'Pending';
        break;
      case order_models.OrderStatus.confirmed:
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        label = 'Confirmed';
        break;
      case order_models.OrderStatus.processing:
        backgroundColor = Colors.purple.shade100;
        textColor = Colors.purple.shade800;
        label = 'Processing';
        break;
      case order_models.OrderStatus.shipped:
        backgroundColor = Colors.indigo.shade100;
        textColor = Colors.indigo.shade800;
        label = 'Shipped';
        break;
      case order_models.OrderStatus.delivered:
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        label = 'Delivered';
        break;
      case order_models.OrderStatus.cancelled:
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        label = 'Cancelled';
        break;
      case order_models.OrderStatus.refunded:
        backgroundColor = Colors.grey.shade100;
        textColor = Colors.grey.shade800;
        label = 'Refunded';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  void _showOrderDetails(BuildContext context, order_models.Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Text(
                'Order Details',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Order Info
                      _buildDetailRow('Order ID', '#${order.id.substring(0, 8)}'),
                      _buildDetailRow('Date', DateFormat('MMM dd, yyyy HH:mm').format(order.createdAt)),
                      _buildDetailRow('Status', _getStatusText(order.status)),
                      _buildDetailRow('Payment', _getPaymentStatusText(order.paymentStatus)),
                      
                      if (order.trackingNumber != null)
                        _buildDetailRow('Tracking', order.trackingNumber!),
                      
                      const SizedBox(height: 24),

                      // Shipping Address
                      Text(
                        'Shipping Address',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${order.shippingAddress.fullName}\n'
                        '${order.shippingAddress.street}\n'
                        '${order.shippingAddress.city}, ${order.shippingAddress.postalCode}\n'
                        '${order.shippingAddress.country}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),

                      const SizedBox(height: 24),

                      // Order Summary
                      Text(
                        'Order Summary',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildDetailRow('Subtotal', '${order.subtotal.toStringAsFixed(2)} TND'),
                      _buildDetailRow('Tax', '${order.tax.toStringAsFixed(2)} TND'),
                      _buildDetailRow('Shipping', order.shipping == 0 ? 'FREE' : '${order.shipping.toStringAsFixed(2)} TND'),
                      const Divider(),
                      _buildDetailRow('Total', '${order.total.toStringAsFixed(2)} TND', isTotal: true),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? AppColors.primary : null,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(order_models.OrderStatus status) {
    switch (status) {
      case order_models.OrderStatus.pending:
        return 'Pending';
      case order_models.OrderStatus.confirmed:
        return 'Confirmed';
      case order_models.OrderStatus.processing:
        return 'Processing';
      case order_models.OrderStatus.shipped:
        return 'Shipped';
      case order_models.OrderStatus.delivered:
        return 'Delivered';
      case order_models.OrderStatus.cancelled:
        return 'Cancelled';
      case order_models.OrderStatus.refunded:
        return 'Refunded';
    }
  }

  String _getPaymentStatusText(order_models.PaymentStatus status) {
    switch (status) {
      case order_models.PaymentStatus.pending:
        return 'Pending';
      case order_models.PaymentStatus.paid:
        return 'Paid';
      case order_models.PaymentStatus.failed:
        return 'Failed';
      case order_models.PaymentStatus.refunded:
        return 'Refunded';
    }
  }

  void _reorderItems(BuildContext context, order_models.Order order) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reorder feature coming soon'),
      ),
    );
  }

  void _cancelOrder(BuildContext context, order_models.Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: Text('Are you sure you want to cancel order #${order.id.substring(0, 8)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cancel order feature coming soon'),
                ),
              );
            },
            child: Text(
              'Yes, Cancel',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
