import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:go_router/go_router.dart';

import '../../../core/services/scanner_service.dart';
import '../../../core/services/product_service.dart';
import '../../../core/utils/barcode_utils.dart';
import '../../../core/widgets/scanner_overlay.dart';
import '../../../generated/app_localizations.dart';

/// Professional barcode scanner screen with custom overlay and controls
class BarcodeScannerScreen extends StatefulWidget {
  final String? title;
  final String? subtitle;
  final Function(BarcodeScanResult)? onBarcodeScanned;
  final bool allowManualEntry;
  final bool showHistory;
  final List<String>? allowedTypes;
  final bool autoClose;

  const BarcodeScannerScreen({
    super.key,
    this.title,
    this.subtitle,
    this.onBarcodeScanned,
    this.allowManualEntry = true,
    this.showHistory = false,
    this.allowedTypes,
    this.autoClose = true,
  });

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen>
    with WidgetsBindingObserver {
  final ScannerService _scannerService = ScannerService();
  final ProductService _productService = ProductService();
  StreamSubscription<String>? _scanSubscription;

  bool _isFlashOn = false;
  final bool _canSwitchCamera = true;
  bool _isTorchAvailable = false;
  bool _isProcessing = false;
  bool _isSearchingProduct = false;

  final List<BarcodeScanResult> _scanHistory = [];
  String? _lastScannedCode;
  DateTime? _lastScanTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeScanner();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scanSubscription?.cancel();
    _scannerService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _scannerService.stopScanning();
    } else if (state == AppLifecycleState.resumed) {
      _scannerService.startScanning();
    }
  }

  Future<void> _initializeScanner() async {
    try {
      final success = await _scannerService.initialize();
      if (!success) {
        _showErrorDialog(
            'Failed to initialize scanner. Please check camera permissions.');
        return;
      }

      // Check torch availability
      _isTorchAvailable = await _scannerService.isTorchAvailable();

      // Don't start scanning here - wait for MobileScanner widget to be built

      // Listen to scan results
      _scanSubscription =
          _scannerService.scanResultStream?.listen(_handleScanResult);

      if (mounted) {
        setState(() {});
        // Start scanning after setState completes and widget is rebuilt
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scannerService.startScanning();
        });
      }
    } catch (e) {
      _showErrorDialog('Scanner initialization failed: $e');
    }
  }

  void _handleScanResult(String code) {
    if (_isProcessing || _isSearchingProduct) return;

    // Prevent duplicate scans
    final now = DateTime.now();
    if (_lastScannedCode == code &&
        _lastScanTime != null &&
        now.difference(_lastScanTime!).inMilliseconds < 2000) {
      return;
    }

    _lastScannedCode = code;
    _lastScanTime = now;
    _isProcessing = true;

    // Stop scanning while processing
    _scannerService.stopScanning();

    // Validate barcode
    final result = _processBarcode(code);

    if (result.isValid) {
      // Show loading immediately and search for product
      _searchProductByBarcode(result.formattedCode);
    } else {
      // Show error for invalid barcode
      _showScanResult(result);
      _isProcessing = false;
    }
  }

  BarcodeScanResult _processBarcode(String code) {
    try {
      // Clean and detect barcode type
      final cleanCode = BarcodeUtils.cleanBarcode(code);
      final detectedType = BarcodeUtils.detectBarcodeType(cleanCode);

      // Check if type is allowed
      if (widget.allowedTypes != null &&
          widget.allowedTypes!.isNotEmpty &&
          !widget.allowedTypes!.contains(detectedType)) {
        return BarcodeScanResult.error(
            code, 'Barcode type $detectedType not allowed');
      }

      // Validate barcode
      final isValid =
          BarcodeUtils.isValidBarcode(cleanCode, expectedType: detectedType);

      if (isValid) {
        return BarcodeScanResult.success(cleanCode, type: detectedType);
      } else {
        return BarcodeScanResult.error(code, 'Invalid barcode format');
      }
    } catch (e) {
      return BarcodeScanResult.error(code, 'Barcode processing error: $e');
    }
  }

  void _showScanResult(BarcodeScanResult result) {
    // Provide haptic feedback
    if (result.isValid) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }

    // Show result dialog for invalid barcodes only
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _buildResultDialog(dialogContext, result),
    );
  }

  Widget _buildResultDialog(
      BuildContext dialogContext, BarcodeScanResult result) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.error,
            color: Colors.red,
          ),
          const SizedBox(width: 8),
          Text('Invalid Barcode'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Code: ${result.code}'),
          const SizedBox(height: 8),
          Text(
            'Error: ${result.errorMessage}',
            style: TextStyle(color: Colors.red[700]),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _scanAnother,
          child: const Text('Try Again'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(l10n.ok),
        ),
      ],
    );
  }

  void _handleConfirmedScan(BarcodeScanResult result) {
    widget.onBarcodeScanned?.call(result);

    if (widget.autoClose) {
      context.go('/dashboard');
    }
  }

  Future<void> _searchProductByBarcode(String barcode) async {
    setState(() {
      _isSearchingProduct = true;
      _isProcessing = true; // Ensure processing flag is also set
    });

    try {
      final product = await _productService.getProductByBarcode(barcode);

      if (mounted) {
        // Navigate directly to product detail
        context.go('/products/${product.id}');
      }
    } catch (e) {
      if (mounted) {
        // Show error if product not found
        _showProductNotFoundDialog(barcode, e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSearchingProduct = false;
          _isProcessing = false;
        });
        _scannerService.startScanning();
      }
    }
  }

  void _showProductNotFoundDialog(String barcode, String error) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Product Not Found'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Barcode: $barcode'),
            const SizedBox(height: 8),
            Text(
              'Error: ${error.contains('not found') ? 'No product found with this barcode' : error}',
              style: TextStyle(color: Colors.red[700]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _scanAnother,
            child: const Text('Scan Another'),
          ),
        ],
      ),
    );
  }

  void _continueScanning() {
    _isProcessing = false;
    _isSearchingProduct = false;
    _scannerService.startScanning();
  }

  void _scanAnother() {
    // Close any open dialogs and restart scanning
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
    _continueScanning();
  }

  Future<void> _toggleFlash() async {
    if (!_isTorchAvailable) return;

    try {
      await _scannerService.toggleTorch();
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    } catch (e) {
      _showErrorDialog('Failed to toggle flash: $e');
    }
  }

  Future<void> _switchCamera() async {
    try {
      await _scannerService.switchCamera();
    } catch (e) {
      _showErrorDialog('Failed to switch camera: $e');
    }
  }

  void _showManualEntry() {
    showDialog(
      context: context,
      builder: (context) => _buildManualEntryDialog(),
    );
  }

  Widget _buildManualEntryDialog() {
    final controller = TextEditingController();

    return AlertDialog(
      title: const Text('Enter Barcode Manually'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Barcode',
              hintText: 'Enter barcode number...',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.characters,
            onChanged: (value) {
              // Auto-format as user types
              final cleaned = BarcodeUtils.cleanBarcode(value);
              if (cleaned !=
                  value.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '')) {
                controller.text = cleaned;
                controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: cleaned.length),
                );
              }
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Supported formats: EAN-8, EAN-13, UPC-A, Code 128, Code 39, QR Code',
            style: Theme.of(context).textTheme.bodySmall,
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
            final code = controller.text.trim();
            if (code.isNotEmpty) {
              Navigator.of(context).pop();
              final result = _processBarcode(code);
              if (result.isValid) {
                _searchProductByBarcode(result.formattedCode);
              } else {
                _showScanResult(result);
              }
            }
          },
          child: const Text('Validate'),
        ),
      ],
    );
  }

  void _showScanHistory() {
    showDialog(
      context: context,
      builder: (context) => _buildHistoryDialog(),
    );
  }

  Widget _buildHistoryDialog() {
    return AlertDialog(
      title: const Text('Scan History'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: _scanHistory.isEmpty
            ? const Center(child: Text('No scans yet'))
            : ListView.builder(
                itemCount: _scanHistory.length,
                itemBuilder: (context, index) {
                  final result = _scanHistory[index];
                  return ListTile(
                    leading: Icon(
                      result.isValid ? Icons.check_circle : Icons.error,
                      color: result.isValid ? Colors.green : Colors.red,
                    ),
                    title: Text(result.formattedCode),
                    subtitle: Text(result.typeDescription),
                    trailing: Text(
                      '${result.timestamp.hour}:${result.timestamp.minute.toString().padLeft(2, '0')}',
                    ),
                    onTap: () {
                      if (result.isValid) {
                        Navigator.of(context).pop(); // Close history dialog
                        context.go(
                            '/dashboard'); // Close scanner and go to dashboard
                        _handleConfirmedScan(result);
                      }
                    },
                  );
                },
              ),
      ),
      actions: [
        if (_scanHistory.isNotEmpty)
          TextButton(
            onPressed: () {
              setState(() {
                _scanHistory.clear();
              });
              Navigator.of(context).pop();
            },
            child: const Text('Clear History'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Scanner Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_scannerService.isInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 16),
              Text(
                'Initializing scanner...',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview
          if (_scannerService.controller != null)
            Positioned.fill(
              child: MobileScanner(
                controller: _scannerService.controller!,
                onDetect: _scannerService.onBarcodeDetected,
              ),
            ),

          // Scanner overlay
          Positioned.fill(
            child: ScannerOverlay(
              title: widget.title ?? 'Scan Barcode',
              subtitle: widget.subtitle ?? 'Position barcode within the frame',
              onFlashToggle: _isTorchAvailable ? _toggleFlash : null,
              onCameraSwitch: _canSwitchCamera ? _switchCamera : null,
              onManualEntry: widget.allowManualEntry ? _showManualEntry : null,
              onClose: () {
                context.go('/dashboard');
              },
              isFlashOn: _isFlashOn,
              canSwitchCamera: _canSwitchCamera,
            ),
          ),

          // History button (if enabled)
          if (widget.showHistory && _scanHistory.isNotEmpty)
            Positioned(
              top: 100,
              right: 16,
              child: SafeArea(
                child: FloatingActionButton.small(
                  onPressed: _showScanHistory,
                  backgroundColor: Colors.black.withValues(alpha: 0.7),
                  foregroundColor: Colors.white,
                  child: Stack(
                    children: [
                      const Icon(Icons.history),
                      if (_scanHistory.isNotEmpty)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(1),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '${_scanHistory.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

          // Loading overlay for product search
          if (_isSearchingProduct)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.8),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(color: Colors.white),
                      const SizedBox(height: 16),
                      Text(
                        'Searching for product...',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please wait a moment',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
