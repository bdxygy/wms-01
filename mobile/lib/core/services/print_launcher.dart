import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/product.dart';
import '../models/user.dart';
import '../models/store.dart';
import '../widgets/bluetooth_setup_dialog.dart';

/// Global service for thermal printer operations via Bluetooth
class PrintLauncher {
  static final PrintLauncher _instance = PrintLauncher._internal();
  factory PrintLauncher() => _instance;
  PrintLauncher._internal();

  /// Check if all required Bluetooth permissions are granted
  Future<bool> get hasBluetoothPermission async {
    try {
      // Check individual permissions using permission_handler (more reliable)
      final bluetoothConnect = await Permission.bluetoothConnect.status;
      final bluetoothScan = await Permission.bluetoothScan.status;
      final location = await Permission.location.status;

      debugPrint('Bluetooth Connect: $bluetoothConnect');
      debugPrint('Bluetooth Scan: $bluetoothScan');
      debugPrint('Location: $location');

      // For Android 12+ (API 31+), we need BLUETOOTH_CONNECT and BLUETOOTH_SCAN
      // For older versions, we need location permission
      final hasModernPermissions =
          (bluetoothConnect.isGranted || bluetoothConnect.isLimited) &&
              (bluetoothScan.isGranted || bluetoothScan.isLimited);

      final hasLegacyPermissions = location.isGranted;

      final hasPermissions = hasModernPermissions || hasLegacyPermissions;

      debugPrint('Has Bluetooth permissions: $hasPermissions');
      return hasPermissions;
    } catch (e) {
      debugPrint('Error checking Bluetooth permission: $e');
      return false;
    }
  }

  /// Request all necessary Bluetooth permissions
  Future<bool> requestBluetoothPermissions() async {
    try {
      // Request permissions step by step with explanations
      final permissions = <Permission>[];

      // Check what permissions we need to request
      if (!(await Permission.bluetoothConnect.isGranted)) {
        permissions.add(Permission.bluetoothConnect);
      }

      if (!(await Permission.bluetoothScan.isGranted)) {
        permissions.add(Permission.bluetoothScan);
      }

      if (!(await Permission.location.isGranted)) {
        permissions.add(Permission.location);
      }

      if (permissions.isNotEmpty) {
        final results = await permissions.request();

        // Check if all permissions were granted
        for (final permission in permissions) {
          final status = results[permission];
          if (status != PermissionStatus.granted &&
              status != PermissionStatus.limited) {
            debugPrint('Permission $permission was denied: $status');
            return false;
          }
        }
      }

      return await hasBluetoothPermission;
    } catch (e) {
      debugPrint('Error requesting Bluetooth permissions: $e');
      return false;
    }
  }

  /// Check if Bluetooth is enabled on the device
  Future<bool> get isBluetoothEnabled async {
    try {
      return await PrintBluetoothThermal.bluetoothEnabled;
    } catch (e) {
      debugPrint('Error checking Bluetooth status: $e');
      return false;
    }
  }

  /// Get list of paired Bluetooth devices (Android) or nearby devices (iOS)
  Future<List<BluetoothInfo>> getPairedDevices() async {
    try {
      // Try to get paired devices even if permission check fails
      debugPrint('Attempting to get paired Bluetooth devices...');
      final devices = await PrintBluetoothThermal.pairedBluetooths;
      debugPrint('Found ${devices.length} paired devices');
      return devices;
    } catch (e) {
      debugPrint('Error getting paired devices: $e');

      // If we get a permission error, provide guidance but don't fail completely
      if (e.toString().contains('permission')) {
        debugPrint('Permission error detected, but continuing with empty list');
        // Return empty list instead of crashing - the dialog will show no devices
        // and guide the user to enable permissions
      }

      return [];
    }
  }

  /// Connect to a thermal printer using MAC address
  Future<bool> connectToPrinter(String macAddress) async {
    try {
      // Check Bluetooth is enabled
      if (!await isBluetoothEnabled) {
        throw Exception(
            'Bluetooth is not enabled. Please enable Bluetooth in device settings.');
      }

      // Check and request permissions if needed
      if (!await hasBluetoothPermission) {
        debugPrint('Bluetooth permissions not granted, requesting...');
        final granted = await requestBluetoothPermissions();
        if (!granted) {
          throw Exception(
              'Bluetooth permissions are required for printer connection. Please grant permissions in device settings.');
        }
      }

      debugPrint('Attempting to connect to printer: $macAddress');

      // Try to connect even if the thermal permission check fails
      // The actual connection may work if we have the proper Android permissions
      try {
        final connected =
            await PrintBluetoothThermal.connect(macPrinterAddress: macAddress);
        debugPrint('Connection result: $connected');

        if (!connected) {
          // If connection fails, provide helpful guidance
          throw Exception(
              'Failed to connect to printer. Make sure the printer is:\n'
              '1. Turned on and in pairing mode\n'
              '2. Within Bluetooth range\n'
              '3. Not connected to another device');
        }

        return connected;
      } catch (e) {
        debugPrint('PrintBluetoothThermal.connect error: $e');

        // Check if it's a permission error specifically
        if (e.toString().contains('permission')) {
          throw Exception('Bluetooth permission issue. Please:\n'
              '1. Open device Settings\n'
              '2. Go to Apps → WMS Mobile → Permissions\n'
              '3. Enable "Nearby devices" and "Location"\n'
              '4. Restart the app and try again');
        }

        rethrow;
      }
    } catch (e) {
      debugPrint('Error in connectToPrinter: $e');
      rethrow;
    }
  }

  /// Check current connection status
  Future<bool> get isConnected async {
    try {
      return await PrintBluetoothThermal.connectionStatus;
    } catch (e) {
      debugPrint('Error checking connection status: $e');
      return false;
    }
  }

  /// Disconnect from current printer
  Future<bool> disconnect() async {
    try {
      return await PrintBluetoothThermal.disconnect;
    } catch (e) {
      debugPrint('Error disconnecting from printer: $e');
      return false;
    }
  }

  /// Print product barcode label
  Future<bool> printProductBarcode({
    required Product product,
    Store? store,
    User? user,
  }) async {
    if (!await isConnected) {
      throw Exception('Printer not connected');
    }

    try {
      final bytes = await _generateProductBarcodeTicket(
        product: product,
        store: store,
        user: user,
      );

      debugPrint('Printing product barcode...');
      return await PrintBluetoothThermal.writeBytes(bytes);
    } catch (e) {
      debugPrint('Error printing product barcode: $e');
      rethrow;
    }
  }

  /// Print transaction receipt
  Future<bool> printTransactionReceipt({
    required Map<String, dynamic> transaction,
    Store? store,
    User? user,
  }) async {
    if (!await isConnected) {
      throw Exception('Printer not connected');
    }

    try {
      final bytes = await _generateTransactionReceipt(
        transaction: transaction,
        store: store,
        user: user,
      );

      return await PrintBluetoothThermal.writeBytes(bytes);
    } catch (e) {
      debugPrint('Error printing transaction receipt: $e');
      rethrow;
    }
  }

  /// Print payment note
  Future<bool> printPaymentNote({
    required Map<String, dynamic> transaction,
    Store? store,
    User? user,
  }) async {
    if (!await isConnected) {
      throw Exception('Printer not connected');
    }

    try {
      final bytes = await _generatePaymentNote(
        transaction: transaction,
        store: store,
        user: user,
      );

      return await PrintBluetoothThermal.writeBytes(bytes);
    } catch (e) {
      debugPrint('Error printing payment note: $e');
      rethrow;
    }
  }

  /// Print test page to verify printer functionality
  Future<bool> printTestPage() async {
    if (!await isConnected) {
      throw Exception('Printer not connected');
    }

    try {
      final bytes = await _generateTestTicket();
      return await PrintBluetoothThermal.writeBytes(bytes);
    } catch (e) {
      debugPrint('Error printing test page: $e');
      rethrow;
    }
  }

  /// Generate product barcode ticket
  Future<List<int>> _generateProductBarcodeTicket({
    required Product product,
    Store? store,
    User? user,
  }) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];

    bytes += generator.reset();

    // Store name (if available)
    if (store != null) {
      bytes += generator.text(
        store.name,
        styles: PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      );
      bytes += generator.feed(1);
    }

    // Product name
    bytes += generator.text(
      product.name,
      styles: PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size1,
        width: PosTextSize.size1,
      ),
    );

    // SKU
    if (product.sku.isNotEmpty) {
      bytes += generator.text(
        'SKU: ${product.sku}',
        styles: PosStyles(align: PosAlign.center),
      );
    }

    // Barcode
    if (product.barcode.isNotEmpty) {
      try {
        debugPrint('Generating barcode: ${product.barcode}');
        // Generate barcode using Code128 format
        bytes +=
            generator.barcode(Barcode.code128(product.barcode.split('').toList()));
      } catch (e) {
        debugPrint('Error generating barcode: $e');
        // Fallback to text representation
        bytes += generator.text(
          product.barcode,
          styles: PosStyles(
            align: PosAlign.center,
            fontType: PosFontType.fontB,
          ),
        );
      }
    }

    // Price (if available)
    if (product.salePrice != null) {
      bytes += generator.text(
        '\$${product.salePrice!.toInt()}',
        styles: PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      );
    }

    // Quantity for IMEI products
    if (product.isImei) {
      bytes += generator.text(
        'IMEI Tracked',
        styles: PosStyles(align: PosAlign.center),
      );
    } else {
      bytes += generator.text(
        'Qty: ${product.quantity}',
        styles: PosStyles(align: PosAlign.center),
      );
    }

    bytes += generator.feed(2);
    bytes += generator.cut();

    return bytes;
  }

  /// Generate transaction receipt
  Future<List<int>> _generateTransactionReceipt({
    required Map<String, dynamic> transaction,
    Store? store,
    User? user,
  }) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];

    bytes += generator.reset();

    // Store header
    if (store != null) {
      bytes += generator.text(
        store.name,
        styles: PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      );
      bytes += generator.feed(1);
    }

    // Receipt title
    bytes += generator.text(
      'RECEIPT',
      styles: PosStyles(
        align: PosAlign.center,
        bold: true,
      ),
    );

    bytes += generator.hr();

    // Transaction details
    final transactionType = transaction['type'] ?? 'SALE';
    final createdAt =
        transaction['createdAt'] ?? DateTime.now().toIso8601String();

    bytes += generator.row([
      PosColumn(text: 'Type:', width: 6, styles: PosStyles(bold: true)),
      PosColumn(
          text: transactionType,
          width: 6,
          styles: PosStyles(align: PosAlign.right)),
    ]);

    bytes += generator.row([
      PosColumn(text: 'Date:', width: 6, styles: PosStyles(bold: true)),
      PosColumn(
          text: _formatDateTime(createdAt),
          width: 6,
          styles: PosStyles(align: PosAlign.right)),
    ]);

    if (user != null) {
      bytes += generator.row([
        PosColumn(text: 'Cashier:', width: 6, styles: PosStyles(bold: true)),
        PosColumn(
            text: user.name,
            width: 6,
            styles: PosStyles(align: PosAlign.right)),
      ]);
    }

    bytes += generator.hr();

    // Items
    final items = transaction['items'] as List<dynamic>? ?? [];
    double totalAmount = 0.0;

    for (final item in items) {
      final productName = item['productName'] ?? 'Unknown Product';
      final quantity = item['quantity'] ?? 1;
      final price = (item['price'] as num?)?.toDouble() ?? 0.0;
      final subtotal = quantity * price;
      totalAmount += subtotal;

      bytes += generator.text(
        productName,
        styles: PosStyles(bold: true),
      );

      bytes += generator.row([
        PosColumn(
          text: '$quantity x \$${price.toInt()}',
          width: 8,
        ),
        PosColumn(
          text: '\$${subtotal.toInt()}',
          width: 4,
          styles: PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    bytes += generator.hr();

    // Total
    bytes += generator.row([
      PosColumn(
        text: 'TOTAL:',
        width: 8,
        styles: PosStyles(bold: true, height: PosTextSize.size2),
      ),
      PosColumn(
        text: '\$${totalAmount.toInt()}',
        width: 4,
        styles: PosStyles(
          align: PosAlign.right,
          bold: true,
          height: PosTextSize.size2,
        ),
      ),
    ]);

    bytes += generator.feed(2);

    // Footer
    bytes += generator.text(
      'Thank you for your purchase!',
      styles: PosStyles(align: PosAlign.center),
    );

    bytes += generator.feed(3);
    bytes += generator.cut();

    return bytes;
  }

  /// Generate payment note
  Future<List<int>> _generatePaymentNote({
    required Map<String, dynamic> transaction,
    Store? store,
    User? user,
  }) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];

    bytes += generator.reset();

    // Store header
    if (store != null) {
      bytes += generator.text(
        store.name,
        styles: PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      );
      bytes += generator.feed(1);
    }

    // Payment note title
    bytes += generator.text(
      'PAYMENT NOTE',
      styles: PosStyles(
        align: PosAlign.center,
        bold: true,
      ),
    );

    bytes += generator.hr();

    // Basic transaction info
    final transactionType = transaction['type'] ?? 'SALE';
    final createdAt =
        transaction['createdAt'] ?? DateTime.now().toIso8601String();
    final totalAmount = (transaction['totalAmount'] as num?)?.toDouble() ?? 0.0;

    bytes += generator.row([
      PosColumn(text: 'Type:', width: 6, styles: PosStyles(bold: true)),
      PosColumn(
          text: transactionType,
          width: 6,
          styles: PosStyles(align: PosAlign.right)),
    ]);

    bytes += generator.row([
      PosColumn(text: 'Date:', width: 6, styles: PosStyles(bold: true)),
      PosColumn(
          text: _formatDateTime(createdAt),
          width: 6,
          styles: PosStyles(align: PosAlign.right)),
    ]);

    bytes += generator.row([
      PosColumn(text: 'Amount:', width: 6, styles: PosStyles(bold: true)),
      PosColumn(
          text: '\$${totalAmount.toInt()}',
          width: 6,
          styles: PosStyles(align: PosAlign.right)),
    ]);

    if (user != null) {
      bytes += generator.row([
        PosColumn(
            text: 'Processed by:', width: 6, styles: PosStyles(bold: true)),
        PosColumn(
            text: user.name,
            width: 6,
            styles: PosStyles(align: PosAlign.right)),
      ]);
    }

    bytes += generator.hr();

    // Payment instructions or notes
    bytes += generator.text(
      'Please keep this note for your records.',
      styles: PosStyles(align: PosAlign.center),
    );

    bytes += generator.feed(3);
    bytes += generator.cut();

    return bytes;
  }

  /// Generate test ticket to verify printer functionality
  Future<List<int>> _generateTestTicket() async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];

    bytes += generator.reset();

    // Header
    bytes += generator.text(
      'WMS PRINTER TEST',
      styles: PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );

    bytes += generator.feed(1);

    // Test text styles
    bytes += generator.text('Regular text', styles: PosStyles());
    bytes += generator.text('Bold text', styles: PosStyles(bold: true));
    bytes +=
        generator.text('Underlined text', styles: PosStyles(underline: true));
    bytes += generator.text('Reverse text', styles: PosStyles(reverse: true));

    bytes += generator.feed(1);

    // Test alignment
    bytes +=
        generator.text('Left aligned', styles: PosStyles(align: PosAlign.left));
    bytes += generator.text('Center aligned',
        styles: PosStyles(align: PosAlign.center));
    bytes += generator.text('Right aligned',
        styles: PosStyles(align: PosAlign.right));

    bytes += generator.feed(1);

    // Test sizes
    bytes += generator.text('Size 1 (100%)',
        styles: PosStyles(height: PosTextSize.size1, width: PosTextSize.size1));
    bytes += generator.text('Size 2 (200%)',
        styles: PosStyles(height: PosTextSize.size2, width: PosTextSize.size2));

    bytes += generator.feed(1);

    // Test table
    bytes += generator.row([
      PosColumn(text: 'Item', width: 6, styles: PosStyles(bold: true)),
      PosColumn(
          text: 'Price',
          width: 6,
          styles: PosStyles(bold: true, align: PosAlign.right)),
    ]);

    bytes += generator.row([
      PosColumn(text: 'Test Product', width: 6),
      PosColumn(
          text: '\$10.00', width: 6, styles: PosStyles(align: PosAlign.right)),
    ]);

    bytes += generator.hr();

    // Test barcode
    try {
      bytes += generator.barcode(Barcode.code128('123456789'.codeUnits));
    } catch (e) {
      bytes += generator.text('Barcode: 123456789',
          styles: PosStyles(align: PosAlign.center));
    }

    // Test QR code
    bytes += generator.qrcode('https://wms.example.com');

    bytes += generator.feed(1);

    // Footer
    bytes += generator.text(
      'Test completed successfully!',
      styles: PosStyles(align: PosAlign.center, bold: true),
    );

    bytes += generator.text(
      DateTime.now().toIso8601String(),
      styles: PosStyles(align: PosAlign.center),
    );

    bytes += generator.feed(3);
    bytes += generator.cut();

    return bytes;
  }

  /// Format date time for printing
  String _formatDateTime(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return isoString;
    }
  }

  /// Show comprehensive Bluetooth setup dialog with nearby devices
  Future<BluetoothInfo?> showBluetoothSetupDialog(BuildContext context) async {
    try {
      // Check Bluetooth is enabled
      if (!await isBluetoothEnabled) {
        throw Exception(
            'Bluetooth is not enabled. Please enable Bluetooth in device settings and try again.');
      }

      // Try to request permissions, but don't fail if the permission system has issues
      try {
        if (!await hasBluetoothPermission) {
          debugPrint('Requesting Bluetooth permissions...');
          await requestBluetoothPermissions();
          // Note: We don't fail here even if permissions seem denied
          // because the print_bluetooth_thermal package may have internal issues
          // but the actual Android permissions might be working
        }
      } catch (permissionError) {
        debugPrint('Permission check/request had issues: $permissionError');
        // Continue anyway - the dialog will handle permission issues gracefully
      }

      if (!context.mounted) return null;

      return showDialog<BluetoothInfo>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const BluetoothSetupDialog(),
      );
    } catch (e) {
      debugPrint('Error in showBluetoothSetupDialog: $e');
      rethrow;
    }
  }

  /// Show simple printer selection dialog (legacy method)
  Future<BluetoothInfo?> showPrinterSelectionDialog(
      BuildContext context) async {
    // Check Bluetooth is enabled
    if (!await isBluetoothEnabled) {
      throw Exception(
          'Bluetooth is not enabled. Please enable Bluetooth in device settings and try again.');
    }

    // Check and request permissions
    if (!await hasBluetoothPermission) {
      debugPrint('Requesting Bluetooth permissions...');
      final granted = await requestBluetoothPermissions();
      if (!granted) {
        throw Exception(
            'Bluetooth permissions are required for printing. Please grant "Nearby devices" permission in device settings.');
      }
    }

    // Get paired devices
    debugPrint('Getting paired devices...');
    final devices = await getPairedDevices();
    debugPrint('Found ${devices.length} paired devices');

    if (devices.isEmpty) {
      throw Exception(
          'No paired Bluetooth devices found. Please pair your thermal printer in device Bluetooth settings first.');
    }

    if (!context.mounted) return null;

    return showDialog<BluetoothInfo>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Printer'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final device = devices[index];
              return ListTile(
                title: Text(
                    device.name.isNotEmpty ? device.name : 'Unknown Device'),
                subtitle: Text(device.macAdress),
                trailing: const Icon(Icons.print),
                onTap: () => Navigator.of(context).pop(device),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  /// Show permission settings guidance dialog
  Future<void> showPermissionSettingsDialog(BuildContext context) async {
    if (!context.mounted) return;

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bluetooth Permissions Required'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'To use the thermal printer, you need to grant Bluetooth permissions.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('Steps to enable permissions:'),
            SizedBox(height: 8),
            Text('1. Open device Settings'),
            Text('2. Go to Apps & Permissions (or Applications)'),
            Text('3. Find this app (WMS Mobile)'),
            Text('4. Tap on Permissions'),
            Text('5. Enable "Nearby devices" or "Bluetooth"'),
            Text('6. Enable "Location" (required for device discovery)'),
            SizedBox(height: 16),
            Text(
              'Note: Different Android versions may have slightly different menu names.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  /// Connect and print with comprehensive Bluetooth setup dialog
  Future<bool> connectAndPrint(
    BuildContext context, {
    Product? product,
    Store? store,
    User? user,
  }) async {
    debugPrint('Attempting to connect and print...');

    try {
      // Check if already connected
      if (await isConnected) {
        if (product != null) {
          return await printProductBarcode(
            product: product,
            store: store,
            user: user,
          );
        } else {
          return await printTestPage();
        }
      }

      // Show comprehensive setup dialog
      if (!context.mounted) return false;
      final selectedDevice = await showBluetoothSetupDialog(context);
      if (selectedDevice == null) return false;

      debugPrint(
          'Requesting Bluetooth permissions...${selectedDevice.toString()}');

      // The dialog handles connection, so just verify we're connected
      if (await isConnected) {
        if (product != null) {
          return await printProductBarcode(
            product: product,
            store: store,
            user: user,
          );
        } else {
          return await printTestPage();
        }
      }

      return false;
    } catch (e) {
      debugPrint('Connect and print failed: $e');
      rethrow;
    }
  }

  /// Connect to printer with user interaction (legacy method)
  Future<bool> connectWithDialog(BuildContext context) async {
    try {
      final selectedDevice = await showBluetoothSetupDialog(context);
      if (selectedDevice == null) return false;

      return await isConnected;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
  }
}
