import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../services/scanner_service.dart';
import '../utils/barcode_utils.dart';
import 'scanner_overlay.dart';

/// Result model for barcode scanning
class BarcodeScanResult {
  final String code;
  final String formattedCode;
  final String type;
  final bool isValid;
  final String? errorMessage;
  final DateTime timestamp;

  BarcodeScanResult._({
    required this.code,
    required this.formattedCode,
    required this.type,
    required this.isValid,
    this.errorMessage,
    required this.timestamp,
  });

  factory BarcodeScanResult.success(String code, {required String type}) {
    return BarcodeScanResult._(
      code: code,
      formattedCode: code,
      type: type,
      isValid: true,
      timestamp: DateTime.now(),
    );
  }

  factory BarcodeScanResult.error(String code, String errorMessage) {
    return BarcodeScanResult._(
      code: code,
      formattedCode: code,
      type: 'UNKNOWN',
      isValid: false,
      errorMessage: errorMessage,
      timestamp: DateTime.now(),
    );
  }

  String get typeDescription {
    switch (type) {
      case 'EAN13':
        return 'EAN-13';
      case 'EAN8':
        return 'EAN-8';
      case 'UPCA':
        return 'UPC-A';
      case 'CODE128':
        return 'Code 128';
      case 'CODE39':
        return 'Code 39';
      case 'QR_CODE':
        return 'QR Code';
      case 'UNKNOWN':
        return 'Unknown';
      default:
        return type;
    }
  }
}

/// Configuration for the global barcode scanner
class BarcodeScannerConfig {
  final String? title;
  final String? subtitle;
  final bool allowManualEntry;
  final bool showHistory;
  final List<String>? allowedTypes;
  final bool autoClose;
  final Duration? scanDebounce;
  final bool enableHapticFeedback;

  const BarcodeScannerConfig({
    this.title,
    this.subtitle,
    this.allowManualEntry = true,
    this.showHistory = false,
    this.allowedTypes,
    this.autoClose = true,
    this.scanDebounce = const Duration(milliseconds: 2000),
    this.enableHapticFeedback = true,
  });
}

/// Global flexible barcode scanner widget
/// 
/// Can be used for different purposes:
/// - IMEI scanning with auto-fill callback
/// - Product search with service callback
/// - Generic barcode scanning with custom callback
class GlobalBarcodeScanner extends StatefulWidget {
  /// Configuration for the scanner
  final BarcodeScannerConfig config;

  /// Callback function that handles the scan result
  /// This function determines what happens with the scanned barcode
  final Future<void> Function(BarcodeScanResult result) onScanResult;

  /// Optional callback for scanner dismissal
  final VoidCallback? onDismiss;

  const GlobalBarcodeScanner({
    super.key,
    required this.config,
    required this.onScanResult,
    this.onDismiss,
  });

  @override
  State<GlobalBarcodeScanner> createState() => _GlobalBarcodeScannerState();
}

class _GlobalBarcodeScannerState extends State<GlobalBarcodeScanner>
    with WidgetsBindingObserver {
  final ScannerService _scannerService = ScannerService();
  StreamSubscription<String>? _scanSubscription;

  bool _isFlashOn = false;
  final bool _canSwitchCamera = true;
  bool _isTorchAvailable = false;
  bool _isProcessing = false;

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

      // Start scanning
      await _scannerService.startScanning();

      // Listen to scan results
      _scanSubscription =
          _scannerService.scanResultStream?.listen(_handleScanResult);

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      _showErrorDialog('Scanner initialization failed: $e');
    }
  }

  void _handleScanResult(String code) {
    if (_isProcessing) return;

    // Prevent duplicate scans with debounce
    final now = DateTime.now();
    if (_lastScannedCode == code &&
        _lastScanTime != null &&
        now.difference(_lastScanTime!) < (widget.config.scanDebounce ?? const Duration(milliseconds: 2000))) {
      return;
    }

    _lastScannedCode = code;
    _lastScanTime = now;
    _isProcessing = true;

    // Stop scanning while processing
    _scannerService.stopScanning();

    // Process barcode and create result
    final result = _processBarcode(code);

    // Add to history if enabled
    if (widget.config.showHistory) {
      setState(() {
        _scanHistory.insert(0, result);
        // Keep only last 50 scans
        if (_scanHistory.length > 50) {
          _scanHistory.removeRange(50, _scanHistory.length);
        }
      });
    }

    // Provide haptic feedback
    if (widget.config.enableHapticFeedback) {
      if (result.isValid) {
        HapticFeedback.mediumImpact();
      } else {
        HapticFeedback.lightImpact();
      }
    }

    // Handle the result based on validity
    if (result.isValid) {
      _handleValidScan(result);
    } else {
      _handleInvalidScan(result);
    }
  }

  BarcodeScanResult _processBarcode(String code) {
    try {
      // Clean and detect barcode type
      final cleanCode = BarcodeUtils.cleanBarcode(code);
      final detectedType = BarcodeUtils.detectBarcodeType(cleanCode);

      // Check if type is allowed
      if (widget.config.allowedTypes != null &&
          widget.config.allowedTypes!.isNotEmpty &&
          !widget.config.allowedTypes!.contains(detectedType)) {
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

  Future<void> _handleValidScan(BarcodeScanResult result) async {
    try {
      // Call the external callback function to handle the result
      await widget.onScanResult(result);
      
      // If auto-close is enabled and we get here, close the scanner
      if (widget.config.autoClose && mounted) {
        _dismissScanner();
      } else {
        // Continue scanning if auto-close is disabled
        _continueScanning();
      }
    } catch (e) {
      // If the callback throws an error, show error and continue scanning
      if (mounted) {
        _showCallbackErrorDialog(result, e.toString());
      }
    }
  }

  void _handleInvalidScan(BarcodeScanResult result) {
    // Show error dialog for invalid barcodes
    _showInvalidBarcodeDialog(result);
  }

  void _showInvalidBarcodeDialog(BarcodeScanResult result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
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
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _continueScanning();
            },
            child: const Text('Try Again'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _dismissScanner();
            },
            child: const Text('Close Scanner'),
          ),
        ],
      ),
    );
  }

  void _showCallbackErrorDialog(BarcodeScanResult result, String error) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Processing Error'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Scanned: ${result.formattedCode}'),
            const SizedBox(height: 8),
            Text(
              'Error: $error',
              style: TextStyle(color: Colors.red[700]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _continueScanning();
            },
            child: const Text('Scan Again'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _dismissScanner();
            },
            child: const Text('Close Scanner'),
          ),
        ],
      ),
    );
  }

  void _continueScanning() {
    setState(() {
      _isProcessing = false;
    });
    _scannerService.startScanning();
  }

  void _dismissScanner() {
    widget.onDismiss?.call();
    Navigator.of(context).pop();
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
                _handleValidScan(result);
              } else {
                _handleInvalidScan(result);
              }
            }
          },
          child: const Text('Process'),
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
                        _handleValidScan(result);
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
            onPressed: () {
              Navigator.of(context).pop();
              _dismissScanner();
            },
            child: const Text('Close Scanner'),
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
              title: widget.config.title ?? 'Scan Barcode',
              subtitle: widget.config.subtitle ?? 'Position barcode within the frame',
              onFlashToggle: _isTorchAvailable ? _toggleFlash : null,
              onCameraSwitch: _canSwitchCamera ? _switchCamera : null,
              onManualEntry: widget.config.allowManualEntry ? _showManualEntry : null,
              onClose: _dismissScanner,
              isFlashOn: _isFlashOn,
              canSwitchCamera: _canSwitchCamera,
            ),
          ),

          // History button (if enabled)
          if (widget.config.showHistory && _scanHistory.isNotEmpty)
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

          // Processing overlay
          if (_isProcessing)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.8),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 16),
                      Text(
                        'Processing barcode...',
                        style: TextStyle(color: Colors.white, fontSize: 16),
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