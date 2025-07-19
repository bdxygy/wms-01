class ErrorCodes {
  // Network Errors
  static const String networkError = 'NETWORK_ERROR';
  static const String connectionTimeout = 'CONNECTION_TIMEOUT';
  static const String serverError = 'SERVER_ERROR';
  static const String unknownError = 'UNKNOWN_ERROR';
  
  // Authentication Errors
  static const String invalidCredentials = 'INVALID_CREDENTIALS';
  static const String tokenExpired = 'TOKEN_EXPIRED';
  static const String refreshTokenExpired = 'REFRESH_TOKEN_EXPIRED';
  static const String unauthorizedAccess = 'UNAUTHORIZED_ACCESS';
  
  // Validation Errors
  static const String validationError = 'VALIDATION_ERROR';
  static const String requiredField = 'REQUIRED_FIELD';
  static const String invalidFormat = 'INVALID_FORMAT';
  static const String duplicateEntry = 'DUPLICATE_ENTRY';
  
  // Business Logic Errors
  static const String insufficientStock = 'INSUFFICIENT_STOCK';
  static const String invalidTransaction = 'INVALID_TRANSACTION';
  static const String storeNotFound = 'STORE_NOT_FOUND';
  static const String productNotFound = 'PRODUCT_NOT_FOUND';
  static const String userNotFound = 'USER_NOT_FOUND';
  
  // Permission Errors
  static const String permissionDenied = 'PERMISSION_DENIED';
  static const String roleRestriction = 'ROLE_RESTRICTION';
  static const String storeAccessDenied = 'STORE_ACCESS_DENIED';
  
  // Device/Hardware Errors
  static const String cameraNotAvailable = 'CAMERA_NOT_AVAILABLE';
  static const String printerNotConnected = 'PRINTER_NOT_CONNECTED';
  static const String bluetoothNotEnabled = 'BLUETOOTH_NOT_ENABLED';
  static const String locationPermissionDenied = 'LOCATION_PERMISSION_DENIED';
  
  // Storage Errors
  static const String storageError = 'STORAGE_ERROR';
  static const String diskFull = 'DISK_FULL';
  static const String fileNotFound = 'FILE_NOT_FOUND';
}