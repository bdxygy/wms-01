class AppConstants {
  // Environment
  static const String appName = 'WMS Mobile';
  static const String appVersion = '1.0.0';
  
  // API Base URLs
  static const String baseUrlDev = 'http://localhost:3000';
  static const String baseUrlStaging = 'https://staging-api.wms.example.com';
  static const String baseUrlProd = 'https://api.wms.example.com';
  
  // API Endpoints
  static const String apiVersion = '/api/v1';
  
  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String tokenExpiryKey = 'token_expiry';
  static const String userDataKey = 'user_data';
  static const String selectedStoreKey = 'selected_store';
  static const String printerDeviceKey = 'printer_device';
  static const String biometricEnabledKey = 'biometric_enabled';
  
  // Network Configuration
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Print Configuration
  static const int printerPaperWidth = 58; // mm
  static const int printerCharacterWidth = 32;
  
  // Image Configuration
  static const int maxImageSizeKB = 1024; // 1MB
  static const double imageCompressionQuality = 0.8;
  
  // Scanner Configuration
  static const List<String> supportedBarcodeFormats = [
    'EAN_13',
    'EAN_8',
    'UPC_A',
    'UPC_E',
    'CODE_128',
    'CODE_39',
    'QR_CODE',
  ];
}