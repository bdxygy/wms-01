import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';
import '../models/user.dart';
import '../models/auth_response.dart';
import 'dart:convert';

class SecureStorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_PKCS1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Token management
  Future<void> storeTokens(AuthResponse authResponse) async {
    await Future.wait([
      _storage.write(
        key: AppConstants.accessTokenKey,
        value: authResponse.accessToken,
      ),
      _storage.write(
        key: AppConstants.refreshTokenKey,
        value: authResponse.refreshToken,
      ),
      _storage.write(
        key: AppConstants.tokenExpiryKey,
        value: authResponse.expiresAt.toIso8601String(),
      ),
    ]);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: AppConstants.accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: AppConstants.refreshTokenKey);
  }

  Future<DateTime?> getTokenExpiry() async {
    final expiryString = await _storage.read(key: AppConstants.tokenExpiryKey);
    if (expiryString != null) {
      return DateTime.parse(expiryString);
    }
    return null;
  }

  Future<bool> hasValidTokens() async {
    final accessToken = await getAccessToken();
    final expiry = await getTokenExpiry();
    
    if (accessToken == null || expiry == null) return false;
    
    return DateTime.now().isBefore(expiry);
  }

  Future<bool> isTokenNearExpiry() async {
    final expiry = await getTokenExpiry();
    if (expiry == null) return true;
    
    return DateTime.now().add(const Duration(minutes: 5)).isAfter(expiry);
  }

  // User data management
  Future<void> storeUser(User user) async {
    await _storage.write(
      key: AppConstants.userDataKey,
      value: jsonEncode(user.toJson()),
    );
  }

  Future<User?> getUser() async {
    final userString = await _storage.read(key: AppConstants.userDataKey);
    if (userString != null) {
      try {
        final userJson = jsonDecode(userString) as Map<String, dynamic>;
        return User.fromJson(userJson);
      } catch (e) {
        // Clear corrupted user data
        await clearUser();
        return null;
      }
    }
    return null;
  }

  Future<void> clearUser() async {
    await _storage.delete(key: AppConstants.userDataKey);
  }

  // Store context management (for non-owner users)
  Future<void> storeSelectedStoreId(String storeId) async {
    await _storage.write(
      key: AppConstants.selectedStoreKey,
      value: storeId,
    );
  }

  Future<String?> getSelectedStoreId() async {
    return await _storage.read(key: AppConstants.selectedStoreKey);
  }

  Future<void> clearSelectedStore() async {
    await _storage.delete(key: AppConstants.selectedStoreKey);
  }

  // Biometric authentication preparation
  Future<void> storeBiometricEnabled(bool enabled) async {
    await _storage.write(
      key: AppConstants.biometricEnabledKey,
      value: enabled.toString(),
    );
  }

  Future<bool> isBiometricEnabled() async {
    final enabledString = await _storage.read(key: AppConstants.biometricEnabledKey);
    return enabledString == 'true';
  }

  // Complete logout cleanup
  Future<void> clearAllAuthData() async {
    await Future.wait([
      _storage.delete(key: AppConstants.accessTokenKey),
      _storage.delete(key: AppConstants.refreshTokenKey),
      _storage.delete(key: AppConstants.tokenExpiryKey),
      _storage.delete(key: AppConstants.userDataKey),
      _storage.delete(key: AppConstants.selectedStoreKey),
    ]);
  }

  // Security utilities
  Future<bool> containsKey(String key) async {
    return await _storage.containsKey(key: key);
  }

  Future<Map<String, String>> getAllStoredData() async {
    return await _storage.readAll();
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // Backup and restore for development/testing
  Future<Map<String, String?>> exportAuthData() async {
    return {
      'accessToken': await getAccessToken(),
      'refreshToken': await getRefreshToken(),
      'tokenExpiry': (await getTokenExpiry())?.toIso8601String(),
      'userData': await _storage.read(key: AppConstants.userDataKey),
      'selectedStore': await getSelectedStoreId(),
    };
  }

  Future<void> importAuthData(Map<String, String?> data) async {
    if (data['accessToken'] != null) {
      await _storage.write(key: AppConstants.accessTokenKey, value: data['accessToken']!);
    }
    if (data['refreshToken'] != null) {
      await _storage.write(key: AppConstants.refreshTokenKey, value: data['refreshToken']!);
    }
    if (data['tokenExpiry'] != null) {
      await _storage.write(key: AppConstants.tokenExpiryKey, value: data['tokenExpiry']!);
    }
    if (data['userData'] != null) {
      await _storage.write(key: AppConstants.userDataKey, value: data['userData']!);
    }
    if (data['selectedStore'] != null) {
      await _storage.write(key: AppConstants.selectedStoreKey, value: data['selectedStore']!);
    }
  }
}