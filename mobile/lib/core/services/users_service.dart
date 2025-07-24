import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/user.dart';
import '../models/api_response.dart';

/// Service for managing users with CRUD operations
class UsersService {
  final ApiClient _apiClient;

  UsersService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient.instance;

  /// Get paginated list of users with optional filtering
  Future<PaginatedResponse<User>> getUsers({
    int page = 1,
    int limit = 20,
    String? role,
    String? storeId,
    bool? isActive,
    String? search,
  }) async {
    final queryParams = {
      ...ApiEndpoints.paginationParams(page: page, limit: limit),
      ...ApiEndpoints.userFilterParams(
        role: role,
        storeId: storeId,
        isActive: isActive,
        search: search,
      ),
    };

    final response = await _apiClient.get(
      ApiEndpoints.usersList,
      queryParameters: queryParams,
    );

    return PaginatedResponse<User>.fromJson(
      response.data,
      (json) => User.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Get user by ID
  Future<ApiResponse<User>> getUserById(String id) async {
    final response = await _apiClient.get(ApiEndpoints.usersById(id));

    return ApiResponse<User>.fromJson(
      response.data,
      (json) => User.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Create new user
  Future<ApiResponse<User>> createUser({
    required String name,
    required String username,
    required String password,
    required UserRole role,
    String? storeId,
  }) async {
    final requestData = {
      'name': name,
      'username': username,
      'password': password,
      'role': role.roleString,
      if (storeId != null) 'storeId': storeId,
    };

    final response = await _apiClient.post(
      ApiEndpoints.usersCreate,
      data: requestData,
    );

    return ApiResponse<User>.fromJson(
      response.data,
      (json) => User.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Update existing user
  Future<ApiResponse<User>> updateUser({
    required String id,
    String? name,
    String? username,
    String? password,
    UserRole? role,
    String? storeId,
    bool? isActive,
  }) async {
    final requestData = <String, dynamic>{};
    
    if (name != null) requestData['name'] = name;
    if (username != null) requestData['username'] = username;
    if (password != null) requestData['password'] = password;
    if (role != null) requestData['role'] = role.roleString;
    if (storeId != null) requestData['storeId'] = storeId;
    if (isActive != null) requestData['isActive'] = isActive;

    final response = await _apiClient.put(
      ApiEndpoints.usersUpdate(id),
      data: requestData,
    );

    return ApiResponse<User>.fromJson(
      response.data,
      (json) => User.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Delete user (soft delete)
  Future<ApiResponse<void>> deleteUser(String id) async {
    final response = await _apiClient.delete(ApiEndpoints.usersDelete(id));

    return ApiResponse<void>.fromJson(response.data, (_) {});
  }

  /// Search users by name or username
  Future<PaginatedResponse<User>> searchUsers({
    required String query,
    int page = 1,
    int limit = 20,
    String? role,
    bool? isActive,
  }) async {
    return getUsers(
      page: page,
      limit: limit,
      role: role,
      isActive: isActive,
      search: query,
    );
  }

  /// Get users by role
  Future<PaginatedResponse<User>> getUsersByRole({
    required UserRole role,
    int page = 1,
    int limit = 20,
    bool? isActive,
  }) async {
    return getUsers(
      page: page,
      limit: limit,
      role: role.roleString,
      isActive: isActive,
    );
  }

  /// Get active users only
  Future<PaginatedResponse<User>> getActiveUsers({
    int page = 1,
    int limit = 20,
    String? role,
  }) async {
    return getUsers(
      page: page,
      limit: limit,
      role: role,
      isActive: true,
    );
  }
}

/// Extension to add role string conversion
extension UserRoleExtension on UserRole {
  String get roleString {
    switch (this) {
      case UserRole.owner:
        return 'OWNER';
      case UserRole.admin:
        return 'ADMIN';
      case UserRole.staff:
        return 'STAFF';
      case UserRole.cashier:
        return 'CASHIER';
    }
  }
}