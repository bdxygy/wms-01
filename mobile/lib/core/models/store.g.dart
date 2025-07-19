// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Store _$StoreFromJson(Map<String, dynamic> json) => Store(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String,
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
      isActive: json['isActive'] as bool,
      openTime: json['openTime'] == null
          ? null
          : DateTime.parse(json['openTime'] as String),
      closeTime: json['closeTime'] == null
          ? null
          : DateTime.parse(json['closeTime'] as String),
      timezone: json['timezone'] as String,
      mapLocation: json['mapLocation'] as String?,
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
    );

Map<String, dynamic> _$StoreToJson(Store instance) => <String, dynamic>{
      'id': instance.id,
      'ownerId': instance.ownerId,
      'name': instance.name,
      'type': instance.type,
      'addressLine1': instance.addressLine1,
      'addressLine2': instance.addressLine2,
      'city': instance.city,
      'province': instance.province,
      'postalCode': instance.postalCode,
      'country': instance.country,
      'phoneNumber': instance.phoneNumber,
      'email': instance.email,
      'isActive': instance.isActive,
      'openTime': instance.openTime?.toIso8601String(),
      'closeTime': instance.closeTime?.toIso8601String(),
      'timezone': instance.timezone,
      'mapLocation': instance.mapLocation,
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
    };
