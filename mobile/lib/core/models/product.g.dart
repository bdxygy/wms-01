// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
      id: json['id'] as String,
      createdBy: json['createdBy'] as String,
      storeId: json['storeId'] as String,
      name: json['name'] as String,
      categoryId: json['categoryId'] as String?,
      sku: json['sku'] as String,
      isImei: json['isImei'] as bool,
      barcode: json['barcode'] as String,
      quantity: (json['quantity'] as num).toInt(),
      purchasePrice: (json['purchasePrice'] as num).toDouble(),
      salePrice: (json['salePrice'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
      categoryName: json['categoryName'] as String?,
      storeName: json['storeName'] as String?,
      imeis: (json['imeis'] as List<dynamic>?)
          ?.map((e) => ProductImei.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
      'id': instance.id,
      'createdBy': instance.createdBy,
      'storeId': instance.storeId,
      'name': instance.name,
      'categoryId': instance.categoryId,
      'sku': instance.sku,
      'isImei': instance.isImei,
      'barcode': instance.barcode,
      'quantity': instance.quantity,
      'purchasePrice': instance.purchasePrice,
      'salePrice': instance.salePrice,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
      'categoryName': instance.categoryName,
      'storeName': instance.storeName,
      'imeis': instance.imeis,
    };

ProductImei _$ProductImeiFromJson(Map<String, dynamic> json) => ProductImei(
      id: json['id'] as String,
      productId: json['productId'] as String,
      imei: json['imei'] as String,
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ProductImeiToJson(ProductImei instance) =>
    <String, dynamic>{
      'id': instance.id,
      'productId': instance.productId,
      'imei': instance.imei,
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
