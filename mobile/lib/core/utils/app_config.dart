import '../constants/app_constants.dart';

enum Environment { dev, staging, prod }

class AppConfig {
  static Environment _environment = Environment.dev;
  
  static Environment get environment => _environment;
  
  static void setEnvironment(Environment env) {
    _environment = env;
  }
  
  static String get baseUrl {
    switch (_environment) {
      case Environment.dev:
        return AppConstants.baseUrlDev;
      case Environment.staging:
        return AppConstants.baseUrlStaging;
      case Environment.prod:
        return AppConstants.baseUrlProd;
    }
  }
  
  static String get apiUrl => baseUrl + AppConstants.apiVersion;
  
  static bool get isDev => _environment == Environment.dev;
  static bool get isStaging => _environment == Environment.staging;
  static bool get isProd => _environment == Environment.prod;
  
  static bool get isDebugMode => isDev || isStaging;
  
  // Certificate pinning fingerprints
  static String get certificateFingerprint {
    switch (_environment) {
      case Environment.dev:
        return 'SHA256:DEV_CERT_FINGERPRINT_HERE';
      case Environment.staging:
        return 'SHA256:STAGING_CERT_FINGERPRINT_HERE';
      case Environment.prod:
        return 'SHA256:PROD_CERT_FINGERPRINT_HERE';
    }
  }
  
  // Allowed API hosts for security validation
  static List<String> get allowedHosts {
    switch (_environment) {
      case Environment.dev:
        return ['localhost:3000', '127.0.0.1:3000', '10.0.2.2:3000'];
      case Environment.staging:
        return ['staging-api.wms.example.com'];
      case Environment.prod:
        return ['api.wms.example.com'];
    }
  }
}