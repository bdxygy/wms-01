import 'package:json_annotation/json_annotation.dart';

part 'store.g.dart';

@JsonSerializable()
class Store {
  final String id;
  final String ownerId;
  final String name;
  final String type;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String province;
  final String postalCode;
  final String country;
  final String phoneNumber;
  final String? email;
  final bool isActive;
  final DateTime? openTime;
  final DateTime? closeTime;
  final String timezone;
  final String? mapLocation;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  Store({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.type,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.province,
    required this.postalCode,
    required this.country,
    required this.phoneNumber,
    this.email,
    required this.isActive,
    this.openTime,
    this.closeTime,
    required this.timezone,
    this.mapLocation,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory Store.fromJson(Map<String, dynamic> json) => _$StoreFromJson(json);

  Map<String, dynamic> toJson() => _$StoreToJson(this);

  // Helper methods
  String get fullAddress {
    final parts = [
      addressLine1,
      if (addressLine2?.isNotEmpty == true) addressLine2,
      city,
      province,
      postalCode,
      country,
    ];
    return parts.join(', ');
  }

  String get displayName => '$name ($city)';

  bool get hasOperatingHours => openTime != null && closeTime != null;

  Store copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? type,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? province,
    String? postalCode,
    String? country,
    String? phoneNumber,
    String? email,
    bool? isActive,
    DateTime? openTime,
    DateTime? closeTime,
    String? timezone,
    String? mapLocation,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Store(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      type: type ?? this.type,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      province: province ?? this.province,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      isActive: isActive ?? this.isActive,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      timezone: timezone ?? this.timezone,
      mapLocation: mapLocation ?? this.mapLocation,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}