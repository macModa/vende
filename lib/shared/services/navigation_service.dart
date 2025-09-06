import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// import 'package:firebase_auth/firebase_auth.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/products/presentation/screens/home_screen.dart';
import '../../features/products/presentation/screens/categories_screen.dart';
import '../../features/products/presentation/screens/product_detail_screen.dart';
import '../../features/products/presentation/screens/search_screen.dart';
import '../../features/cart/presentation/screens/cart_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../shared/widgets/main_navigation.dart';
import '../../features/auth/presentation/providers/mock_auth_providers.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    // refreshListenable: GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),
    routes: [
      // Authentication Routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      
      // Main App Routes with Bottom Navigation
      ShellRoute(
        builder: (context, state, child) {
          return MainNavigation(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/categories',
            name: 'categories',
            builder: (context, state) => const CategoriesScreen(),
          ),
          GoRoute(
            path: '/search',
            name: 'search',
            builder: (context, state) => const SearchScreen(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/cart',
            name: 'cart',
            builder: (context, state) => const CartScreen(),
          ),
        ],
      ),
      
      // Product Detail Route
      GoRoute(
        path: '/product/:id',
        name: 'product-detail',
        builder: (context, state) {
          final productId = state.pathParameters['id']!;
          return ProductDetailScreen(productId: productId);
        },
      ),
    ],
    
    // Redirect to appropriate screen based on auth state
    redirect: (context, state) {
      // For local testing without Firebase - no redirects
      return null;
    },
  );
});

// Navigation helpers
// Helper class to refresh GoRouter when auth state changes
// (Commented out for local testing without Firebase)
// class GoRouterRefreshStream extends ChangeNotifier {
//   GoRouterRefreshStream(Stream<User?> stream) {
//     notifyListeners();
//     _subscription = stream.asBroadcastStream().listen((_) {
//       notifyListeners();
//     });
//   }
// 
//   late final StreamSubscription<User?> _subscription;
// 
//   @override
//   void dispose() {
//     _subscription.cancel();
//     super.dispose();
//   }
// }

class AppNavigation {
  static void toLogin(BuildContext context) {
    context.goNamed('login');
  }
  
  static void toRegister(BuildContext context) {
    context.goNamed('register');
  }
  
  static void toHome(BuildContext context) {
    context.goNamed('home');
  }
  
  static void toCategories(BuildContext context) {
    context.goNamed('categories');
  }
  
  static void toSearch(BuildContext context) {
    context.goNamed('search');
  }
  
  static void toProfile(BuildContext context) {
    context.goNamed('profile');
  }
  
  static void toCart(BuildContext context) {
    context.goNamed('cart');
  }
  
  static void toProductDetail(BuildContext context, String productId) {
    context.goNamed('product-detail', pathParameters: {'id': productId});
  }
}
