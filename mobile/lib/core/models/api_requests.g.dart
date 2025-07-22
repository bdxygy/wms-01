// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_requests.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateProductRequest _$CreateProductRequestFromJson(
        Map<String, dynamic> json) =>
    CreateProductRequest(
      name: json['name'] as String,
      storeId: json['storeId'] as String,
      categoryId: json['categoryId'] as String?,
      sku: json['sku'] as String,
      isImei: json['isImei'] as bool,
      quantity: (json['quantity'] as num).toInt(),
      purchasePrice: (json['purchasePrice'] as num).toDouble(),
      salePrice: (json['salePrice'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$CreateProductRequestToJson(
        CreateProductRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'storeId': instance.storeId,
      'categoryId': instance.categoryId,
      'sku': instance.sku,
      'isImei': instance.isImei,
      'quantity': instance.quantity,
      'purchasePrice': instance.purchasePrice,
      'salePrice': instance.salePrice,
    };

UpdateProductRequest _$UpdateProductRequestFromJson(
        Map<String, dynamic> json) =>
    UpdateProductRequest(
      name: json['name'] as String?,
      categoryId: json['categoryId'] as String?,
      sku: json['sku'] as String?,
      isImei: json['isImei'] as bool?,
      quantity: (json['quantity'] as num?)?.toInt(),
      purchasePrice: (json['purchasePrice'] as num?)?.toDouble(),
      salePrice: (json['salePrice'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$UpdateProductRequestToJson(
        UpdateProductRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'categoryId': instance.categoryId,
      'sku': instance.sku,
      'isImei': instance.isImei,
      'quantity': instance.quantity,
      'purchasePrice': instance.purchasePrice,
      'salePrice': instance.salePrice,
    };

CreateCategoryRequest _$CreateCategoryRequestFromJson(
        Map<String, dynamic> json) =>
    CreateCategoryRequest(
      name: json['name'] as String,
      storeId: json['storeId'] as String,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$CreateCategoryRequestToJson(
        CreateCategoryRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'storeId': instance.storeId,
      'description': instance.description,
    };

UpdateCategoryRequest _$UpdateCategoryRequestFromJson(
        Map<String, dynamic> json) =>
    UpdateCategoryRequest(
      name: json['name'] as String?,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$UpdateCategoryRequestToJson(
        UpdateCategoryRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
    };

CreateStoreRequest _$CreateStoreRequestFromJson(Map<String, dynamic> json) =>
    CreateStoreRequest(
      name: json['name'] as String,
      address: json['address'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$CreateStoreRequestToJson(CreateStoreRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'address': instance.address,
      'phone': instance.phone,
      'email': instance.email,
      'description': instance.description,
    };

UpdateStoreRequest _$UpdateStoreRequestFromJson(Map<String, dynamic> json) =>
    UpdateStoreRequest(
      name: json['name'] as String?,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$UpdateStoreRequestToJson(UpdateStoreRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'address': instance.address,
      'phone': instance.phone,
      'email': instance.email,
      'description': instance.description,
    };

CreateUserRequest _$CreateUserRequestFromJson(Map<String, dynamic> json) =>
    CreateUserRequest(
      name: json['name'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
      role: json['role'] as String,
      storeId: json['storeId'] as String?,
    );

Map<String, dynamic> _$CreateUserRequestToJson(CreateUserRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'username': instance.username,
      'password': instance.password,
      'role': instance.role,
      'storeId': instance.storeId,
    };

UpdateUserRequest _$UpdateUserRequestFromJson(Map<String, dynamic> json) =>
    UpdateUserRequest(
      name: json['name'] as String?,
      username: json['username'] as String?,
      password: json['password'] as String?,
      role: json['role'] as String?,
      storeId: json['storeId'] as String?,
      isActive: json['isActive'] as bool?,
    );

Map<String, dynamic> _$UpdateUserRequestToJson(UpdateUserRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'username': instance.username,
      'password': instance.password,
      'role': instance.role,
      'storeId': instance.storeId,
      'isActive': instance.isActive,
    };

CreateTransactionRequest _$CreateTransactionRequestFromJson(
        Map<String, dynamic> json) =>
    CreateTransactionRequest(
      type: json['type'] as String,
      storeId: json['storeId'] as String,
      destinationStoreId: json['destinationStoreId'] as String?,
      photoProofUrl: json['photoProofUrl'] as String?,
      items: (json['items'] as List<dynamic>)
          .map(
              (e) => TransactionItemRequest.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CreateTransactionRequestToJson(
        CreateTransactionRequest instance) =>
    <String, dynamic>{
      'type': instance.type,
      'storeId': instance.storeId,
      'destinationStoreId': instance.destinationStoreId,
      'photoProofUrl': instance.photoProofUrl,
      'items': instance.items,
    };

TransactionItemRequest _$TransactionItemRequestFromJson(
        Map<String, dynamic> json) =>
    TransactionItemRequest(
      productId: json['productId'] as String,
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toInt(),
      price: (json['price'] as num).toDouble(),
    );

Map<String, dynamic> _$TransactionItemRequestToJson(
        TransactionItemRequest instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'name': instance.name,
      'quantity': instance.quantity,
      'price': instance.price,
    };

UpdateTransactionRequest _$UpdateTransactionRequestFromJson(
        Map<String, dynamic> json) =>
    UpdateTransactionRequest(
      type: json['type'] as String?,
      destinationStoreId: json['destinationStoreId'] as String?,
      photoProofUrl: json['photoProofUrl'] as String?,
      items: (json['items'] as List<dynamic>?)
          ?.map(
              (e) => TransactionItemRequest.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UpdateTransactionRequestToJson(
        UpdateTransactionRequest instance) =>
    <String, dynamic>{
      'type': instance.type,
      'destinationStoreId': instance.destinationStoreId,
      'photoProofUrl': instance.photoProofUrl,
      'items': instance.items,
    };

AddImeiRequest _$AddImeiRequestFromJson(Map<String, dynamic> json) =>
    AddImeiRequest(
      imei: json['imei'] as String,
    );

Map<String, dynamic> _$AddImeiRequestToJson(AddImeiRequest instance) =>
    <String, dynamic>{
      'imei': instance.imei,
    };

CreateProductWithImeisRequest _$CreateProductWithImeisRequestFromJson(
        Map<String, dynamic> json) =>
    CreateProductWithImeisRequest(
      name: json['name'] as String,
      storeId: json['storeId'] as String,
      categoryId: json['categoryId'] as String?,
      sku: json['sku'] as String,
      barcode: json['barcode'] as String,
      quantity: (json['quantity'] as num).toInt(),
      purchasePrice: (json['purchasePrice'] as num).toDouble(),
      salePrice: (json['salePrice'] as num?)?.toDouble(),
      imeis: (json['imeis'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$CreateProductWithImeisRequestToJson(
        CreateProductWithImeisRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'storeId': instance.storeId,
      'categoryId': instance.categoryId,
      'sku': instance.sku,
      'barcode': instance.barcode,
      'quantity': instance.quantity,
      'purchasePrice': instance.purchasePrice,
      'salePrice': instance.salePrice,
      'imeis': instance.imeis,
    };

UpdateProductWithImeisRequest _$UpdateProductWithImeisRequestFromJson(
        Map<String, dynamic> json) =>
    UpdateProductWithImeisRequest(
      name: json['name'] as String?,
      categoryId: json['categoryId'] as String?,
      sku: json['sku'] as String?,
      purchasePrice: (json['purchasePrice'] as num?)?.toDouble(),
      salePrice: (json['salePrice'] as num?)?.toDouble(),
      imeis: (json['imeis'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$UpdateProductWithImeisRequestToJson(
        UpdateProductWithImeisRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'categoryId': instance.categoryId,
      'sku': instance.sku,
      'purchasePrice': instance.purchasePrice,
      'salePrice': instance.salePrice,
      'imeis': instance.imeis,
    };
