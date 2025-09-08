import 'package:flutter/foundation.dart';

/// Environment configuration for the app
/// This helps manage different configurations for dev/staging/prod
class Environment {
  static const String _environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  static bool get isDevelopment => _environment == 'development';
  static bool get isStaging => _environment == 'staging';
  static bool get isProduction => _environment == 'production';

  static String get currentEnvironment => _environment;

  // Firebase project IDs for different environments
  static String get firebaseProjectId {
    switch (_environment) {
      case 'production':
        return 'tunisian-marketplace-prod';
      case 'staging':
        return 'tunisian-marketplace-staging';
      case 'development':
      default:
        return 'tunisian-marketplace-dev';
    }
  }

  // API endpoints for different environments
  static String get apiBaseUrl {
    switch (_environment) {
      case 'production':
        return 'https://api.tunisian-marketplace.com';
      case 'staging':
        return 'https://staging-api.tunisian-marketplace.com';
      case 'development':
      default:
        return 'https://dev-api.tunisian-marketplace.com';
    }
  }

  // Debug settings
  static bool get enableLogging => !isProduction;
  static bool get enableDebugBanner => isDevelopment;

  // Feature flags
  static bool get enableAnalytics => isProduction || isStaging;
  static bool get enableCrashlytics => isProduction || isStaging;
  static bool get enablePerformanceMonitoring => isProduction || isStaging;

  // App configuration
  static String get appName {
    switch (_environment) {
      case 'production':
        return 'Tunisian Marketplace';
      case 'staging':
        return 'Tunisian Marketplace (Staging)';
      case 'development':
      default:
        return 'Tunisian Marketplace (Dev)';
    }
  }

  // Bundle identifiers for different environments
  static String get bundleId {
    switch (_environment) {
      case 'production':
        return 'com.tunisianmarketplace.app';
      case 'staging':
        return 'com.tunisianmarketplace.staging';
      case 'development':
      default:
        return 'com.tunisianmarketplace.dev';
    }
  }

  static void logEnvironmentInfo() {
    if (kDebugMode) {
      print('🌍 Environment: $_environment');
      print('🔥 Firebase Project: ${firebaseProjectId}');
      print('🌐 API Base URL: ${apiBaseUrl}');
      print('📱 App Name: ${appName}');
      print('📦 Bundle ID: ${bundleId}');
    }
  }
}
