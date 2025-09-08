import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/mock_auth_service.dart';

// Re-export mock auth providers
export '../../data/mock_auth_service.dart' show mockAuthServiceProvider, mockAuthStateProvider, mockCurrentUserProvider;

// Use alias to match the original provider names for seamless integration
final authServiceProvider = mockAuthServiceProvider;
final authStateProvider = mockAuthStateProvider;
final currentUserProvider = mockCurrentUserProvider;

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
