/// Utility functions for number formatting and display
class NumberUtils {
  /// Formats a number with dot separators (e.g., 1000000 -> 1.000.000)
  /// 
  /// Example usage:
  /// ```dart
  /// NumberUtils.formatWithDots(1000000) // Returns "1.000.000"
  /// NumberUtils.formatWithDots(1500) // Returns "1.500"
  /// NumberUtils.formatWithDots(500) // Returns "500"
  /// ```
  static String formatWithDots(num value) {
    // Convert to integer string
    final intValue = value.toInt();
    final stringValue = intValue.toString();
    
    // Guard clause: if number is less than 1000, no formatting needed
    if (intValue < 1000) {
      return stringValue;
    }
    
    // Split the string into chunks of 3 from right to left
    final reversed = stringValue.split('').reversed.toList();
    final chunks = <String>[];
    
    for (int i = 0; i < reversed.length; i += 3) {
      final endIndex = (i + 3 < reversed.length) ? i + 3 : reversed.length;
      final chunk = reversed.sublist(i, endIndex).reversed.join('');
      chunks.add(chunk);
    }
    
    // Join chunks with dots, reverse the order
    return chunks.reversed.join('.');
  }
  
  /// Formats a price with dot separators and optional currency symbol
  /// 
  /// Example usage:
  /// ```dart
  /// NumberUtils.formatPrice(1000000) // Returns "1.000.000"
  /// NumberUtils.formatPrice(1000000, currencySymbol: 'Rp') // Returns "Rp 1.000.000"
  /// ```
  static String formatPrice(num value, {String? currencySymbol}) {
    final formattedValue = formatWithDots(value);
    
    // Guard clause: return formatted value if no currency symbol
    if (currencySymbol == null || currencySymbol.isEmpty) {
      return formattedValue;
    }
    
    return '$currencySymbol $formattedValue';
  }
  
  /// Formats a double value as an integer with dot separators
  /// This is useful for prices that are stored as double but displayed as whole numbers
  /// 
  /// Example usage:
  /// ```dart
  /// NumberUtils.formatDoubleAsInt(1500.99) // Returns "1.500"
  /// NumberUtils.formatDoubleAsInt(1000000.0) // Returns "1.000.000"
  /// ```
  static String formatDoubleAsInt(double value) {
    return formatWithDots(value.toInt());
  }
  
  /// Parses a dot-formatted number string back to a numeric value
  /// 
  /// Example usage:
  /// ```dart
  /// NumberUtils.parseDotFormatted('1.000.000') // Returns 1000000.0
  /// NumberUtils.parseDotFormatted('1.500') // Returns 1500.0
  /// NumberUtils.parseDotFormatted('500') // Returns 500.0
  /// ```
  static double parseDotFormatted(String value) {
    // Guard clause: return 0 if empty or null
    if (value.trim().isEmpty) {
      return 0.0;
    }
    
    // Remove dots and parse as double
    final cleanValue = value.replaceAll('.', '');
    return double.tryParse(cleanValue) ?? 0.0;
  }
}