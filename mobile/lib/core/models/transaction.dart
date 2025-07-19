import 'package:json_annotation/json_annotation.dart';

part 'transaction.g.dart';

enum TransactionType {
  @JsonValue('SALE')
  sale,
  @JsonValue('TRANSFER')
  transfer,
}

@JsonSerializable()
class Transaction {
  final String id;
  final TransactionType type;
  final String? createdBy;
  final String? approvedBy;
  final String? fromStoreId;
  final String? toStoreId;
  final String? photoProofUrl;
  final String? transferProofUrl;
  final String? to;
  final String? customerPhone;
  final double? amount;
  final bool isFinished;
  final DateTime createdAt;

  // Additional fields from API joins
  final String? createdByName;
  final String? approvedByName;
  final String? fromStoreName;
  final String? toStoreName;
  final List<TransactionItem>? items;

  Transaction({
    required this.id,
    required this.type,
    this.createdBy,
    this.approvedBy,
    this.fromStoreId,
    this.toStoreId,
    this.photoProofUrl,
    this.transferProofUrl,
    this.to,
    this.customerPhone,
    this.amount,
    required this.isFinished,
    required this.createdAt,
    this.createdByName,
    this.approvedByName,
    this.fromStoreName,
    this.toStoreName,
    this.items,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionToJson(this);

  // Helper methods
  bool get isSale => type == TransactionType.sale;
  bool get isTransfer => type == TransactionType.transfer;
  bool get hasPhotoProof => photoProofUrl?.isNotEmpty == true;
  bool get hasTransferProof => transferProofUrl?.isNotEmpty == true;
  bool get hasCustomerInfo => to?.isNotEmpty == true || customerPhone?.isNotEmpty == true;
  
  String get statusText => isFinished ? 'Completed' : 'Pending';
  
  String get typeDisplayName {
    switch (type) {
      case TransactionType.sale:
        return 'Sale';
      case TransactionType.transfer:
        return 'Transfer';
    }
  }

  int get totalItems => items?.fold(0, (sum, item) => sum! + item.quantity) ?? 0;
  
  double get calculatedAmount {
    if (amount != null) return amount!;
    return items?.fold(0.0, (sum, item) => sum! + (item.amount ?? 0.0)) ?? 0.0;
  }

  Transaction copyWith({
    String? id,
    TransactionType? type,
    String? createdBy,
    String? approvedBy,
    String? fromStoreId,
    String? toStoreId,
    String? photoProofUrl,
    String? transferProofUrl,
    String? to,
    String? customerPhone,
    double? amount,
    bool? isFinished,
    DateTime? createdAt,
    String? createdByName,
    String? approvedByName,
    String? fromStoreName,
    String? toStoreName,
    List<TransactionItem>? items,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      createdBy: createdBy ?? this.createdBy,
      approvedBy: approvedBy ?? this.approvedBy,
      fromStoreId: fromStoreId ?? this.fromStoreId,
      toStoreId: toStoreId ?? this.toStoreId,
      photoProofUrl: photoProofUrl ?? this.photoProofUrl,
      transferProofUrl: transferProofUrl ?? this.transferProofUrl,
      to: to ?? this.to,
      customerPhone: customerPhone ?? this.customerPhone,
      amount: amount ?? this.amount,
      isFinished: isFinished ?? this.isFinished,
      createdAt: createdAt ?? this.createdAt,
      createdByName: createdByName ?? this.createdByName,
      approvedByName: approvedByName ?? this.approvedByName,
      fromStoreName: fromStoreName ?? this.fromStoreName,
      toStoreName: toStoreName ?? this.toStoreName,
      items: items ?? this.items,
    );
  }
}

@JsonSerializable()
class TransactionItem {
  final String id;
  final String transactionId;
  final String productId;
  final String name;
  final double price;
  final int quantity;
  final double? amount;
  final DateTime createdAt;

  // Additional fields from API joins
  final String? productBarcode;
  final String? productSku;

  TransactionItem({
    required this.id,
    required this.transactionId,
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    this.amount,
    required this.createdAt,
    this.productBarcode,
    this.productSku,
  });

  factory TransactionItem.fromJson(Map<String, dynamic> json) =>
      _$TransactionItemFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionItemToJson(this);

  // Helper methods
  double get calculatedAmount => amount ?? (price * quantity);
  double get unitPrice => price;
  double get totalPrice => calculatedAmount;

  TransactionItem copyWith({
    String? id,
    String? transactionId,
    String? productId,
    String? name,
    double? price,
    int? quantity,
    double? amount,
    DateTime? createdAt,
    String? productBarcode,
    String? productSku,
  }) {
    return TransactionItem(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
      productBarcode: productBarcode ?? this.productBarcode,
      productSku: productSku ?? this.productSku,
    );
  }
}