import 'package:json_annotation/json_annotation.dart';
import 'user.dart';

part 'permission.g.dart';

enum Permission {
  // User management
  @JsonValue('CREATE_USER')
  createUser,
  @JsonValue('READ_USER')
  readUser,
  @JsonValue('UPDATE_USER')
  updateUser,
  @JsonValue('DELETE_USER')
  deleteUser,
  
  // Store management
  @JsonValue('CREATE_STORE')
  createStore,
  @JsonValue('READ_STORE')
  readStore,
  @JsonValue('UPDATE_STORE')
  updateStore,
  @JsonValue('DELETE_STORE')
  deleteStore,
  
  // Product management
  @JsonValue('CREATE_PRODUCT')
  createProduct,
  @JsonValue('READ_PRODUCT')
  readProduct,
  @JsonValue('UPDATE_PRODUCT')
  updateProduct,
  @JsonValue('DELETE_PRODUCT')
  deleteProduct,
  
  // Transaction management
  @JsonValue('CREATE_TRANSACTION')
  createTransaction,
  @JsonValue('READ_TRANSACTION')
  readTransaction,
  @JsonValue('UPDATE_TRANSACTION')
  updateTransaction,
  @JsonValue('DELETE_TRANSACTION')
  deleteTransaction,
  
  // Category management
  @JsonValue('CREATE_CATEGORY')
  createCategory,
  @JsonValue('READ_CATEGORY')
  readCategory,
  @JsonValue('UPDATE_CATEGORY')
  updateCategory,
  @JsonValue('DELETE_CATEGORY')
  deleteCategory,
  
  // IMEI management
  @JsonValue('MANAGE_IMEI')
  manageImei,
  
  // Special permissions
  @JsonValue('FULL_ACCESS')
  fullAccess,
}

@JsonSerializable()
class UserPermissions {
  final UserRole role;
  final List<Permission> permissions;
  final List<String> storeIds; // For non-owner users

  UserPermissions({
    required this.role,
    required this.permissions,
    required this.storeIds,
  });

  factory UserPermissions.fromJson(Map<String, dynamic> json) =>
      _$UserPermissionsFromJson(json);

  Map<String, dynamic> toJson() => _$UserPermissionsToJson(this);

  bool hasPermission(Permission permission) {
    return permissions.contains(permission) || permissions.contains(Permission.fullAccess);
  }

  bool canAccessStore(String storeId) {
    // OWNER can access all stores
    if (role == UserRole.owner) return true;
    // Others can only access assigned stores
    return storeIds.contains(storeId);
  }

  bool get canCreateProducts => hasPermission(Permission.createProduct);
  bool get canCreateTransactions => hasPermission(Permission.createTransaction);
  bool get canManageUsers => hasPermission(Permission.createUser);
  bool get canManageStores => hasPermission(Permission.createStore);
  bool get canDeleteData => hasPermission(Permission.deleteUser) && 
                          hasPermission(Permission.deleteProduct) && 
                          hasPermission(Permission.deleteTransaction);

  // Role-based permission factory methods
  factory UserPermissions.forOwner() {
    return UserPermissions(
      role: UserRole.owner,
      permissions: [Permission.fullAccess],
      storeIds: [], // Empty because OWNER has access to all stores
    );
  }

  factory UserPermissions.forAdmin(List<String> storeIds) {
    return UserPermissions(
      role: UserRole.admin,
      permissions: [
        Permission.createUser,
        Permission.readUser,
        Permission.updateUser,
        Permission.readStore,
        Permission.createProduct,
        Permission.readProduct,
        Permission.updateProduct,
        Permission.createTransaction,
        Permission.readTransaction,
        Permission.updateTransaction,
        Permission.createCategory,
        Permission.readCategory,
        Permission.updateCategory,
        Permission.manageImei,
      ],
      storeIds: storeIds,
    );
  }

  factory UserPermissions.forStaff(List<String> storeIds) {
    return UserPermissions(
      role: UserRole.staff,
      permissions: [
        Permission.readUser,
        Permission.readStore,
        Permission.readProduct,
        Permission.readTransaction,
        Permission.readCategory,
      ],
      storeIds: storeIds,
    );
  }

  factory UserPermissions.forCashier(List<String> storeIds) {
    return UserPermissions(
      role: UserRole.cashier,
      permissions: [
        Permission.readStore,
        Permission.readProduct,
        Permission.createTransaction,
        Permission.readTransaction,
        Permission.readCategory,
      ],
      storeIds: storeIds,
    );
  }
}