import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/theme/app_theme.dart';

class AddressesScreen extends ConsumerWidget {
  const AddressesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Addresses'),
        actions: [
          IconButton(
            icon: Icon(PhosphorIcons.plus()),
            onPressed: () => _showAddAddressDialog(context),
          ),
        ],
      ),
      body: _buildAddressList(context),
    );
  }

  Widget _buildAddressList(BuildContext context) {
    // Mock addresses data
    final mockAddresses = [
      {
        'title': 'Home',
        'name': 'Ahmed Ben Ali',
        'address': '15 Avenue Habib Bourguiba\nTunis, 1001\nTunisia',
        'phone': '+216 20 123 456',
        'isDefault': true,
      },
      {
        'title': 'Work',
        'name': 'Ahmed Ben Ali',
        'address': '32 Rue de la Liberté\nSfax, 3000\nTunisia',
        'phone': '+216 20 123 456',
        'isDefault': false,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: mockAddresses.length,
      itemBuilder: (context, index) {
        final address = mockAddresses[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                address['title'] == 'Home' 
                    ? PhosphorIcons.house()
                    : PhosphorIcons.buildings(),
                color: AppColors.primary,
              ),
            ),
            title: Row(
              children: [
                Text(
                  address['title'] as String,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (address['isDefault'] as bool) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Default',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  address['name'] as String,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(address['address'] as String),
                const SizedBox(height: 2),
                Text(
                  address['phone'] as String,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            trailing: PopupMenuButton(
              icon: Icon(PhosphorIcons.dotsThreeVertical()),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(PhosphorIcons.pencil()),
                      const SizedBox(width: 8),
                      const Text('Edit'),
                    ],
                  ),
                ),
                if (!(address['isDefault'] as bool))
                  PopupMenuItem(
                    value: 'default',
                    child: Row(
                      children: [
                        Icon(PhosphorIcons.star()),
                        const SizedBox(width: 8),
                        const Text('Set as Default'),
                      ],
                    ),
                  ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(PhosphorIcons.trash(), color: AppColors.error),
                      const SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: AppColors.error)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) => _handleAddressAction(context, value as String, address),
            ),
          ),
        );
      },
    );
  }

  void _handleAddressAction(BuildContext context, String action, Map<String, dynamic> address) {
    switch (action) {
      case 'edit':
        _showAddAddressDialog(context, address: address);
        break;
      case 'default':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${address['title']} set as default address'),
          ),
        );
        break;
      case 'delete':
        _showDeleteConfirmation(context, address);
        break;
    }
  }

  void _showAddAddressDialog(BuildContext context, {Map<String, dynamic>? address}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(address == null ? 'Add Address' : 'Edit Address'),
        content: const Text('Address management feature coming soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Map<String, dynamic> address) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Address'),
        content: Text('Are you sure you want to delete "${address['title']}" address?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Address deletion feature coming soon'),
                ),
              );
            },
            child: Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
