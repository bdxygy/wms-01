import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_provider.dart';
import '../../../core/providers/app_provider.dart';
import '../../../core/providers/store_context_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Initialize app providers
    final appProvider = context.read<AppProvider>();
    final authProvider = context.read<AuthProvider>();
    final storeProvider = context.read<StoreContextProvider>();

    try {
      // Initialize app settings
      await appProvider.initialize();
      
      // Initialize authentication
      await authProvider.initialize();
      
      // Initialize store context if authenticated
      if (authProvider.isAuthenticated) {
        await storeProvider.initialize();
      }

      // Wait a minimum time for splash experience
      await Future.delayed(const Duration(seconds: 2));

      // Navigate based on authentication state
      if (mounted) {
        _navigateBasedOnState();
      }
    } catch (e) {
      // Handle initialization error
      if (mounted) {
        _showErrorAndRetry(e.toString());
      }
    }
  }

  void _navigateBasedOnState() {
    final authProvider = context.read<AuthProvider>();
    final storeProvider = context.read<StoreContextProvider>();

    if (!authProvider.isAuthenticated) {
      // Navigate to login
      context.goNamed('login');
    } else if (authProvider.needsStoreSelection && !storeProvider.hasStoreSelected) {
      // Navigate to store selection
      context.goNamed('store-selection');
    } else {
      // Navigate to main dashboard
      context.goNamed('dashboard');
    }
  }

  void _showErrorAndRetry(String error) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Initialization Error'),
        content: Text('Failed to initialize app: $error'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _initializeApp();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo/icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onPrimary,
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.warehouse,
                size: 60,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // App name
            Text(
              'WMS Mobile',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // App tagline
            Text(
              'Warehouse Management System',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.8),
              ),
            ),
            
            const SizedBox(height: 48),
            
            // Loading indicator
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.onPrimary,
                ),
                strokeWidth: 3,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Loading text
            Text(
              'Initializing...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}