import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/api_response.dart';
import '../models/transaction.dart';
import '../models/user.dart';

/// Transaction types matching backend enum
class TransactionTypes {
  static const String sale = 'SALE';
  static const String transfer = 'TRANSFER';
  
  static const List<String> all = [sale, transfer];
  
  /// Validate if transaction type is valid
  static bool isValid(String type) => all.contains(type);
  
  /// Get display name for transaction type
  static String getDisplayName(String type) {
    switch (type) {
      case sale:
        return 'Sale';
      case transfer:
        return 'Transfer';
      default:
        return type;
    }
  }
  
  /// Get all transaction types with display names
  static Map<String, String> getAllTypesWithDisplayNames() {
    return {
      sale: getDisplayName(sale),
      transfer: getDisplayName(transfer),
    };
  }
  
  /// Convert TransactionType enum to string constant
  static String fromTransactionTypeEnum(TransactionType type) {
    switch (type) {
      case TransactionType.sale:
        return sale;
      case TransactionType.transfer:
        return transfer;
    }
  }
  
  /// Convert string constant to TransactionType enum
  static TransactionType toTransactionTypeEnum(String type) {
    switch (type) {
      case sale:
        return TransactionType.sale;
      case transfer:
        return TransactionType.transfer;
      default:
        throw ArgumentError('Invalid transaction type: $type');
    }
  }
}

/// Comprehensive TransactionService based on backend API structure
/// 
/// Backend API Routes:
/// - POST /api/v1/transactions (Create transaction)
/// - GET /api/v1/transactions (List transactions with filters)
/// - GET /api/v1/transactions/:id (Get transaction by ID)
/// - PUT /api/v1/transactions/:id (Update transaction)
/// 
/// Features:
/// - RBAC: OWNER/ADMIN can create/update all types, CASHIER can create SALE only
/// - Transaction types: SALE, TRANSFER (use TransactionTypes constants)
/// - Store-scoped operations with owner isolation
/// - Optional photo proof support for SALE transactions
/// - Comprehensive validation and error handling
/// - Role-based business rules enforcement
/// 
/// Example Usage:
/// ```dart
/// final service = TransactionService();
/// 
/// // Create a SALE transaction
/// final saleRequest = service.createSaleTransactionRequest(
///   storeId: store.id,
///   items: [
///     service.createTransactionItem(
///       productId: 'product-uuid',
///       name: 'Product Name',
///       price: 100.0,
///       quantity: 2,
///     ),
///   ],
///   photoProofUrl: 'https://example.com/photo.jpg',
///   to: 'Customer Name',
///   customerPhone: '+1234567890',
/// );
/// final transaction = await service.createTransaction(saleRequest);
/// 
/// // Get transactions with filters
/// final transactions = await service.getTransactions(
///   type: TransactionTypes.sale,
///   storeId: store.id,
///   isFinished: false,
///   startDate: DateTime.now().subtract(Duration(days: 30)),
/// );
/// 
/// // Update transaction
/// await service.finishTransaction(transaction.id);
/// await service.addPhotoProof(transaction.id, 'https://example.com/photo2.jpg');
/// 
/// // Role-based validation
/// final errors = service.validateTransaction(request, userRole: UserRole.cashier);
/// if (errors.isNotEmpty) {
///   // Handle validation errors
/// }
/// 
/// // Check permissions
/// final canCreate = TransactionService.canCreateTransactionType(
///   UserRole.cashier, 
///   TransactionTypes.sale,
/// ); // true
/// 
/// final allowedTypes = TransactionService.getAllowedTransactionTypes(
///   UserRole.cashier,
/// ); // ['SALE']
/// 
/// // Check photo proof recommendations
/// final isPhotoRecommended = TransactionService.isPhotoProofRecommended(
///   UserRole.cashier,
///   TransactionTypes.sale,
/// ); // true (recommended, not required)
/// 
/// // Check transfer proof recommendations  
/// final isTransferRecommended = TransactionService.isTransferProofRecommended(
///   UserRole.owner,
///   TransactionTypes.transfer,
/// ); // true (recommended for TRANSFER)
/// 
/// // Get non-blocking warnings
/// final warnings = service.getTransactionWarnings(request, UserRole.owner);
/// if (warnings.isNotEmpty) {
///   // Show recommendations to user
///   // May include: photoProof, transferProof, customer, transferTo
/// }
/// ```
class TransactionService {
  final ApiClient _apiClient = ApiClient.instance;

  /// Create new transaction (OWNER/ADMIN/CASHIER)
  /// 
  /// Business Rules:
  /// - SALE: Photo proof optional, at least one item required
  /// - TRANSFER: Must have fromStoreId and toStoreId
  /// - CASHIER: Can only create SALE transactions (photo proof recommended)
  /// - Validates product availability and store access
  Future<Transaction> createTransaction(CreateTransactionBackendRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.transactionsCreate, 
        data: request.toJson(),
      );
      
      final apiResponse = ApiResponse<Transaction>.fromJson(
        response.data,
        (json) => Transaction.fromJson(json as Map<String, dynamic>),
      );
      
      if (!apiResponse.success || apiResponse.data == null) {
        throw Exception(apiResponse.error?.message ?? 'Failed to create transaction');
      }
      
      return apiResponse.data!;
    } catch (e) {
      rethrow;
    }
  }

  /// Get transaction by ID with all items and store information
  Future<Transaction> getTransactionById(String transactionId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.transactionsById(transactionId));
      
      final apiResponse = ApiResponse<Transaction>.fromJson(
        response.data,
        (json) => Transaction.fromJson(json as Map<String, dynamic>),
      );
      
      if (!apiResponse.success || apiResponse.data == null) {
        throw Exception(apiResponse.error?.message ?? 'Transaction not found');
      }
      
      return apiResponse.data!;
    } catch (e) {
      rethrow;
    }
  }

  /// Get paginated list of transactions with comprehensive filtering
  /// 
  /// Filters supported:
  /// - type: TransactionTypes.sale or TransactionTypes.transfer
  /// - storeId: Filter by fromStoreId or toStoreId
  /// - isFinished: true/false for completion status
  /// - startDate/endDate: Date range filtering
  /// - minAmount/maxAmount: Amount range filtering
  Future<PaginatedResponse<Transaction>> getTransactions({
    int page = 1,
    int limit = 20,
    String? type, // Use TransactionTypes.sale or TransactionTypes.transfer
    String? storeId,
    bool? isFinished,
    DateTime? startDate,
    DateTime? endDate,
    double? minAmount,
    double? maxAmount,
  }) async {
    try {
      // Build query parameters
      final Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
      };

      if (type != null) queryParams['type'] = type;
      if (storeId != null) queryParams['storeId'] = storeId;
      if (isFinished != null) queryParams['isFinished'] = isFinished;
      if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();
      if (minAmount != null) queryParams['minAmount'] = minAmount;
      if (maxAmount != null) queryParams['maxAmount'] = maxAmount;

      final response = await _apiClient.get(
        ApiEndpoints.transactionsList,
        queryParameters: queryParams,
      );
      
      return PaginatedResponse<Transaction>.fromJson(
        response.data,
        (json) => Transaction.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Update transaction (OWNER/ADMIN only)
  /// 
  /// Can update:
  /// - Photo proof URLs
  /// - Transfer proof URLs
  /// - Customer information (to, customerPhone)
  /// - Completion status (isFinished)
  /// - Transaction items (complete replacement)
  Future<Transaction> updateTransaction(
    String transactionId, 
    UpdateTransactionBackendRequest request,
  ) async {
    try {
      final response = await _apiClient.put(
        ApiEndpoints.transactionsUpdate(transactionId),
        data: request.toJson(),
      );
      
      final apiResponse = ApiResponse<Transaction>.fromJson(
        response.data,
        (json) => Transaction.fromJson(json as Map<String, dynamic>),
      );
      
      if (!apiResponse.success || apiResponse.data == null) {
        throw Exception(apiResponse.error?.message ?? 'Failed to update transaction');
      }
      
      return apiResponse.data!;
    } catch (e) {
      rethrow;
    }
  }

  /// Mark transaction as finished
  Future<Transaction> finishTransaction(String transactionId) async {
    return updateTransaction(
      transactionId,
      UpdateTransactionBackendRequest(isFinished: true),
    );
  }

  /// Add photo proof to transaction
  Future<Transaction> addPhotoProof(String transactionId, String photoProofUrl) async {
    return updateTransaction(
      transactionId,
      UpdateTransactionBackendRequest(photoProofUrl: photoProofUrl),
    );
  }

  /// Add transfer proof to transaction
  Future<Transaction> addTransferProof(String transactionId, String transferProofUrl) async {
    return updateTransaction(
      transactionId,
      UpdateTransactionBackendRequest(transferProofUrl: transferProofUrl),
    );
  }

  /// Update customer information
  Future<Transaction> updateCustomerInfo(
    String transactionId, {
    String? to,
    String? customerPhone,
  }) async {
    return updateTransaction(
      transactionId,
      UpdateTransactionBackendRequest(
        to: to,
        customerPhone: customerPhone,
      ),
    );
  }

  /// Update transaction items (complete replacement)
  Future<Transaction> updateTransactionItems(
    String transactionId,
    List<TransactionItemBackendRequest> items,
  ) async {
    return updateTransaction(
      transactionId,
      UpdateTransactionBackendRequest(items: items),
    );
  }

  // === Utility Methods ===

  /// Calculate total amount from transaction items
  double calculateTransactionTotal(List<TransactionItemBackendRequest> items) {
    return items.fold(0.0, (sum, item) => sum + item.amount);
  }

  // === Role-Based Permission Methods ===

  /// Check if user can create transactions of given type
  /// CASHIER: Can only create SALE transactions
  /// ADMIN/OWNER: Can create any transaction type
  static bool canCreateTransactionType(UserRole userRole, String transactionType) {
    switch (userRole) {
      case UserRole.owner:
      case UserRole.admin:
        return true; // Can create any transaction type
      case UserRole.cashier:
        return transactionType == TransactionTypes.sale; // SALE only
      case UserRole.staff:
        return false; // Cannot create transactions
    }
  }

  /// Check if user can update transactions
  /// CASHIER: Can update SALE transactions (limited fields)
  /// ADMIN/OWNER: Can update any transaction
  static bool canUpdateTransaction(UserRole userRole) {
    switch (userRole) {
      case UserRole.owner:
      case UserRole.admin:
      case UserRole.cashier:
        return true; // Can update transactions
      case UserRole.staff:
        return false; // Cannot update transactions
    }
  }

  /// Get allowed transaction types for user role
  static List<String> getAllowedTransactionTypes(UserRole userRole) {
    switch (userRole) {
      case UserRole.owner:
      case UserRole.admin:
        return [TransactionTypes.sale, TransactionTypes.transfer];
      case UserRole.cashier:
        return [TransactionTypes.sale];
      case UserRole.staff:
        return []; // Cannot create transactions
    }
  }

  /// Check if user can create any transactions
  static bool canCreateTransactions(UserRole userRole) {
    return getAllowedTransactionTypes(userRole).isNotEmpty;
  }

  /// Check if photo proof is recommended for user role
  static bool isPhotoProofRecommended(UserRole userRole, String transactionType) {
    switch (userRole) {
      case UserRole.cashier:
        return transactionType == TransactionTypes.sale; // Recommended for CASHIER SALE
      case UserRole.owner:
      case UserRole.admin:
      case UserRole.staff:
        return false; // Not specifically recommended for other roles
    }
  }

  /// Check if transfer proof is recommended for user role
  static bool isTransferProofRecommended(UserRole userRole, String transactionType) {
    switch (userRole) {
      case UserRole.owner:
      case UserRole.admin:
        return transactionType == TransactionTypes.transfer; // Recommended for TRANSFER
      case UserRole.cashier:
      case UserRole.staff:
        return false; // CASHIER cannot create TRANSFER, STAFF cannot create any
    }
  }

  /// Get role-specific requirements for transactions
  static Map<String, dynamic> getRoleRequirements(UserRole userRole) {
    switch (userRole) {
      case UserRole.owner:
      case UserRole.admin:
        return {
          'canCreateSale': true,
          'canCreateTransfer': true,
          'canUpdateAll': true,
          'requiresPhotoProof': false,
          'requiresTransferProof': false,
          'recommendsPhotoProof': false,
          'recommendsTransferProof': true, // Recommended for TRANSFER transactions
          'description': 'Full transaction management access',
        };
      case UserRole.cashier:
        return {
          'canCreateSale': true,
          'canCreateTransfer': false,
          'canUpdateAll': false,
          'requiresPhotoProof': false, // Optional, not required
          'requiresTransferProof': false, // N/A - cannot create TRANSFER
          'recommendsPhotoProof': true, // Recommended for best practices
          'recommendsTransferProof': false, // N/A - cannot create TRANSFER
          'description': 'Can create SALE transactions (photo proof recommended)',
        };
      case UserRole.staff:
        return {
          'canCreateSale': false,
          'canCreateTransfer': false,
          'canUpdateAll': false,
          'requiresPhotoProof': false,
          'requiresTransferProof': false,
          'recommendsPhotoProof': false,
          'recommendsTransferProof': false,
          'description': 'Read-only access to transactions',
        };
    }
  }

  /// Validate role permissions for transaction creation
  Map<String, String> validateRolePermissions(
    CreateTransactionBackendRequest request, 
    UserRole userRole,
  ) {
    final errors = <String, String>{};

    // Check if user can create transactions
    if (!canCreateTransactionType(userRole, request.type)) {
      if (userRole == UserRole.staff) {
        errors['permission'] = 'STAFF users cannot create transactions';
      } else if (userRole == UserRole.cashier && request.type != TransactionTypes.sale) {
        errors['permission'] = 'CASHIER users can only create SALE transactions';
      } else {
        errors['permission'] = 'Insufficient permissions to create ${request.type} transactions';
      }
    }

    // CASHIER specific validations for SALE transactions
    if (userRole == UserRole.cashier && request.type == TransactionTypes.sale) {
      // Photo proof is recommended but not required for CASHIER
      // This is just a service-layer preference, not enforced
      if (request.photoProofUrl == null || request.photoProofUrl!.isEmpty) {
        // Note: Not adding to errors - making it optional
        // Could add a warning instead if needed
      }
    }

    return errors;
  }

  /// Get warnings/recommendations for transaction (non-blocking)
  Map<String, String> getTransactionWarnings(
    CreateTransactionBackendRequest request,
    UserRole userRole,
  ) {
    final warnings = <String, String>{};

    // Photo proof recommendation for CASHIER SALE transactions
    if (isPhotoProofRecommended(userRole, request.type)) {
      if (request.photoProofUrl == null || request.photoProofUrl!.isEmpty) {
        warnings['photoProof'] = 'Photo proof is recommended for better record keeping';
      }
    }

    // Transfer proof recommendation for OWNER/ADMIN TRANSFER transactions
    if (isTransferProofRecommended(userRole, request.type)) {
      if (request.transferProofUrl == null || request.transferProofUrl!.isEmpty) {
        warnings['transferProof'] = 'Transfer proof is recommended for TRANSFER transactions';
      }
    }

    // Customer information recommendations
    if (request.type == TransactionTypes.sale) {
      if ((request.to == null || request.to!.isEmpty) && 
          (request.customerPhone == null || request.customerPhone!.isEmpty)) {
        warnings['customer'] = 'Customer information is recommended for SALE transactions';
      }
    }

    // Transfer destination recommendations
    if (request.type == TransactionTypes.transfer) {
      if (request.to == null || request.to!.isEmpty) {
        warnings['transferTo'] = 'Destination/recipient information is recommended for TRANSFER transactions';
      }
    }

    return warnings;
  }

  /// Validate transaction before creation
  /// 
  /// Optionally provide userRole for role-based validation
  Map<String, String> validateTransaction(
    CreateTransactionBackendRequest request, {
    UserRole? userRole,
  }) {
    final errors = <String, String>{};

    // Must have at least one item
    if (request.items.isEmpty) {
      errors['items'] = 'Transaction must have at least one item';
    }

    // Validate transaction type
    if (!TransactionTypes.isValid(request.type)) {
      errors['type'] = 'Invalid transaction type. Must be ${TransactionTypes.all.join(" or ")}';
    }

    // Role-based validation
    if (userRole != null) {
      final roleErrors = validateRolePermissions(request, userRole);
      errors.addAll(roleErrors);
    }

    // Type-specific validations
    switch (request.type) {
      case TransactionTypes.sale:
        // SALE transactions should have from/to store
        if (request.fromStoreId == null && request.toStoreId == null) {
          errors['stores'] = 'SALE transactions require at least one store';
        }
        break;
        
      case TransactionTypes.transfer:
        // TRANSFER transactions must have both stores
        if (request.fromStoreId == null || request.toStoreId == null) {
          errors['stores'] = 'TRANSFER transactions require both source and destination stores';
        }
        // Cannot transfer to the same store
        if (request.fromStoreId == request.toStoreId) {
          errors['stores'] = 'Cannot transfer to the same store';
        }
        break;
    }

    // Validate all items
    for (int i = 0; i < request.items.length; i++) {
      final item = request.items[i];
      
      if (item.quantity <= 0) {
        errors['item_$i'] = 'Item quantity must be positive';
      }
      
      if (item.price < 0) {
        errors['item_$i'] = 'Item price cannot be negative';
      }
      
      if (item.amount <= 0) {
        errors['item_$i'] = 'Item amount must be positive';
      }

      if (item.name.trim().isEmpty) {
        errors['item_$i'] = 'Item name is required';
      }
    }

    return errors;
  }

  /// Create transaction item from product
  TransactionItemBackendRequest createTransactionItem({
    required String productId,
    required String name,
    required double price,
    required int quantity,
  }) {
    return TransactionItemBackendRequest(
      productId: productId,
      name: name,
      price: price,
      quantity: quantity,
      amount: price * quantity,
    );
  }

  /// Helper to create SALE transaction request
  CreateTransactionBackendRequest createSaleTransactionRequest({
    required String storeId,
    required List<TransactionItemBackendRequest> items,
    String? photoProofUrl,
    String? to,
    String? customerPhone,
  }) {
    return CreateTransactionBackendRequest(
      type: TransactionTypes.sale,
      fromStoreId: storeId,
      items: items,
      photoProofUrl: photoProofUrl,
      to: to,
      customerPhone: customerPhone,
    );
  }

  /// Helper to create TRANSFER transaction request
  CreateTransactionBackendRequest createTransferTransactionRequest({
    required String fromStoreId,
    required String toStoreId,
    required List<TransactionItemBackendRequest> items,
    String? transferProofUrl,
    String? to,
  }) {
    return CreateTransactionBackendRequest(
      type: TransactionTypes.transfer,
      fromStoreId: fromStoreId,
      toStoreId: toStoreId,
      items: items,
      transferProofUrl: transferProofUrl,
      to: to,
    );
  }

  // === Analytics and Reporting Methods ===

  /// Get transaction statistics for a date range
  Future<TransactionStats> getTransactionStats({
    DateTime? startDate,
    DateTime? endDate,
    String? storeId,
  }) async {
    // Get all transactions in the date range
    final transactions = await getTransactions(
      page: 1,
      limit: 1000, // Get a large number for stats
      startDate: startDate,
      endDate: endDate,
      storeId: storeId,
    );

    return _calculateStats(transactions.data);
  }

  /// Calculate statistics from transaction list
  TransactionStats _calculateStats(List<Transaction> transactions) {
    double totalSales = 0;
    double totalTransfers = 0;
    int completedCount = 0;
    int pendingCount = 0;
    int saleCount = 0;
    int transferCount = 0;

    for (final transaction in transactions) {
      if (transaction.isFinished) {
        completedCount++;
      } else {
        pendingCount++;
      }

      switch (transaction.type) {
        case TransactionType.sale:
          saleCount++;
          totalSales += transaction.calculatedAmount;
          break;
        case TransactionType.transfer:
          transferCount++;
          totalTransfers += transaction.calculatedAmount;
          break;
      }
    }

    return TransactionStats(
      totalTransactions: transactions.length,
      totalSales: totalSales,
      totalTransfers: totalTransfers,
      completedCount: completedCount,
      pendingCount: pendingCount,
      saleCount: saleCount,
      transferCount: transferCount,
    );
  }
}

/// Transaction statistics model
class TransactionStats {
  final int totalTransactions;
  final double totalSales;
  final double totalTransfers;
  final int completedCount;
  final int pendingCount;
  final int saleCount;
  final int transferCount;

  TransactionStats({
    required this.totalTransactions,
    required this.totalSales,
    required this.totalTransfers,
    required this.completedCount,
    required this.pendingCount,
    required this.saleCount,
    required this.transferCount,
  });

  double get averageTransactionValue => 
      totalTransactions > 0 ? (totalSales + totalTransfers) / totalTransactions : 0;
  
  double get completionRate =>
      totalTransactions > 0 ? completedCount / totalTransactions : 0;
}

/// Backend-compatible request models

class CreateTransactionBackendRequest {
  final String type; // 'SALE' or 'TRANSFER'
  final String? fromStoreId;
  final String? toStoreId;
  final String? photoProofUrl;
  final String? transferProofUrl;
  final String? to;
  final String? customerPhone;
  final List<TransactionItemBackendRequest> items;

  CreateTransactionBackendRequest({
    required this.type,
    this.fromStoreId,
    this.toStoreId,
    this.photoProofUrl,
    this.transferProofUrl,
    this.to,
    this.customerPhone,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
    'type': type,
    if (fromStoreId != null) 'fromStoreId': fromStoreId,
    if (toStoreId != null) 'toStoreId': toStoreId,
    if (photoProofUrl != null) 'photoProofUrl': photoProofUrl,
    if (transferProofUrl != null) 'transferProofUrl': transferProofUrl,
    if (to != null) 'to': to,
    if (customerPhone != null) 'customerPhone': customerPhone,
    'items': items.map((item) => item.toJson()).toList(),
  };
}

class UpdateTransactionBackendRequest {
  final String? photoProofUrl;
  final String? transferProofUrl;
  final String? to;
  final String? customerPhone;
  final bool? isFinished;
  final List<TransactionItemBackendRequest>? items;

  UpdateTransactionBackendRequest({
    this.photoProofUrl,
    this.transferProofUrl,
    this.to,
    this.customerPhone,
    this.isFinished,
    this.items,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (photoProofUrl != null) json['photoProofUrl'] = photoProofUrl;
    if (transferProofUrl != null) json['transferProofUrl'] = transferProofUrl;
    if (to != null) json['to'] = to;
    if (customerPhone != null) json['customerPhone'] = customerPhone;
    if (isFinished != null) json['isFinished'] = isFinished;
    if (items != null) json['items'] = items!.map((item) => item.toJson()).toList();
    return json;
  }
}

class TransactionItemBackendRequest {
  final String productId;
  final String name;
  final double price;
  final int quantity;
  final double amount;

  TransactionItemBackendRequest({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.amount,
  });

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'name': name,
    'price': price,
    'quantity': quantity,
    'amount': amount,
  };
}