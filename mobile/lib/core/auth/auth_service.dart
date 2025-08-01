import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../api/api_exceptions.dart';
import '../models/auth_response.dart';
import '../models/api_response.dart';
import '../models/store.dart';
import '../models/user.dart';
import '../utils/app_config.dart';
import 'secure_storage.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient.instance;
  final SecureStorageService _storage = SecureStorageService();

  // Login with username and password
  Future<AuthResponse> login(String username, String password) async {
    try {
      final loginRequest = LoginRequest(
        username: username,
        password: password,
      );

      final response = await _apiClient.post(
        ApiEndpoints.authLogin,
        data: loginRequest.toJson(),
      );

      final apiResponse = ApiResponse<LoginResponseData>.fromJson(
        response.data,
        (json) => LoginResponseData.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.success && apiResponse.data != null) {
        final loginData = apiResponse.data!;
        
        // Parse the authentication response
        final authResponse = AuthResponse(
          accessToken: loginData.tokens.accessToken,
          refreshToken: loginData.tokens.refreshToken ?? '', // Handle missing refreshToken
          user: loginData.user,
          expiresAt: DateTime.now().add(const Duration(hours: 1)), // Default 1 hour
        );

        // Store tokens and user data securely
        await _storage.storeTokens(authResponse);
        await _storage.storeUser(authResponse.user);

        if (AppConfig.isDebugMode) {
         debugPrint('🔐 User ${authResponse.user.username} logged in successfully');
        }

        return authResponse;
      } else {
        throw AuthException(
          message: apiResponse.error?.message ?? 'Login failed',
          code: apiResponse.error?.code ?? 'LOGIN_FAILED',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException(
          message: 'Invalid username or password',
          code: 'INVALID_CREDENTIALS',
        );
      }
      rethrow;
    }
  }

  // Refresh access token using refresh token
  Future<AuthResponse?> refreshToken() async {
    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        if (AppConfig.isDebugMode) {
         debugPrint('🔄 No refresh token available, clearing auth data');
        }
        await logout();
        throw AuthException(
          message: 'No refresh token available',
          code: 'NO_REFRESH_TOKEN',
        );
      }

      final refreshRequest = RefreshTokenRequest(
        refreshToken: refreshToken,
      );

      final response = await _apiClient.post(
        ApiEndpoints.authRefresh,
        data: refreshRequest.toJson(),
      );

      final apiResponse = ApiResponse<LoginResponseData>.fromJson(
        response.data,
        (json) => LoginResponseData.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.success && apiResponse.data != null) {
        final loginData = apiResponse.data!;
        
        final authResponse = AuthResponse(
          accessToken: loginData.tokens.accessToken,
          refreshToken: loginData.tokens.refreshToken ?? '', // Handle missing refreshToken
          user: loginData.user,
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
        );

        // Update stored tokens
        await _storage.storeTokens(authResponse);
        await _storage.storeUser(authResponse.user);

        if (AppConfig.isDebugMode) {
         debugPrint('🔄 Token refreshed successfully');
        }

        return authResponse;
      } else {
        // Refresh failed, clear all tokens
        await logout();
        throw AuthException(
          message: apiResponse.error?.message ?? 'Token refresh failed',
          code: apiResponse.error?.code ?? 'REFRESH_FAILED',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        // Refresh token is invalid, clear all auth data
        await logout();
        throw AuthException(
          message: 'Session expired. Please login again.',
          code: 'SESSION_EXPIRED',
        );
      }
      rethrow;
    }
  }

  // Logout user and clear all stored data
  Future<void> logout() async {
    try {
      final refreshToken = await _storage.getRefreshToken();
      
      if (refreshToken != null) {
        // Try to invalidate token on server
        try {
          await _apiClient.post(
            ApiEndpoints.authLogout,
            data: {'refreshToken': refreshToken},
          );
          
          if (AppConfig.isDebugMode) {
           debugPrint('🚪 Logout successful on server');
          }
        } catch (e) {
          // Server logout failed, but continue with local cleanup
          if (AppConfig.isDebugMode) {
           debugPrint('⚠️ Server logout failed, continuing with local cleanup');
          }
        }
      }
    } finally {
      // Always clear local auth data
      await _storage.clearAllAuthData();
      
      // Clear API client instance to reset interceptors
      ApiClient.clearInstance();
      
      if (AppConfig.isDebugMode) {
       debugPrint('🧹 Local auth data cleared');
      }
    }
  }

  // Check if user is currently authenticated
  Future<bool> isAuthenticated() async {
    try {
      final hasValidTokens = await _storage.hasValidTokens();
      final user = await _storage.getUser();
      
      return hasValidTokens && user != null;
    } catch (e) {
      return false;
    }
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    return await _storage.getUser();
  }

  // Check if token needs refresh
  Future<bool> needsTokenRefresh() async {
    // First check if we have a refresh token available
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      if (AppConfig.isDebugMode) {
       debugPrint('🔄 No refresh token available, cannot refresh');
      }
      return false;
    }
    
    return await _storage.isTokenNearExpiry();
  }

  // Auto-refresh token if needed
  Future<bool> ensureValidToken() async {
    try {
      // First check if we have tokens locally
      if (!await isAuthenticated()) {
        return false;
      }

      // If token is near expiry, try to refresh it
      if (await needsTokenRefresh()) {
        try {
          final refreshResult = await refreshToken();
          return refreshResult != null;
        } catch (e) {
          // If refresh fails, clear auth data and return false
          if (AppConfig.isDebugMode) {
           debugPrint('❌ Token refresh failed, clearing auth data: $e');
          }
          await logout();
          return false;
        }
      }

      // Validate token with server by making a test API call
      return await _validateTokenWithServer();
    } catch (e) {
      if (AppConfig.isDebugMode) {
       debugPrint('❌ Token validation failed: $e');
      }
      return false;
    }
  }

  // Validate token with server by making a test API call
  Future<bool> _validateTokenWithServer() async {
    try {
      // Make a simple authenticated API call to verify token is valid
      // Using the users endpoint which requires authentication
      final response = await _apiClient.get('${ApiEndpoints.usersList}?limit=1');
      
      // If we get a successful response, token is valid
      return response.statusCode == 200;
    } catch (e) {
      if (AppConfig.isDebugMode) {
       debugPrint('🔍 Server token validation failed: $e');
      }
      // If API call fails (401, 403, etc.), token is invalid
      return false;
    }
  }

  // Register new user (dev/admin only)
  Future<User> register(RegisterRequest registerRequest) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.authRegister,
        data: registerRequest.toJson(),
      );

      if (response.data != null && response.data!['success'] == true) {
        final userData = response.data!['data'] as Map<String, dynamic>;
        final user = User.fromJson(userData);

        if (AppConfig.isDebugMode) {
         debugPrint('👤 User ${user.username} registered successfully');
        }

        return user;
      } else {
        throw AuthException(
          message: response.data?['message'] ?? 'Registration failed',
          code: 'REGISTRATION_FAILED',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final errorData = e.response?.data;
        if (errorData != null && errorData['error'] != null) {
          throw ValidationException(
            message: errorData['error']['message'] ?? 'Registration failed',
            code: 'VALIDATION_ERROR',
            details: errorData,
          );
        }
      }
      rethrow;
    }
  }

  // Development register (creates OWNER user)
  Future<User> devRegister(String name, String username, String password) async {
    try {
      final registerRequest = RegisterRequest(
        name: name,
        username: username,
        password: password,
        role: 'OWNER',
      );

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.authDevRegister,
        data: registerRequest.toJson(),
      );

      if (response.data != null && response.data!['success'] == true) {
        final userData = response.data!['data'] as Map<String, dynamic>;
        final user = User.fromJson(userData);

        if (AppConfig.isDebugMode) {
         debugPrint('👑 OWNER user ${user.username} created successfully');
        }

        return user;
      } else {
        throw AuthException(
          message: response.data?['message'] ?? 'Dev registration failed',
          code: 'DEV_REGISTRATION_FAILED',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get stored authentication state for app initialization
  Future<AuthenticationState> getStoredAuthState() async {
    try {
      final user = await _storage.getUser();
      final hasValidTokens = await _storage.hasValidTokens();
      final selectedStoreId = await _storage.getSelectedStoreId();

      if (user != null && hasValidTokens) {
        // Check if non-owner user needs store selection
        if (!user.isOwner && selectedStoreId == null) {
          return AuthenticationState.needsStoreSelection(user);
        }
        
        return AuthenticationState.authenticated(user, selectedStoreId);
      }
      
      return AuthenticationState.unauthenticated();
    } catch (e) {
      if (AppConfig.isDebugMode) {
       debugPrint('⚠️ Error getting stored auth state: $e');
      }
      return AuthenticationState.unauthenticated();
    }
  }

  // Store selected store for non-owner users
  Future<void> selectStore(String storeId) async {
    await _storage.storeSelectedStoreId(storeId);
  }

  // Clear selected store
  Future<void> clearSelectedStore() async {
    await _storage.clearSelectedStore();
  }

  // Get user stores
  Future<List<Store>> getUserStores() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.stores,
      );

      if (response.data != null && response.data!['success'] == true) {
        final data = response.data!['data'];
        
        if (data is Map<String, dynamic> && data['stores'] is List) {
          final storesJson = data['stores'] as List;
          return storesJson
              .map((store) => Store.fromJson(store as Map<String, dynamic>))
              .toList();
        } else if (data is List) {
          return data
              .map((store) => Store.fromJson(store as Map<String, dynamic>))
              .toList();
        }
      }
      
      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return []; // No stores found
      }
      throw ApiException(
        message: e.response?.data?['message'] ?? 'Failed to fetch stores',
        code: 'FETCH_STORES_FAILED',
      );
    }
  }
}

// Authentication state for app initialization
class AuthenticationState {
  final bool isAuthenticated;
  final bool needsStoreSelection;
  final User? user;
  final String? selectedStoreId;

  AuthenticationState._(
    this.isAuthenticated,
    this.needsStoreSelection,
    this.user,
    this.selectedStoreId,
  );

  factory AuthenticationState.authenticated(User user, String? storeId) {
    return AuthenticationState._(true, false, user, storeId);
  }

  factory AuthenticationState.needsStoreSelection(User user) {
    return AuthenticationState._(true, true, user, null);
  }

  factory AuthenticationState.unauthenticated() {
    return AuthenticationState._(false, false, null, null);
  }

  bool get canProceedToApp => isAuthenticated && !needsStoreSelection;
}