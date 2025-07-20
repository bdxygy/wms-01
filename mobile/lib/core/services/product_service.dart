import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/api_response.dart';
import '../models/api_requests.dart';
import '../models/product.dart';

class ProductService {
  final ApiClient _apiClient = ApiClient.instance;

  /// Get paginated list of products with optional filtering
  Future<PaginatedResponse<Product>> getProducts({
    int page = 1,
    int limit = 20,
    String? search,
    String? storeId,
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    bool? hasImei,
  }) async {
    // Use API endpoints utility methods
    final paginationParams = ApiEndpoints.paginationParams(page: page, limit: limit);
    final filterParams = ApiEndpoints.productFilterParams(
      storeId: storeId,
      categoryId: categoryId,
      isImei: hasImei,
      minPrice: minPrice,
      maxPrice: maxPrice,
      search: search,
    );

    // Combine pagination and filter parameters
    final queryParams = {...paginationParams, ...filterParams};

    try {
      final response = await _apiClient.get(ApiEndpoints.productsList, queryParameters: queryParams);
      return PaginatedResponse<Product>.fromJson(
        response.data,
        (json) => Product.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get product by ID
  Future<Product> getProductById(String productId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.productsById(productId));
      final apiResponse = ApiResponse<Product>.fromJson(
        response.data,
        (json) => Product.fromJson(json as Map<String, dynamic>),
      );
      if (apiResponse.data == null) {
        throw Exception('Product not found');
      }
      return apiResponse.data!;
    } catch (e) {
      rethrow;
    }
  }

  /// Search product by barcode
  Future<Product> getProductByBarcode(String barcode) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.productsByBarcode(barcode));
      final apiResponse = ApiResponse<Product>.fromJson(
        response.data,
        (json) => Product.fromJson(json as Map<String, dynamic>),
      );
      if (apiResponse.data == null) {
        throw Exception('Product not found');
      }
      return apiResponse.data!;
    } catch (e) {
      rethrow;
    }
  }

  /// Search product by IMEI
  Future<Product> getProductByImei(String imei) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.productsByImei(imei));
      final apiResponse = ApiResponse<Product>.fromJson(
        response.data,
        (json) => Product.fromJson(json as Map<String, dynamic>),
      );
      if (apiResponse.data == null) {
        throw Exception('Product not found');
      }
      return apiResponse.data!;
    } catch (e) {
      rethrow;
    }
  }

  /// Create new product (OWNER/ADMIN only)
  Future<Product> createProduct(CreateProductRequest request) async {
    try {
      final response = await _apiClient.post(ApiEndpoints.productsCreate, data: request.toJson());
      final apiResponse = ApiResponse<Product>.fromJson(
        response.data,
        (json) => Product.fromJson(json as Map<String, dynamic>),
      );
      if (!apiResponse.success || apiResponse.data == null) {
        throw Exception(apiResponse.error?.message ?? 'Failed to create product');
      }
      return apiResponse.data!;
    } catch (e) {
      rethrow;
    }
  }

  /// Update product (OWNER/ADMIN only)
  Future<Product> updateProduct(String productId, UpdateProductRequest request) async {
    try {
      final response = await _apiClient.put(ApiEndpoints.productsUpdate(productId), data: request.toJson());
      final apiResponse = ApiResponse<Product>.fromJson(
        response.data,
        (json) => Product.fromJson(json as Map<String, dynamic>),
      );
      if (!apiResponse.success || apiResponse.data == null) {
        throw Exception(apiResponse.error?.message ?? 'Failed to update product');
      }
      return apiResponse.data!;
    } catch (e) {
      rethrow;
    }
  }
}