// lib/router/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/signup_screen.dart';
import '../features/auth/role_selection_screen.dart';
import '../features/customer/customer_main_screen.dart';
import '../features/customer/restaurant/restaurant_detail_screen.dart';
import '../features/customer/cart/cart_screen.dart';
import '../features/customer/checkout/checkout_screen.dart';
import '../features/customer/checkout/payment_screen.dart';
import '../features/customer/order/order_confirmation_screen.dart';
import '../features/restaurant_owner/owner_main_screen.dart';
import '../features/admin/admin_main_screen.dart';

class AppRouter {
  static GoRouter router(AuthProvider auth) {
    return GoRouter(
      initialLocation: '/login',
      refreshListenable: auth,
      redirect: (context, state) {
        if (auth.isInitializing) return null;

        final loggedIn = auth.isAuthenticated;
        final role = auth.userRole;
        final loc = state.matchedLocation;

        final isAuth = loc == '/login' ||
            loc == '/signup' ||
            loc == '/role-selection';

        if (!loggedIn && !isAuth) return '/login';

        if (loggedIn && isAuth) {
          if (role == 'restaurant_owner') return '/owner';
          if (role == 'admin') return '/admin';
          return '/customer';
        }

        // Protect routes by role
        if (loggedIn && role == 'restaurant_owner') {
          if (loc.startsWith('/customer') || loc.startsWith('/admin')) {
            return '/owner';
          }
        }
        if (loggedIn && role == 'customer') {
          if (loc.startsWith('/owner') || loc.startsWith('/admin')) {
            return '/customer';
          }
        }
        if (loggedIn && role == 'admin') {
          if (loc.startsWith('/owner') || loc.startsWith('/customer')) {
            return '/admin';
          }
        }
        return null;
      },
      routes: [
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/signup', builder: (_, __) => const SignupScreen()),
        GoRoute(path: '/role-selection',
            builder: (_, __) => const RoleSelectionScreen()),
        GoRoute(
          path: '/customer',
          builder: (_, __) => const CustomerMainScreen(),
          routes: [
            GoRoute(
              path: 'restaurant/:id',
              builder: (_, s) => RestaurantDetailScreen(
                  restaurantId: s.pathParameters['id']!),
            ),
            GoRoute(path: 'cart',
                builder: (_, __) => const CartScreen()),
            GoRoute(path: 'checkout',
                builder: (_, __) => const CheckoutScreen()),
            GoRoute(path: 'payment',
                builder: (_, __) => const PaymentScreen()),
            GoRoute(path: 'order-confirmation',
                builder: (_, __) => const OrderConfirmationScreen()),
          ],
        ),
        GoRoute(path: '/owner',
            builder: (_, __) => const OwnerMainScreen()),
        GoRoute(path: '/admin',
            builder: (_, __) => const AdminMainScreen()),
      ],
      errorBuilder: (ctx, s) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Page Not Found',
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 24),
              ElevatedButton(
                  onPressed: () => ctx.go('/login'),
                  child: const Text('Go to Login')),
            ],
          ),
        ),
      ),
    );
  }
}