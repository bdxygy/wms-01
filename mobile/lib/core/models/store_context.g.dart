// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_context.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StoreContext _$StoreContextFromJson(Map<String, dynamic> json) => StoreContext(
      selectedStoreId: json['selectedStoreId'] as String?,
      selectedStore: json['selectedStore'] == null
          ? null
          : Store.fromJson(json['selectedStore'] as Map<String, dynamic>),
      availableStores: (json['availableStores'] as List<dynamic>?)
              ?.map((e) => Store.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      lastUpdated: json['lastUpdated'] == null
          ? null
          : DateTime.parse(json['lastUpdated'] as String),
      isLoading: json['isLoading'] as bool? ?? false,
      error: json['error'] as String?,
    );

Map<String, dynamic> _$StoreContextToJson(StoreContext instance) =>
    <String, dynamic>{
      'selectedStoreId': instance.selectedStoreId,
      'selectedStore': instance.selectedStore,
      'availableStores': instance.availableStores,
      'lastUpdated': instance.lastUpdated?.toIso8601String(),
      'isLoading': instance.isLoading,
      'error': instance.error,
    };
