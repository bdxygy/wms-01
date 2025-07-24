import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/utils/app_config.dart';
import 'generated/app_localizations.dart';
import 'core/providers/app_provider.dart';
import 'core/auth/auth_provider.dart';
import 'core/providers/store_context_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set environment - in production this would be configured via build variants
  AppConfig.setEnvironment(Environment.dev);
  
  runApp(const WMSApp());
}

class WMSApp extends StatelessWidget {
  const WMSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => StoreContextProvider()),
      ],
      child: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          // Apply system overlay style based on theme mode
          final isDarkMode = appProvider.themeMode == ThemeMode.dark ||
              (appProvider.themeMode == ThemeMode.system &&
                  MediaQuery.platformBrightnessOf(context) == Brightness.dark);
          
          SystemChrome.setSystemUIOverlayStyle(
            isDarkMode
                ? const SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    statusBarIconBrightness: Brightness.light, // Light icons in dark mode
                    statusBarBrightness: Brightness.dark, // Dark status bar background
                    systemNavigationBarColor: Colors.black,
                    systemNavigationBarIconBrightness: Brightness.light,
                  )
                : const SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    statusBarIconBrightness: Brightness.dark, // Dark icons in light mode
                    statusBarBrightness: Brightness.light, // Light status bar background
                    systemNavigationBarColor: Colors.white,
                    systemNavigationBarIconBrightness: Brightness.dark,
                  ),
          );
          
          return MaterialApp.router(
            title: 'WMS Mobile',
            debugShowCheckedModeBanner: false,
            
            // Theme configuration
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: appProvider.themeMode,
            
            // Localization
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: appProvider.locale,
            
            // Router configuration
            routerConfig: AppRouter.createRouter(),
            
            // Material app configuration
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(1.0), // Disable font scaling
                ),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}
