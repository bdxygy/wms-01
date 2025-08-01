import 'dart:math';

/// Utility class for barcode validation, formatting, and generation
class BarcodeUtils {
  /// Validate different barcode formats
  static bool isValidBarcode(String code, {String? expectedType}) {
    if (code.isEmpty) return false;

    return _validateAnyFormat(code);
  }

  /// Clean and format barcode
  static String cleanBarcode(String code) {
    return code;
  }

  /// Detect barcode type from code
  static String detectBarcodeType(String code) {
    final cleaned = cleanBarcode(code);

    // Numeric-only barcodes (most common product codes)
    if (_isNumeric(cleaned)) {
      // EAN-13 (13 digits)
      if (cleaned.length == 13) {
        return 'EAN13';
      }
      // UPC-A (12 digits)
      if (cleaned.length == 12) {
        return 'UPCA';
      }
      // EAN-8 (8 digits)
      if (cleaned.length == 8) {
        return 'EAN8';
      }
      // UPC-E (6-7 digits to avoid EAN-8 conflict)
      if (cleaned.length >= 6 && cleaned.length <= 7) {
        return 'UPCE';
      }
      // ITF (Interleaved 2 of 5) - even number of digits
      if (cleaned.length >= 4 &&
          cleaned.length <= 30 &&
          cleaned.length % 2 == 0) {
        return 'ITF';
      }
    }

    // Code 39 (alphanumeric with specific character set)
    if (_isCode39Valid(cleaned)) {
      return 'CODE39';
    }

    // Code 128 (high-density alphanumeric, most flexible 1D)
    if (_isAlphanumeric(cleaned) &&
        cleaned.isNotEmpty &&
        cleaned.length <= 50) {
      return 'CODE128';
    }

    // Codabar (numeric with A-D start/stop, used in libraries/blood banks)
    if (_isCodabarValid(cleaned)) {
      return 'CODABAR';
    }

    // 2D Barcodes for complex data
    if (cleaned.length > 100) {
      // PDF417 (stacked linear barcode)
      if (_hasPDF417Pattern(cleaned)) {
        return 'PDF417';
      }
      // Data Matrix
      if (_hasDataMatrixPattern(cleaned)) {
        return 'DATAMATRIX';
      }
      // Aztec
      if (_hasAztecPattern(cleaned)) {
        return 'AZTEC';
      }
    }

    // Default to QR Code for any other pattern (most flexible)
    if (code.isNotEmpty && code.length <= 4000) {
      return 'QR_CODE';
    }

    return 'UNKNOWN';
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
      // Linear/1D Barcodes
      'EAN-8',
      'EAN-13',
      'UPC-A',
      'UPC-E',
      'Code 128',
      'Code 39',
      'Code 93',
      'Codabar',
      'ITF (Interleaved 2 of 5)',
      // 2D Barcodes
      'QR Code',
      'Data Matrix',
      'PDF417',
      'Aztec',
    ];
  }

  /// Private helper methods
  static bool _validateAnyFormat(String code) {
    return validateEan13(code) ||
        validateEan8(code) ||
        (_isNumeric(code) && code.length == 12) || // UPC-A
        (_isNumeric(code) && code.length >= 6 && code.length <= 8) || // UPC-E
        (_isAlphanumeric(code) &&
            code.length >= 4 &&
            code.length <= 50) || // Code 128
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
        str.isNotEmpty &&
        str.length <= 50;
  }

  // Additional helper methods for enhanced barcode type detection

  static bool _hasQRCodePattern(String code) {
    // QR codes often contain URLs, JSON, or structured data
    return code.contains('http://') ||
        code.contains('https://') ||
        code.contains('www.') ||
        code.contains('{') ||
        code.contains('[') ||
        code.contains('=') ||
        code.contains('&') ||
        code.length > 50;
  }

  static bool _isCodabarValid(String code) {
    // Codabar starts and ends with A, B, C, or D and contains digits and -$:/.+
    if (code.length < 3) return false;
    final start = code[0];
    final end = code[code.length - 1];
    return ['A', 'B', 'C', 'D'].contains(start) &&
        ['A', 'B', 'C', 'D'].contains(end) &&
        RegExp(r'^[ABCD][0-9\-\$:\/\.\+]+[ABCD]$').hasMatch(code);
  }

  static bool _hasPDF417Pattern(String code) {
    // PDF417 often contains structured data or long text
    return code.length > 200 ||
        code.contains('\n') ||
        code.contains('|') ||
        RegExp(r'[A-Z]{10,}').hasMatch(code);
  }

  static bool _hasDataMatrixPattern(String code) {
    // Data Matrix often contains structured identifiers
    return RegExp(r'\d{2}[A-Z]{2}\d+').hasMatch(code) ||
        code.contains(';') ||
        (code.length > 50 && code.length < 200);
  }

  static bool _hasAztecPattern(String code) {
    // Aztec codes are often used for transportation tickets
    return code.contains('AZTEC') ||
        RegExp(r'^[A-Z]{4}\d{8}').hasMatch(code) ||
        (code.length > 30 && RegExp(r'[A-Z]{3,}').hasMatch(code));
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
    switch (type.toUpperCase()) {
      // Linear/1D Barcodes
      case 'EAN13':
      case 'EAN-13':
        return 'EAN-13 (13-digit product code)';
      case 'EAN8':
      case 'EAN-8':
        return 'EAN-8 (8-digit product code)';
      case 'UPCA':
      case 'UPC-A':
        return 'UPC-A (12-digit product code)';
      case 'UPCE':
      case 'UPC-E':
        return 'UPC-E (6-8 digit compressed UPC)';
      case 'CODE128':
      case 'CODE_128':
      case 'CODE 128':
        return 'Code 128 (high-density alphanumeric)';
      case 'CODE39':
      case 'CODE_39':
      case 'CODE 39':
        return 'Code 39 (alphanumeric with symbols)';
      case 'CODE93':
      case 'CODE_93':
      case 'CODE 93':
        return 'Code 93 (extended ASCII)';
      case 'CODABAR':
        return 'Codabar (numeric with 4 start/stop chars)';
      case 'ITF':
        return 'ITF (Interleaved 2 of 5)';

      // 2D Barcodes
      case 'QRCODE':
      case 'QR_CODE':
      case 'QR CODE':
        return 'QR Code (2D matrix barcode)';
      case 'DATAMATRIX':
      case 'DATA_MATRIX':
      case 'DATA MATRIX':
        return 'Data Matrix (2D barcode)';
      case 'PDF417':
      case 'PDF_417':
        return 'PDF417 (2D stacked barcode)';
      case 'AZTEC':
        return 'Aztec (2D matrix barcode)';

      // Manual entry or unknown
      case 'MANUAL':
        return 'Manually entered';
      case 'UNKNOWN':
        return 'Unknown format';
      default:
        return type.isNotEmpty ? type : 'Unknown format';
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
      timestamp:
          DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      isValid: json['isValid'] ?? false,
      errorMessage: json['errorMessage'],
    );
  }
}
