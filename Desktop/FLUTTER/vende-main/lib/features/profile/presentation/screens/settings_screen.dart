import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/theme/app_theme.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notifications = true;
  bool _emailMarketing = false;
  bool _darkMode = false;
  String _language = 'English';
  String _currency = 'TND';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Account Section
          _buildSectionHeader(context, 'Account'),
          _buildSettingTile(
            context,
            icon: PhosphorIcons.user(),
            title: 'Account Information',
            subtitle: 'Update your profile and account details',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account settings coming soon'),
                ),
              );
            },
          ),
          _buildSettingTile(
            context,
            icon: PhosphorIcons.lock(),
            title: 'Privacy & Security',
            subtitle: 'Manage your privacy settings',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Privacy settings coming soon'),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // App Preferences Section
          _buildSectionHeader(context, 'App Preferences'),
          
          // Notifications Toggle
          Card(
            child: SwitchListTile(
              secondary: Icon(PhosphorIcons.bell()),
              title: const Text('Push Notifications'),
              subtitle: const Text('Receive notifications about orders and updates'),
              value: _notifications,
              onChanged: (value) {
                setState(() {
                  _notifications = value;
                });
              },
            ),
          ),

          // Email Marketing Toggle
          Card(
            child: SwitchListTile(
              secondary: Icon(PhosphorIcons.envelope()),
              title: const Text('Email Marketing'),
              subtitle: const Text('Receive promotional emails and offers'),
              value: _emailMarketing,
              onChanged: (value) {
                setState(() {
                  _emailMarketing = value;
                });
              },
            ),
          ),

          // Dark Mode Toggle
          Card(
            child: SwitchListTile(
              secondary: Icon(PhosphorIcons.moon()),
              title: const Text('Dark Mode'),
              subtitle: const Text('Use dark theme throughout the app'),
              value: _darkMode,
              onChanged: (value) {
                setState(() {
                  _darkMode = value;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Dark mode feature coming soon'),
                  ),
                );
              },
            ),
          ),

          // Language Setting
          _buildSettingTile(
            context,
            icon: PhosphorIcons.translate(),
            title: 'Language',
            subtitle: _language,
            trailing: Icon(PhosphorIcons.caretRight()),
            onTap: () => _showLanguageDialog(context),
          ),

          // Currency Setting
          _buildSettingTile(
            context,
            icon: PhosphorIcons.currencyCircleDollar(),
            title: 'Currency',
            subtitle: _currency,
            trailing: Icon(PhosphorIcons.caretRight()),
            onTap: () => _showCurrencyDialog(context),
          ),

          const SizedBox(height: 24),

          // Support Section
          _buildSectionHeader(context, 'Support'),
          _buildSettingTile(
            context,
            icon: PhosphorIcons.chatCircle(),
            title: 'Help Center',
            subtitle: 'Get answers to common questions',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Help center coming soon'),
                ),
              );
            },
          ),
          _buildSettingTile(
            context,
            icon: PhosphorIcons.bug(),
            title: 'Report a Problem',
            subtitle: 'Tell us about issues you\'re experiencing',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Problem reporting coming soon'),
                ),
              );
            },
          ),
          _buildSettingTile(
            context,
            icon: PhosphorIcons.info(),
            title: 'About',
            subtitle: 'App version and legal information',
            onTap: () => _showAboutDialog(context),
          ),

          const SizedBox(height: 24),

          // Danger Zone
          _buildSectionHeader(context, 'Danger Zone'),
          Card(
            color: AppColors.error.withValues(alpha: 0.1),
            child: ListTile(
              leading: Icon(PhosphorIcons.warning(), color: AppColors.error),
              title: Text(
                'Delete Account',
                style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('Permanently delete your account and data'),
              onTap: () => _showDeleteAccountDialog(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8, top: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: trailing ?? Icon(PhosphorIcons.caretRight()),
        onTap: onTap,
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final languages = ['English', 'العربية', 'Français'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((lang) => ListTile(
            title: Text(lang),
            leading: Radio<String>(
              value: lang,
              groupValue: _language,
              onChanged: (value) {
                setState(() {
                  _language = value!;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Language changed to $value')),
                );
              },
            ),
            onTap: () {
              setState(() {
                _language = lang;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Language changed to $lang')),
              );
            },
          )).toList(),
        ),
      ),
    );
  }

  void _showCurrencyDialog(BuildContext context) {
    final currencies = ['TND', 'USD', 'EUR'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Currency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: currencies.map((curr) => ListTile(
            title: Text(curr),
            leading: Radio<String>(
              value: curr,
              groupValue: _currency,
              onChanged: (value) {
                setState(() {
                  _currency = value!;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Currency changed to $value')),
                );
              },
            ),
            onTap: () {
              setState(() {
                _currency = curr;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Currency changed to $curr')),
              );
            },
          )).toList(),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Tunisian Marketplace'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text('Discover authentic Tunisian treasures from skilled artisans.'),
            SizedBox(height: 16),
            Text('© 2024 Tunisian Marketplace'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Account',
          style: TextStyle(color: AppColors.error),
        ),
        content: const Text(
          'This will permanently delete your account and all associated data. This action cannot be undone.',
        ),
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
                  content: Text('Account deletion feature coming soon'),
                  backgroundColor: Colors.red,
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
