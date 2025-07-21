class TransactionValidators {
  /// Validate store selection
  static String? validateStoreSelection(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please select a store';
    }
    return null;
  }

  /// Validate destination store for transfers
  static String? validateDestinationStore(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please select a destination store for transfer';
    }
    return null;
  }

  /// Validate customer name (optional but if provided, must be valid)
  static String? validateCustomerName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    
    if (value.trim().length < 2) {
      return 'Customer name must be at least 2 characters';
    }
    
    if (value.trim().length > 100) {
      return 'Customer name must be less than 100 characters';
    }
    
    // Check for valid characters (letters, spaces, hyphens, apostrophes)
    final nameRegex = RegExp(r"^[a-zA-Z\s\-']+$");
    if (!nameRegex.hasMatch(value.trim())) {
      return 'Customer name contains invalid characters';
    }
    
    return null;
  }

  /// Validate customer phone (optional but if provided, must be valid)
  static String? validateCustomerPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    
    // Remove all non-digit characters for validation
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digitsOnly.length < 10) {
      return 'Phone number must be at least 10 digits';
    }
    
    if (digitsOnly.length > 15) {
      return 'Phone number must be less than 15 digits';
    }
    
    // Basic phone format validation (allows +, -, spaces, parentheses)
    final phoneRegex = RegExp(r'^[\+]?[0-9\-\s\(\)]+$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Invalid phone number format';
    }
    
    return null;
  }

  /// Validate transaction item quantity
  static String? validateItemQuantity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Quantity is required';
    }
    
    final quantity = int.tryParse(value.trim());
    if (quantity == null) {
      return 'Quantity must be a valid number';
    }
    
    if (quantity <= 0) {
      return 'Quantity must be greater than 0';
    }
    
    if (quantity > 10000) {
      return 'Quantity cannot exceed 10,000';
    }
    
    return null;
  }

  /// Validate transaction item price
  static String? validateItemPrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Price is required';
    }
    
    final price = double.tryParse(value.trim());
    if (price == null) {
      return 'Price must be a valid number';
    }
    
    if (price < 0) {
      return 'Price cannot be negative';
    }
    
    if (price > 1000000) {
      return 'Price cannot exceed 1,000,000';
    }
    
    // Check for reasonable decimal places (max 2)
    final decimalPlaces = value.contains('.') ? value.split('.')[1].length : 0;
    if (decimalPlaces > 2) {
      return 'Price can have at most 2 decimal places';
    }
    
    return null;
  }

  /// Validate that transaction has items
  static String? validateTransactionItems(List<dynamic> items) {
    if (items.isEmpty) {
      return 'Transaction must have at least one item';
    }
    
    if (items.length > 100) {
      return 'Transaction cannot have more than 100 items';
    }
    
    return null;
  }

  /// Validate photo proof URL (for SALE transactions)
  static String? validatePhotoProof(String? value, {bool isRequired = false}) {
    if (!isRequired && (value == null || value.trim().isEmpty)) {
      return null; // Optional
    }
    
    if (isRequired && (value == null || value.trim().isEmpty)) {
      return 'Photo proof is required for sale transactions';
    }
    
    if (value != null && value.isNotEmpty) {
      // Basic URL validation
      final urlRegex = RegExp(
        r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$'
      );
      
      if (!urlRegex.hasMatch(value.trim())) {
        return 'Invalid photo URL format';
      }
    }
    
    return null;
  }

  /// Validate transaction type
  static String? validateTransactionType(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Transaction type is required';
    }
    
    final validTypes = ['SALE', 'TRANSFER'];
    if (!validTypes.contains(value.toUpperCase())) {
      return 'Invalid transaction type';
    }
    
    return null;
  }

  /// Validate that source and destination stores are different (for transfers)
  static String? validateDifferentStores(String? sourceStoreId, String? destinationStoreId) {
    if (sourceStoreId != null && destinationStoreId != null && sourceStoreId == destinationStoreId) {
      return 'Source and destination stores must be different';
    }
    return null;
  }

  /// Comprehensive transaction validation
  static List<String> validateTransaction({
    required String type,
    required String storeId,
    String? destinationStoreId,
    String? photoProofUrl,
    required List<dynamic> items,
    String? customerName,
    String? customerPhone,
  }) {
    final errors = <String>[];
    
    // Validate transaction type
    final typeError = validateTransactionType(type);
    if (typeError != null) errors.add(typeError);
    
    // Validate store selection
    final storeError = validateStoreSelection(storeId);
    if (storeError != null) errors.add(storeError);
    
    // Validate items
    final itemsError = validateTransactionItems(items);
    if (itemsError != null) errors.add(itemsError);
    
    // Type-specific validations
    if (type.toUpperCase() == 'TRANSFER') {
      final destStoreError = validateDestinationStore(destinationStoreId);
      if (destStoreError != null) errors.add(destStoreError);
      
      final differentStoresError = validateDifferentStores(storeId, destinationStoreId);
      if (differentStoresError != null) errors.add(differentStoresError);
    }
    
    if (type.toUpperCase() == 'SALE') {
      final photoError = validatePhotoProof(photoProofUrl, isRequired: true);
      if (photoError != null) errors.add(photoError);
    }
    
    // Optional customer information validation
    if (customerName != null && customerName.isNotEmpty) {
      final nameError = validateCustomerName(customerName);
      if (nameError != null) errors.add(nameError);
    }
    
    if (customerPhone != null && customerPhone.isNotEmpty) {
      final phoneError = validateCustomerPhone(customerPhone);
      if (phoneError != null) errors.add(phoneError);
    }
    
    return errors;
  }
}