import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/utils/barcode_utils.dart';
import '../../../generated/app_localizations.dart';

/// Simple, reliable barcode scanner screen
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
  MobileScannerController? _controller;
  bool _isInitialized = false;
  bool _isProcessing = false;
  bool _isTorchOn = false;
  String? _lastScannedCode;
  DateTime? _lastScanTime;

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
        _controller!.start();
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
      debugPrint('Scanner initialization error: $e');
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
        debugPrint('Scanner dispose error: $e');
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
        now.difference(_lastScanTime!).inMilliseconds < 2000) {
      return;
    }

    _lastScannedCode = code;
    _lastScanTime = now;
    _isProcessing = true;

    // Provide haptic feedback
    HapticFeedback.mediumImpact();

    // Process the barcode
    _processBarcode(code);
  }

  void _processBarcode(String code) {
    try {
      // Create result object
      final result = BarcodeScanResult.success(code);

      if (widget.onBarcodeScanned != null) {
        // Call the callback
        widget.onBarcodeScanned!(result);
        
        // Close scanner if auto-close is enabled
        if (widget.autoClose && mounted) {
          context.pop();
        }
      } else {
        // Show result dialog if no callback
        _showScanResult(result);
      }
    } catch (e) {
      debugPrint('Barcode processing error: $e');
      _showErrorDialog('Error processing barcode: $e');
    } finally {
      _isProcessing = false;
    }
  }

  void _showScanResult(BarcodeScanResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Barcode Scanned'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Code: ${result.code}'),
            const SizedBox(height: 8),
            Text('Type: ${result.typeDescription}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _isProcessing = false;
            },
            child: const Text('Scan Again'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.pop();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.pop();
            },
            child: const Text('Close'),
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
                _processBarcode(controller.text);
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
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? l10n.scanBarcode),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          if (widget.allowManualEntry)
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
                
                // Overlay with scan area
                Container(
                  decoration: ShapeDecoration(
                    shape: ScannerOverlayShape(),
                  ),
                ),
                
                // Instructions
                Positioned(
                  bottom: 100,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.subtitle ?? 'Position barcode within the frame',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
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
}

/// Custom shape for scanner overlay
class ScannerOverlayShape extends ShapeBorder {
  const ScannerOverlayShape();

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..fillType = PathFillType.evenOdd..addRect(rect);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path outerPath = Path()..addRect(rect);
    Path innerPath = Path();
    
    // Create the scan area (square in center)
    final scanAreaSize = rect.width * 0.7;
    final left = rect.center.dx - scanAreaSize / 2;
    final top = rect.center.dy - scanAreaSize / 2;
    final scanRect = Rect.fromLTWH(left, top, scanAreaSize, scanAreaSize);
    
    innerPath.addRRect(RRect.fromRectAndRadius(scanRect, const Radius.circular(12)));
    
    return Path.combine(PathOperation.difference, outerPath, innerPath);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    const double scanAreaOpacity = 0.8;
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: scanAreaOpacity)
      ..style = PaintingStyle.fill;

    canvas.drawPath(getOuterPath(rect), paint);
    
    // Draw corner indicators
    final scanAreaSize = rect.width * 0.7;
    final left = rect.center.dx - scanAreaSize / 2;
    final top = rect.center.dy - scanAreaSize / 2;
    final scanRect = Rect.fromLTWH(left, top, scanAreaSize, scanAreaSize);
    
    final cornerPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    
    final cornerLength = 30.0;
    
    // Top-left corner
    canvas.drawLine(
      Offset(scanRect.left, scanRect.top + cornerLength),
      Offset(scanRect.left, scanRect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanRect.left, scanRect.top),
      Offset(scanRect.left + cornerLength, scanRect.top),
      cornerPaint,
    );
    
    // Top-right corner
    canvas.drawLine(
      Offset(scanRect.right - cornerLength, scanRect.top),
      Offset(scanRect.right, scanRect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanRect.right, scanRect.top),
      Offset(scanRect.right, scanRect.top + cornerLength),
      cornerPaint,
    );
    
    // Bottom-left corner
    canvas.drawLine(
      Offset(scanRect.left, scanRect.bottom - cornerLength),
      Offset(scanRect.left, scanRect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanRect.left, scanRect.bottom),
      Offset(scanRect.left + cornerLength, scanRect.bottom),
      cornerPaint,
    );
    
    // Bottom-right corner
    canvas.drawLine(
      Offset(scanRect.right - cornerLength, scanRect.bottom),
      Offset(scanRect.right, scanRect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanRect.right, scanRect.bottom),
      Offset(scanRect.right, scanRect.bottom - cornerLength),
      cornerPaint,
    );
  }

  @override
  ShapeBorder scale(double t) => ScannerOverlayShape();
}