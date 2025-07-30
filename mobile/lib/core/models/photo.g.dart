// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Photo _$PhotoFromJson(Map<String, dynamic> json) => Photo(
      id: json['id'] as String,
      publicId: json['publicId'] as String,
      secureUrl: json['secureUrl'] as String,
      type: $enumDecode(_$PhotoTypeEnumMap, json['type']),
      transactionId: json['transactionId'] as String?,
      productId: json['productId'] as String?,
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
    );

Map<String, dynamic> _$PhotoToJson(Photo instance) => <String, dynamic>{
      'id': instance.id,
      'publicId': instance.publicId,
      'secureUrl': instance.secureUrl,
      'type': _$PhotoTypeEnumMap[instance.type]!,
      'transactionId': instance.transactionId,
      'productId': instance.productId,
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
    };

const _$PhotoTypeEnumMap = {
  PhotoType.product: 'product',
  PhotoType.photoProof: 'photoProof',
  PhotoType.transferProof: 'transferProof',
};

UploadPhotoRequest _$UploadPhotoRequestFromJson(Map<String, dynamic> json) =>
    UploadPhotoRequest(
      type: $enumDecode(_$PhotoTypeEnumMap, json['type']),
      transactionId: json['transactionId'] as String?,
      productId: json['productId'] as String?,
    );

Map<String, dynamic> _$UploadPhotoRequestToJson(UploadPhotoRequest instance) =>
    <String, dynamic>{
      'type': _$PhotoTypeEnumMap[instance.type]!,
      'transactionId': instance.transactionId,
      'productId': instance.productId,
    };

DeletePhotoResponse _$DeletePhotoResponseFromJson(Map<String, dynamic> json) =>
    DeletePhotoResponse(
      message: json['message'] as String,
    );

Map<String, dynamic> _$DeletePhotoResponseToJson(
        DeletePhotoResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
    };
