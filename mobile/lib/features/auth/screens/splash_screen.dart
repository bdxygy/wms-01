import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_provider.dart';
import '../../../core/providers/app_provider.dart';
import '../../../core/providers/store_context_provider.dart';
import '../../../generated/app_localizations.dart';

/// Modern Animated Splash Screen with Gradient Background and Smooth Transitions
/// 
/// Features:
/// - Beautiful gradient background with brand colors
/// - Animated logo with scale and fade transitions
/// - Floating animation effects
/// - Modern typography with smooth opacity transitions
/// - Enhanced loading indicator with pulsing effect
/// - Professional branding and smooth user experience
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> 
    with TickerProviderStateMixin {
  bool _isInitializing = false;
  
  // Animation controllers
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _loadingController;
  
  // Animations
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<Offset> _logoSlideAnimation;
  late Animation<double> _textOpacityAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _loadingPulseAnimation;
  
  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
    _initializeApp();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    // Logo animation controller (1.2 seconds)
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Text animation controller (800ms, delayed by 400ms)
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Loading pulse animation controller (continuous)
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Logo animations
    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _logoOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeInOut,
    ));

    _logoSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutBack,
    ));

    // Text animations
    _textOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeInOut,
    ));

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.5),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    ));

    // Loading pulse animation
    _loadingPulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _loadingController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimations() async {
    // Start logo animation immediately
    _logoController.forward();
    
    // Start text animation after 400ms delay
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      _textController.forward();
    }
    
    // Start loading pulse animation after 1 second delay and repeat
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      _loadingController.repeat(reverse: true);
    }
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

      // Wait a minimum time for splash experience (ensure animations complete)
     debugPrint('⏱️ Splash: Waiting for animations to complete');
      await Future.delayed(const Duration(seconds: 3));

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
      body: Container(
        // Modern gradient background
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withValues(alpha:0.8),
              Theme.of(context).colorScheme.secondary.withValues(alpha:0.6),
            ],
            stops: const [0.0, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                
                // Animated logo section
                _buildAnimatedLogo(),
                
                const SizedBox(height: 48),
                
                // Animated text section
                _buildAnimatedText(),
                
                const Spacer(),
                
                // Animated loading section
                _buildAnimatedLoading(),
                
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _logoController,
      builder: (context, child) {
        return SlideTransition(
          position: _logoSlideAnimation,
          child: FadeTransition(
            opacity: _logoOpacityAnimation,
            child: ScaleTransition(
              scale: _logoScaleAnimation,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha:0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.white.withValues(alpha:0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.warehouse_rounded,
                  size: 70,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedText() {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return SlideTransition(
          position: _textSlideAnimation,
          child: FadeTransition(
            opacity: _textOpacityAnimation,
            child: Column(
              children: [
                // App title with modern styling
                Text(
                  AppLocalizations.of(context)!.appTitle,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 12),
                
                // App tagline with elegant styling
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha:0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha:0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.appTagline,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha:0.9),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedLoading() {
    return AnimatedBuilder(
      animation: _loadingController,
      builder: (context, child) {
        return Column(
          children: [
            // Pulsing loading indicator
            ScaleTransition(
              scale: _loadingPulseAnimation,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha:0.2),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 3,
                      backgroundColor: Colors.white.withValues(alpha:0.2),
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Loading text
            Text(
              AppLocalizations.of(context)!.initializing,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha:0.8),
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        );
      },
    );
  }
}