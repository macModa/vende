/// Privacy Policy and GDPR compliance utilities
class PrivacyPolicy {
  static const String privacyPolicyUrl = 'https://tunisian-marketplace.com/privacy';
  static const String termsOfServiceUrl = 'https://tunisian-marketplace.com/terms';
  
  static const String privacyPolicyText = '''
# Privacy Policy

## Data Collection
We collect the following information:
- Email address and name for account creation
- Profile information you choose to provide
- Usage data to improve our services
- Device information for security purposes

## Data Usage
Your data is used to:
- Provide and maintain our services
- Authenticate your account
- Send important service notifications
- Improve user experience
- Comply with legal obligations

## Data Sharing
We do not sell your personal data. We may share data with:
- Service providers who help us operate the app
- Legal authorities when required by law
- Other users (only information you choose to make public)

## Data Security
We implement industry-standard security measures to protect your data:
- Encrypted data transmission
- Secure authentication systems
- Regular security audits
- Limited access controls

## Your Rights
You have the right to:
- Access your personal data
- Correct inaccurate data
- Delete your account and data
- Export your data
- Withdraw consent

## Contact
For privacy concerns, contact us at: privacy@tunisian-marketplace.com

Last updated: ${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}
''';

  static const String termsOfServiceText = '''
# Terms of Service

## Acceptance of Terms
By using this app, you agree to these terms.

## User Accounts
- You must provide accurate information
- You are responsible for account security
- One account per person
- Must be 13+ years old

## Prohibited Activities
- Illegal activities
- Harassment or abuse
- Spam or unauthorized advertising
- Attempting to breach security

## Content
- You retain rights to your content
- We may remove inappropriate content
- Respect intellectual property rights

## Service Availability
- We strive for 99.9% uptime
- Maintenance may cause temporary outages
- We reserve the right to modify features

## Limitation of Liability
Our liability is limited to the maximum extent permitted by law.

## Termination
We may terminate accounts for violations of these terms.

## Changes
We may update these terms with notice to users.

## Contact
For questions about these terms: legal@tunisian-marketplace.com

Last updated: ${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}
''';
}

/// GDPR compliance utilities
class GDPRCompliance {
  static const List<String> requiredConsents = [
    'essential', // Essential cookies and functionality
    'analytics', // Usage analytics
    'marketing', // Marketing communications
  ];

  static const Map<String, String> consentDescriptions = {
    'essential': 'Required for the app to function properly. Cannot be disabled.',
    'analytics': 'Helps us understand how you use the app to improve it.',
    'marketing': 'Allows us to send you promotional content and updates.',
  };

  /// Checks if user has given required consents
  static bool hasRequiredConsents(Map<String, bool> userConsents) {
    // Essential consent is always required
    return userConsents['essential'] == true;
  }

  /// Gets list of data we collect for GDPR transparency
  static List<Map<String, String>> getDataCollectionInfo() {
    return [
      {
        'type': 'Account Information',
        'data': 'Email, name, profile photo',
        'purpose': 'Account creation and authentication',
        'retention': 'Until account deletion',
      },
      {
        'type': 'Usage Data',
        'data': 'App interactions, preferences',
        'purpose': 'Service improvement and personalization',
        'retention': '2 years or until withdrawal of consent',
      },
      {
        'type': 'Device Information',
        'data': 'Device type, OS version, app version',
        'purpose': 'Technical support and security',
        'retention': '1 year',
      },
      {
        'type': 'Transaction Data',
        'data': 'Order history, payment information',
        'purpose': 'Order processing and customer support',
        'retention': '7 years for tax purposes',
      },
    ];
  }

  /// Gets user rights under GDPR
  static List<Map<String, String>> getUserRights() {
    return [
      {
        'right': 'Right to Access',
        'description': 'Request a copy of your personal data',
        'action': 'Contact support to request data export',
      },
      {
        'right': 'Right to Rectification',
        'description': 'Correct inaccurate personal data',
        'action': 'Update your profile or contact support',
      },
      {
        'right': 'Right to Erasure',
        'description': 'Request deletion of your personal data',
        'action': 'Delete account in settings or contact support',
      },
      {
        'right': 'Right to Portability',
        'description': 'Receive your data in a machine-readable format',
        'action': 'Contact support to request data export',
      },
      {
        'right': 'Right to Object',
        'description': 'Object to processing of your personal data',
        'action': 'Adjust privacy settings or contact support',
      },
      {
        'right': 'Right to Withdraw Consent',
        'description': 'Withdraw consent for data processing',
        'action': 'Adjust consent settings in privacy preferences',
      },
    ];
  }
}
