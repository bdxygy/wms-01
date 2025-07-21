class ApiEndpoints {
  // Base paths
  static const String auth = '/auth';
  static const String users = '/users';
  static const String stores = '/stores';
  static const String categories = '/categories';
  static const String products = '/products';
  static const String transactions = '/transactions';
  static const String imeis = '/imeis';

  // Authentication endpoints
  static const String authLogin = '$auth/login';
  static const String authRegister = '$auth/register';
  static const String authDevRegister = '$auth/dev/register';
  static const String authRefresh = '$auth/refresh';
  static const String authLogout = '$auth/logout';

  // User endpoints
  static const String usersList = users;
  static const String usersCreate = users;
  static String usersById(String id) => '$users/$id';
  static String usersUpdate(String id) => '$users/$id';
  static String usersDelete(String id) => '$users/$id';

  // Store endpoints
  static const String storesList = stores;
  static const String storesCreate = stores;
  static String storesById(String id) => '$stores/$id';
  static String storesUpdate(String id) => '$stores/$id';

  // Category endpoints
  static const String categoriesList = categories;
  static const String categoriesCreate = categories;
  static String categoriesById(String id) => '$categories/$id';
  static String categoriesUpdate(String id) => '$categories/$id';

  // Product endpoints
  static const String productsList = products;
  static const String productsCreate = products;
  static String productsById(String id) => '$products/$id';
  static String productsUpdate(String id) => '$products/$id';
  static String productsDelete(String id) => '$products/$id';
  static String productsByBarcode(String barcode) => '$products/barcode/$barcode';
  
  // Product IMEI endpoints
  static String productsAddImei(String productId) => '$products/$productId/imeis';
  static String productsListImeis(String productId) => '$products/$productId/imeis';
  static String productsUpdateWithImeis(String productId) => '$products/$productId/imeis';
  static String productsCreateWithImeis() => '$products/imeis';
  static String productsByImei(String imei) => '$products/imeis/$imei';
  static String imeisDelete(String imeiId) => '$imeis/$imeiId';

  // Transaction endpoints
  static const String transactionsList = transactions;
  static const String transactionsCreate = transactions;
  static String transactionsById(String id) => '$transactions/$id';
  static String transactionsUpdate(String id) => '$transactions/$id';

  // Utility methods for query parameters
  static Map<String, dynamic> paginationParams({
    int page = 1,
    int limit = 20,
  }) {
    return {
      'page': page,
      'limit': limit,
    };
  }

  static Map<String, dynamic> userFilterParams({
    String? role,
    String? storeId,
    bool? isActive,
    String? search,
  }) {
    final params = <String, dynamic>{};
    if (role != null) params['role'] = role;
    if (storeId != null) params['storeId'] = storeId;
    if (isActive != null) params['isActive'] = isActive;
    if (search != null && search.isNotEmpty) params['search'] = search;
    return params;
  }

  static Map<String, dynamic> productFilterParams({
    String? storeId,
    String? categoryId,
    bool? isImei,
    double? minPrice,
    double? maxPrice,
    String? search,
  }) {
    final params = <String, dynamic>{};
    if (storeId != null) params['storeId'] = storeId;
    if (categoryId != null) params['categoryId'] = categoryId;
    if (isImei != null) params['isImei'] = isImei;
    if (minPrice != null) params['minPrice'] = minPrice;
    if (maxPrice != null) params['maxPrice'] = maxPrice;
    if (search != null && search.isNotEmpty) params['search'] = search;
    return params;
  }

  static Map<String, dynamic> transactionFilterParams({
    String? type,
    String? storeId,
    bool? isFinished,
    DateTime? startDate,
    DateTime? endDate,
    String? search,
  }) {
    final params = <String, dynamic>{};
    if (type != null) params['type'] = type;
    if (storeId != null) params['storeId'] = storeId;
    if (isFinished != null) params['isFinished'] = isFinished;
    if (startDate != null) params['startDate'] = startDate.toIso8601String();
    if (endDate != null) params['endDate'] = endDate.toIso8601String();
    if (search != null && search.isNotEmpty) params['search'] = search;
    return params;
  }

  static Map<String, dynamic> categoryFilterParams({
    String? storeId,
    String? search,
  }) {
    final params = <String, dynamic>{};
    if (storeId != null) params['storeId'] = storeId;
    if (search != null && search.isNotEmpty) params['search'] = search;
    return params;
  }
}