import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/store.dart';
import '../constants/app_constants.dart';

class StoreContextProvider extends ChangeNotifier {
  Store? _selectedStore;
  List<Store> _availableStores = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  Store? get selectedStore => _selectedStore;
  List<Store> get availableStores => _availableStores;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasStoreSelected => _selectedStore != null;

  // Helper getters
  String? get selectedStoreId => _selectedStore?.id;
  String? get selectedStoreName => _selectedStore?.name;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Initialize store context
  Future<void> initialize() async {
    _setLoading(true);
    _setError(null);

    try {
      // Load selected store from preferences
      final prefs = await SharedPreferences.getInstance();
      final storeId = prefs.getString(AppConstants.selectedStoreKey);
      
      if (storeId != null) {
        // TODO: Load store details from API or local cache
        // For now, simulate store loading
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Create demo store
        _selectedStore = Store(
          id: storeId,
          ownerId: 'demo-owner-id',
          name: 'Demo Store',
          type: 'Retail',
          addressLine1: '123 Main Street',
          city: 'Jakarta',
          province: 'DKI Jakarta',
          postalCode: '12345',
          country: 'Indonesia',
          phoneNumber: '+62-21-1234567',
          isActive: true,
          timezone: 'Asia/Jakarta',
          createdBy: 'demo-user-id',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }
    } catch (e) {
      _setError('Failed to load store context: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Load available stores for user
  Future<void> loadAvailableStores() async {
    _setLoading(true);
    _setError(null);

    try {
      // TODO: Load stores from API based on user permissions
      await Future.delayed(const Duration(seconds: 1));
      
      // Create demo stores
      _availableStores = [
        Store(
          id: 'store-1',
          ownerId: 'demo-owner-id',
          name: 'Main Store',
          type: 'Retail',
          addressLine1: '123 Main Street',
          city: 'Jakarta',
          province: 'DKI Jakarta',
          postalCode: '12345',
          country: 'Indonesia',
          phoneNumber: '+62-21-1234567',
          isActive: true,
          timezone: 'Asia/Jakarta',
          createdBy: 'demo-user-id',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Store(
          id: 'store-2',
          ownerId: 'demo-owner-id',
          name: 'Branch Store',
          type: 'Retail',
          addressLine1: '456 Second Street',
          city: 'Bandung',
          province: 'West Java',
          postalCode: '54321',
          country: 'Indonesia',
          phoneNumber: '+62-22-7654321',
          isActive: true,
          timezone: 'Asia/Jakarta',
          createdBy: 'demo-user-id',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
    } catch (e) {
      _setError('Failed to load available stores: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Select a store
  Future<void> selectStore(Store store) async {
    _setLoading(true);
    _setError(null);

    try {
      _selectedStore = store;
      
      // Persist selection
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.selectedStoreKey, store.id);
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to select store: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Clear store selection
  Future<void> clearStoreSelection() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.selectedStoreKey);
      
      _selectedStore = null;
      notifyListeners();
    } catch (e) {
      _setError('Failed to clear store selection: ${e.toString()}');
    }
  }

  // Switch store (for OWNER users)
  Future<void> switchStore(Store store) async {
    await selectStore(store);
  }

  // Get store by ID from available stores
  Store? getStoreById(String storeId) {
    try {
      return _availableStores.firstWhere((store) => store.id == storeId);
    } catch (e) {
      return null;
    }
  }

  // Refresh store data
  Future<void> refreshStoreData() async {
    if (_selectedStore != null) {
      // TODO: Refresh store data from API
      // For now, just notify listeners
      notifyListeners();
    }
  }

  // Reset store context (for logout)
  void reset() {
    _selectedStore = null;
    _availableStores = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}