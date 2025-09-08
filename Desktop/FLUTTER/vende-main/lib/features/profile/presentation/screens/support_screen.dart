import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/theme/app_theme.dart';

class SupportScreen extends ConsumerWidget {
  const SupportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Contact Options
          _buildContactCard(
            context,
            icon: PhosphorIcons.chatCircle(),
            iconColor: Colors.blue,
            title: 'Live Chat',
            subtitle: 'Chat with our support team',
            isAvailable: true,
            onTap: () => _showFeatureComingSoon(context, 'Live chat'),
          ),

          _buildContactCard(
            context,
            icon: PhosphorIcons.envelope(),
            iconColor: Colors.green,
            title: 'Email Support',
            subtitle: 'support@tunisianmarketplace.com',
            isAvailable: true,
            onTap: () => _showFeatureComingSoon(context, 'Email support'),
          ),

          _buildContactCard(
            context,
            icon: PhosphorIcons.phone(),
            iconColor: Colors.orange,
            title: 'Phone Support',
            subtitle: '+216 70 123 456 (9 AM - 6 PM)',
            isAvailable: false,
            onTap: () => _showFeatureComingSoon(context, 'Phone support'),
          ),

          const SizedBox(height: 24),

          // FAQ Section
          Text(
            'Frequently Asked Questions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          _buildFAQItem(
            context,
            question: 'How do I track my order?',
            answer: 'You can track your order in the "My Orders" section of your profile. Each order includes a tracking number.',
          ),

          _buildFAQItem(
            context,
            question: 'What payment methods do you accept?',
            answer: 'We accept major credit cards, PayPal, and cash on delivery for local orders.',
          ),

          _buildFAQItem(
            context,
            question: 'How long does shipping take?',
            answer: 'Shipping typically takes 3-7 business days within Tunisia, and 7-14 days for international orders.',
          ),

          _buildFAQItem(
            context,
            question: 'Can I return or exchange items?',
            answer: 'Yes, we accept returns within 14 days of delivery. Items must be in original condition.',
          ),

          _buildFAQItem(
            context,
            question: 'How do I become a seller?',
            answer: 'You can apply to become a seller through our seller portal. We review applications to ensure quality.',
          ),

          const SizedBox(height: 24),

          // Report Issue Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showReportIssueDialog(context),
              icon: Icon(PhosphorIcons.bug()),
              label: const Text('Report an Issue'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isAvailable,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Row(
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isAvailable) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Available',
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
        subtitle: Text(subtitle),
        trailing: Icon(PhosphorIcons.caretRight()),
        onTap: onTap,
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, {required String question, required String answer}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: Icon(
          PhosphorIcons.question(),
          color: AppColors.primary,
        ),
        title: Text(
          question,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              answer,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFeatureComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon'),
      ),
    );
  }

  void _showReportIssueDialog(BuildContext context) {
    final issueController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report an Issue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please describe the issue you\'re experiencing:'),
            const SizedBox(height: 12),
            TextField(
              controller: issueController,
              decoration: const InputDecoration(
                hintText: 'Describe your issue...',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Issue reporting feature coming soon'),
                ),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
