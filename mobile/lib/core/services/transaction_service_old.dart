import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/api_response.dart';
import '../models/api_requests.dart';
import '../models/transaction.dart';

class TransactionService {
  final ApiClient _apiClient = ApiClient.instance;

  /// Get paginated list of transactions with optional filtering
  Future<PaginatedResponse<Transaction>> getTransactions({
    int page = 1,
    int limit = 20,
    String? type,
    String? storeId,
    DateTime? startDate,
    DateTime? endDate,
    bool? isFinished,
  }) async {
    // Use API endpoints utility methods
    final paginationParams = ApiEndpoints.paginationParams(page: page, limit: limit);
    final filterParams = ApiEndpoints.transactionFilterParams(
      type: type,
      storeId: storeId,
      startDate: startDate,
      endDate: endDate,
      isFinished: isFinished,
    );

    // Combine pagination and filter parameters
    final queryParams = {...paginationParams, ...filterParams};

    try {
      final response = await _apiClient.get(ApiEndpoints.transactionsList, queryParameters: queryParams);
      return PaginatedResponse<Transaction>.fromJson(
        response.data,
        (json) => Transaction.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get transaction by ID with items
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

  /// Create new transaction (OWNER/ADMIN/CASHIER)
  Future<Transaction> createTransaction(CreateTransactionRequest request) async {
    try {
      final response = await _apiClient.post(ApiEndpoints.transactionsCreate, data: request.toJson());
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

  /// Update transaction (OWNER/ADMIN only)
  Future<Transaction> updateTransaction(String transactionId, UpdateTransactionRequest request) async {
    try {
      final response = await _apiClient.put(ApiEndpoints.transactionsUpdate(transactionId), data: request.toJson());
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

  /// Calculate transaction total from items
  double calculateTransactionTotal(List<TransactionItemRequest> items) {
    return items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  /// Validate transaction before creation
  bool validateTransaction(CreateTransactionRequest request) {
    // Must have at least one item
    if (request.items.isEmpty) {
      throw Exception('Transaction must have at least one item');
    }

    // Photo proof is now handled through separate photos table
    // SALE transactions should have photo proof - validation moved to photos service

    // TRANSFER transactions must have destination store
    if (request.type == 'TRANSFER' && request.destinationStoreId?.isEmpty != false) {
      throw Exception('TRANSFER transactions require destination store');
    }

    // Validate all items have positive quantities and prices
    for (final item in request.items) {
      if (item.quantity <= 0) {
        throw Exception('Item quantities must be positive');
      }
      if (item.price < 0) {
        throw Exception('Item prices cannot be negative');
      }
    }

    return true;
  }

  /// Helper method to create transaction item from product
  TransactionItemRequest createTransactionItem({
    required String productId,
    required String name,
    required int quantity,
    required double price,
  }) {
    return TransactionItemRequest(
      productId: productId,
      name: name,
      quantity: quantity,
      price: price,
    );
  }
}