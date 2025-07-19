// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'permission.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserPermissions _$UserPermissionsFromJson(Map<String, dynamic> json) =>
    UserPermissions(
      role: $enumDecode(_$UserRoleEnumMap, json['role']),
      permissions: (json['permissions'] as List<dynamic>)
          .map((e) => $enumDecode(_$PermissionEnumMap, e))
          .toList(),
      storeIds:
          (json['storeIds'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$UserPermissionsToJson(UserPermissions instance) =>
    <String, dynamic>{
      'role': _$UserRoleEnumMap[instance.role]!,
      'permissions':
          instance.permissions.map((e) => _$PermissionEnumMap[e]!).toList(),
      'storeIds': instance.storeIds,
    };

const _$UserRoleEnumMap = {
  UserRole.owner: 'OWNER',
  UserRole.admin: 'ADMIN',
  UserRole.staff: 'STAFF',
  UserRole.cashier: 'CASHIER',
};

const _$PermissionEnumMap = {
  Permission.createUser: 'CREATE_USER',
  Permission.readUser: 'READ_USER',
  Permission.updateUser: 'UPDATE_USER',
  Permission.deleteUser: 'DELETE_USER',
  Permission.createStore: 'CREATE_STORE',
  Permission.readStore: 'READ_STORE',
  Permission.updateStore: 'UPDATE_STORE',
  Permission.deleteStore: 'DELETE_STORE',
  Permission.createProduct: 'CREATE_PRODUCT',
  Permission.readProduct: 'READ_PRODUCT',
  Permission.updateProduct: 'UPDATE_PRODUCT',
  Permission.deleteProduct: 'DELETE_PRODUCT',
  Permission.createTransaction: 'CREATE_TRANSACTION',
  Permission.readTransaction: 'READ_TRANSACTION',
  Permission.updateTransaction: 'UPDATE_TRANSACTION',
  Permission.deleteTransaction: 'DELETE_TRANSACTION',
  Permission.createCategory: 'CREATE_CATEGORY',
  Permission.readCategory: 'READ_CATEGORY',
  Permission.updateCategory: 'UPDATE_CATEGORY',
  Permission.deleteCategory: 'DELETE_CATEGORY',
  Permission.manageImei: 'MANAGE_IMEI',
  Permission.fullAccess: 'FULL_ACCESS',
};
