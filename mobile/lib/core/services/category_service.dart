import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/api_response.dart';
import '../models/api_requests.dart';
import '../models/category.dart';

class CategoryService {
  final ApiClient _apiClient = ApiClient.instance;

  /// Get paginated list of categories with optional filtering
  Future<PaginatedResponse<Category>> getCategories({
    int page = 1,
    int limit = 20,
    String? storeId,
    String? search,
  }) async {
    // Use API endpoints utility methods
    final paginationParams = ApiEndpoints.paginationParams(page: page, limit: limit);
    final filterParams = ApiEndpoints.categoryFilterParams(
      storeId: storeId,
      search: search,
    );

    // Combine pagination and filter parameters
    final queryParams = {...paginationParams, ...filterParams};

    try {
      final response = await _apiClient.get(ApiEndpoints.categoriesList, queryParameters: queryParams);
      return PaginatedResponse<Category>.fromJson(
        response.data,
        (json) => Category.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get category by ID
  Future<Category> getCategoryById(String categoryId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.categoriesById(categoryId));
      final apiResponse = ApiResponse<Category>.fromJson(
        response.data,
        (json) => Category.fromJson(json as Map<String, dynamic>),
      );
      if (apiResponse.data == null) {
        throw Exception('Category not found');
      }
      return apiResponse.data!;
    } catch (e) {
      rethrow;
    }
  }

  /// Create new category (OWNER/ADMIN only)
  Future<Category> createCategory(CreateCategoryRequest request) async {
    try {
      final response = await _apiClient.post(ApiEndpoints.categoriesCreate, data: request.toJson());
      final apiResponse = ApiResponse<Category>.fromJson(
        response.data,
        (json) => Category.fromJson(json as Map<String, dynamic>),
      );
      if (!apiResponse.success || apiResponse.data == null) {
        throw Exception(apiResponse.error?.message ?? 'Failed to create category');
      }
      return apiResponse.data!;
    } catch (e) {
      rethrow;
    }
  }

  /// Update category (OWNER/ADMIN only)
  Future<Category> updateCategory(String categoryId, UpdateCategoryRequest request) async {
    try {
      final response = await _apiClient.put(ApiEndpoints.categoriesUpdate(categoryId), data: request.toJson());
      final apiResponse = ApiResponse<Category>.fromJson(
        response.data,
        (json) => Category.fromJson(json as Map<String, dynamic>),
      );
      if (!apiResponse.success || apiResponse.data == null) {
        throw Exception(apiResponse.error?.message ?? 'Failed to update category');
      }
      return apiResponse.data!;
    } catch (e) {
      rethrow;
    }
  }

  /// Delete category (OWNER/ADMIN only) - Soft delete
  Future<Category> deleteCategory(String categoryId) async {
    try {
      final response = await _apiClient.delete(ApiEndpoints.categoriesDelete(categoryId));
      final apiResponse = ApiResponse<Category>.fromJson(
        response.data,
        (json) => Category.fromJson(json as Map<String, dynamic>),
      );
      if (!apiResponse.success || apiResponse.data == null) {
        throw Exception(apiResponse.error?.message ?? 'Failed to delete category');
      }
      return apiResponse.data!;
    } catch (e) {
      rethrow;
    }
  }
}