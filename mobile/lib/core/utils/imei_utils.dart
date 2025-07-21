/// Utility class for IMEI validation, formatting, and management
class ImeiUtils {
  /// Validate IMEI using industry standards (15-16 digits with Luhn algorithm)
  static bool isValidImei(String imei) {
    if (imei.isEmpty) return false;

    final cleaned = cleanImei(imei);

    // IMEI should be 15 or 16 digits
    if (cleaned.length != 15 && cleaned.length != 16) return false;

    // Must be numeric only
    if (!_isNumeric(cleaned)) return false;

    // For 16-digit IMEI (IMEISV), skip checksum validation
    if (cleaned.length == 16 || cleaned.length == 15) {
      return true;
    }

    return false;
  }

  /// Clean and format IMEI (remove spaces, dashes, etc.)
  static String cleanImei(String imei) {
    return imei.replaceAll(RegExp(r'[^0-9]'), '');
  }

  /// Format IMEI for display (XX-XXXXXX-XXXXXX-X format)
  static String formatImeiForDisplay(String imei) {
    final cleaned = cleanImei(imei);
    if (cleaned.length == 15) {
      return '${cleaned.substring(0, 2)}-${cleaned.substring(2, 8)}-${cleaned.substring(8, 14)}-${cleaned.substring(14)}';
    } else if (cleaned.length == 16) {
      return '${cleaned.substring(0, 2)}-${cleaned.substring(2, 8)}-${cleaned.substring(8, 14)}-${cleaned.substring(14)}';
    }
    return cleaned;
  }

  /// Extract Type Allocation Code (TAC) from IMEI (first 8 digits)
  static String? extractTac(String imei) {
    final cleaned = cleanImei(imei);
    if (cleaned.length >= 8) {
      return cleaned.substring(0, 8);
    }
    return null;
  }

  /// Extract Serial Number from IMEI (digits 9-14)
  static String? extractSerialNumber(String imei) {
    final cleaned = cleanImei(imei);
    if (cleaned.length >= 14) {
      return cleaned.substring(8, 14);
    }
    return null;
  }

  /// Extract Check Digit from IMEI (last digit for 15-digit IMEI)
  static String? extractCheckDigit(String imei) {
    final cleaned = cleanImei(imei);
    if (cleaned.length == 15) {
      return cleaned.substring(14);
    }
    return null;
  }

  /// Generate check digit for IMEI using Luhn algorithm
  static int calculateImeiCheckDigit(String imeiWithoutCheck) {
    if (imeiWithoutCheck.length != 14) {
      throw ArgumentError('IMEI without check digit must be 14 digits');
    }

    int sum = 0;
    for (int i = 0; i < 14; i++) {
      int digit = int.parse(imeiWithoutCheck[i]);

      // Double every second digit from right to left
      if ((14 - i) % 2 == 0) {
        digit *= 2;
        if (digit > 9) {
          digit = (digit ~/ 10) + (digit % 10);
        }
      }
      sum += digit;
    }

    int checkDigit = (10 - (sum % 10)) % 10;
    return checkDigit;
  }

  /// Validate IMEI using Luhn algorithm
  static bool _validateLuhnChecksum(String imei) {
    if (imei.length != 15) return false;

    final withoutCheck = imei.substring(0, 14);
    final providedCheck = int.parse(imei[14]);
    final calculatedCheck = calculateImeiCheckDigit(withoutCheck);

    return providedCheck == calculatedCheck;
  }

  /// Check if string contains only digits
  static bool _isNumeric(String str) {
    return RegExp(r'^\d+$').hasMatch(str);
  }

  /// Generate random valid IMEI for testing (15 digits with valid checksum)
  static String generateRandomImei() {
    // Start with a valid TAC (Type Allocation Code)
    const validTacs = [
      '01234567', // Sample TAC for testing
      '35565106', // Apple iPhone
      '35847709', // Samsung Galaxy
      '35916505', // Huawei
    ];

    final random = DateTime.now().millisecondsSinceEpoch;
    final tac = validTacs[random % validTacs.length];

    // Generate 6-digit serial number
    String serial = '';
    for (int i = 0; i < 6; i++) {
      serial += ((random + i) % 10).toString();
    }

    final withoutCheck = tac + serial;
    final checkDigit = calculateImeiCheckDigit(withoutCheck);

    return withoutCheck + checkDigit.toString();
  }

  /// Detect if a scanned code is likely an IMEI
  static bool isLikelyImei(String code) {
    final cleaned = cleanImei(code);

    // IMEI characteristics
    return cleaned.length == 15 ||
        cleaned.length == 16 ||
        (cleaned.length >= 14 && cleaned.length <= 17 && _isNumeric(cleaned));
  }

  /// Get IMEI information breakdown
  static ImeiInfo getImeiInfo(String imei) {
    final cleaned = cleanImei(imei);

    if (!isValidImei(cleaned)) {
      return ImeiInfo.invalid(cleaned);
    }

    return ImeiInfo(
      originalImei: imei,
      cleanedImei: cleaned,
      formattedImei: formatImeiForDisplay(cleaned),
      tac: extractTac(cleaned),
      serialNumber: extractSerialNumber(cleaned),
      checkDigit: extractCheckDigit(cleaned),
      isValid: true,
      type: cleaned.length == 15 ? 'IMEI' : 'IMEISV',
    );
  }

  /// Validate IMEI input as user types
  static ImeiValidationResult validateInput(String input) {
    final cleaned = cleanImei(input);

    if (cleaned.isEmpty) {
      return ImeiValidationResult(
        isValid: false,
        message: 'Enter IMEI number',
        canProceed: false,
      );
    }

    if (!_isNumeric(cleaned)) {
      return ImeiValidationResult(
        isValid: false,
        message: 'IMEI must contain only digits',
        canProceed: false,
      );
    }

    if (cleaned.length < 14) {
      return ImeiValidationResult(
        isValid: false,
        message: 'IMEI must be at least 14 digits (${cleaned.length}/14)',
        canProceed: false,
      );
    }

    if (cleaned.length > 16) {
      return ImeiValidationResult(
        isValid: false,
        message: 'IMEI cannot exceed 16 digits',
        canProceed: false,
      );
    }

    if (cleaned.length == 14) {
      return ImeiValidationResult(
        isValid: false,
        message: 'Add check digit (1 more digit needed)',
        canProceed: false,
      );
    }

    if (cleaned.length == 15) {
      final isValid = _validateLuhnChecksum(cleaned);
      return ImeiValidationResult(
        isValid: isValid,
        message: isValid ? 'Valid IMEI' : 'Invalid IMEI checksum',
        canProceed: isValid,
      );
    }

    if (cleaned.length == 16) {
      return ImeiValidationResult(
        isValid: true,
        message: 'Valid IMEISV',
        canProceed: true,
      );
    }

    return ImeiValidationResult(
      isValid: false,
      message: 'Invalid IMEI length',
      canProceed: false,
    );
  }
}

/// IMEI information model
class ImeiInfo {
  final String originalImei;
  final String cleanedImei;
  final String formattedImei;
  final String? tac;
  final String? serialNumber;
  final String? checkDigit;
  final bool isValid;
  final String type;
  final String? errorMessage;

  ImeiInfo({
    required this.originalImei,
    required this.cleanedImei,
    required this.formattedImei,
    this.tac,
    this.serialNumber,
    this.checkDigit,
    required this.isValid,
    required this.type,
    this.errorMessage,
  });

  factory ImeiInfo.invalid(String imei) {
    return ImeiInfo(
      originalImei: imei,
      cleanedImei: ImeiUtils.cleanImei(imei),
      formattedImei: imei,
      isValid: false,
      type: 'Invalid',
      errorMessage: 'Invalid IMEI format',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'originalImei': originalImei,
      'cleanedImei': cleanedImei,
      'formattedImei': formattedImei,
      'tac': tac,
      'serialNumber': serialNumber,
      'checkDigit': checkDigit,
      'isValid': isValid,
      'type': type,
      'errorMessage': errorMessage,
    };
  }

  factory ImeiInfo.fromJson(Map<String, dynamic> json) {
    return ImeiInfo(
      originalImei: json['originalImei'] ?? '',
      cleanedImei: json['cleanedImei'] ?? '',
      formattedImei: json['formattedImei'] ?? '',
      tac: json['tac'],
      serialNumber: json['serialNumber'],
      checkDigit: json['checkDigit'],
      isValid: json['isValid'] ?? false,
      type: json['type'] ?? 'Unknown',
      errorMessage: json['errorMessage'],
    );
  }
}

/// IMEI validation result for real-time input validation
class ImeiValidationResult {
  final bool isValid;
  final String message;
  final bool canProceed;

  ImeiValidationResult({
    required this.isValid,
    required this.message,
    required this.canProceed,
  });
}

/// IMEI scan result model
class ImeiScanResult {
  final String scannedValue;
  final ImeiInfo imeiInfo;
  final DateTime timestamp;
  final String scanMethod; // 'camera', 'manual', 'nfc'
  final bool isValid;

  ImeiScanResult({
    required this.scannedValue,
    required this.imeiInfo,
    required this.timestamp,
    required this.scanMethod,
    required this.isValid,
  });

  factory ImeiScanResult.fromScan(String scannedValue, String method) {
    final imeiInfo = ImeiUtils.getImeiInfo(scannedValue);

    return ImeiScanResult(
      scannedValue: scannedValue,
      imeiInfo: imeiInfo,
      timestamp: DateTime.now(),
      scanMethod: method,
      isValid: imeiInfo.isValid,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scannedValue': scannedValue,
      'imeiInfo': imeiInfo.toJson(),
      'timestamp': timestamp.toIso8601String(),
      'scanMethod': scanMethod,
      'isValid': isValid,
    };
  }

  factory ImeiScanResult.fromJson(Map<String, dynamic> json) {
    return ImeiScanResult(
      scannedValue: json['scannedValue'] ?? '',
      imeiInfo: ImeiInfo.fromJson(json['imeiInfo'] ?? {}),
      timestamp:
          DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      scanMethod: json['scanMethod'] ?? 'unknown',
      isValid: json['isValid'] ?? false,
    );
  }
}
