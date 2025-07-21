import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/store.dart';
import '../models/auth_response.dart';
import '../api/api_exceptions.dart';
import '../utils/app_config.dart';
import 'auth_service.dart';

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  needsStoreSelection,
  error,
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  AuthState _state = AuthState.initial;
  User? _user;
  String? _selectedStoreId;
  String? _error;

  // Getters
  AuthState get state => _state;
  User? get user => _user;
  User? get currentUser => _user;
  String? get selectedStoreId => _selectedStoreId;
  String? get error => _error;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isLoading => _state == AuthState.loading;
  bool get needsStoreSelection => _state == AuthState.needsStoreSelection;

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

  // Store context helpers
  bool get hasStoreContext => _selectedStoreId != null;
  bool get canProceedToApp => isAuthenticated && (!_needsStoreSelection || hasStoreContext);

  bool get _needsStoreSelection {
    if (_user == null || !isAuthenticated) return false;
    return !_user!.isOwner && _selectedStoreId == null;
  }

  // Set authentication state
  void _setState(AuthState state) {
    _state = state;
    notifyListeners();
    
    if (AppConfig.isDebugMode) {
     debugPrint('🔄 AuthProvider state changed to: $state');
    }
  }

  void _setError(String error) {
    _error = error;
    _setState(AuthState.error);
    
    if (AppConfig.isDebugMode) {
     debugPrint('❌ AuthProvider error: $error');
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Initialize authentication state from stored data
  Future<void> initialize() async {
    _setState(AuthState.loading);

    try {
      final authState = await _authService.getStoredAuthState();
      
      if (authState.isAuthenticated && authState.user != null) {
        _user = authState.user;
        _selectedStoreId = authState.selectedStoreId;
        
        if (authState.needsStoreSelection) {
          _setState(AuthState.needsStoreSelection);
        } else {
          _setState(AuthState.authenticated);
        }
        
        // Ensure token is still valid
        final isValid = await _authService.ensureValidToken();
        if (!isValid) {
          await logout();
          return;
        }
        
        if (AppConfig.isDebugMode) {
         debugPrint('🔐 Auth initialized for user: ${_user!.username}');
        }
      } else {
        _setState(AuthState.unauthenticated);
        if (AppConfig.isDebugMode) {
         debugPrint('🔓 No stored authentication found');
        }
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
      final authResponse = await _authService.login(username, password);
      _user = authResponse.user;
      
      // Check if user needs store selection
      if (!_user!.isOwner) {
        _setState(AuthState.needsStoreSelection);
        if (AppConfig.isDebugMode) {
         debugPrint('🏪 User ${_user!.username} needs store selection');
        }
      } else {
        _setState(AuthState.authenticated);
        if (AppConfig.isDebugMode) {
         debugPrint('👑 OWNER ${_user!.username} logged in');
        }
      }
      
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } on ValidationException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Login failed: ${e.toString()}');
      return false;
    }
  }

  // Select store for non-owner users
  Future<bool> selectStore(String storeId) async {
    if (_user == null || _user!.isOwner) {
      _setError('Store selection not required for this user');
      return false;
    }

    _setState(AuthState.loading);
    clearError();

    try {
      await _authService.selectStore(storeId);
      _selectedStoreId = storeId;
      _setState(AuthState.authenticated);
      
      if (AppConfig.isDebugMode) {
       debugPrint('🏪 Store $storeId selected for user ${_user!.username}');
      }
      
      return true;
    } catch (e) {
      _setError('Failed to select store: ${e.toString()}');
      return false;
    }
  }

  // Change selected store (for OWNER users or re-selection)
  Future<bool> changeStore(String storeId) async {
    if (_user == null) return false;

    try {
      await _authService.selectStore(storeId);
      _selectedStoreId = storeId;
      notifyListeners();
      
      if (AppConfig.isDebugMode) {
       debugPrint('🔄 Store changed to $storeId for user ${_user!.username}');
      }
      
      return true;
    } catch (e) {
      _setError('Failed to change store: ${e.toString()}');
      return false;
    }
  }

  // Clear selected store
  Future<void> clearSelectedStore() async {
    try {
      await _authService.clearSelectedStore();
      _selectedStoreId = null;
      
      if (_user != null && !_user!.isOwner) {
        _setState(AuthState.needsStoreSelection);
      } else {
        notifyListeners();
      }
      
      if (AppConfig.isDebugMode) {
       debugPrint('🗑️ Selected store cleared');
      }
    } catch (e) {
      _setError('Failed to clear selected store: ${e.toString()}');
    }
  }

  // Logout
  Future<void> logout() async {
    _setState(AuthState.loading);

    try {
      await _authService.logout();
      
      _user = null;
      _selectedStoreId = null;
      _error = null;
      _setState(AuthState.unauthenticated);
      
      if (AppConfig.isDebugMode) {
       debugPrint('🚪 User logged out successfully');
      }
    } catch (e) {
      _setError('Logout failed: ${e.toString()}');
    }
  }

  // Refresh authentication token
  Future<bool> refreshAuth() async {
    try {
      final isValid = await _authService.ensureValidToken();
      
      if (!isValid) {
        await logout();
        return false;
      }
      
      // Update user data in case it changed
      final currentUser = await _authService.getCurrentUser();
      if (currentUser != null) {
        _user = currentUser;
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _setError('Authentication refresh failed: ${e.toString()}');
      return false;
    }
  }

  // Register new user (for admin/dev purposes)
  Future<bool> register({
    required String name,
    required String username,
    required String password,
    required String role,
    String? storeId,
  }) async {
    _setState(AuthState.loading);
    clearError();

    try {
      final registerRequest = RegisterRequest(
        name: name,
        username: username,
        password: password,
        role: role,
        storeId: storeId,
      );

      await _authService.register(registerRequest);
      
      if (AppConfig.isDebugMode) {
       debugPrint('👤 User $username registered successfully');
      }
      
      // Don't change auth state after registration
      _setState(_state == AuthState.loading ? AuthState.authenticated : _state);
      return true;
    } on ValidationException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Registration failed: ${e.toString()}');
      return false;
    }
  }

  // Development register (creates OWNER user)
  Future<bool> devRegister({
    required String name,
    required String username,
    required String password,
  }) async {
    _setState(AuthState.loading);
    clearError();

    try {
      await _authService.devRegister(name, username, password);
      
      if (AppConfig.isDebugMode) {
       debugPrint('👑 OWNER user $username created successfully');
      }
      
      _setState(AuthState.unauthenticated);
      return true;
    } catch (e) {
      _setError('Dev registration failed: ${e.toString()}');
      return false;
    }
  }

  // Update user data
  void updateUser(User user) {
    _user = user;
    notifyListeners();
  }

  // Force logout (for security or session timeout)
  Future<void> forceLogout({String? reason}) async {
    if (reason != null) {
      _setError(reason);
    }
    await logout();
  }

  // Check authentication status
  Future<bool> checkAuthStatus() async {
    try {
      return await _authService.isAuthenticated();
    } catch (e) {
      return false;
    }
  }

  // Get user stores
  Future<List<Store>> getUserStores() async {
    if (_user == null || !isAuthenticated) {
      throw Exception('User not authenticated');
    }

    try {
      // For OWNER users, they can see all their stores
      // For non-OWNER users, they see stores they're assigned to
      return await _authService.getUserStores();
    } catch (e) {
      _setError('Failed to fetch user stores: ${e.toString()}');
      rethrow;
    }
  }

  // Get authentication service for direct access if needed
  AuthService get authService => _authService;
}