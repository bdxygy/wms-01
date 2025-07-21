import 'package:flutter/material.dart';

import '../services/product_service.dart';
import '../routing/app_router.dart';
import '../widgets/global_barcode_scanner.dart';

/// Utility class for launching the global barcode scanner with different configurations
class ScannerLauncher {
  /// Launch scanner for IMEI entry with auto-fill callback
  /// 
  /// Example usage:
  /// ```dart
  /// ScannerLauncher.forImeiEntry(
  ///   context,
  ///   onImeiScanned: (imei) {
  ///     // Auto-fill IMEI field
  ///     controller.text = imei;
  ///   },
  /// );
  /// ```
  static Future<void> forImeiEntry(
    BuildContext context, {
    required Function(String imei) onImeiScanned,
    String? title,
    String? subtitle,
    VoidCallback? onDismiss,
  }) async {
    final config = BarcodeScannerConfig(
      title: title ?? 'Scan IMEI Barcode',
      subtitle: subtitle ?? 'Scan the IMEI barcode on the device',
      allowManualEntry: true,
      showHistory: false,
      allowedTypes: null, // Allow all barcode types
      autoClose: true,
    );

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GlobalBarcodeScanner(
          config: config,
          onScanResult: (result) async {
            if (result.isValid && result.formattedCode.length >= 14) {
              onImeiScanned(result.formattedCode);
            } else {
              throw Exception('IMEI must be at least 14 characters long');
            }
          },
          onDismiss: onDismiss,
        ),
      ),
    );
  }

  /// Launch scanner for product search with service callback
  /// 
  /// Example usage:
  /// ```dart
  /// ScannerLauncher.forProductSearch(
  ///   context,
  ///   onProductFound: (product) {
  ///     // Navigate to product detail or add to cart
  ///     AppRouter.goToProductDetail(context, product.id);
  ///   },
  ///   onProductNotFound: (barcode) {
  ///     // Handle product not found case
  ///     showDialog(...);
  ///   },
  /// );
  /// ```
  static Future<void> forProductSearch(
    BuildContext context, {
    required Function(dynamic product) onProductFound,
    required Function(String barcode) onProductNotFound,
    String? title,
    String? subtitle,
    VoidCallback? onDismiss,
  }) async {
    final productService = ProductService();
    
    final config = BarcodeScannerConfig(
      title: title ?? 'Scan Product Barcode',
      subtitle: subtitle ?? 'Scan barcode to search for product',
      allowManualEntry: true,
      showHistory: true,
      autoClose: true,
    );

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GlobalBarcodeScanner(
          config: config,
          onScanResult: (result) async {
            if (!result.isValid) {
              throw Exception('Invalid barcode format');
            }

            try {
              final product = await productService.getProductByBarcode(result.formattedCode);
              onProductFound(product);
            } catch (e) {
              onProductNotFound(result.formattedCode);
              throw Exception('Product not found: ${e.toString()}');
            }
          },
          onDismiss: onDismiss,
        ),
      ),
    );
  }

  /// Launch scanner for IMEI product search (searches by IMEI instead of barcode)
  /// 
  /// Example usage:
  /// ```dart
  /// ScannerLauncher.forImeiProductSearch(
  ///   context,
  ///   onProductFound: (product) {
  ///     AppRouter.goToProductDetail(context, product.id);
  ///   },
  ///   onImeiNotFound: (imei) {
  ///     showErrorDialog('No product found with IMEI: $imei');
  ///   },
  /// );
  /// ```
  static Future<void> forImeiProductSearch(
    BuildContext context, {
    required Function(dynamic product) onProductFound,
    required Function(String imei) onImeiNotFound,
    String? title,
    String? subtitle,
    VoidCallback? onDismiss,
  }) async {
    final productService = ProductService();
    
    final config = BarcodeScannerConfig(
      title: title ?? 'Scan IMEI',
      subtitle: subtitle ?? 'Scan IMEI to find product',
      allowManualEntry: true,
      showHistory: true,
      allowedTypes: null, // Allow all barcode types
      autoClose: true,
    );

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GlobalBarcodeScanner(
          config: config,
          onScanResult: (result) async {
            if (!result.isValid || result.formattedCode.length < 14) {
              throw Exception('IMEI must be at least 14 characters long');
            }

            try {
              final product = await productService.getProductByImei(result.formattedCode);
              onProductFound(product);
            } catch (e) {
              onImeiNotFound(result.formattedCode);
              throw Exception('No product found with this IMEI: ${e.toString()}');
            }
          },
          onDismiss: onDismiss,
        ),
      ),
    );
  }

  /// Launch scanner for custom use case with flexible callback
  /// 
  /// Example usage:
  /// ```dart
  /// ScannerLauncher.forCustomAction(
  ///   context,
  ///   title: 'Scan QR Code',
  ///   allowedTypes: ['QR_CODE'],
  ///   onScanResult: (result) async {
  ///     // Custom processing logic
  ///     if (result.formattedCode.startsWith('https://')) {
  ///       // Open URL
  ///       launchUrl(Uri.parse(result.formattedCode));
  ///     } else {
  ///       throw Exception('Invalid QR code format');
  ///     }
  ///   },
  /// );
  /// ```
  static Future<void> forCustomAction(
    BuildContext context, {
    required Future<void> Function(BarcodeScanResult result) onScanResult,
    String? title,
    String? subtitle,
    bool allowManualEntry = true,
    bool showHistory = false,
    List<String>? allowedTypes,
    bool autoClose = true,
    Duration? scanDebounce,
    bool enableHapticFeedback = true,
    VoidCallback? onDismiss,
  }) async {
    final config = BarcodeScannerConfig(
      title: title,
      subtitle: subtitle,
      allowManualEntry: allowManualEntry,
      showHistory: showHistory,
      allowedTypes: allowedTypes,
      autoClose: autoClose,
      scanDebounce: scanDebounce,
      enableHapticFeedback: enableHapticFeedback,
    );

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GlobalBarcodeScanner(
          config: config,
          onScanResult: onScanResult,
          onDismiss: onDismiss,
        ),
      ),
    );
  }

  /// Launch scanner for general barcode scanning (no specific action)
  /// Returns the scan result through a Future
  /// 
  /// Example usage:
  /// ```dart
  /// final result = await ScannerLauncher.scanBarcode(context);
  /// if (result != null && result.isValid) {
  ///  debugPrint('Scanned: ${result.formattedCode}');
  /// }
  /// ```
  static Future<BarcodeScanResult?> scanBarcode(
    BuildContext context, {
    String? title,
    String? subtitle,
    bool allowManualEntry = true,
    bool showHistory = false,
    List<String>? allowedTypes,
    Duration? scanDebounce,
    bool enableHapticFeedback = true,
  }) async {
    BarcodeScanResult? scanResult;
    
    final config = BarcodeScannerConfig(
      title: title ?? 'Scan Barcode',
      subtitle: subtitle ?? 'Position barcode within the frame',
      allowManualEntry: allowManualEntry,
      showHistory: showHistory,
      allowedTypes: allowedTypes,
      autoClose: true,
      scanDebounce: scanDebounce,
      enableHapticFeedback: enableHapticFeedback,
    );

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GlobalBarcodeScanner(
          config: config,
          onScanResult: (result) async {
            scanResult = result;
            // Don't throw error, just capture the result
          },
        ),
      ),
    );

    return scanResult;
  }
}