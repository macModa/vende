import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Security configuration and utilities for the app
class SecurityConfig {
  // Password validation rules
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  
  // Session timeout (in minutes)
  static const int sessionTimeoutMinutes = 30;
  
  // Maximum login attempts before lockout
  static const int maxLoginAttempts = 5;
  static const int lockoutDurationMinutes = 15;

  /// Validates password strength
  static bool isPasswordStrong(String password) {
    if (password.length < minPasswordLength) return false;
    if (password.length > maxPasswordLength) return false;
    
    // Check for at least one uppercase letter
    if (!password.contains(RegExp(r'[A-Z]'))) return false;
    
    // Check for at least one lowercase letter
    if (!password.contains(RegExp(r'[a-z]'))) return false;
    
    // Check for at least one digit
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    
    // Check for at least one special character
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return false;
    
    return true;
  }

  /// Gets password strength score (0-4)
  static int getPasswordStrength(String password) {
    int score = 0;
    
    if (password.length >= minPasswordLength) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[a-z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;
    
    return score;
  }

  /// Validates email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }

  /// Sanitizes user input to prevent XSS
  static String sanitizeInput(String input) {
    return input
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;')
        .replaceAll('&', '&amp;');
  }

  /// Checks if user needs to verify email
  static bool requiresEmailVerification(User? user) {
    if (user == null) return false;
    return !user.emailVerified;
  }

  /// Checks if user session is still valid
  static bool isSessionValid(User? user) {
    if (user == null) return false;
    
    final metadata = user.metadata;
    final lastSignIn = metadata.lastSignInTime;
    
    if (lastSignIn == null) return false;
    
    final now = DateTime.now();
    final sessionDuration = now.difference(lastSignIn);
    
    return sessionDuration.inMinutes < sessionTimeoutMinutes;
  }

  /// Gets security recommendations for user
  static List<String> getSecurityRecommendations(User? user) {
    final recommendations = <String>[];
    
    if (user == null) return recommendations;
    
    if (!user.emailVerified) {
      recommendations.add('Verify your email address for enhanced security');
    }
    
    if (user.photoURL == null) {
      recommendations.add('Add a profile photo to help identify your account');
    }
    
    final metadata = user.metadata;
    final creationTime = metadata.creationTime;
    final lastSignIn = metadata.lastSignInTime;
    
    if (creationTime != null && lastSignIn != null) {
      final daysSinceCreation = DateTime.now().difference(creationTime).inDays;
      final daysSinceLastSignIn = DateTime.now().difference(lastSignIn).inDays;
      
      if (daysSinceCreation > 30 && daysSinceLastSignIn > 7) {
        recommendations.add('Consider updating your password regularly');
      }
    }
    
    return recommendations;
  }

  /// Logs security events (only in debug mode)
  static void logSecurityEvent(String event, {Map<String, dynamic>? details}) {
    if (kDebugMode) {
      print('🔒 Security Event: $event');
      if (details != null) {
        details.forEach((key, value) {
          print('   $key: $value');
        });
      }
    }
  }
}
