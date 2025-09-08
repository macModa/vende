import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/auth_service.dart';

// Re-export auth providers from auth_service for convenience
export '../../data/auth_service.dart' show authServiceProvider, authStateProvider, currentUserProvider;

// Authentication loading state provider
final authLoadingProvider = StateProvider<bool>((ref) => false);

// Check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
});

// User display name provider
final userDisplayNameProvider = Provider<String?>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.displayName;
});

// User email provider  
final userEmailProvider = Provider<String?>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.email;
});

// User photo URL provider
final userPhotoUrlProvider = Provider<String?>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.photoURL;
});
