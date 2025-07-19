import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

enum UserRole {
  @JsonValue('OWNER')
  owner,
  @JsonValue('ADMIN')
  admin,
  @JsonValue('STAFF')
  staff,
  @JsonValue('CASHIER')
  cashier,
}

@JsonSerializable()
class User {
  final String id;
  final String? ownerId;
  final String name;
  final String username;
  final UserRole role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  User({
    required this.id,
    this.ownerId,
    required this.name,
    required this.username,
    required this.role,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  // Helper methods
  bool get isOwner => role == UserRole.owner;
  bool get isAdmin => role == UserRole.admin;
  bool get isStaff => role == UserRole.staff;
  bool get isCashier => role == UserRole.cashier;

  bool get canCreateProducts => isOwner || isAdmin;
  bool get canCreateTransactions => isOwner || isAdmin || isCashier;
  bool get canManageUsers => isOwner || isAdmin;
  bool get canManageStores => isOwner;
  bool get canDeleteData => isOwner;

  User copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? username,
    UserRole? role,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return User(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      username: username ?? this.username,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}