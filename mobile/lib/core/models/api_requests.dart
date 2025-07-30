import 'package:json_annotation/json_annotation.dart';

part 'api_requests.g.dart';

// Product requests
@JsonSerializable(includeIfNull: false)
class CreateProductRequest {
  final String name;
  final String? description;
  final String storeId;
  final String? categoryId;
  final String sku;
  final bool isImei;
  final bool isMustCheck;
  final int quantity;
  final double purchasePrice;
  final double? salePrice;

  CreateProductRequest({
    required this.name,
    this.description,
    required this.storeId,
    this.categoryId,
    required this.sku,
    required this.isImei,
    required this.isMustCheck,
    required this.quantity,
    required this.purchasePrice,
    this.salePrice,
  });

  factory CreateProductRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateProductRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateProductRequestToJson(this);
}

@JsonSerializable(includeIfNull: false)
class UpdateProductRequest {
  final String? name;
  final String? description;
  final String? categoryId;
  final String? sku;
  final bool? isImei;
  final bool? isMustCheck;
  final int? quantity;
  final double? purchasePrice;
  final double? salePrice;

  UpdateProductRequest({
    this.name,
    this.description,
    this.categoryId,
    this.sku,
    this.isImei,
    this.isMustCheck,
    this.quantity,
    this.purchasePrice,
    this.salePrice,
  });

  factory UpdateProductRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateProductRequestFromJson(json);

  Map<String, dynamic> toJson() {
    final json = _$UpdateProductRequestToJson(this);
    
    // Validate IMEI business rules before sending
    if (isImei == true && quantity != null && quantity != 1) {
      throw ArgumentError('IMEI products must have quantity of 1');
    }
    
    return json;
  }
}

// Category requests
@JsonSerializable(includeIfNull: false)
class CreateCategoryRequest {
  final String name;
  final String storeId;
  final String? description;

  CreateCategoryRequest({
    required this.name,
    required this.storeId,
    this.description,
  });

  factory CreateCategoryRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateCategoryRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateCategoryRequestToJson(this);
}

@JsonSerializable(includeIfNull: false)
class UpdateCategoryRequest {
  final String? name;
  final String? description;

  UpdateCategoryRequest({
    this.name,
    this.description,
  });

  factory UpdateCategoryRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateCategoryRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateCategoryRequestToJson(this);
}

// Store requests
@JsonSerializable(includeIfNull: false)
class CreateStoreRequest {
  final String name;
  final String type;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String province;
  final String postalCode;
  final String country;
  final String phoneNumber;
  final String? email;
  final String? openTime;
  final String? closeTime;
  final String? timezone;
  final String? mapLocation;

  CreateStoreRequest({
    required this.name,
    required this.type,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.province,
    required this.postalCode,
    required this.country,
    required this.phoneNumber,
    this.email,
    this.openTime,
    this.closeTime,
    this.timezone,
    this.mapLocation,
  });

  factory CreateStoreRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateStoreRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateStoreRequestToJson(this);
}

@JsonSerializable(includeIfNull: false)
class UpdateStoreRequest {
  final String? name;
  final String? type;
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? province;
  final String? postalCode;
  final String? country;
  final String? phoneNumber;
  final String? email;
  final bool? isActive;
  final String? openTime;
  final String? closeTime;
  final String? timezone;
  final String? mapLocation;

  UpdateStoreRequest({
    this.name,
    this.type,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.province,
    this.postalCode,
    this.country,
    this.phoneNumber,
    this.email,
    this.isActive,
    this.openTime,
    this.closeTime,
    this.timezone,
    this.mapLocation,
  });

  factory UpdateStoreRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateStoreRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateStoreRequestToJson(this);
}

// User requests
@JsonSerializable(includeIfNull: false)
class CreateUserRequest {
  final String name;
  final String username;
  final String password;
  final String role;
  final String? storeId;

  CreateUserRequest({
    required this.name,
    required this.username,
    required this.password,
    required this.role,
    this.storeId,
  });

  factory CreateUserRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateUserRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateUserRequestToJson(this);
}

@JsonSerializable(includeIfNull: false)
class UpdateUserRequest {
  final String? name;
  final String? username;
  final String? password;
  final String? role;
  final String? storeId;
  final bool? isActive;

  UpdateUserRequest({
    this.name,
    this.username,
    this.password,
    this.role,
    this.storeId,
    this.isActive,
  });

  factory UpdateUserRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateUserRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateUserRequestToJson(this);
}

// Transaction requests
@JsonSerializable(includeIfNull: false)
class CreateTransactionRequest {
  final String type;
  final String storeId;
  final String? destinationStoreId;
  final List<TransactionItemRequest> items;

  CreateTransactionRequest({
    required this.type,
    required this.storeId,
    this.destinationStoreId,
    required this.items,
  });

  factory CreateTransactionRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateTransactionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateTransactionRequestToJson(this);
}

@JsonSerializable(includeIfNull: false)
class TransactionItemRequest {
  final String productId;
  final String name;
  final int quantity;
  final double price;

  TransactionItemRequest({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
  });

  factory TransactionItemRequest.fromJson(Map<String, dynamic> json) =>
      _$TransactionItemRequestFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionItemRequestToJson(this);
}

@JsonSerializable(includeIfNull: false)
class UpdateTransactionRequest {
  final String? type;
  final String? destinationStoreId;
  final List<TransactionItemRequest>? items;

  UpdateTransactionRequest({
    this.type,
    this.destinationStoreId,
    this.items,
  });

  factory UpdateTransactionRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateTransactionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateTransactionRequestToJson(this);
}

// IMEI requests
@JsonSerializable(includeIfNull: false)
class AddImeiRequest {
  final String imei;

  AddImeiRequest({
    required this.imei,
  });

  factory AddImeiRequest.fromJson(Map<String, dynamic> json) =>
      _$AddImeiRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AddImeiRequestToJson(this);
}

@JsonSerializable(includeIfNull: false)
class CreateProductWithImeisRequest {
  final String name;
  final String? description;
  final String storeId;
  final String? categoryId;
  final String sku;
  final String barcode;
  final int quantity;
  final double purchasePrice;
  final double? salePrice;
  final List<String> imeis;

  CreateProductWithImeisRequest({
    required this.name,
    this.description,
    required this.storeId,
    this.categoryId,
    required this.sku,
    required this.barcode,
    required this.quantity,
    required this.purchasePrice,
    this.salePrice,
    required this.imeis,
  });

  factory CreateProductWithImeisRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateProductWithImeisRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateProductWithImeisRequestToJson(this);
}

@JsonSerializable(includeIfNull: false)
class UpdateProductWithImeisRequest {
  final String? name;
  final String? description;
  final String? categoryId;
  final String? sku;
  final double? purchasePrice;
  final double? salePrice;
  final List<String> imeis;

  UpdateProductWithImeisRequest({
    this.name,
    this.description,
    this.categoryId,
    this.sku,
    this.purchasePrice,
    this.salePrice,
    required this.imeis,
  });

  factory UpdateProductWithImeisRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateProductWithImeisRequestFromJson(json);

  Map<String, dynamic> toJson() {
    final json = _$UpdateProductWithImeisRequestToJson(this);
    
    // Validate that IMEIs are provided and unique
    if (imeis.isEmpty) {
      throw ArgumentError('At least one IMEI is required');
    }
    
    final uniqueImeis = imeis.toSet();
    if (uniqueImeis.length != imeis.length) {
      throw ArgumentError('All IMEIs must be unique');
    }
    
    return json;
  }
}