import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/store.dart';
import '../models/store_context.dart';
import '../constants/app_constants.dart';
import '../auth/auth_service.dart';
import '../utils/app_config.dart';

class StoreContextProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  StoreContext _context = StoreContext.initial();

  // Getters for backward compatibility and convenience
  StoreContext get context => _context;
  Store? get selectedStore => _context.selectedStore;
  List<Store> get availableStores => _context.availableStores;
  bool get isLoading => _context.isLoading;
  String? get error => _context.error;
  bool get hasStoreSelected => _context.hasStoreSelected;
  bool get needsStoreSelection => _context.needsStoreSelection;
  String? get selectedStoreId => _context.selectedStoreId;
  String? get selectedStoreName => _context.selectedStoreName;

  // Update context and notify listeners
  void _updateContext(StoreContext newContext) {
    _context = newContext;
    
    // Defer notifyListeners to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
    
    if (AppConfig.isDebugMode) {
     debugPrint('🏪 StoreContext updated: $newContext');
    }
  }

  void clearError() {
    _updateContext(_context.copyWith(clearError: true));
  }

  // Initialize store context from persisted data
  Future<void> initialize() async {
    _updateContext(StoreContext.loading());

    try {
      // Load persisted store context
      final prefs = await SharedPreferences.getInstance();
      final contextJson = prefs.getString(AppConstants.storeContextKey);
      
      if (contextJson != null) {
        final persistedData = json.decode(contextJson) as Map<String, dynamic>;
        final persistedContext = StoreContext.fromPersistedJson(persistedData);
        
        // Validate persisted store is still valid
        if (persistedContext.selectedStore != null) {
          final isValid = await _validateStorePersistence(persistedContext.selectedStore!);
          if (isValid) {
            _updateContext(persistedContext);
            
            if (AppConfig.isDebugMode) {
             debugPrint('🏪 Restored store context: ${persistedContext.selectedStoreName}');
            }
            return;
          }
        }
      }
      
      // If no valid persisted context, start fresh
      _updateContext(StoreContext.initial());
      
    } catch (e) {
      _updateContext(StoreContext.error('Failed to initialize store context: ${e.toString()}'));
      
      if (AppConfig.isDebugMode) {
       debugPrint('❌ Store context initialization failed: $e');
      }
    }
  }

  // Validate that a persisted store is still valid
  Future<bool> _validateStorePersistence(Store store) async {
    try {
      // Check if store still exists and user has access
      // For now, assume valid - in production this would call API
      return store.isActive;
    } catch (e) {
      return false;
    }
  }

  // Load available stores for the current user
  Future<void> loadAvailableStores() async {
    _updateContext(_context.copyWith(isLoading: true, clearError: true));

    try {
      final stores = await _authService.getUserStores();
      
      _updateContext(StoreContext.loaded(
        stores: stores,
        selectedStore: _context.selectedStore,
      ));
      
      if (AppConfig.isDebugMode) {
       debugPrint('🏪 Loaded ${stores.length} available stores');
      }
      
    } catch (e) {
      _updateContext(StoreContext.error('Failed to load available stores: ${e.toString()}'));
      
      if (AppConfig.isDebugMode) {
       debugPrint('❌ Failed to load stores: $e');
      }
    }
  }

  // Select a store
  Future<void> selectStore(Store store) async {
    if (!_context.canSelectStore(store.id)) {
      _updateContext(_context.copyWith(
        error: 'Cannot select inactive or unauthorized store',
      ));
      return;
    }

    _updateContext(_context.copyWith(isLoading: true, clearError: true));

    try {
      // Update context with selected store
      final newContext = _context.copyWith(
        selectedStore: store,
        selectedStoreId: store.id,
        isLoading: false,
      );
      
      // Persist the selection
      await _persistStoreContext(newContext);
      
      _updateContext(newContext);
      
      if (AppConfig.isDebugMode) {
       debugPrint('🏪 Selected store: ${store.name}');
      }
      
    } catch (e) {
      _updateContext(_context.copyWith(
        isLoading: false,
        error: 'Failed to select store: ${e.toString()}',
      ));
      
      if (AppConfig.isDebugMode) {
       debugPrint('❌ Failed to select store: $e');
      }
    }
  }

  // Switch store (for OWNER users)
  Future<void> switchStore(Store store) async {
    await selectStore(store);
  }

  // Clear store selection
  Future<void> clearStoreSelection() async {
    try {
      final newContext = _context.copyWith(
        clearSelectedStore: true,
        clearError: true,
      );
      
      await _persistStoreContext(newContext);
      _updateContext(newContext);
      
      if (AppConfig.isDebugMode) {
       debugPrint('🏪 Cleared store selection');
      }
      
    } catch (e) {
      _updateContext(_context.copyWith(
        error: 'Failed to clear store selection: ${e.toString()}',
      ));
    }
  }

  // Get store by ID from available stores
  Store? getStoreById(String storeId) {
    return _context.getStoreById(storeId);
  }

  // Refresh store data
  Future<void> refreshStoreData() async {
    if (_context.hasStoreSelected) {
      // Reload available stores which will refresh the selected store
      await loadAvailableStores();
    }
  }

  // Persist store context to SharedPreferences
  Future<void> _persistStoreContext(StoreContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final contextJson = json.encode(context.toPersistedJson());
      await prefs.setString(AppConstants.storeContextKey, contextJson);
      
      if (AppConfig.isDebugMode) {
       debugPrint('🏪 Persisted store context');
      }
      
    } catch (e) {
      if (AppConfig.isDebugMode) {
       debugPrint('❌ Failed to persist store context: $e');
      }
    }
  }

  // Reset store context (for logout)
  Future<void> reset() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.storeContextKey);
      await prefs.remove(AppConstants.selectedStoreKey); // Remove legacy key
      
      _updateContext(StoreContext.initial());
      
      if (AppConfig.isDebugMode) {
       debugPrint('🏪 Reset store context');
      }
      
    } catch (e) {
      if (AppConfig.isDebugMode) {
       debugPrint('❌ Failed to reset store context: $e');
      }
    }
  }

  // Check if user needs to select a store
  bool requiresStoreSelection() {
    return _context.needsStoreSelection;
  }

  // Set available stores (for manual updates)
  void setAvailableStores(List<Store> stores) {
    _updateContext(StoreContext.loaded(
      stores: stores,
      selectedStore: _context.selectedStore,
    ));
  }

  // Update selected store without persistence (for temporary updates)
  void updateSelectedStore(Store store) {
    if (_context.canSelectStore(store.id)) {
      _updateContext(_context.copyWith(selectedStore: store));
    }
  }

  // Check if store context is stale and needs refresh
  bool isStale() {
    if (_context.lastUpdated == null) return true;
    
    final staleThreshold = DateTime.now().subtract(const Duration(minutes: 30));
    return _context.lastUpdated!.isBefore(staleThreshold);
  }

  // Refresh if stale
  Future<void> refreshIfStale() async {
    if (isStale()) {
      await loadAvailableStores();
    }
  }
}