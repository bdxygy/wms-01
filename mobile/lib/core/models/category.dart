import 'package:json_annotation/json_annotation.dart';

part 'category.g.dart';

@JsonSerializable()
class Category {
  final String id;
  final String storeId;
  final String name;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  // Additional fields from API joins
  final String? storeName;
  final int? productCount;

  Category({
    required this.id,
    required this.storeId,
    required this.name,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.storeName,
    this.productCount,
  });

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryToJson(this);

  // Helper methods
  bool get hasProducts => productCount != null && productCount! > 0;
  
  String get displayName => name;
  
  String get displayInfo {
    if (productCount != null) {
      return '$name (${productCount!} products)';
    }
    return name;
  }

  Category copyWith({
    String? id,
    String? storeId,
    String? name,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    String? storeName,
    int? productCount,
  }) {
    return Category(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      name: name ?? this.name,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      storeName: storeName ?? this.storeName,
      productCount: productCount ?? this.productCount,
    );
  }
}