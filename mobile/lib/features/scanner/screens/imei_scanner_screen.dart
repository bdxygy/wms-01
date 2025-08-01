import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/utils/imei_utils.dart';
import '../../../core/services/imei_scanner_service.dart';
import '../../../core/services/product_service.dart';
import '../../../core/routing/app_router.dart';

/// Simple, reliable IMEI scanner screen
class ImeiScannerScreen extends StatefulWidget {
  final String? title;
  final String? subtitle;
  final Function(String)? onImeiScanned;
  final Function(dynamic)? onProductFound;
  final bool allowManualEntry;
  final bool showHistory;
  final bool autoSearchProduct;
  final bool autoClose;

  const ImeiScannerScreen({
    super.key,
    this.title,
    this.subtitle,
    this.onImeiScanned,
    this.onProductFound,
    this.allowManualEntry = true,
    this.showHistory = true,
    this.autoSearchProduct = true,
    this.autoClose = false,
  });

  @override
  State<ImeiScannerScreen> createState() => _ImeiScannerScreenState();
}

class _ImeiScannerScreenState extends State<ImeiScannerScreen>
    with WidgetsBindingObserver {
  MobileScannerController? _controller;
  bool _isInitialized = false;
  bool _isProcessing = false;
  bool _isTorchOn = false;
  bool _isSearchingProduct = false;
  String? _lastScannedCode;
  DateTime? _lastScanTime;

  final ImeiScannerService _imeiScannerService = ImeiScannerService();
  final ProductService _productService = ProductService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeController();
    _imeiScannerService.initialize();
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
        if (!_isProcessing && !_isSearchingProduct) {
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
          // Focus on formats that commonly contain IMEI
          BarcodeFormat.code128,
          BarcodeFormat.code39,
          BarcodeFormat.qrCode,
          BarcodeFormat.dataMatrix,
          // Include other formats for flexibility
          BarcodeFormat.ean13,
          BarcodeFormat.ean8,
          BarcodeFormat.upcA,
          BarcodeFormat.upcE,
          BarcodeFormat.pdf417,
          BarcodeFormat.aztec,
        ],
      );

      // Don't start here - let the MobileScanner widget handle initialization
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('IMEI scanner initialization error: $e');
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
        debugPrint('IMEI scanner dispose error: $e');
      }
      _controller = null;
    }
  }

  void _onBarcodeDetected(BarcodeCapture capture) {
    if (_isProcessing || _isSearchingProduct || capture.barcodes.isEmpty) return;

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

    // Process the scanned code
    _processScannedCode(code);
  }

  void _processScannedCode(String code) {
    // Check if the scanned code looks like an IMEI
    if (ImeiUtils.isLikelyImei(code)) {
      _processImei(code);
    } else {
      // Not an IMEI, show error
      _showNotImeiDialog(code);
    }
  }

  void _processImei(String imei) {
    // Process with IMEI scanner service
    _imeiScannerService.processScannedCode(imei);

    if (widget.onImeiScanned != null) {
      // Call the callback
      widget.onImeiScanned!(imei);
      
      // Close scanner if auto-close is enabled
      if (widget.autoClose && mounted) {
        context.pop();
        return;
      }
    }

    // Auto-search for product if enabled
    if (widget.autoSearchProduct) {
      _searchProductByImei(imei);
    } else {
      _showImeiScannedDialog(imei);
    }
  }

  Future<void> _searchProductByImei(String imei) async {
    setState(() {
      _isSearchingProduct = true;
      _isProcessing = true;
    });

    try {
      final product = await _productService.getProductByImei(imei);

      if (mounted) {
        if (widget.onProductFound != null) {
          widget.onProductFound!(product);
          if (widget.autoClose) {
            context.pop();
            return;
          }
        } else {
          // Navigate to product detail
          AppRouter.goToProductDetail(context, product.id);
        }
      }
    } catch (e) {
      if (mounted) {
        _showProductNotFoundDialog(imei, e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSearchingProduct = false;
          _isProcessing = false;
        });
        _controller?.start();
      }
    }
  }

  void _showImeiScannedDialog(String imei) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('IMEI Scanned'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('IMEI: $imei'),
            const SizedBox(height: 8),
            Text('Valid: ${ImeiUtils.getImeiInfo(imei).isValid ? "Yes" : "No"}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _isProcessing = false;
              _controller?.start();
            },
            child: const Text('Scan Again'),
          ),
          if (widget.autoSearchProduct)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _searchProductByImei(imei);
              },
              child: const Text('Search Product'),
            ),
          if (!widget.autoSearchProduct)
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

  void _showNotImeiDialog(String code) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Not an IMEI'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Scanned: $code'),
            const SizedBox(height: 8),
            const Text('This doesn\'t appear to be a valid IMEI number.'),
            const SizedBox(height: 8),
            const Text('IMEIs are typically 15 digits long.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _isProcessing = false;
              _controller?.start();
            },
            child: const Text('Try Again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.pop();
            },
            child: const Text('Close Scanner'),
          ),
        ],
      ),
    );
  }

  void _showProductNotFoundDialog(String imei, String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Product Not Found'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('IMEI: $imei'),
            const SizedBox(height: 8),
            Text(
              'Error: ${error.contains('not found') ? 'No product found with this IMEI' : error}',
              style: TextStyle(color: Colors.red[700]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _isProcessing = false;
              _controller?.start();
            },
            child: const Text('Scan Another'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.pop();
            },
            child: const Text('Close Scanner'),
          ),
        ],
      ),
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
        title: const Text('Enter IMEI Manually'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter IMEI (15 digits)...',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          maxLength: 15,
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
                _processScannedCode(controller.text);
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
        title: Text(widget.title ?? 'Scan IMEI'),
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
                    shape: ImeiScannerOverlayShape(),
                  ),
                ),
                
                // Loading indicator when searching
                if (_isSearchingProduct)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 16),
                          Text(
                            'Searching for product...',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
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
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.subtitle ?? 'Position IMEI barcode or text within the frame',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'IMEI: 15-digit device identifier',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
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

/// Custom shape for IMEI scanner overlay
class ImeiScannerOverlayShape extends ShapeBorder {
  const ImeiScannerOverlayShape();

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
    
    // Create the scan area (rectangle for IMEI scanning)
    final scanAreaWidth = rect.width * 0.8;
    final scanAreaHeight = rect.height * 0.3;
    final left = rect.center.dx - scanAreaWidth / 2;
    final top = rect.center.dy - scanAreaHeight / 2;
    final scanRect = Rect.fromLTWH(left, top, scanAreaWidth, scanAreaHeight);
    
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
    final scanAreaWidth = rect.width * 0.8;
    final scanAreaHeight = rect.height * 0.3;
    final left = rect.center.dx - scanAreaWidth / 2;
    final top = rect.center.dy - scanAreaHeight / 2;
    final scanRect = Rect.fromLTWH(left, top, scanAreaWidth, scanAreaHeight);
    
    final cornerPaint = Paint()
      ..color = Colors.blue
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
  ShapeBorder scale(double t) => ImeiScannerOverlayShape();
}