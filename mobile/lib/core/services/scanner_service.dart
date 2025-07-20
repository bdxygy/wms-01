import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service for managing barcode scanning functionality
class ScannerService {
  static final ScannerService _instance = ScannerService._internal();
  factory ScannerService() => _instance;
  ScannerService._internal();

  MobileScannerController? _controller;
  bool _isInitialized = false;
  bool _isScanning = false;
  StreamController<String>? _scanResultController;

  /// Current scanner controller
  MobileScannerController? get controller => _controller;

  /// Whether the scanner service is initialized
  bool get isInitialized => _isInitialized;

  /// Whether currently scanning
  bool get isScanning => _isScanning;

  /// Stream of scan results
  Stream<String>? get scanResultStream => _scanResultController?.stream;

  /// Initialize scanner service
  Future<bool> initialize() async {
    try {
      // Check camera permission
      final permissionStatus = await _checkCameraPermission();
      if (!permissionStatus) {
        return false;
      }

      // Initialize controller
      _controller = MobileScannerController(
        detectionSpeed: DetectionSpeed.noDuplicates,
        facing: CameraFacing.back,
        torchEnabled: false,
        returnImage: false,
        formats: [
          BarcodeFormat.ean8,
          BarcodeFormat.ean13,
          BarcodeFormat.upcA,
          BarcodeFormat.upcE,
          BarcodeFormat.code128,
          BarcodeFormat.code39,
          BarcodeFormat.code93,
          BarcodeFormat.qrCode,
          BarcodeFormat.dataMatrix,
          BarcodeFormat.pdf417,
        ],
      );

      // Initialize scan result stream
      _scanResultController = StreamController<String>.broadcast();

      _isInitialized = true;
      return true;
    } catch (e) {
      _isInitialized = false;
      return false;
    }
  }

  /// Check and request camera permission
  Future<bool> _checkCameraPermission() async {
    final status = await Permission.camera.status;
    
    if (status.isGranted) {
      return true;
    }
    
    if (status.isDenied) {
      final result = await Permission.camera.request();
      return result.isGranted;
    }
    
    return false;
  }

  /// Start scanning
  Future<bool> startScanning() async {
    if (!_isInitialized || _controller == null) {
      return false;
    }

    try {
      await _controller!.start();
      _isScanning = true;
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Stop scanning
  Future<void> stopScanning() async {
    if (!_isInitialized || _controller == null) return;

    try {
      await _controller!.stop();
      _isScanning = false;
    } catch (e) {
      // Ignore errors when stopping
    }
  }

  /// Toggle torch/flashlight
  Future<void> toggleTorch() async {
    if (!_isInitialized || _controller == null) return;

    try {
      await _controller!.toggleTorch();
    } catch (e) {
      // Ignore torch errors
    }
  }

  /// Switch camera (front/back)
  Future<void> switchCamera() async {
    if (!_isInitialized || _controller == null) return;

    try {
      await _controller!.switchCamera();
    } catch (e) {
      // Ignore camera switch errors
    }
  }

  /// Check if torch is available
  Future<bool> isTorchAvailable() async {
    if (!_isInitialized || _controller == null) return false;

    try {
      return await _controller!.hasTorch();
    } catch (e) {
      return false;
    }
  }

  /// Process barcode detection
  void onBarcodeDetected(BarcodeCapture capture) {
    if (capture.barcodes.isNotEmpty) {
      final barcode = capture.barcodes.first;
      final code = barcode.rawValue;
      
      if (code != null && code.isNotEmpty) {
        // Validate barcode format
        if (_isValidBarcode(code)) {
          _scanResultController?.add(code);
          
          // Provide haptic feedback
          HapticFeedback.mediumImpact();
          
          // Auto-stop after successful scan (optional)
          // stopScanning();
        }
      }
    }
  }

  /// Validate barcode format
  bool _isValidBarcode(String code) {
    if (code.isEmpty) return false;
    
    // Basic validation rules
    final numericRegex = RegExp(r'^\d+$');
    final alphanumericRegex = RegExp(r'^[A-Z0-9]+$');
    
    // EAN/UPC codes (numeric only)
    if (code.length == 8 || code.length == 12 || code.length == 13) {
      return numericRegex.hasMatch(code);
    }
    
    // Code128/Code39 (alphanumeric)
    if (code.length >= 4 && code.length <= 50) {
      return alphanumericRegex.hasMatch(code.toUpperCase());
    }
    
    // QR codes (more flexible)
    if (code.length >= 1 && code.length <= 1000) {
      return true;
    }
    
    return false;
  }

  /// Format barcode for consistency
  String formatBarcode(String code) {
    if (code.isEmpty) return code;
    
    // Remove any whitespace
    final cleaned = code.replaceAll(RegExp(r'\s+'), '');
    
    // Ensure uppercase for alphanumeric codes
    if (RegExp(r'^[A-Z0-9]+$').hasMatch(cleaned.toUpperCase())) {
      return cleaned.toUpperCase();
    }
    
    return cleaned;
  }

  /// Get supported barcode formats as strings
  List<String> getSupportedFormats() {
    return [
      'EAN-8',
      'EAN-13', 
      'UPC-A',
      'UPC-E',
      'Code 128',
      'Code 39',
      'Code 93',
      'QR Code',
      'Data Matrix',
      'PDF417',
    ];
  }

  /// Manual barcode entry validation
  bool validateManualEntry(String code) {
    if (code.isEmpty) return false;
    
    final formatted = formatBarcode(code);
    return _isValidBarcode(formatted);
  }

  /// Simulate barcode scan (for testing)
  void simulateBarcodeScan(String code) {
    if (_isValidBarcode(code)) {
      _scanResultController?.add(formatBarcode(code));
      HapticFeedback.lightImpact();
    }
  }

  /// Get scanner statistics
  Map<String, dynamic> getScannerStats() {
    return {
      'isInitialized': _isInitialized,
      'isScanning': _isScanning,
      'hasController': _controller != null,
      'supportedFormats': getSupportedFormats().length,
    };
  }

  /// Reset scanner state
  Future<void> reset() async {
    await dispose();
    await initialize();
  }

  /// Dispose scanner service
  Future<void> dispose() async {
    try {
      await stopScanning();
      await _controller?.dispose();
      await _scanResultController?.close();
      
      _controller = null;
      _scanResultController = null;
      _isInitialized = false;
      _isScanning = false;
    } catch (e) {
      // Ignore disposal errors
    }
  }
}