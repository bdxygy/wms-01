import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/user.dart';
import '../constants/app_constants.dart';

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider extends ChangeNotifier {
  AuthState _state = AuthState.initial;
  User? _user;
  String? _error;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Getters
  AuthState get state => _state;
  User? get user => _user;
  String? get error => _error;
  bool get isAuthenticated => _state == AuthState.authenticated && _user != null;
  bool get isLoading => _state == AuthState.loading;

  // User role helpers
  bool get isOwner => _user?.isOwner ?? false;
  bool get isAdmin => _user?.isAdmin ?? false;
  bool get isStaff => _user?.isStaff ?? false;
  bool get isCashier => _user?.isCashier ?? false;

  // Permission helpers
  bool get canCreateProducts => _user?.canCreateProducts ?? false;
  bool get canCreateTransactions => _user?.canCreateTransactions ?? false;
  bool get canManageUsers => _user?.canManageUsers ?? false;
  bool get canManageStores => _user?.canManageStores ?? false;
  bool get canDeleteData => _user?.canDeleteData ?? false;

  // Set authentication state
  void _setState(AuthState state) {
    _state = state;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    _setState(AuthState.error);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Initialize authentication state
  Future<void> initialize() async {
    _setState(AuthState.loading);

    try {
      // Check for stored tokens
      final accessToken = await _secureStorage.read(key: AppConstants.accessTokenKey);
      final userDataJson = await _secureStorage.read(key: AppConstants.userDataKey);

      if (accessToken != null && userDataJson != null) {
        // TODO: Validate token with backend
        // For now, assume valid if tokens exist
        // _user = User.fromJson(jsonDecode(userDataJson));
        // _setState(AuthState.authenticated);
        
        // Temporary: set as unauthenticated until proper validation
        _setState(AuthState.unauthenticated);
      } else {
        _setState(AuthState.unauthenticated);
      }
    } catch (e) {
      _setError('Failed to initialize authentication: ${e.toString()}');
    }
  }

  // Login with credentials
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    _setState(AuthState.loading);
    clearError();

    try {
      // TODO: Implement actual login with API
      // For now, simulate login
      await Future.delayed(const Duration(seconds: 1));
      
      // Simulate successful login for demo
      _user = User(
        id: 'demo-user-id',
        name: 'Demo User',
        username: username,
        role: UserRole.owner,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Store demo tokens
      await _secureStorage.write(
        key: AppConstants.accessTokenKey,
        value: 'demo-access-token',
      );
      await _secureStorage.write(
        key: AppConstants.refreshTokenKey,
        value: 'demo-refresh-token',
      );
      
      _setState(AuthState.authenticated);
      return true;
    } catch (e) {
      _setError('Login failed: ${e.toString()}');
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _setState(AuthState.loading);

    try {
      // Clear stored tokens
      await _secureStorage.delete(key: AppConstants.accessTokenKey);
      await _secureStorage.delete(key: AppConstants.refreshTokenKey);
      await _secureStorage.delete(key: AppConstants.userDataKey);
      await _secureStorage.delete(key: AppConstants.selectedStoreKey);

      _user = null;
      _error = null;
      _setState(AuthState.unauthenticated);
    } catch (e) {
      _setError('Logout failed: ${e.toString()}');
    }
  }

  // Refresh authentication
  Future<bool> refreshAuth() async {
    try {
      // TODO: Implement token refresh with API
      return false;
    } catch (e) {
      _setError('Authentication refresh failed: ${e.toString()}');
      return false;
    }
  }

  // Update user data
  void updateUser(User user) {
    _user = user;
    notifyListeners();
  }

  // Check if user needs store selection
  bool get needsStoreSelection {
    if (!isAuthenticated || _user == null) return false;
    // Only non-owner users need to select a store
    return !_user!.isOwner;
  }
}