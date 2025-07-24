import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme_colors.dart';
import 'typography.dart';

class AppTheme {
  static const String fontFamily = 'Poppins';

  // Custom WMS color scheme
  static const FlexSchemeColor _wmsLightScheme = FlexSchemeColor(
    primary: WMSColors.primaryBlue,
    primaryContainer: WMSColors.primaryBlueLight,
    secondary: WMSColors.secondaryGreen,
    secondaryContainer: WMSColors.secondaryGreenLight,
    tertiary: WMSColors.accentOrange,
    tertiaryContainer: WMSColors.accentOrangeLight,
    appBarColor: WMSColors.primaryBlue,
    error: WMSColors.errorRed,
  );

  static const FlexSchemeColor _wmsDarkScheme = FlexSchemeColor(
    primary: WMSColors.primaryBlueDark,
    primaryContainer: WMSColors.primaryBlue,
    secondary: WMSColors.secondaryGreenDark,
    secondaryContainer: WMSColors.secondaryGreen,
    tertiary: WMSColors.accentOrangeDark,
    tertiaryContainer: WMSColors.accentOrange,
    appBarColor: WMSColors.primaryBlueDark,
    error: WMSColors.errorRedDark,
  );

  // Light theme configuration
  static ThemeData get lightTheme {
    return FlexThemeData.light(
      colors: _wmsLightScheme,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 7,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 10,
        blendOnColors: false,
        useMaterial3Typography: true,
        useM2StyleDividerInM3: true,
        alignedDropdown: true,
        useInputDecoratorThemeInDialogs: true,
        inputDecoratorSchemeColor: SchemeColor.primary,
        inputDecoratorBorderSchemeColor: SchemeColor.outline,
        inputDecoratorRadius: 12.0,
        fabSchemeColor: SchemeColor.primary,
        fabUseShape: true,
        fabRadius: 16.0,
        chipSchemeColor: SchemeColor.primary,
        chipSelectedSchemeColor: SchemeColor.primary,
        chipRadius: 8.0,
        cardRadius: 12.0,
        cardElevation: 2.0,
        elevatedButtonRadius: 12.0,
        elevatedButtonElevation: 2.0,
        outlinedButtonRadius: 12.0,
        textButtonRadius: 12.0,
        dialogRadius: 16.0,
        timePickerDialogRadius: 16.0,
        snackBarRadius: 8.0,
        snackBarElevation: 4.0,
        appBarBackgroundSchemeColor: SchemeColor.primary,
        appBarForegroundSchemeColor: SchemeColor.onPrimary,
        tabBarIndicatorSchemeColor: SchemeColor.onPrimary,
        drawerIndicatorSchemeColor: SchemeColor.primary,
        bottomNavigationBarSelectedLabelSchemeColor: SchemeColor.primary,
        bottomNavigationBarSelectedIconSchemeColor: SchemeColor.primary,
        navigationBarSelectedLabelSchemeColor: SchemeColor.primary,
        navigationBarSelectedIconSchemeColor: SchemeColor.primary,
        navigationBarIndicatorSchemeColor: SchemeColor.primaryContainer,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      swapLegacyOnMaterial3: true,
      fontFamily: GoogleFonts.poppins().fontFamily,
    ).copyWith(
      textTheme: WMSTypography.createTextTheme(isDark: false),
      iconTheme: const IconThemeData(
        size: 24.0,
        color: WMSColors.textColor, // Dark icons in light mode
      ),
      appBarTheme: _buildAppBarTheme(isDark: false),
      bottomNavigationBarTheme: _buildBottomNavigationBarTheme(isDark: false),
      floatingActionButtonTheme: _buildFabTheme(isDark: false),
    );
  }

  // Dark theme configuration
  static ThemeData get darkTheme {
    return FlexThemeData.dark(
      colors: _wmsDarkScheme,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 13,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 20,
        useMaterial3Typography: true,
        useM2StyleDividerInM3: true,
        alignedDropdown: true,
        useInputDecoratorThemeInDialogs: true,
        inputDecoratorSchemeColor: SchemeColor.primary,
        inputDecoratorBorderSchemeColor: SchemeColor.outline,
        inputDecoratorRadius: 12.0,
        fabSchemeColor: SchemeColor.primary,
        fabUseShape: true,
        fabRadius: 16.0,
        chipSchemeColor: SchemeColor.primary,
        chipSelectedSchemeColor: SchemeColor.primary,
        chipRadius: 8.0,
        cardRadius: 12.0,
        cardElevation: 4.0,
        elevatedButtonRadius: 12.0,
        elevatedButtonElevation: 2.0,
        outlinedButtonRadius: 12.0,
        textButtonRadius: 12.0,
        dialogRadius: 16.0,
        timePickerDialogRadius: 16.0,
        snackBarRadius: 8.0,
        snackBarElevation: 4.0,
        appBarBackgroundSchemeColor: SchemeColor.surface,
        appBarForegroundSchemeColor: SchemeColor.onSurface,
        tabBarIndicatorSchemeColor: SchemeColor.primary,
        drawerIndicatorSchemeColor: SchemeColor.primary,
        bottomNavigationBarSelectedLabelSchemeColor: SchemeColor.primary,
        bottomNavigationBarSelectedIconSchemeColor: SchemeColor.primary,
        navigationBarSelectedLabelSchemeColor: SchemeColor.primary,
        navigationBarSelectedIconSchemeColor: SchemeColor.primary,
        navigationBarIndicatorSchemeColor: SchemeColor.primaryContainer,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      swapLegacyOnMaterial3: true,
      fontFamily: GoogleFonts.poppins().fontFamily,
    ).copyWith(
      textTheme: WMSTypography.createTextTheme(isDark: true),
      iconTheme: const IconThemeData(
        size: 24.0,
        color: WMSColors.iconColorDark,
      ),
      appBarTheme: _buildAppBarTheme(isDark: true),
      bottomNavigationBarTheme: _buildBottomNavigationBarTheme(isDark: true),
      floatingActionButtonTheme: _buildFabTheme(isDark: true),
    );
  }

  // Custom app bar theme
  static AppBarTheme _buildAppBarTheme({required bool isDark}) {
    return AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 4,
      centerTitle: true,
      backgroundColor: isDark ? WMSColors.surfaceDark : WMSColors.primaryBlue,
      foregroundColor: isDark ? WMSColors.textColorDark : Colors.white,
      systemOverlayStyle: isDark
          ? const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness:
                  Brightness.light, // Light icons in dark mode
              statusBarBrightness:
                  Brightness.dark, // Dark status bar background
            )
          : const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness:
                  Brightness.dark, // Dark icons in light mode
              statusBarBrightness:
                  Brightness.light, // Light status bar background
            ),
      titleTextStyle: WMSTypography.appBarTitle.copyWith(
        color: isDark ? WMSColors.textColorDark : Colors.white,
      ),
      iconTheme: IconThemeData(
        color: isDark ? WMSColors.textColorDark : Colors.white,
        size: 24,
      ),
      actionsIconTheme: IconThemeData(
        color: isDark ? WMSColors.textColorDark : Colors.white,
        size: 24,
      ),
    );
  }

  // Custom bottom navigation bar theme
  static BottomNavigationBarThemeData _buildBottomNavigationBarTheme(
      {required bool isDark}) {
    return BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: isDark ? WMSColors.surfaceDark : Colors.white,
      selectedItemColor: WMSColors.primaryBlue,
      unselectedItemColor:
          isDark ? WMSColors.textSecondaryDark : WMSColors.textSecondary,
      selectedLabelStyle: WMSTypography.labelSmall.copyWith(
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: WMSTypography.labelSmall.copyWith(
        fontWeight: FontWeight.w400,
      ),
      elevation: 8,
      showUnselectedLabels: true,
    );
  }

  // Custom floating action button theme
  static FloatingActionButtonThemeData _buildFabTheme({required bool isDark}) {
    return FloatingActionButtonThemeData(
      backgroundColor: WMSColors.primaryBlue,
      foregroundColor: Colors.white,
      elevation: 6,
      focusElevation: 8,
      hoverElevation: 8,
      highlightElevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

// System UI overlay styles for status bar
class SystemUIStyles {
  static const SystemUiOverlayStyle lightStatusBar = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light, // Light icons on dark background
    statusBarBrightness: Brightness.dark, // Dark status bar background
    systemNavigationBarColor: Colors.black,
    systemNavigationBarIconBrightness: Brightness.light,
  );

  static const SystemUiOverlayStyle darkStatusBar = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark, // Dark icons on light background
    statusBarBrightness: Brightness.light, // Light status bar background
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  );
}
