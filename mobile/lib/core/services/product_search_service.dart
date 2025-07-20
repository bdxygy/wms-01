import 'dart:async';

import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/product.dart';
import '../utils/barcode_utils.dart';
import '../utils/imei_utils.dart';

/// Service for product search operations including barcode-based search
class ProductSearchService {
  static final ProductSearchService _instance = ProductSearchService._internal();
  factory ProductSearchService() => _instance;
  ProductSearchService._internal();

  final ApiClient _apiClient = ApiClient.instance;

  /// Search products by barcode
  Future<Product?> searchByBarcode(String barcode) async {
    try {
      // Clean and validate barcode
      final cleanBarcode = BarcodeUtils.cleanBarcode(barcode);
      if (!BarcodeUtils.isValidBarcode(cleanBarcode)) {
        throw ArgumentError('Invalid barcode format');
      }

      // Make API call to search by barcode
      final response = await _apiClient.get(
        '${ApiEndpoints.productsByBarcode}/$cleanBarcode',
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          final product = Product.fromJson(data['data']);
          return product;
        }
      } else if (response.statusCode == 404) {
        return null;
      }

      throw Exception('Failed to search product by barcode');
    } catch (e) {
      rethrow;
    }
  }

  /// Search products by IMEI (for electronics) with enhanced validation
  Future<Product?> searchByImei(String imei) async {
    try {
      // Enhanced IMEI validation using ImeiUtils
      final cleanImei = ImeiUtils.cleanImei(imei);
      if (!ImeiUtils.isValidImei(cleanImei)) {
        throw ArgumentError('Invalid IMEI format');
      }

      // Make API call to search by IMEI
      final response = await _apiClient.get(
        '${ApiEndpoints.productsByImei}/$cleanImei',
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          final product = Product.fromJson(data['data']);
          return product;
        }
      } else if (response.statusCode == 404) {
        return null;
      }

      throw Exception('Failed to search product by IMEI');
    } catch (e) {
      rethrow;
    }
  }

  /// Enhanced IMEI search with detailed result information
  Future<ImeiSearchResult> searchByImeiDetailed(String imei) async {
    try {
      final imeiInfo = ImeiUtils.getImeiInfo(imei);
      
      if (!imeiInfo.isValid) {
        return ImeiSearchResult.error(
          imei, 
          'Invalid IMEI format: ${imeiInfo.errorMessage}',
          imeiInfo,
        );
      }

      final product = await searchByImei(imeiInfo.cleanedImei);
      
      return ImeiSearchResult(
        imei: imeiInfo.cleanedImei,
        imeiInfo: imeiInfo,
        product: product,
        timestamp: DateTime.now(),
        isSuccess: true,
        wasFound: product != null,
      );
    } catch (e) {
      return ImeiSearchResult.error(
        imei, 
        'Search failed: ${e.toString()}',
        ImeiUtils.getImeiInfo(imei),
      );
    }
  }

  /// Search products by text query with optional barcode integration
  Future<List<Product>> searchProducts({
    String? query,
    String? categoryId,
    String? storeId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (query != null && query.isNotEmpty) {
        // Check if query looks like an IMEI first
        if (ImeiUtils.isLikelyImei(query)) {
          final product = await searchByImei(query);
          if (product != null) {
            return [product];
          }
        }
        
        // Check if query looks like a barcode
        if (BarcodeUtils.isValidBarcode(query)) {
          // Try barcode search first
          final product = await searchByBarcode(query);
          if (product != null) {
            return [product];
          }
        }
        queryParams['search'] = query;
      }

      if (categoryId != null) {
        queryParams['categoryId'] = categoryId;
      }

      if (storeId != null) {
        queryParams['storeId'] = storeId;
      }

      final response = await _apiClient.get(
        ApiEndpoints.productsList,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> productList = data['data'];
          final products = productList.map((json) => Product.fromJson(json)).toList();
          return products;
        }
      }

      throw Exception('Failed to search products');
    } catch (e) {
      rethrow;
    }
  }

  /// Quick product lookup by various identifiers
  Future<ProductSearchResult> quickSearch(String identifier) async {
    try {
      final cleanIdentifier = identifier.trim();
      if (cleanIdentifier.isEmpty) {
        return ProductSearchResult.empty();
      }

      // Determine search type based on identifier format
      final searchType = _detectSearchType(cleanIdentifier);
      Product? product;

      switch (searchType) {
        case WmsProductSearchType.barcode:
          product = await searchByBarcode(cleanIdentifier);
          break;
        case WmsProductSearchType.imei:
          product = await searchByImei(cleanIdentifier);
          break;
        case WmsProductSearchType.text:
          final products = await searchProducts(query: cleanIdentifier, limit: 1);
          product = products.isNotEmpty ? products.first : null;
          break;
      }

      return ProductSearchResult(
        product: product,
        searchType: searchType,
        query: cleanIdentifier,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      return ProductSearchResult.error(identifier, e.toString());
    }
  }

  /// Detect the type of search based on identifier format
  WmsProductSearchType _detectSearchType(String identifier) {
    // Check if it's likely an IMEI first
    if (ImeiUtils.isLikelyImei(identifier)) {
      return WmsProductSearchType.imei;
    }
    
    // Check if it's a valid barcode
    if (BarcodeUtils.isValidBarcode(identifier)) {
      return WmsProductSearchType.barcode;
    }
    
    // Default to text search
    return WmsProductSearchType.text;
  }

  /// Get search suggestions based on query
  Future<List<String>> getSearchSuggestions(String query) async {
    try {
      if (query.length < 2) return [];
      
      final response = await _apiClient.get(
        '${ApiEndpoints.productsList}/suggestions',
        queryParameters: {'q': query, 'limit': '10'},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> suggestions = data['data'];
          return suggestions.map((s) => s.toString()).toList();
        }
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  /// Validate product access based on user role and store context
  bool canAccessProduct(Product product, String userRole, String? currentStoreId) {
    switch (userRole.toUpperCase()) {
      case 'OWNER':
        return true; // Owners can access all products
      case 'ADMIN':
      case 'STAFF':
      case 'CASHIER':
        // Non-owners can only access products from their current store
        return currentStoreId != null && product.storeId == currentStoreId;
      default:
        return false;
    }
  }
}

/// Enhanced IMEI search result with detailed information
class ImeiSearchResult {
  final String imei;
  final ImeiInfo imeiInfo;
  final Product? product;
  final DateTime timestamp;
  final bool isSuccess;
  final bool wasFound;
  final String? errorMessage;

  ImeiSearchResult({
    required this.imei,
    required this.imeiInfo,
    this.product,
    required this.timestamp,
    required this.isSuccess,
    required this.wasFound,
    this.errorMessage,
  });

  factory ImeiSearchResult.error(String imei, String errorMessage, ImeiInfo imeiInfo) {
    return ImeiSearchResult(
      imei: imei,
      imeiInfo: imeiInfo,
      timestamp: DateTime.now(),
      isSuccess: false,
      wasFound: false,
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
      'wasFound': wasFound,
      'errorMessage': errorMessage,
    };
  }

  factory ImeiSearchResult.fromJson(Map<String, dynamic> json) {
    return ImeiSearchResult(
      imei: json['imei'] ?? '',
      imeiInfo: ImeiInfo.fromJson(json['imeiInfo'] ?? {}),
      product: json['product'] != null ? Product.fromJson(json['product']) : null,
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      isSuccess: json['isSuccess'] ?? false,
      wasFound: json['wasFound'] ?? false,
      errorMessage: json['errorMessage'],
    );
  }
}

/// Enum for different product search types
enum WmsProductSearchType {
  barcode,
  imei,
  text,
}

/// Product search result with metadata
class ProductSearchResult {
  final Product? product;
  final WmsProductSearchType searchType;
  final String query;
  final DateTime timestamp;
  final bool isSuccess;
  final String? errorMessage;

  ProductSearchResult({
    this.product,
    required this.searchType,
    required this.query,
    required this.timestamp,
    this.isSuccess = true,
    this.errorMessage,
  });

  factory ProductSearchResult.empty() {
    return ProductSearchResult(
      searchType: WmsProductSearchType.text,
      query: '',
      timestamp: DateTime.now(),
      isSuccess: false,
    );
  }

  factory ProductSearchResult.error(String query, String errorMessage) {
    return ProductSearchResult(
      searchType: WmsProductSearchType.text,
      query: query,
      timestamp: DateTime.now(),
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }

  bool get hasProduct => product != null;
  bool get isEmpty => product == null && isSuccess;
  bool get hasError => !isSuccess && errorMessage != null;

  String get searchTypeDisplay {
    switch (searchType) {
      case WmsProductSearchType.barcode:
        return 'Barcode';
      case WmsProductSearchType.imei:
        return 'IMEI';
      case WmsProductSearchType.text:
        return 'Text';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product?.toJson(),
      'searchType': searchType.name,
      'query': query,
      'timestamp': timestamp.toIso8601String(),
      'isSuccess': isSuccess,
      'errorMessage': errorMessage,
    };
  }
}