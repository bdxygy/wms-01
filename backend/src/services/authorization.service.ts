import { HTTPException } from "hono/http-exception";
import { db } from "../config/database";
import { users } from "../models/users";
import { stores } from "../models/stores";
import { products } from "../models/products";
import { transactions } from "../models/transactions";
import { categories } from "../models/categories";
import { eq, and, isNull, or } from "drizzle-orm";
import type { User } from "../models/users";

export type Permission = 
  | "CREATE_USER"
  | "READ_USER"
  | "UPDATE_USER"
  | "DELETE_USER"
  | "CREATE_STORE"
  | "READ_STORE"
  | "UPDATE_STORE"
  | "DELETE_STORE"
  | "CREATE_CATEGORY"
  | "READ_CATEGORY"
  | "UPDATE_CATEGORY"
  | "DELETE_CATEGORY"
  | "CREATE_PRODUCT"
  | "READ_PRODUCT"
  | "UPDATE_PRODUCT"
  | "DELETE_PRODUCT"
  | "CREATE_TRANSACTION"
  | "READ_TRANSACTION"
  | "UPDATE_TRANSACTION"
  | "DELETE_TRANSACTION";

export type Resource = 
  | "USER"
  | "STORE"
  | "CATEGORY"
  | "PRODUCT"
  | "TRANSACTION";

export type Action = 
  | "CREATE"
  | "READ"
  | "UPDATE"
  | "DELETE";

export class AuthorizationService {
  private static rolePermissions: Record<string, Permission[]> = {
    OWNER: [
      "CREATE_USER",
      "READ_USER",
      "UPDATE_USER",
      "DELETE_USER",
      "CREATE_STORE",
      "READ_STORE",
      "UPDATE_STORE",
      "DELETE_STORE",
      "CREATE_CATEGORY",
      "READ_CATEGORY",
      "UPDATE_CATEGORY",
      "DELETE_CATEGORY",
      "CREATE_PRODUCT",
      "READ_PRODUCT",
      "UPDATE_PRODUCT",
      "DELETE_PRODUCT",
      "CREATE_TRANSACTION",
      "READ_TRANSACTION",
      "UPDATE_TRANSACTION",
      "DELETE_TRANSACTION",
    ],
    ADMIN: [
      "CREATE_USER", // Limited to STAFF role only
      "READ_USER",
      "UPDATE_USER",
      "READ_STORE",
      "CREATE_CATEGORY",
      "READ_CATEGORY",
      "UPDATE_CATEGORY",
      "CREATE_PRODUCT",
      "READ_PRODUCT",
      "UPDATE_PRODUCT",
      "CREATE_TRANSACTION",
      "READ_TRANSACTION",
      "UPDATE_TRANSACTION",
    ],
    STAFF: [
      "READ_USER",
      "READ_STORE",
      "READ_CATEGORY",
      "READ_PRODUCT",
      "UPDATE_PRODUCT", // Product checking only
      "READ_TRANSACTION",
    ],
    CASHIER: [
      "READ_USER",
      "READ_STORE",
      "READ_CATEGORY",
      "READ_PRODUCT",
      "CREATE_TRANSACTION", // SALE only
      "READ_TRANSACTION",
      "UPDATE_TRANSACTION",
    ],
  };

  static hasPermission(user: User, permission: Permission): boolean {
    const userPermissions = this.rolePermissions[user.role] || [];
    return userPermissions.includes(permission);
  }

  static hasResourceAccess(user: User, resource: Resource, action: Action): boolean {
    const permission = `${action}_${resource}` as Permission;
    return this.hasPermission(user, permission);
  }

  static async checkOwnerScope(user: User, ownerId: string): Promise<boolean> {
    if (user.role === "OWNER") {
      return user.id === ownerId;
    } else {
      return user.ownerId === ownerId;
    }
  }

  static async checkUserAccess(requestingUser: User, targetUserId: string): Promise<boolean> {
    const targetUser = await db
      .select()
      .from(users)
      .where(and(eq(users.id, targetUserId), isNull(users.deletedAt)));

    if (!targetUser[0]) {
      throw new HTTPException(404, { message: "User not found" });
    }

    // Check owner scope
    if (requestingUser.role === "OWNER") {
      return targetUser[0].ownerId === requestingUser.id || targetUser[0].id === requestingUser.id;
    } else {
      return targetUser[0].ownerId === requestingUser.ownerId;
    }
  }

  static async checkStoreAccess(requestingUser: User, storeId: string): Promise<boolean> {
    const store = await db
      .select()
      .from(stores)
      .where(and(eq(stores.id, storeId), isNull(stores.deletedAt)));

    if (!store[0]) {
      throw new HTTPException(404, { message: "Store not found" });
    }

    return this.checkOwnerScope(requestingUser, store[0].ownerId);
  }

  static async checkCategoryAccess(requestingUser: User, categoryId: string): Promise<boolean> {
    const category = await db
      .select({
        id: categories.id,
        createdBy: categories.createdBy,
        createdByOwnerId: users.ownerId,
        createdByRole: users.role,
      })
      .from(categories)
      .innerJoin(users, eq(categories.createdBy, users.id))
      .where(and(eq(categories.id, categoryId), isNull(categories.deletedAt)));

    if (!category[0]) {
      throw new HTTPException(404, { message: "Category not found" });
    }

    // Check owner scope - categories are owned by the user who created them
    if (requestingUser.role === "OWNER") {
      return category[0].createdBy === requestingUser.id || 
             category[0].createdByOwnerId === requestingUser.id;
    } else {
      return category[0].createdByOwnerId === requestingUser.ownerId;
    }
  }

  static async checkProductAccess(requestingUser: User, productId: string): Promise<boolean> {
    const product = await db
      .select({
        id: products.id,
        storeId: products.storeId,
        storeOwnerId: stores.ownerId,
      })
      .from(products)
      .innerJoin(stores, eq(products.storeId, stores.id))
      .where(and(eq(products.id, productId), isNull(products.deletedAt)));

    if (!product[0]) {
      throw new HTTPException(404, { message: "Product not found" });
    }

    return this.checkOwnerScope(requestingUser, product[0].storeOwnerId);
  }

  static async checkTransactionAccess(requestingUser: User, transactionId: string): Promise<boolean> {
    const transaction = await db
      .select({
        id: transactions.id,
        fromStoreId: transactions.fromStoreId,
        toStoreId: transactions.toStoreId,
      })
      .from(transactions)
      .where(eq(transactions.id, transactionId));

    if (!transaction[0]) {
      throw new HTTPException(404, { message: "Transaction not found" });
    }

    // Check access through any involved store
    const storeIds = [transaction[0].fromStoreId, transaction[0].toStoreId].filter(Boolean);
    
    if (storeIds.length === 0) {
      return false;
    }

    const userStores = await db
      .select()
      .from(stores)
      .where(
        and(
          requestingUser.role === "OWNER" 
            ? eq(stores.ownerId, requestingUser.id)
            : eq(stores.ownerId, requestingUser.ownerId!),
          or(...storeIds.map(storeId => eq(stores.id, storeId!)))
        )
      );

    return userStores.length > 0;
  }

  static validateRoleHierarchy(requestingUser: User, targetRole: string): boolean {
    const roleHierarchy = ["OWNER", "ADMIN", "STAFF", "CASHIER"];
    const requestingRoleLevel = roleHierarchy.indexOf(requestingUser.role);
    const targetRoleLevel = roleHierarchy.indexOf(targetRole);

    // OWNER can manage all roles
    if (requestingUser.role === "OWNER") {
      return true;
    }

    // ADMIN can only create STAFF users
    if (requestingUser.role === "ADMIN") {
      return targetRole === "STAFF";
    }

    // STAFF and CASHIER cannot create users
    return false;
  }

  static validateTransactionType(user: User, transactionType: string): boolean {
    if (user.role === "CASHIER") {
      return transactionType === "SALE";
    }
    return true; // Other roles can create any transaction type
  }

  static async enforcePermission(user: User, permission: Permission): Promise<void> {
    if (!this.hasPermission(user, permission)) {
      throw new HTTPException(403, { 
        message: `Insufficient permissions. Required: ${permission}` 
      });
    }
  }

  static async enforceResourceAccess(user: User, resource: Resource, action: Action): Promise<void> {
    if (!this.hasResourceAccess(user, resource, action)) {
      throw new HTTPException(403, { 
        message: `Access denied. Cannot ${action.toLowerCase()} ${resource.toLowerCase()}` 
      });
    }
  }

  static async enforceOwnerScope(user: User, ownerId: string): Promise<void> {
    const hasAccess = await this.checkOwnerScope(user, ownerId);
    if (!hasAccess) {
      throw new HTTPException(403, { message: "Access denied - owner scope violation" });
    }
  }

  static async enforceUserAccess(requestingUser: User, targetUserId: string): Promise<void> {
    const hasAccess = await this.checkUserAccess(requestingUser, targetUserId);
    if (!hasAccess) {
      throw new HTTPException(403, { message: "Access denied to user" });
    }
  }

  static async enforceStoreAccess(requestingUser: User, storeId: string): Promise<void> {
    const hasAccess = await this.checkStoreAccess(requestingUser, storeId);
    if (!hasAccess) {
      throw new HTTPException(403, { message: "Access denied to store" });
    }
  }

  static async enforceCategoryAccess(requestingUser: User, categoryId: string): Promise<void> {
    const hasAccess = await this.checkCategoryAccess(requestingUser, categoryId);
    if (!hasAccess) {
      throw new HTTPException(403, { message: "Access denied to category" });
    }
  }

  static async enforceProductAccess(requestingUser: User, productId: string): Promise<void> {
    const hasAccess = await this.checkProductAccess(requestingUser, productId);
    if (!hasAccess) {
      throw new HTTPException(403, { message: "Access denied to product" });
    }
  }

  static async enforceTransactionAccess(requestingUser: User, transactionId: string): Promise<void> {
    const hasAccess = await this.checkTransactionAccess(requestingUser, transactionId);
    if (!hasAccess) {
      throw new HTTPException(403, { message: "Access denied to transaction" });
    }
  }

  static enforceRoleHierarchy(requestingUser: User, targetRole: string): void {
    if (!this.validateRoleHierarchy(requestingUser, targetRole)) {
      throw new HTTPException(403, { 
        message: `Cannot manage users with role: ${targetRole}` 
      });
    }
  }

  static enforceTransactionType(user: User, transactionType: string): void {
    if (!this.validateTransactionType(user, transactionType)) {
      throw new HTTPException(403, { 
        message: `Role ${user.role} can only create SALE transactions` 
      });
    }
  }
}