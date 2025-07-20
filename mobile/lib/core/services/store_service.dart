import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/api_response.dart';
import '../models/api_requests.dart';
import '../models/store.dart';

class StoreService {
  final ApiClient _apiClient = ApiClient.instance;

  /// Get paginated list of stores with optional filtering
  Future<PaginatedResponse<Store>> getStores({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    // Use API endpoints utility methods
    final paginationParams = ApiEndpoints.paginationParams(page: page, limit: limit);
    final Map<String, dynamic> filterParams = {};
    if (search != null && search.isNotEmpty) {
      filterParams['search'] = search;
    }

    // Combine pagination and filter parameters
    final queryParams = {...paginationParams, ...filterParams};

    try {
      final response = await _apiClient.get(ApiEndpoints.storesList, queryParameters: queryParams);
      return PaginatedResponse<Store>.fromJson(
        response.data,
        (json) => Store.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get store by ID
  Future<Store> getStoreById(String storeId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.storesById(storeId));
      final apiResponse = ApiResponse<Store>.fromJson(
        response.data,
        (json) => Store.fromJson(json as Map<String, dynamic>),
      );
      if (apiResponse.data == null) {
        throw Exception('Store not found');
      }
      return apiResponse.data!;
    } catch (e) {
      rethrow;
    }
  }

  /// Create new store (OWNER only)
  Future<Store> createStore(CreateStoreRequest request) async {
    try {
      final response = await _apiClient.post(ApiEndpoints.storesCreate, data: request.toJson());
      final apiResponse = ApiResponse<Store>.fromJson(
        response.data,
        (json) => Store.fromJson(json as Map<String, dynamic>),
      );
      if (!apiResponse.success || apiResponse.data == null) {
        throw Exception(apiResponse.error?.message ?? 'Failed to create store');
      }
      return apiResponse.data!;
    } catch (e) {
      rethrow;
    }
  }

  /// Update store (OWNER only)
  Future<Store> updateStore(String storeId, UpdateStoreRequest request) async {
    try {
      final response = await _apiClient.put(ApiEndpoints.storesUpdate(storeId), data: request.toJson());
      final apiResponse = ApiResponse<Store>.fromJson(
        response.data,
        (json) => Store.fromJson(json as Map<String, dynamic>),
      );
      if (!apiResponse.success || apiResponse.data == null) {
        throw Exception(apiResponse.error?.message ?? 'Failed to update store');
      }
      return apiResponse.data!;
    } catch (e) {
      rethrow;
    }
  }
}