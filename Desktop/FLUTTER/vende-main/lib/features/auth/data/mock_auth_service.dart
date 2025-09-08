import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Mock User class to replace Firebase User
class MockUser {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;

  MockUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
  });
}

// Mock credential class
class MockUserCredential {
  final MockUser? user;
  MockUserCredential({this.user});
}

class MockAuthService {
  MockUser? _currentUser;
  final StreamController<MockUser?> _authStateController = StreamController<MockUser?>.broadcast();

  // Get current user
  MockUser? get currentUser => _currentUser;
  
  // Auth state stream
  Stream<MockUser?> get authStateChanges => _authStateController.stream;

  // Sign in with email and password
  Future<MockUserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock validation
    if (email.isEmpty || password.isEmpty) {
      throw AuthException('Please enter both email and password');
    }
    
    if (password.length < 6) {
      throw AuthException('Password must be at least 6 characters');
    }
    
    // Create mock user
    _currentUser = MockUser(
      uid: 'mock_${email.hashCode}',
      email: email,
      displayName: email.split('@')[0],
    );
    
    _authStateController.add(_currentUser);
    
    return MockUserCredential(user: _currentUser);
  }

  // Register with email and password
  Future<MockUserCredential?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock validation
    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      throw AuthException('Please fill in all fields');
    }
    
    if (password.length < 6) {
      throw AuthException('Password must be at least 6 characters');
    }
    
    // Create mock user
    _currentUser = MockUser(
      uid: 'mock_${email.hashCode}',
      email: email,
      displayName: name,
    );
    
    _authStateController.add(_currentUser);
    
    return MockUserCredential(user: _currentUser);
  }

  // Sign in with Google
  Future<MockUserCredential?> signInWithGoogle() async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Create mock Google user
    _currentUser = MockUser(
      uid: 'mock_google_123',
      email: 'demo@gmail.com',
      displayName: 'Demo User',
      photoURL: 'https://via.placeholder.com/100x100?text=Demo',
    );
    
    _authStateController.add(_currentUser);
    
    return MockUserCredential(user: _currentUser);
  }

  // Sign out
  Future<void> signOut() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    _currentUser = null;
    _authStateController.add(null);
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(seconds: 1));
    // In mock mode, just pretend to send email
    if (email.isEmpty) {
      throw AuthException('Please enter your email address');
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (_currentUser == null) {
      throw AuthException('No user is currently signed in.');
    }
    
    _currentUser = MockUser(
      uid: _currentUser!.uid,
      email: _currentUser!.email,
      displayName: displayName ?? _currentUser!.displayName,
      photoURL: photoURL ?? _currentUser!.photoURL,
    );
    
    _authStateController.add(_currentUser);
  }

  // Delete user account
  Future<void> deleteAccount() async {
    await Future.delayed(const Duration(seconds: 1));
    
    if (_currentUser == null) {
      throw AuthException('No user is currently signed in.');
    }
    
    _currentUser = null;
    _authStateController.add(null);
  }
  
  void dispose() {
    _authStateController.close();
  }
}

// Custom exception for authentication errors
class AuthException implements Exception {
  final String message;
  
  const AuthException(this.message);
  
  @override
  String toString() => 'AuthException: $message';
}

// Provider for MockAuthService
final mockAuthServiceProvider = Provider<MockAuthService>((ref) {
  return MockAuthService();
});

// Provider for auth state changes
final mockAuthStateProvider = StreamProvider<MockUser?>((ref) {
  final authService = ref.watch(mockAuthServiceProvider);
  return authService.authStateChanges;
});

// Provider for current user
final mockCurrentUserProvider = Provider<MockUser?>((ref) {
  final authState = ref.watch(mockAuthStateProvider);
  return authState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
});
