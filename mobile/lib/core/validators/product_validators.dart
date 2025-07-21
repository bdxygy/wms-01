import '../utils/imei_utils.dart';

/// Product form validation rules
class ProductValidators {
  /// Product name validation
  static String? validateProductName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Product name is required';
    }
    if (value.trim().length < 2) {
      return 'Product name must be at least 2 characters';
    }
    if (value.trim().length > 255) {
      return 'Product name must be less than 255 characters';
    }
    return null;
  }

  /// SKU validation
  static String? validateSku(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'SKU is required';
    }
    if (value.trim().length < 2) {
      return 'SKU must be at least 2 characters';
    }
    if (value.trim().length > 50) {
      return 'SKU must be less than 50 characters';
    }
    // Allow alphanumeric, underscore, hyphen
    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(value.trim())) {
      return 'SKU can only contain letters, numbers, underscore, and hyphen';
    }
    return null;
  }

  /// Barcode validation
  static String? validateBarcode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Barcode is required';
    }
    final trimmed = value.trim();
    if (trimmed.length < 6) {
      return 'Barcode must be at least 6 characters';
    }
    if (trimmed.length > 50) {
      return 'Barcode must be less than 50 characters';
    }
    // Allow alphanumeric only
    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(trimmed)) {
      return 'Barcode can only contain uppercase letters and numbers';
    }
    return null;
  }

  /// Purchase price validation
  static String? validatePurchasePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Purchase price is required';
    }
    final price = double.tryParse(value.trim());
    if (price == null) {
      return 'Purchase price must be a valid number';
    }
    if (price < 0) {
      return 'Purchase price cannot be negative';
    }
    if (price > 1000000) {
      return 'Purchase price must be less than 1,000,000';
    }
    return null;
  }

  /// Sale price validation
  static String? validateSalePrice(String? value, double? purchasePrice) {
    if (value == null || value.trim().isEmpty) {
      return null; // Sale price is optional
    }
    final price = double.tryParse(value.trim());
    if (price == null) {
      return 'Sale price must be a valid number';
    }
    if (price < 0) {
      return 'Sale price cannot be negative';
    }
    if (price > 1000000) {
      return 'Sale price must be less than 1,000,000';
    }
    // Cross-field validation: sale price should be >= purchase price
    if (purchasePrice != null && price < purchasePrice) {
      return 'Sale price should be at least the purchase price';
    }
    return null;
  }

  /// Quantity validation
  static String? validateQuantity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Quantity is required';
    }
    final quantity = int.tryParse(value.trim());
    if (quantity == null) {
      return 'Quantity must be a valid number';
    }
    if (quantity < 0) {
      return 'Quantity cannot be negative';
    }
    if (quantity > 999999) {
      return 'Quantity must be less than 999,999';
    }
    return null;
  }

  /// IMEI validation
  static String? validateImei(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'IMEI is required';
    }

    return value.length == 15 || value.length == 16
        ? null
        : 'IMEI must be 15 or 16 digits';
  }

  /// Store selection validation
  static String? validateStore(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Store selection is required';
    }
    return null;
  }

  /// Category validation (optional)
  static String? validateCategory(String? value) {
    // Category is optional, so null/empty is valid
    return null;
  }

  /// Description validation (optional)
  static String? validateDescription(String? value) {
    if (value != null && value.trim().length > 1000) {
      return 'Description must be less than 1000 characters';
    }
    return null;
  }

  /// Validate IMEI list for dynamic form
  static String? validateImeiList(List<String> imeis) {
    if (imeis.isEmpty) {
      return 'At least one IMEI is required';
    }

    // Check for duplicates
    final uniqueImeis = imeis.toSet();
    if (uniqueImeis.length != imeis.length) {
      return 'Duplicate IMEIs are not allowed';
    }

    // Validate each IMEI
    for (int i = 0; i < imeis.length; i++) {
      final validation = validateImei(imeis[i]);
      if (validation != null) {
        return 'IMEI ${i + 1}: $validation';
      }
    }

    return null;
  }

  /// Validate quantity for IMEI products (must be 1)
  static String? validateQuantityForImei(String? value, bool isImeiProduct) {
    if (!isImeiProduct) {
      return validateQuantity(value);
    }

    // For IMEI products, quantity must be exactly 1
    final quantity = int.tryParse(value?.trim() ?? '');
    if (quantity != 1) {
      return 'Quantity for IMEI products must be 1';
    }

    return null;
  }

  /// Validate entire product form
  static Map<String, String> validateProductForm({
    required String? name,
    required String? sku,
    required String? barcode,
    required String? purchasePrice,
    String? salePrice,
    required String? quantity,
    required String? storeId,
    String? categoryId,
    String? description,
    bool isImei = false,
    List<String>? imeis,
  }) {
    final errors = <String, String>{};

    final nameError = validateProductName(name);
    if (nameError != null) errors['name'] = nameError;

    final skuError = validateSku(sku);
    if (skuError != null) errors['sku'] = skuError;

    final barcodeError = validateBarcode(barcode);
    if (barcodeError != null) errors['barcode'] = barcodeError;

    final purchasePriceError = validatePurchasePrice(purchasePrice);
    if (purchasePriceError != null)
      errors['purchasePrice'] = purchasePriceError;

    final parsedPurchasePrice = double.tryParse(purchasePrice ?? '');
    final salePriceError = validateSalePrice(salePrice, parsedPurchasePrice);
    if (salePriceError != null) errors['salePrice'] = salePriceError;

    final quantityError = validateQuantity(quantity);
    if (quantityError != null) errors['quantity'] = quantityError;

    final storeError = validateStore(storeId);
    if (storeError != null) errors['store'] = storeError;

    final categoryError = validateCategory(categoryId);
    if (categoryError != null) errors['category'] = categoryError;

    final descriptionError = validateDescription(description);
    if (descriptionError != null) errors['description'] = descriptionError;

    // Validate IMEIs if product supports IMEI
    if (isImei && imeis != null) {
      final imeiError = validateImeiList(imeis);
      if (imeiError != null) errors['imeis'] = imeiError;
    }

    return errors;
  }
}
