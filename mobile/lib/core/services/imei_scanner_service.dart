import 'dart:async';

import '../utils/imei_utils.dart';
import '../services/scanner_service.dart';
import '../services/product_search_service.dart';
import '../models/product.dart';

/// Service for IMEI-specific scanning and management
class ImeiScannerService {
  static final ImeiScannerService _instance = ImeiScannerService._internal();
  factory ImeiScannerService() => _instance;
  ImeiScannerService._internal();

  final ScannerService _scannerService = ScannerService();
  
  /// Get access to the underlying scanner service
  ScannerService get scannerService => _scannerService;
  final ProductSearchService _productSearchService = ProductSearchService();
  
  StreamController<ImeiScanResult>? _imeiScanController;
  final List<ImeiScanResult> _scanHistory = [];
  
  /// Stream of IMEI scan results
  Stream<ImeiScanResult>? get imeiScanStream => _imeiScanController?.stream;
  
  /// IMEI scan history
  List<ImeiScanResult> get scanHistory => List.unmodifiable(_scanHistory);
  
  /// Initialize IMEI scanner service
  Future<bool> initialize() async {
    try {
      // Initialize the underlying scanner service
      final scannerInitialized = await _scannerService.initialize();
      if (!scannerInitialized) {
        return false;
      }
      
      // Initialize IMEI scan result stream
      _imeiScanController = StreamController<ImeiScanResult>.broadcast();
      
      // Listen to general scan results and filter for IMEI
      _scannerService.scanResultStream?.listen(_handleScanResult);
      
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Handle scan results and filter for IMEI
  void _handleScanResult(String scannedCode) {
    // Check if the scanned code is likely an IMEI
    if (ImeiUtils.isLikelyImei(scannedCode)) {
      final result = ImeiScanResult.fromScan(scannedCode, 'camera');
      _processImeiScanResult(result);
    }
  }
  
  /// Process IMEI scan result
  void _processImeiScanResult(ImeiScanResult result) {
    // Add to history
    _scanHistory.insert(0, result);
    if (_scanHistory.length > 100) {
      _scanHistory.removeLast();
    }
    
    // Emit result
    _imeiScanController?.add(result);
  }
  
  /// Start IMEI scanning
  Future<bool> startScanning() async {
    return await _scannerService.startScanning();
  }
  
  /// Stop IMEI scanning
  Future<void> stopScanning() async {
    await _scannerService.stopScanning();
  }
  
  /// Manually enter IMEI
  ImeiScanResult enterImeiManually(String imei) {
    final result = ImeiScanResult.fromScan(imei, 'manual');
    _processImeiScanResult(result);
    return result;
  }
  
  /// Search product by IMEI
  Future<ImeiProductSearchResult> searchProductByImei(String imei) async {
    try {
      final imeiInfo = ImeiUtils.getImeiInfo(imei);
      
      if (!imeiInfo.isValid) {
        return ImeiProductSearchResult.error(
          imei, 
          'Invalid IMEI format',
          imeiInfo,
        );
      }
      
      // Search using the product search service
      final product = await _productSearchService.searchByImei(imeiInfo.cleanedImei);
      
      return ImeiProductSearchResult(
        imei: imeiInfo.cleanedImei,
        imeiInfo: imeiInfo,
        product: product,
        timestamp: DateTime.now(),
        isSuccess: product != null,
      );
    } catch (e) {
      return ImeiProductSearchResult.error(
        imei, 
        'Search failed: ${e.toString()}',
        ImeiUtils.getImeiInfo(imei),
      );
    }
  }
  
  /// Batch search multiple IMEIs
  Future<List<ImeiProductSearchResult>> searchMultipleImeis(List<String> imeis) async {
    final results = <ImeiProductSearchResult>[];
    
    for (final imei in imeis) {
      final result = await searchProductByImei(imei);
      results.add(result);
    }
    
    return results;
  }
  
  /// Validate IMEI and provide feedback
  ImeiValidationResult validateImei(String imei) {
    return ImeiUtils.validateInput(imei);
  }
  
  /// Get IMEI scanner statistics
  Map<String, dynamic> getImeiScannerStats() {
    final totalScans = _scanHistory.length;
    final validScans = _scanHistory.where((scan) => scan.isValid).length;
    final uniqueImeis = _scanHistory.map((scan) => scan.imeiInfo.cleanedImei).toSet().length;
    
    return {
      'totalScans': totalScans,
      'validScans': validScans,
      'invalidScans': totalScans - validScans,
      'uniqueImeis': uniqueImeis,
      'scanMethods': _getScanMethodStats(),
      'lastScanTime': _scanHistory.isNotEmpty ? _scanHistory.first.timestamp.toIso8601String() : null,
    };
  }
  
  /// Get scan method statistics
  Map<String, int> _getScanMethodStats() {
    final methodCounts = <String, int>{};
    
    for (final scan in _scanHistory) {
      methodCounts[scan.scanMethod] = (methodCounts[scan.scanMethod] ?? 0) + 1;
    }
    
    return methodCounts;
  }
  
  /// Clear IMEI scan history
  void clearScanHistory() {
    _scanHistory.clear();
  }
  
  /// Get recent IMEI scans (last N scans)
  List<ImeiScanResult> getRecentScans({int limit = 10}) {
    return _scanHistory.take(limit).toList();
  }
  
  /// Find scans by IMEI
  List<ImeiScanResult> findScansByImei(String imei) {
    final cleanedImei = ImeiUtils.cleanImei(imei);
    return _scanHistory
        .where((scan) => scan.imeiInfo.cleanedImei == cleanedImei)
        .toList();
  }
  
  /// Export scan history as JSON
  List<Map<String, dynamic>> exportScanHistory() {
    return _scanHistory.map((scan) => scan.toJson()).toList();
  }
  
  /// Import scan history from JSON
  void importScanHistory(List<Map<String, dynamic>> jsonData) {
    _scanHistory.clear();
    for (final json in jsonData) {
      try {
        final scan = ImeiScanResult.fromJson(json);
        _scanHistory.add(scan);
      } catch (e) {
        // Skip invalid entries
        continue;
      }
    }
  }
  
  /// Check if IMEI scanner is ready
  bool get isReady => _scannerService.isInitialized && _imeiScanController != null;
  
  /// Check if currently scanning
  bool get isScanning => _scannerService.isScanning;
  
  /// Toggle torch for IMEI scanning
  Future<void> toggleTorch() async {
    await _scannerService.toggleTorch();
  }
  
  /// Switch camera for IMEI scanning
  Future<void> switchCamera() async {
    await _scannerService.switchCamera();
  }
  
  /// Check if torch is available
  Future<bool> isTorchAvailable() async {
    return await _scannerService.isTorchAvailable();
  }
  
  /// Simulate IMEI scan for testing
  void simulateImeiScan(String imei) {
    final result = ImeiScanResult.fromScan(imei, 'simulation');
    _processImeiScanResult(result);
  }
  
  /// Dispose IMEI scanner service
  Future<void> dispose() async {
    await _imeiScanController?.close();
    _imeiScanController = null;
    _scanHistory.clear();
  }
}

/// IMEI product search result model
class ImeiProductSearchResult {
  final String imei;
  final ImeiInfo imeiInfo;
  final Product? product;
  final DateTime timestamp;
  final bool isSuccess;
  final String? errorMessage;

  ImeiProductSearchResult({
    required this.imei,
    required this.imeiInfo,
    this.product,
    required this.timestamp,
    required this.isSuccess,
    this.errorMessage,
  });

  factory ImeiProductSearchResult.error(String imei, String errorMessage, ImeiInfo imeiInfo) {
    return ImeiProductSearchResult(
      imei: imei,
      imeiInfo: imeiInfo,
      timestamp: DateTime.now(),
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }

  bool get hasProduct => product != null;
  bool get hasError => !isSuccess && errorMessage != null;

  Map<String, dynamic> toJson() {
    return {
      'imei': imei,
      'imeiInfo': imeiInfo.toJson(),
      'product': product?.toJson(),
      'timestamp': timestamp.toIso8601String(),
      'isSuccess': isSuccess,
      'errorMessage': errorMessage,
    };
  }

  factory ImeiProductSearchResult.fromJson(Map<String, dynamic> json) {
    return ImeiProductSearchResult(
      imei: json['imei'] ?? '',
      imeiInfo: ImeiInfo.fromJson(json['imeiInfo'] ?? {}),
      product: json['product'] != null ? Product.fromJson(json['product']) : null,
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      isSuccess: json['isSuccess'] ?? false,
      errorMessage: json['errorMessage'],
    );
  }
}

/// IMEI management service for adding/removing IMEIs from products
class ImeiManagementService {
  static final ImeiManagementService _instance = ImeiManagementService._internal();
  factory ImeiManagementService() => _instance;
  ImeiManagementService._internal();

  final ProductSearchService _productSearchService = ProductSearchService();

  /// Add IMEI to a product
  Future<bool> addImeiToProduct(String productId, String imei) async {
    try {
      final imeiInfo = ImeiUtils.getImeiInfo(imei);
      if (!imeiInfo.isValid) {
        throw ArgumentError('Invalid IMEI format');
      }

      // TODO: Implement API call to add IMEI to product
      // This would call the backend endpoint: POST /api/v1/products/:id/imeis
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Remove IMEI from a product
  Future<bool> removeImeiFromProduct(String imeiId) async {
    try {
      // TODO: Implement API call to remove IMEI
      // This would call the backend endpoint: DELETE /api/v1/imeis/:id
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get all IMEIs for a product
  Future<List<String>> getProductImeis(String productId) async {
    try {
      // TODO: Implement API call to get product IMEIs
      // This would call the backend endpoint: GET /api/v1/products/:id/imeis
      
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Validate IMEI uniqueness
  Future<bool> isImeiUnique(String imei) async {
    try {
      final product = await _productSearchService.searchByImei(imei);
      return product == null; // IMEI is unique if no product found
    } catch (e) {
      return false;
    }
  }
}