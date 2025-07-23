import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme_colors.dart';

/// Typography utilities for the WMS application
/// Provides consistent text styles and font configurations
class WMSTypography {
  // Private constructor to prevent instantiation
  WMSTypography._();

  // === FONT CONFIGURATION ===
  static const String primaryFontFamily = 'Poppins';
  static final String googleFontFamily = GoogleFonts.poppins().fontFamily!;

  // === TEXT STYLE GETTERS ===
  
  /// Get headline text styles
  static TextStyle get headlineLarge => GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static TextStyle get headlineMedium => GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
    height: 1.3,
  );

  static TextStyle get headlineSmall => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.25,
    height: 1.3,
  );

  /// Get title text styles
  static TextStyle get titleLarge => GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
  );

  static TextStyle get titleMedium => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    height: 1.5,
  );

  static TextStyle get titleSmall => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.4,
  );

  /// Get body text styles
  static TextStyle get bodyLarge => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.5,
  );

  static TextStyle get bodyMedium => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.4,
  );

  static TextStyle get bodySmall => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.3,
  );

  /// Get label text styles
  static TextStyle get labelLarge => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.4,
  );

  static TextStyle get labelMedium => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.3,
  );

  static TextStyle get labelSmall => GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.2,
  );

  // === SPECIAL PURPOSE TEXT STYLES ===

  /// Button text styles
  static TextStyle get buttonLarge => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.2,
  );

  static TextStyle get buttonMedium => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.2,
  );

  static TextStyle get buttonSmall => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.2,
  );

  /// Caption and overline text styles
  static TextStyle get caption => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.3,
  );

  static TextStyle get overline => GoogleFonts.poppins(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
    height: 1.6,
  );

  /// App bar title style
  static TextStyle get appBarTitle => GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.2,
  );

  /// Tab text style
  static TextStyle get tabText => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.2,
  );

  /// Numeric display styles (for prices, quantities, etc.)
  static TextStyle get numericLarge => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.2,
  );

  static TextStyle get numericMedium => GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.2,
  );

  static TextStyle get numericSmall => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.2,
  );

  // === CONTEXT-SPECIFIC TEXT STYLES ===

  /// Product related text styles
  static TextStyle get productName => titleMedium.copyWith(
    fontWeight: FontWeight.w600,
  );

  static TextStyle get productSku => bodySmall.copyWith(
    fontWeight: FontWeight.w500,
  );

  static TextStyle get productPrice => numericMedium.copyWith(
    color: WMSColors.primaryBlue,
  );

  /// Transaction related text styles
  static TextStyle get transactionId => bodySmall.copyWith(
    fontWeight: FontWeight.w500,
    fontFeatures: [const FontFeature.tabularFigures()],
  );

  static TextStyle get transactionAmount => numericLarge.copyWith(
    color: WMSColors.successGreen,
  );

  /// User interface text styles
  static TextStyle get formLabel => labelMedium.copyWith(
    fontWeight: FontWeight.w500,
  );

  static TextStyle get formError => bodySmall.copyWith(
    color: WMSColors.errorRed,
  );

  static TextStyle get formHint => bodySmall;

  /// Status text styles
  static TextStyle get statusActive => labelSmall.copyWith(
    color: WMSColors.successGreen,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get statusInactive => labelSmall.copyWith(
    color: WMSColors.textSecondary,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get statusWarning => labelSmall.copyWith(
    color: WMSColors.warningAmber,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get statusError => labelSmall.copyWith(
    color: WMSColors.errorRed,
    fontWeight: FontWeight.w600,
  );

  // === HELPER METHODS ===

  /// Apply color to text style
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Apply opacity to text style
  static TextStyle withOpacity(TextStyle style, double opacity) {
    return style.copyWith(color: style.color?.withValues(alpha:opacity));
  }

  /// Apply font weight to text style
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  /// Apply font size to text style
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }

  /// Get text style for specific role
  static TextStyle getRoleStyle(String role) {
    final baseStyle = labelMedium.copyWith(fontWeight: FontWeight.w600);
    return baseStyle.copyWith(color: WMSColors.getRoleColor(role));
  }

  /// Get text style for transaction type
  static TextStyle getTransactionTypeStyle(String type) {
    final baseStyle = labelMedium.copyWith(fontWeight: FontWeight.w600);
    return baseStyle.copyWith(color: WMSColors.getTransactionTypeColor(type));
  }

  /// Get text style for product status
  static TextStyle getProductStatusStyle(String status) {
    final baseStyle = labelSmall.copyWith(fontWeight: FontWeight.w600);
    return baseStyle.copyWith(color: WMSColors.getProductStatusColor(status));
  }

  /// Get responsive text style based on screen size
  static TextStyle getResponsiveStyle(BuildContext context, TextStyle baseStyle) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < 360) {
      // Small screen - reduce font size by 10%
      return baseStyle.copyWith(
        fontSize: (baseStyle.fontSize ?? 14) * 0.9,
      );
    } else if (screenWidth > 600) {
      // Large screen - increase font size by 10%
      return baseStyle.copyWith(
        fontSize: (baseStyle.fontSize ?? 14) * 1.1,
      );
    }
    
    return baseStyle;
  }

  /// Create text theme for Material Design
  static TextTheme createTextTheme({required bool isDark}) {
    final baseColor = isDark ? WMSColors.textColorDark : WMSColors.textColor;
    final secondaryColor = isDark ? WMSColors.textSecondaryDark : WMSColors.textSecondary;

    return TextTheme(
      headlineLarge: headlineLarge.copyWith(color: baseColor),
      headlineMedium: headlineMedium.copyWith(color: baseColor),
      headlineSmall: headlineSmall.copyWith(color: baseColor),
      titleLarge: titleLarge.copyWith(color: baseColor),
      titleMedium: titleMedium.copyWith(color: baseColor),
      titleSmall: titleSmall.copyWith(color: baseColor),
      bodyLarge: bodyLarge.copyWith(color: baseColor),
      bodyMedium: bodyMedium.copyWith(color: baseColor),
      bodySmall: bodySmall.copyWith(color: secondaryColor),
      labelLarge: labelLarge.copyWith(color: baseColor),
      labelMedium: labelMedium.copyWith(color: baseColor),
      labelSmall: labelSmall.copyWith(color: secondaryColor),
    );
  }
}

/// Extension on TextStyle for common modifications
extension WMSTextStyleExtension on TextStyle {
  /// Make text bold
  TextStyle get bold => copyWith(fontWeight: FontWeight.bold);
  
  /// Make text semi-bold
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);
  
  /// Make text medium weight
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);
  
  /// Make text regular weight
  TextStyle get regular => copyWith(fontWeight: FontWeight.w400);
  
  /// Make text light weight
  TextStyle get light => copyWith(fontWeight: FontWeight.w300);
  
  /// Apply primary color
  TextStyle get primary => copyWith(color: WMSColors.primaryBlue);
  
  /// Apply secondary color
  TextStyle get secondary => copyWith(color: WMSColors.secondaryGreen);
  
  /// Apply error color
  TextStyle get error => copyWith(color: WMSColors.errorRed);
  
  /// Apply success color
  TextStyle get success => copyWith(color: WMSColors.successGreen);
  
  /// Apply warning color
  TextStyle get warning => copyWith(color: WMSColors.warningAmber);
  
  /// Apply custom color
  TextStyle withCustomColor(Color color) => copyWith(color: color);
  
  /// Apply custom opacity
  TextStyle withCustomOpacity(double opacity) => copyWith(
    color: color?.withValues(alpha:opacity),
  );
  
  /// Scale font size
  TextStyle scale(double factor) => copyWith(
    fontSize: (fontSize ?? 14) * factor,
  );
}