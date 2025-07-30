import 'dart:math';

/// Utility class for barcode validation, formatting, and generation
class BarcodeUtils {
  
  /// Validate different barcode formats
  static bool isValidBarcode(String code, {String? expectedType}) {
    if (code.isEmpty) return false;
    
    final cleaned = cleanBarcode(code);
    return _validateAnyFormat(cleaned);
  }
  
  /// Clean and format barcode
  static String cleanBarcode(String code) {
    return code.replaceAll(RegExp(r'[^A-Z0-9]'), '').toUpperCase();
  }
  
  /// Detect barcode type from code
  static String detectBarcodeType(String code) {
    final cleaned = cleanBarcode(code);
    
    // EAN-13 (13 digits)
    if (_isNumeric(cleaned) && cleaned.length == 13) {
      return 'EAN-13';
    }
    
    // EAN-8 (8 digits)
    if (_isNumeric(cleaned) && cleaned.length == 8) {
      return 'EAN-8';
    }
    
    // UPC-A (12 digits)
    if (_isNumeric(cleaned) && cleaned.length == 12) {
      return 'UPC-A';
    }
    
    // UPC-E (6-8 digits)
    if (_isNumeric(cleaned) && cleaned.length >= 6 && cleaned.length <= 8) {
      return 'UPC-E';
    }
    
    // Code 128 (variable length alphanumeric)
    if (_isAlphanumeric(cleaned) && cleaned.length >= 4 && cleaned.length <= 50) {
      return 'Code 128';
    }
    
    // Code 39 (variable length, specific character set)
    if (_isCode39Valid(cleaned)) {
      return 'Code 39';
    }
    
    // QR Code (very flexible)
    if (code.isNotEmpty && code.length <= 4000) {
      return 'QR Code';
    }
    
    return 'Unknown';
  }
  
  /// Validate EAN-13 check digit
  static bool validateEan13(String code) {
    if (!_isNumeric(code) || code.length != 13) return false;
    
    final dataDigits = code.substring(0, 12);
    final checkDigit = int.parse(code[12]);
    final calculatedCheckDigit = calculateEanCheckDigit(dataDigits);
    
    return checkDigit == calculatedCheckDigit;
  }
  
  /// Validate EAN-8 check digit
  static bool validateEan8(String code) {
    if (!_isNumeric(code) || code.length != 8) return false;
    
    final dataDigits = code.substring(0, 7);
    final checkDigit = int.parse(code[7]);
    final calculatedCheckDigit = calculateEanCheckDigit(dataDigits);
    
    return checkDigit == calculatedCheckDigit;
  }
  
  /// Generate check digit for EAN/UPC codes
  static int calculateEanCheckDigit(String code) {
    if (!_isNumeric(code) || (code.length != 12 && code.length != 7)) {
      throw ArgumentError('Invalid code for EAN check digit calculation');
    }
    
    int sum = 0;
    for (int i = 0; i < code.length; i++) {
      int digit = int.parse(code[i]);
      if (i % 2 == 0) {
        sum += digit;
      } else {
        sum += digit * 3;
      }
    }
    
    int checkDigit = (10 - (sum % 10)) % 10;
    return checkDigit;
  }
  
  /// Generate random barcode for testing
  static String generateRandomEan13() {
    final random = Random();
    String code = '';
    for (int i = 0; i < 12; i++) {
      code += random.nextInt(10).toString();
    }
    final checkDigit = calculateEanCheckDigit(code);
    return code + checkDigit.toString();
  }
  
  /// Get supported barcode formats
  static List<String> getSupportedFormats() {
    return [
      'EAN-8',
      'EAN-13', 
      'UPC-A',
      'UPC-E',
      'Code 128',
      'Code 39',
      'Code 93',
      'QR Code',
    ];
  }
  
  /// Private helper methods
  static bool _validateAnyFormat(String code) {
    return validateEan13(code) ||
           validateEan8(code) ||
           (_isNumeric(code) && code.length == 12) || // UPC-A
           (_isNumeric(code) && code.length >= 6 && code.length <= 8) || // UPC-E
           (_isAlphanumeric(code) && code.length >= 4 && code.length <= 50) || // Code 128
           _isCode39Valid(code) || // Code 39
           (code.isNotEmpty && code.length <= 4000); // QR Code
  }
  
  static bool _isNumeric(String str) {
    return RegExp(r'^\d+$').hasMatch(str);
  }
  
  static bool _isAlphanumeric(String str) {
    return RegExp(r'^[A-Z0-9]+$').hasMatch(str);
  }
  
  static bool _isCode39Valid(String str) {
    // Code 39 supports A-Z, 0-9, and special characters: - . $ / + % space
    return RegExp(r'^[A-Z0-9\-\.\$\/\+%\s]+$').hasMatch(str) && 
           str.isNotEmpty && str.length <= 50;
  }
}

/// Barcode scan result model
class BarcodeScanResult {
  final String code;
  final String type;
  final DateTime timestamp;
  final bool isValid;
  final String? errorMessage;

  BarcodeScanResult({
    required this.code,
    required this.type,
    required this.timestamp,
    required this.isValid,
    this.errorMessage,
  });

  factory BarcodeScanResult.success(String code, {String? type}) {
    final cleanCode = BarcodeUtils.cleanBarcode(code);
    final detectedType = type ?? BarcodeUtils.detectBarcodeType(cleanCode);
    
    return BarcodeScanResult(
      code: cleanCode,
      type: detectedType,
      timestamp: DateTime.now(),
      isValid: true,
    );
  }

  factory BarcodeScanResult.error(String code, String errorMessage) {
    return BarcodeScanResult(
      code: code,
      type: 'Unknown',
      timestamp: DateTime.now(),
      isValid: false,
      errorMessage: errorMessage,
    );
  }

  String get formattedCode => code;

  String get typeDescription {
    switch (type) {
      case 'EAN-13':
        return 'EAN-13 (13-digit product code)';
      case 'EAN-8':
        return 'EAN-8 (8-digit product code)';
      case 'UPC-A':
        return 'UPC-A (12-digit product code)';
      case 'UPC-E':
        return 'UPC-E (6-8 digit compressed UPC)';
      case 'Code 128':
        return 'Code 128 (high-density alphanumeric)';
      case 'Code 39':
        return 'Code 39 (alphanumeric with symbols)';
      case 'QR Code':
        return 'QR Code (2D matrix barcode)';
      default:
        return 'Unknown format';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'isValid': isValid,
      'errorMessage': errorMessage,
    };
  }

  factory BarcodeScanResult.fromJson(Map<String, dynamic> json) {
    return BarcodeScanResult(
      code: json['code'] ?? '',
      type: json['type'] ?? 'Unknown',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      isValid: json['isValid'] ?? false,
      errorMessage: json['errorMessage'],
    );
  }
}