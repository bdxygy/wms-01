// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Transaction _$TransactionFromJson(Map<String, dynamic> json) => Transaction(
      id: json['id'] as String,
      type: $enumDecode(_$TransactionTypeEnumMap, json['type']),
      createdBy: json['createdBy'] as String?,
      approvedBy: json['approvedBy'] as String?,
      fromStoreId: json['fromStoreId'] as String?,
      toStoreId: json['toStoreId'] as String?,
      photoProofUrl: json['photoProofUrl'] as String?,
      transferProofUrl: json['transferProofUrl'] as String?,
      to: json['to'] as String?,
      customerPhone: json['customerPhone'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      tradeInProductId: json['tradeInProductId'] as String?,
      isFinished: json['isFinished'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdByName: json['createdByName'] as String?,
      approvedByName: json['approvedByName'] as String?,
      fromStoreName: json['fromStoreName'] as String?,
      toStoreName: json['toStoreName'] as String?,
      tradeInProductName: json['tradeInProductName'] as String?,
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => TransactionItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TransactionToJson(Transaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$TransactionTypeEnumMap[instance.type]!,
      'createdBy': instance.createdBy,
      'approvedBy': instance.approvedBy,
      'fromStoreId': instance.fromStoreId,
      'toStoreId': instance.toStoreId,
      'photoProofUrl': instance.photoProofUrl,
      'transferProofUrl': instance.transferProofUrl,
      'to': instance.to,
      'customerPhone': instance.customerPhone,
      'amount': instance.amount,
      'tradeInProductId': instance.tradeInProductId,
      'isFinished': instance.isFinished,
      'createdAt': instance.createdAt.toIso8601String(),
      'createdByName': instance.createdByName,
      'approvedByName': instance.approvedByName,
      'fromStoreName': instance.fromStoreName,
      'toStoreName': instance.toStoreName,
      'tradeInProductName': instance.tradeInProductName,
      'items': instance.items,
    };

const _$TransactionTypeEnumMap = {
  TransactionType.sale: 'SALE',
  TransactionType.transfer: 'TRANSFER',
  TransactionType.trade: 'TRADE',
};

TransactionItem _$TransactionItemFromJson(Map<String, dynamic> json) =>
    TransactionItem(
      id: json['id'] as String,
      transactionId: json['transactionId'] as String?,
      productId: json['productId'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: (json['quantity'] as num).toInt(),
      amount: (json['amount'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      productBarcode: json['productBarcode'] as String?,
      productSku: json['productSku'] as String?,
    );

Map<String, dynamic> _$TransactionItemToJson(TransactionItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'transactionId': instance.transactionId,
      'productId': instance.productId,
      'name': instance.name,
      'price': instance.price,
      'quantity': instance.quantity,
      'amount': instance.amount,
      'createdAt': instance.createdAt.toIso8601String(),
      'productBarcode': instance.productBarcode,
      'productSku': instance.productSku,
    };
