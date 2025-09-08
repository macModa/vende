import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/privacy/privacy_policy.dart';

/// Privacy consent dialog for GDPR compliance
class PrivacyConsentDialog extends ConsumerStatefulWidget {
  const PrivacyConsentDialog({Key? key}) : super(key: key);

  @override
  ConsumerState<PrivacyConsentDialog> createState() => _PrivacyConsentDialogState();
}

class _PrivacyConsentDialogState extends ConsumerState<PrivacyConsentDialog> {
  Map<String, bool> consents = {
    'essential': true, // Always true, cannot be changed
    'analytics': false,
    'marketing': false,
  };

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Privacy & Data Usage'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'We respect your privacy. Please review and accept our data usage policies:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ...GDPRCompliance.requiredConsents.map((consent) => 
              _buildConsentTile(consent)
            ).toList(),
            const SizedBox(height: 16),
            Row(
              children: [
                TextButton(
                  onPressed: () => _showPrivacyPolicy(),
                  child: const Text('Privacy Policy'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => _showTermsOfService(),
                  child: const Text('Terms of Service'),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Decline'),
        ),
        ElevatedButton(
          onPressed: GDPRCompliance.hasRequiredConsents(consents)
              ? () => _acceptConsents()
              : null,
          child: const Text('Accept'),
        ),
      ],
    );
  }

  Widget _buildConsentTile(String consentType) {
    final description = GDPRCompliance.consentDescriptions[consentType] ?? '';
    final isEssential = consentType == 'essential';
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: CheckboxListTile(
        title: Text(_getConsentTitle(consentType)),
        subtitle: Text(description),
        value: consents[consentType] ?? false,
        onChanged: isEssential ? null : (value) {
          setState(() {
            consents[consentType] = value ?? false;
          });
        },
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  String _getConsentTitle(String consentType) {
    switch (consentType) {
      case 'essential':
        return 'Essential Functionality (Required)';
      case 'analytics':
        return 'Analytics & Performance';
      case 'marketing':
        return 'Marketing Communications';
      default:
        return consentType;
    }
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: SingleChildScrollView(
          child: Text(PrivacyPolicy.privacyPolicyText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: SingleChildScrollView(
          child: Text(PrivacyPolicy.termsOfServiceText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _acceptConsents() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save consent preferences
    for (final entry in consents.entries) {
      await prefs.setBool('consent_${entry.key}', entry.value);
    }
    
    // Save consent timestamp
    await prefs.setString('consent_timestamp', DateTime.now().toIso8601String());
    
    // Mark that user has seen privacy dialog
    await prefs.setBool('privacy_consent_given', true);
    
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }
}

/// Provider to check if privacy consent is required
final privacyConsentProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('privacy_consent_given') ?? false;
});

/// Show privacy consent dialog if needed
Future<bool> showPrivacyConsentIfNeeded(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  final hasConsent = prefs.getBool('privacy_consent_given') ?? false;
  
  if (!hasConsent) {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PrivacyConsentDialog(),
    );
    return result ?? false;
  }
  
  return true;
}
