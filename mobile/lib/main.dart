import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

import 'core/utils/app_config.dart';
import 'core/providers/app_provider.dart';
import 'core/auth/auth_provider.dart';
import 'core/providers/store_context_provider.dart';
import 'features/auth/screens/splash_screen.dart';

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
          return MaterialApp(
            title: 'WMS Mobile',
            debugShowCheckedModeBanner: false,
            
            // Theme configuration
            theme: _buildLightTheme(),
            darkTheme: _buildDarkTheme(),
            themeMode: appProvider.themeMode,
            
            // Localization
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', 'US'), // English
              Locale('id', 'ID'), // Indonesian
            ],
            locale: appProvider.locale,
            
            // Initial route
            home: const SplashScreen(),
            
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

  ThemeData _buildLightTheme() {
    return FlexThemeData.light(
      scheme: FlexScheme.blue,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 7,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 10,
        blendOnColors: false,
        useMaterial3Typography: true,
        useM2StyleDividerInM3: true,
        alignedDropdown: true,
        useInputDecoratorThemeInDialogs: true,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      swapLegacyOnMaterial3: true,
      fontFamily: GoogleFonts.poppins().fontFamily,
    ).copyWith(
      textTheme: GoogleFonts.poppinsTextTheme(),
    );
  }

  ThemeData _buildDarkTheme() {
    return FlexThemeData.dark(
      scheme: FlexScheme.blue,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 13,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 20,
        useMaterial3Typography: true,
        useM2StyleDividerInM3: true,
        alignedDropdown: true,
        useInputDecoratorThemeInDialogs: true,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      swapLegacyOnMaterial3: true,
      fontFamily: GoogleFonts.poppins().fontFamily,
    ).copyWith(
      textTheme: GoogleFonts.poppinsTextTheme(),
    );
  }
}
