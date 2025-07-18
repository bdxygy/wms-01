import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../auth/auth_provider.dart';
import '../providers/store_context_provider.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/welcoming_choose_store_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';

class AppRouter {

  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: '/splash',
      redirect: _globalRedirect,
      routes: [
        // Splash Route
        GoRoute(
          path: '/splash',
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
        ),

        // Authentication Routes
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),

        // Store Selection Route
        GoRoute(
          path: '/store-selection',
          name: 'store-selection',
          redirect: (context, state) => _storeSelectionRedirect(context, state),
          builder: (context, state) => const WelcomingChooseStoreScreen(),
        ),

        // Protected Routes
        GoRoute(
          path: '/dashboard',
          name: 'dashboard',
          redirect: (context, state) => _protectedRedirect(context, state),
          builder: (context, state) => const DashboardScreen(),
        ),

        // Error Routes
        GoRoute(
          path: '/error',
          name: 'error',
          builder: (context, state) {
            final error = state.extra as String? ?? 'Unknown error occurred';
            return ErrorScreen(error: error);
          },
        ),
      ],

      // Global error handling
      errorBuilder: (context, state) => ErrorScreen(
        error: 'Page not found: ${state.matchedLocation}',
      ),

      // Debug logging
      debugLogDiagnostics: true,
    );
  }

  // Global redirect logic
  static String? _globalRedirect(BuildContext context, GoRouterState state) {
    final authProvider = context.read<AuthProvider>();
    final storeProvider = context.read<StoreContextProvider>();
    final currentLocation = state.matchedLocation;

    // Allow splash screen to handle initialization
    if (currentLocation == '/splash') {
      return null;
    }

    // If not authenticated, redirect to login (except if already on login)
    if (!authProvider.isAuthenticated) {
      if (currentLocation != '/login') {
        return '/login';
      }
      return null;
    }

    // If authenticated but needs store selection
    if (authProvider.needsStoreSelection && !storeProvider.hasStoreSelected) {
      if (currentLocation != '/store-selection') {
        return '/store-selection';
      }
      return null;
    }

    // If authenticated and has store context, redirect away from auth screens
    if (authProvider.isAuthenticated && 
        (authProvider.isOwner || storeProvider.hasStoreSelected)) {
      if (currentLocation == '/login' || 
          currentLocation == '/store-selection' || 
          currentLocation == '/splash') {
        return '/dashboard';
      }
    }

    return null;
  }

  // Store selection redirect logic
  static String? _storeSelectionRedirect(BuildContext context, GoRouterState state) {
    final authProvider = context.read<AuthProvider>();
    final storeProvider = context.read<StoreContextProvider>();

    // Must be authenticated to access store selection
    if (!authProvider.isAuthenticated) {
      return '/login';
    }

    // OWNER users don't need store selection
    if (authProvider.isOwner) {
      return '/dashboard';
    }

    // If already has store selected, go to dashboard
    if (storeProvider.hasStoreSelected) {
      return '/dashboard';
    }

    return null;
  }

  // Protected routes redirect logic
  static String? _protectedRedirect(BuildContext context, GoRouterState state) {
    final authProvider = context.read<AuthProvider>();
    final storeProvider = context.read<StoreContextProvider>();

    // Must be authenticated
    if (!authProvider.isAuthenticated) {
      return '/login';
    }

    // Non-owner users must have store selected
    if (!authProvider.isOwner && !storeProvider.hasStoreSelected) {
      return '/store-selection';
    }

    return null;
  }

  // Navigation helpers
  static void goToLogin(BuildContext context) {
    context.goNamed('login');
  }

  static void goToStoreSelection(BuildContext context) {
    context.goNamed('store-selection');
  }

  static void goToDashboard(BuildContext context) {
    context.goNamed('dashboard');
  }

  static void goToSplash(BuildContext context) {
    context.goNamed('splash');
  }

  static void handleLogout(BuildContext context) {
    // Clear all state and go to login
    context.goNamed('login');
  }

  static void handleAuthError(BuildContext context, String error) {
    context.goNamed('error', extra: error);
  }

  // Check if current route requires authentication
  static bool isProtectedRoute(String location) {
    const protectedRoutes = [
      '/dashboard',
      '/products',
      '/transactions',
      '/settings',
      '/categories',
      '/stores',
      '/users'
    ];
    
    return protectedRoutes.any((route) => location.startsWith(route));
  }

  // Check if current route requires store selection
  static bool requiresStoreSelection(String location) {
    const storeRequiredRoutes = [
      '/dashboard',
      '/products',
      '/transactions',
      '/categories'
    ];
    
    return storeRequiredRoutes.any((route) => location.startsWith(route));
  }
}

// Error Screen Widget
class ErrorScreen extends StatelessWidget {
  final String error;

  const ErrorScreen({
    super.key,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
        backgroundColor: Theme.of(context).colorScheme.error,
        foregroundColor: Theme.of(context).colorScheme.onError,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              
              const SizedBox(height: 24),
              
              Text(
                'Oops! Something went wrong',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              Text(
                error,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              ElevatedButton(
                onPressed: () => _handleRetry(context),
                child: const Text('Go to Dashboard'),
              ),
              
              const SizedBox(height: 16),
              
              TextButton(
                onPressed: () => _handleLogout(context),
                child: const Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleRetry(BuildContext context) {
    AppRouter.goToDashboard(context);
  }

  void _handleLogout(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    authProvider.logout().then((_) {
      if (context.mounted) {
        AppRouter.goToLogin(context);
      }
    });
  }
}