// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_requests.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateProductRequest _$CreateProductRequestFromJson(
        Map<String, dynamic> json) =>
    CreateProductRequest(
      name: json['name'] as String,
      description: json['description'] as String?,
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
      if (instance.description case final value?) 'description': value,
      'storeId': instance.storeId,
      if (instance.categoryId case final value?) 'categoryId': value,
      'sku': instance.sku,
      'isImei': instance.isImei,
      'quantity': instance.quantity,
      'purchasePrice': instance.purchasePrice,
      if (instance.salePrice case final value?) 'salePrice': value,
    };

UpdateProductRequest _$UpdateProductRequestFromJson(
        Map<String, dynamic> json) =>
    UpdateProductRequest(
      name: json['name'] as String?,
      description: json['description'] as String?,
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
      if (instance.name case final value?) 'name': value,
      if (instance.description case final value?) 'description': value,
      if (instance.categoryId case final value?) 'categoryId': value,
      if (instance.sku case final value?) 'sku': value,
      if (instance.isImei case final value?) 'isImei': value,
      if (instance.quantity case final value?) 'quantity': value,
      if (instance.purchasePrice case final value?) 'purchasePrice': value,
      if (instance.salePrice case final value?) 'salePrice': value,
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
      if (instance.description case final value?) 'description': value,
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
      if (instance.name case final value?) 'name': value,
      if (instance.description case final value?) 'description': value,
    };

CreateStoreRequest _$CreateStoreRequestFromJson(Map<String, dynamic> json) =>
    CreateStoreRequest(
      name: json['name'] as String,
      type: json['type'] as String,
      addressLine1: json['addressLine1'] as String,
      addressLine2: json['addressLine2'] as String?,
      city: json['city'] as String,
      province: json['province'] as String,
      postalCode: json['postalCode'] as String,
      country: json['country'] as String,
      phoneNumber: json['phoneNumber'] as String,
      email: json['email'] as String?,
      openTime: json['openTime'] as String?,
      closeTime: json['closeTime'] as String?,
      timezone: json['timezone'] as String?,
      mapLocation: json['mapLocation'] as String?,
    );

Map<String, dynamic> _$CreateStoreRequestToJson(CreateStoreRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': instance.type,
      'addressLine1': instance.addressLine1,
      if (instance.addressLine2 case final value?) 'addressLine2': value,
      'city': instance.city,
      'province': instance.province,
      'postalCode': instance.postalCode,
      'country': instance.country,
      'phoneNumber': instance.phoneNumber,
      if (instance.email case final value?) 'email': value,
      if (instance.openTime case final value?) 'openTime': value,
      if (instance.closeTime case final value?) 'closeTime': value,
      if (instance.timezone case final value?) 'timezone': value,
      if (instance.mapLocation case final value?) 'mapLocation': value,
    };

UpdateStoreRequest _$UpdateStoreRequestFromJson(Map<String, dynamic> json) =>
    UpdateStoreRequest(
      name: json['name'] as String?,
      type: json['type'] as String?,
      addressLine1: json['addressLine1'] as String?,
      addressLine2: json['addressLine2'] as String?,
      city: json['city'] as String?,
      province: json['province'] as String?,
      postalCode: json['postalCode'] as String?,
      country: json['country'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      email: json['email'] as String?,
      isActive: json['isActive'] as bool?,
      openTime: json['openTime'] as String?,
      closeTime: json['closeTime'] as String?,
      timezone: json['timezone'] as String?,
      mapLocation: json['mapLocation'] as String?,
    );

Map<String, dynamic> _$UpdateStoreRequestToJson(UpdateStoreRequest instance) =>
    <String, dynamic>{
      if (instance.name case final value?) 'name': value,
      if (instance.type case final value?) 'type': value,
      if (instance.addressLine1 case final value?) 'addressLine1': value,
      if (instance.addressLine2 case final value?) 'addressLine2': value,
      if (instance.city case final value?) 'city': value,
      if (instance.province case final value?) 'province': value,
      if (instance.postalCode case final value?) 'postalCode': value,
      if (instance.country case final value?) 'country': value,
      if (instance.phoneNumber case final value?) 'phoneNumber': value,
      if (instance.email case final value?) 'email': value,
      if (instance.isActive case final value?) 'isActive': value,
      if (instance.openTime case final value?) 'openTime': value,
      if (instance.closeTime case final value?) 'closeTime': value,
      if (instance.timezone case final value?) 'timezone': value,
      if (instance.mapLocation case final value?) 'mapLocation': value,
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
      if (instance.storeId case final value?) 'storeId': value,
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
      if (instance.name case final value?) 'name': value,
      if (instance.username case final value?) 'username': value,
      if (instance.password case final value?) 'password': value,
      if (instance.role case final value?) 'role': value,
      if (instance.storeId case final value?) 'storeId': value,
      if (instance.isActive case final value?) 'isActive': value,
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
      if (instance.destinationStoreId case final value?)
        'destinationStoreId': value,
      if (instance.photoProofUrl case final value?) 'photoProofUrl': value,
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
      if (instance.type case final value?) 'type': value,
      if (instance.destinationStoreId case final value?)
        'destinationStoreId': value,
      if (instance.photoProofUrl case final value?) 'photoProofUrl': value,
      if (instance.items case final value?) 'items': value,
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
      description: json['description'] as String?,
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
      if (instance.description case final value?) 'description': value,
      'storeId': instance.storeId,
      if (instance.categoryId case final value?) 'categoryId': value,
      'sku': instance.sku,
      'barcode': instance.barcode,
      'quantity': instance.quantity,
      'purchasePrice': instance.purchasePrice,
      if (instance.salePrice case final value?) 'salePrice': value,
      'imeis': instance.imeis,
    };

UpdateProductWithImeisRequest _$UpdateProductWithImeisRequestFromJson(
        Map<String, dynamic> json) =>
    UpdateProductWithImeisRequest(
      name: json['name'] as String?,
      description: json['description'] as String?,
      categoryId: json['categoryId'] as String?,
      sku: json['sku'] as String?,
      purchasePrice: (json['purchasePrice'] as num?)?.toDouble(),
      salePrice: (json['salePrice'] as num?)?.toDouble(),
      imeis: (json['imeis'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$UpdateProductWithImeisRequestToJson(
        UpdateProductWithImeisRequest instance) =>
    <String, dynamic>{
      if (instance.name case final value?) 'name': value,
      if (instance.description case final value?) 'description': value,
      if (instance.categoryId case final value?) 'categoryId': value,
      if (instance.sku case final value?) 'sku': value,
      if (instance.purchasePrice case final value?) 'purchasePrice': value,
      if (instance.salePrice case final value?) 'salePrice': value,
      'imeis': instance.imeis,
    };
