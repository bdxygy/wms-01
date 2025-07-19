import 'package:flutter/material.dart';

/// WMS application color palette
/// Defines the brand colors and design system colors for the WMS application
class WMSColors {
  // Private constructor to prevent instantiation
  WMSColors._();

  // === PRIMARY COLORS ===
  /// Primary blue - main brand color for buttons, headers, navigation
  static const Color primaryBlue = Color(0xFF1976D2); // Material Blue 700
  static const Color primaryBlueLight = Color(0xFF42A5F5); // Material Blue 400
  static const Color primaryBlueDark = Color(0xFF0D47A1); // Material Blue 900

  // === SECONDARY COLORS ===
  /// Secondary green - for success states, confirmations, active states
  static const Color secondaryGreen = Color(0xFF388E3C); // Material Green 600
  static const Color secondaryGreenLight = Color(0xFF66BB6A); // Material Green 400
  static const Color secondaryGreenDark = Color(0xFF1B5E20); // Material Green 900

  // === ACCENT COLORS ===
  /// Accent orange - for warnings, highlights, call-to-action
  static const Color accentOrange = Color(0xFFFF9800); // Material Orange 500
  static const Color accentOrangeLight = Color(0xFFFFB74D); // Material Orange 300
  static const Color accentOrangeDark = Color(0xFFE65100); // Material Orange 900

  // === STATUS COLORS ===
  /// Error red - for error states, validation errors, destructive actions
  static const Color errorRed = Color(0xFFD32F2F); // Material Red 700
  static const Color errorRedLight = Color(0xFFEF5350); // Material Red 400
  static const Color errorRedDark = Color(0xFFB71C1C); // Material Red 900

  /// Warning amber - for warning states, pending actions
  static const Color warningAmber = Color(0xFFFFA000); // Material Amber 600
  static const Color warningAmberLight = Color(0xFFFFCC02); // Material Amber 400
  static const Color warningAmberDark = Color(0xFFFF6F00); // Material Amber 900

  /// Info blue - for informational messages, help text
  static const Color infoBlue = Color(0xFF1976D2); // Same as primary
  static const Color infoBlueLight = Color(0xFF2196F3); // Material Blue 500
  static const Color infoBlueDark = Color(0xFF0D47A1); // Material Blue 900

  /// Success green - for success messages, completed actions
  static const Color successGreen = Color(0xFF388E3C); // Same as secondary
  static const Color successGreenLight = Color(0xFF4CAF50); // Material Green 500
  static const Color successGreenDark = Color(0xFF1B5E20); // Material Green 900

  // === NEUTRAL COLORS ===
  /// Surface colors for cards, sheets, dialogs
  static const Color surface = Color(0xFFFFFFFF); // White
  static const Color surfaceDark = Color(0xFF121212); // Dark surface
  static const Color surfaceVariant = Color(0xFFF5F5F5); // Light grey
  static const Color surfaceVariantDark = Color(0xFF1E1E1E); // Dark variant

  /// Background colors
  static const Color background = Color(0xFFFAFAFA); // Very light grey
  static const Color backgroundDark = Color(0xFF0A0A0A); // Very dark grey

  /// Outline colors for borders, dividers
  static const Color outline = Color(0xFFE0E0E0); // Light grey
  static const Color outlineDark = Color(0xFF424242); // Dark grey
  static const Color outlineVariant = Color(0xFFBDBDBD); // Medium grey
  static const Color outlineVariantDark = Color(0xFF616161); // Medium dark grey

  // === TEXT COLORS ===
  /// Primary text colors
  static const Color textColor = Color(0xFF212121); // Almost black
  static const Color textColorDark = Color(0xFFFFFFFF); // White
  
  /// Secondary text colors
  static const Color textSecondary = Color(0xFF757575); // Medium grey
  static const Color textSecondaryDark = Color(0xFFB3B3B3); // Light grey
  
  /// Tertiary text colors
  static const Color textTertiary = Color(0xFF9E9E9E); // Light grey
  static const Color textTertiaryDark = Color(0xFF616161); // Medium dark grey
  
  /// Disabled text colors
  static const Color textDisabled = Color(0xFFBDBDBD); // Very light grey
  static const Color textDisabledDark = Color(0xFF424242); // Dark grey

  // === ICON COLORS ===
  /// Icon colors
  static const Color iconColor = Color(0xFF616161); // Medium dark grey
  static const Color iconColorDark = Color(0xFFE0E0E0); // Light grey
  static const Color iconActive = primaryBlue;
  static const Color iconInactive = Color(0xFF9E9E9E);

  // === ROLE-BASED COLORS ===
  /// Colors specific to user roles
  static const Color ownerColor = Color(0xFF6A1B9A); // Purple 800
  static const Color adminColor = Color(0xFF1976D2); // Blue 700 (primary)
  static const Color staffColor = Color(0xFF388E3C); // Green 600
  static const Color cashierColor = Color(0xFFFF9800); // Orange 500

  // === TRANSACTION TYPE COLORS ===
  /// Colors for different transaction types
  static const Color saleColor = Color(0xFF4CAF50); // Green 500
  static const Color transferColor = Color(0xFF2196F3); // Blue 500
  static const Color returnColor = Color(0xFFFF5722); // Deep Orange 500

  // === PRODUCT STATUS COLORS ===
  /// Colors for product checking statuses
  static const Color statusPending = Color(0xFFFFC107); // Amber 500
  static const Color statusOk = Color(0xFF4CAF50); // Green 500
  static const Color statusMissing = Color(0xFFFF5722); // Deep Orange 500
  static const Color statusBroken = Color(0xFFE91E63); // Pink 500

  // === PRINTER STATUS COLORS ===
  /// Colors for printer connection status
  static const Color printerConnected = successGreen;
  static const Color printerDisconnected = errorRed;
  static const Color printerConnecting = warningAmber;

  // === SCANNER COLORS ===
  /// Colors for barcode scanner overlay
  static const Color scannerOverlay = Color(0x66000000); // Semi-transparent black
  static const Color scannerFrame = primaryBlue;
  static const Color scannerSuccess = successGreen;
  static const Color scannerError = errorRed;

  // === GRADIENTS ===
  /// Primary gradient for headers, buttons
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryBlue, primaryBlueDark],
  );

  /// Success gradient
  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryGreen, secondaryGreenDark],
  );

  /// Warning gradient
  static const LinearGradient warningGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentOrange, accentOrangeDark],
  );

  /// Error gradient
  static const LinearGradient errorGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [errorRed, errorRedDark],
  );

  // === SHADOWS ===
  /// Standard shadow colors
  static const Color shadowLight = Color(0x1A000000); // Light shadow
  static const Color shadowMedium = Color(0x33000000); // Medium shadow
  static const Color shadowDark = Color(0x4D000000); // Dark shadow

  // === HELPER METHODS ===
  /// Get role color based on role string
  static Color getRoleColor(String role) {
    switch (role.toUpperCase()) {
      case 'OWNER':
        return ownerColor;
      case 'ADMIN':
        return adminColor;
      case 'STAFF':
        return staffColor;
      case 'CASHIER':
        return cashierColor;
      default:
        return textSecondary;
    }
  }

  /// Get transaction type color
  static Color getTransactionTypeColor(String type) {
    switch (type.toUpperCase()) {
      case 'SALE':
        return saleColor;
      case 'TRANSFER':
        return transferColor;
      case 'RETURN':
        return returnColor;
      default:
        return textSecondary;
    }
  }

  /// Get product status color
  static Color getProductStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return statusPending;
      case 'OK':
        return statusOk;
      case 'MISSING':
        return statusMissing;
      case 'BROKEN':
        return statusBroken;
      default:
        return textSecondary;
    }
  }

  /// Get color with opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  /// Create a lighter version of a color
  static Color lighten(Color color, [double amount = 0.1]) {
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  /// Create a darker version of a color
  static Color darken(Color color, [double amount = 0.1]) {
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
}