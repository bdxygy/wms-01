import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_provider.dart';
import '../../../core/providers/app_provider.dart';
import '../../../core/providers/store_context_provider.dart';
import '../../../generated/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isInitializing = false;
  
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Prevent multiple concurrent initialization
    if (_isInitializing) {
     debugPrint('⚠️ Splash: Already initializing, skipping...');
      return;
    }
    
    _isInitializing = true;
    
    // Initialize app providers
    final appProvider = context.read<AppProvider>();
    final authProvider = context.read<AuthProvider>();
    final storeProvider = context.read<StoreContextProvider>();

    try {
     debugPrint('🚀 Splash: Starting app initialization');
      
      // Initialize app settings
     debugPrint('📱 Splash: Initializing app provider');
      await appProvider.initialize();
     debugPrint('✅ Splash: App provider initialized');
      
      // Initialize authentication
     debugPrint('🔐 Splash: Initializing auth provider');
      try {
        await authProvider.initialize().timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw Exception('Auth initialization timeout');
          },
        );
       debugPrint('✅ Splash: Auth provider initialized, state: ${authProvider.state}');
      } catch (authError) {
       debugPrint('⚠️ Splash: Auth provider initialization failed: $authError');
        // Clear potentially corrupted auth data and continue
        await authProvider.logout();
       debugPrint('🧹 Splash: Cleared auth data, continuing...');
      }
      
      // Authentication initialization completed successfully
      
      // Initialize store context if authenticated
      if (authProvider.isAuthenticated) {
       debugPrint('🏪 Splash: Initializing store provider');
        await storeProvider.initialize();
       debugPrint('✅ Splash: Store provider initialized');
      }

      // Wait a minimum time for splash experience
     debugPrint('⏱️ Splash: Waiting 2 seconds');
      await Future.delayed(const Duration(seconds: 2));

      // Navigate based on authentication state
     debugPrint('🧭 Splash: Ready to navigate');
      if (mounted) {
        _navigateBasedOnState();
      }
    } catch (e) {
      // Handle initialization error
     debugPrint('❌ Splash: Initialization error: $e');
      if (mounted) {
        _showErrorAndRetry(e.toString());
      }
    } finally {
      _isInitializing = false;
    }
  }

  void _navigateBasedOnState() {
    final authProvider = context.read<AuthProvider>();
    final storeProvider = context.read<StoreContextProvider>();

   debugPrint('🧭 Splash: Navigation check - authenticated: ${authProvider.isAuthenticated}');
   debugPrint('🧭 Splash: Navigation check - needsStoreSelection: ${authProvider.needsStoreSelection}');
   debugPrint('🧭 Splash: Navigation check - hasStoreSelected: ${storeProvider.hasStoreSelected}');

    if (!authProvider.isAuthenticated) {
      // Navigate to login
     debugPrint('➡️ Splash: Navigating to login');
      context.go('/login');
    } else if (authProvider.needsStoreSelection && !storeProvider.hasStoreSelected) {
      // Navigate to store selection
     debugPrint('➡️ Splash: Navigating to store selection');
      context.go('/store-selection');
    } else {
      // Navigate to main dashboard
     debugPrint('➡️ Splash: Navigating to dashboard');
      context.go('/dashboard');
    }
  }

  void _showErrorAndRetry(String error) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.error),
        content: Text('Failed to initialize app: $error'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _isInitializing = false;  // Reset flag before retry
              _initializeApp();
            },
            child: Text(AppLocalizations.of(context)!.retry),
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
              AppLocalizations.of(context)!.appTitle,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // App tagline
            Text(
              AppLocalizations.of(context)!.appTagline,
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
              AppLocalizations.of(context)!.initializing,
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