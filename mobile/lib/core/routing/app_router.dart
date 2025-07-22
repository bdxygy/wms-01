import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../auth/auth_provider.dart';
import '../providers/store_context_provider.dart';
import '../../generated/app_localizations.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/welcoming_choose_store_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/products/screens/products_screen.dart';
import '../../features/transactions/screens/transactions_screen.dart';
import '../../features/stores/screens/stores_screen.dart';
import '../../features/users/screens/users_screen.dart';
import '../../features/categories/screens/categories_screen.dart';
import '../../features/checks/screens/checks_screen.dart';
import '../../features/products/screens/product_detail_screen.dart';
import '../../features/products/screens/create_product_screen.dart';
import '../../features/products/screens/edit_product_screen.dart';
import '../../features/products/screens/product_search_screen.dart';
import '../../features/transactions/screens/create_transaction_screen.dart';
import '../../features/transactions/screens/transaction_detail_screen.dart';
import '../../features/transactions/screens/edit_transaction_screen.dart';
import '../../features/scanner/screens/barcode_scanner_screen.dart';
import '../../features/scanner/screens/imei_scanner_screen.dart';

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

        // Settings Route (for all authenticated users)
        GoRoute(
          path: '/settings',
          name: 'settings',
          redirect: (context, state) => _protectedRedirect(context, state),
          builder: (context, state) => const SettingsScreen(),
        ),

        // Products Route
        GoRoute(
          path: '/products',
          name: 'products',
          redirect: (context, state) => _protectedRedirect(context, state),
          builder: (context, state) => const ProductsScreen(),
          routes: [
            // Create Product Route
            GoRoute(
                path: '/create',
                name: 'create-product',
                redirect: (context, state) =>
                    _protectedRedirect(context, state),
                builder: (context, state) => const CreateProductScreen()),
            // Product Detail Route
            GoRoute(
              path: '/:id',
              name: 'product-detail',
              redirect: (context, state) => _protectedRedirect(context, state),
              builder: (context, state) {
                final productId = state.pathParameters['id']!;
                return ProductDetailScreen(productId: productId);
              },
            ),
            // Edit Product Route
            GoRoute(
              path: '/:id/edit',
              name: 'edit-product',
              redirect: (context, state) => _protectedRedirect(context, state),
              builder: (context, state) {
                final productId = state.pathParameters['id']!;
                return EditProductScreen(productId: productId);
              },
            ),
          ],
        ),

        // Product Search Route
        GoRoute(
          path: '/product-search',
          name: 'product-search',
          redirect: (context, state) => _protectedRedirect(context, state),
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            return ProductSearchScreen(
              initialQuery: extra?['initialQuery'],
              searchType: extra?['searchType'],
            );
          },
        ),

        // Transactions Route
        GoRoute(
          path: '/transactions',
          name: 'transactions',
          redirect: (context, state) => _protectedRedirect(context, state),
          builder: (context, state) => const TransactionsScreen(),
          routes: [
            // Create Transaction Route
            GoRoute(
              path: '/create',
              name: 'create-transaction',
              redirect: (context, state) => _protectedRedirect(context, state),
              builder: (context, state) => const CreateTransactionScreen(),
            ),
            // Transaction Detail Route
            GoRoute(
              path: '/:id',
              name: 'transaction-detail',
              redirect: (context, state) => _protectedRedirect(context, state),
              builder: (context, state) {
                final transactionId = state.pathParameters['id']!;
                return TransactionDetailScreen(transactionId: transactionId);
              },
            ),
            // Edit Transaction Route
            GoRoute(
              path: '/:id/edit',
              name: 'edit-transaction',
              redirect: (context, state) => _protectedRedirect(context, state),
              builder: (context, state) {
                final transactionId = state.pathParameters['id']!;
                return EditTransactionScreen(transactionId: transactionId);
              },
            ),
          ],
        ),

        // Stores Route (OWNER only)
        GoRoute(
          path: '/stores',
          name: 'stores',
          redirect: (context, state) => _protectedRedirect(context, state),
          builder: (context, state) => const StoresScreen(),
        ),

        // Users Route (OWNER/ADMIN only)
        GoRoute(
          path: '/users',
          name: 'users',
          redirect: (context, state) => _protectedRedirect(context, state),
          builder: (context, state) => const UsersScreen(),
        ),

        // Categories Route
        GoRoute(
          path: '/categories',
          name: 'categories',
          redirect: (context, state) => _protectedRedirect(context, state),
          builder: (context, state) => const CategoriesScreen(),
        ),

        // Checks Route (Product Checks)
        GoRoute(
          path: '/checks',
          name: 'checks',
          redirect: (context, state) => _protectedRedirect(context, state),
          builder: (context, state) => const ChecksScreen(),
        ),

        // Scanner Route
        GoRoute(
          path: '/scanner',
          name: 'scanner',
          redirect: (context, state) => _protectedRedirect(context, state),
          builder: (context, state) {
            // Get optional parameters from extra
            final extra = state.extra as Map<String, dynamic>?;
            return BarcodeScannerScreen(
              title: extra?['title'],
              subtitle: extra?['subtitle'],
              onBarcodeScanned: extra?['onBarcodeScanned'],
              allowManualEntry: extra?['allowManualEntry'] ?? true,
              showHistory: extra?['showHistory'] ?? false,
              autoClose: extra?['autoClose'] ?? true,
            );
          },
        ),

        // IMEI Scanner Route
        GoRoute(
          path: '/imei-scanner',
          name: 'imei-scanner',
          redirect: (context, state) => _protectedRedirect(context, state),
          builder: (context, state) {
            // Get optional parameters from extra
            final extra = state.extra as Map<String, dynamic>?;
            return ImeiScannerScreen(
              title: extra?['title'],
              subtitle: extra?['subtitle'],
              onImeiScanned: extra?['onImeiScanned'],
              onProductFound: extra?['onProductFound'],
              allowManualEntry: extra?['allowManualEntry'] ?? true,
              showHistory: extra?['showHistory'] ?? true,
              autoSearchProduct: extra?['autoSearchProduct'] ?? true,
              autoClose: extra?['autoClose'] ?? false,
            );
          },
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
        error:
            AppLocalizations.of(context)!.pageNotFound(state.matchedLocation),
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
  static String? _storeSelectionRedirect(
      BuildContext context, GoRouterState state) {
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

  static void goToSettings(BuildContext context) {
    context.goNamed('settings');
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

  // Product navigation helpers
  static void goToProductDetail(BuildContext context, String productId) {
    context.goNamed('product-detail', pathParameters: {'id': productId});
  }

  static void goToCreateProduct(BuildContext context) {
    context.goNamed('create-product');
  }

  static void goToEditProduct(BuildContext context, String productId) {
    context.goNamed('edit-product', pathParameters: {'id': productId});
  }

  static void goToProductSearch(
    BuildContext context, {
    String? initialQuery,
    String? searchType,
  }) {
    context.goNamed('product-search', extra: {
      if (initialQuery != null) 'initialQuery': initialQuery,
      if (searchType != null) 'searchType': searchType,
    });
  }

  // Scanner navigation helpers
  static void goToScanner(
    BuildContext context, {
    String? title,
    String? subtitle,
    Function(dynamic)? onBarcodeScanned,
    bool allowManualEntry = true,
    bool showHistory = false,
    bool autoClose = true,
  }) {
    context.goNamed('scanner', extra: {
      if (title != null) 'title': title,
      if (subtitle != null) 'subtitle': subtitle,
      if (onBarcodeScanned != null) 'onBarcodeScanned': onBarcodeScanned,
      'allowManualEntry': allowManualEntry,
      'showHistory': showHistory,
      'autoClose': autoClose,
    });
  }

  // IMEI Scanner navigation helpers
  static void goToImeiScanner(
    BuildContext context, {
    String? title,
    String? subtitle,
    Function(dynamic)? onImeiScanned,
    Function(dynamic)? onProductFound,
    bool allowManualEntry = true,
    bool showHistory = true,
    bool autoSearchProduct = true,
    bool autoClose = false,
  }) {
    context.goNamed('imei-scanner', extra: {
      if (title != null) 'title': title,
      if (subtitle != null) 'subtitle': subtitle,
      if (onImeiScanned != null) 'onImeiScanned': onImeiScanned,
      if (onProductFound != null) 'onProductFound': onProductFound,
      'allowManualEntry': allowManualEntry,
      'showHistory': showHistory,
      'autoSearchProduct': autoSearchProduct,
      'autoClose': autoClose,
    });
  }

  // Transaction navigation helpers
  static void goToCreateTransaction(BuildContext context) {
    context.goNamed('create-transaction');
  }

  static void goToTransactionDetail(
      BuildContext context, String transactionId) {
    context
        .goNamed('transaction-detail', pathParameters: {'id': transactionId});
  }

  static void goToEditTransaction(BuildContext context, String transactionId) {
    context.goNamed('edit-transaction', pathParameters: {'id': transactionId});
  }

  // Check if current route requires authentication
  static bool isProtectedRoute(String location) {
    const protectedRoutes = [
      '/dashboard',
      '/products',
      '/product-search',
      '/transactions',
      '/settings',
      '/categories',
      '/stores',
      '/users',
      '/scanner',
      '/imei-scanner'
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
        title: Text(AppLocalizations.of(context)!.error),
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
                AppLocalizations.of(context)!.oopsWentWrong,
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
                child: Text(AppLocalizations.of(context)!.goToDashboard),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => _handleLogout(context),
                child: Text(AppLocalizations.of(context)!.logout),
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
