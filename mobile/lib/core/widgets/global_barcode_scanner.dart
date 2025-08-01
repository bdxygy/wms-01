import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../utils/barcode_utils.dart';

// Using BarcodeScanResult from barcode_utils.dart

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

/// Simplified global barcode scanner widget
class GlobalBarcodeScanner extends StatefulWidget {
  final BarcodeScannerConfig config;
  final Future<void> Function(BarcodeScanResult result) onScanResult;
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
  MobileScannerController? _controller;
  bool _isInitialized = false;
  bool _isProcessing = false;
  bool _isTorchOn = false;
  String? _lastScannedCode;
  DateTime? _lastScanTime;
  final List<BarcodeScanResult> _scanHistory = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeController();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeController();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isInitialized || _controller == null) return;

    switch (state) {
      case AppLifecycleState.resumed:
        if (!_isProcessing) {
          _controller!.start();
        }
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _controller!.stop();
        break;
    }
  }

  Future<void> _initializeController() async {
    try {
      _controller = MobileScannerController(
        autoStart: true, // Let MobileScanner widget handle the start
        detectionSpeed: DetectionSpeed.noDuplicates,
        facing: CameraFacing.back,
        torchEnabled: false,
        returnImage: false,
        formats: [
          // Linear/1D Barcodes
          BarcodeFormat.codabar,
          BarcodeFormat.code39,
          BarcodeFormat.code93,
          BarcodeFormat.code128,
          BarcodeFormat.ean8,
          BarcodeFormat.ean13,
          BarcodeFormat.itf,
          BarcodeFormat.upcA,
          BarcodeFormat.upcE,
          // 2D Barcodes
          BarcodeFormat.aztec,
          BarcodeFormat.dataMatrix,
          BarcodeFormat.pdf417,
          BarcodeFormat.qrCode,
        ],
      );

      // Don't start here - let the MobileScanner widget handle initialization
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('GlobalBarcodeScanner initialization error: $e');
      if (mounted) {
        _showErrorDialog('Failed to initialize camera. Please check permissions.');
      }
    }
  }

  Future<void> _disposeController() async {
    if (_controller != null) {
      try {
        await _controller!.dispose();
      } catch (e) {
        debugPrint('GlobalBarcodeScanner dispose error: $e');
      }
      _controller = null;
    }
  }

  void _onBarcodeDetected(BarcodeCapture capture) {
    if (_isProcessing || capture.barcodes.isEmpty) return;

    final barcode = capture.barcodes.first;
    final code = barcode.rawValue;

    if (code == null || code.isEmpty) return;

    // Prevent duplicate scans
    final now = DateTime.now();
    if (_lastScannedCode == code &&
        _lastScanTime != null &&
        now.difference(_lastScanTime!).inMilliseconds < 
        (widget.config.scanDebounce?.inMilliseconds ?? 2000)) {
      return;
    }

    _lastScannedCode = code;
    _lastScanTime = now;
    _isProcessing = true;

    // Provide haptic feedback
    if (widget.config.enableHapticFeedback) {
      HapticFeedback.mediumImpact();
    }

    // Process the barcode
    _processBarcode(code, barcode.type.name);
  }

  void _processBarcode(String code, String type) {
    try {
      // Create result object
      final result = BarcodeScanResult.success(code, type: type);
      
      // Add to history
      if (widget.config.showHistory) {
        _scanHistory.insert(0, result);
        if (_scanHistory.length > 50) {
          _scanHistory.removeLast();
        }
      }

      // Call the callback
      _handleValidScan(result);
    } catch (e) {
      debugPrint('Barcode processing error: $e');
      final errorResult = BarcodeScanResult.error(code, e.toString());
      _handleInvalidScan(errorResult);
    }
  }

  void _handleValidScan(BarcodeScanResult result) async {
    try {
      await widget.onScanResult(result);
      
      if (widget.config.autoClose && mounted) {
        _dismissScanner();
      } else {
        _continueScanning();
      }
    } catch (e) {
      if (mounted) {
        _showCallbackErrorDialog(result, e.toString());
      }
    }
  }

  void _handleInvalidScan(BarcodeScanResult result) {
    _showErrorDialog('Invalid barcode: ${result.errorMessage}');
  }

  void _continueScanning() {
    setState(() {
      _isProcessing = false;
    });
    if (_controller != null && mounted) {
      _controller!.start();
    }
  }

  void _dismissScanner() {
    widget.onDismiss?.call();
    if (mounted) {
      Navigator.of(context).pop();
    }
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
              _continueScanning();
            },
            child: const Text('Try Again'),
          ),
          ElevatedButton(
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

  void _showCallbackErrorDialog(BarcodeScanResult result, String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Processing Error'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Scanned: ${result.code}'),
            const SizedBox(height: 8),
            Text('Error: $error', style: const TextStyle(color: Colors.red)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _continueScanning();
            },
            child: const Text('Scan Again'),
          ),
          ElevatedButton(
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

  Future<void> _toggleTorch() async {
    if (!_isInitialized || _controller == null) return;

    try {
      await _controller!.toggleTorch();
      setState(() {
        _isTorchOn = !_isTorchOn;
      });
    } catch (e) {
      debugPrint('Torch toggle error: $e');
    }
  }

  void _showManualEntry() {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Barcode Manually'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter barcode...',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (controller.text.isNotEmpty) {
                _processBarcode(controller.text, 'MANUAL');
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.config.title ?? 'Scanner'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          if (widget.config.allowManualEntry)
            IconButton(
              onPressed: _showManualEntry,
              icon: const Icon(Icons.keyboard),
              tooltip: 'Manual Entry',
            ),
          IconButton(
            onPressed: _toggleTorch,
            icon: Icon(_isTorchOn ? Icons.flash_on : Icons.flash_off),
            tooltip: 'Toggle Flash',
          ),
          if (widget.config.showHistory && _scanHistory.isNotEmpty)
            IconButton(
              onPressed: _showHistory,
              icon: const Icon(Icons.history),
              tooltip: 'Scan History',
            ),
        ],
      ),
      backgroundColor: Colors.black,
      body: _isInitialized && _controller != null
          ? Stack(
              children: [
                // Scanner view
                MobileScanner(
                  controller: _controller!,
                  onDetect: _onBarcodeDetected,
                ),
                
                // Simple overlay
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                  ),
                  child: Center(
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                
                // Instructions
                Positioned(
                  bottom: 100,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.config.subtitle ?? 'Position barcode within the frame',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
    );
  }

  void _showHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Scan History'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _scanHistory.length,
            itemBuilder: (context, index) {
              final result = _scanHistory[index];
              return ListTile(
                title: Text(result.code),
                subtitle: Text(result.typeDescription),
                trailing: Text(
                  '${result.timestamp.hour}:${result.timestamp.minute.toString().padLeft(2, '0')}',
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _processBarcode(result.code, result.type);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}