import 'package:json_annotation/json_annotation.dart';

part 'product.g.dart';

@JsonSerializable()
class Product {
  final String id;
  final String createdBy;
  final String storeId;
  final String name;
  final String? description;
  final String? categoryId;
  final String sku;
  @JsonKey(defaultValue: false)
  final bool isImei;
  @JsonKey(defaultValue: false)
  final bool isMustCheck;
  final String barcode;
  final int quantity;
  final double purchasePrice;
  final double? salePrice;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  // Additional fields that might come from API joins
  final String? categoryName;
  final String? storeName;
  final List<ProductImei>? imeis;

  Product({
    required this.id,
    required this.createdBy,
    required this.storeId,
    required this.name,
    this.description,
    this.categoryId,
    required this.sku,
    required this.isImei,
    required this.isMustCheck,
    required this.barcode,
    required this.quantity,
    required this.purchasePrice,
    this.salePrice,
    this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.categoryName,
    this.storeName,
    this.imeis,
  });

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);

  Map<String, dynamic> toJson() => _$ProductToJson(this);

  // Helper methods
  bool get hasCategory => categoryId != null;
  bool get hasSalePrice => salePrice != null;
  bool get isElectronic => isImei;
  bool get inStock => quantity > 0;
  
  double get profitMargin => hasSalePrice 
      ? ((salePrice! - purchasePrice) / purchasePrice) * 100 
      : 0.0;
  
  double get profitAmount => hasSalePrice 
      ? (salePrice! - purchasePrice) 
      : 0.0;

  String get stockStatus {
    if (quantity == 0) return 'Out of Stock';
    if (quantity < 10) return 'Low Stock';
    return 'In Stock';
  }

  Product copyWith({
    String? id,
    String? createdBy,
    String? storeId,
    String? name,
    String? description,
    String? categoryId,
    String? sku,
    bool? isImei,
    bool? isMustCheck,
    String? barcode,
    int? quantity,
    double? purchasePrice,
    double? salePrice,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    String? categoryName,
    String? storeName,
    List<ProductImei>? imeis,
  }) {
    return Product(
      id: id ?? this.id,
      createdBy: createdBy ?? this.createdBy,
      storeId: storeId ?? this.storeId,
      name: name ?? this.name,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      sku: sku ?? this.sku,
      isImei: isImei ?? this.isImei,
      isMustCheck: isMustCheck ?? this.isMustCheck,
      barcode: barcode ?? this.barcode,
      quantity: quantity ?? this.quantity,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      salePrice: salePrice ?? this.salePrice,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      categoryName: categoryName ?? this.categoryName,
      storeName: storeName ?? this.storeName,
      imeis: imeis ?? this.imeis,
    );
  }
}

@JsonSerializable()
class ProductImei {
  final String id;
  final String? productId;
  final String imei;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductImei({
    required this.id,
    this.productId,
    required this.imei,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductImei.fromJson(Map<String, dynamic> json) =>
      _$ProductImeiFromJson(json);

  Map<String, dynamic> toJson() => _$ProductImeiToJson(this);

  ProductImei copyWith({
    String? id,
    String? productId,
    String? imei,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductImei(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      imei: imei ?? this.imei,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}