import { createMiddleware } from "hono/factory";
import { HTTPException } from "hono/http-exception";
import { AuthorizationService, Permission, Resource, Action } from "../services/authorization.service";
import type { Applications } from "../http/hono";
import type { User } from "../models/users";
import { getValidated } from "../utils/context";

export const requirePermission = (permission: Permission) => {
  return createMiddleware<Applications>(async (c, next) => {
    const user: User = c.get("user");
    await AuthorizationService.enforcePermission(user, permission);
    await next();
  });
};

export const requireResourceAccess = (resource: Resource, action: Action) => {
  return createMiddleware<Applications>(async (c, next) => {
    const user: User = c.get("user");
    await AuthorizationService.enforceResourceAccess(user, resource, action);
    await next();
  });
};

export const requireOwnerScope = (ownerIdExtractor: (c: any) => string) => {
  return createMiddleware<Applications>(async (c, next) => {
    const user: User = c.get("user");
    const ownerId = ownerIdExtractor(c);
    await AuthorizationService.enforceOwnerScope(user, ownerId);
    await next();
  });
};

export const requireUserAccess = (userIdExtractor: (c: any) => string) => {
  return createMiddleware<Applications>(async (c, next) => {
    const user: User = c.get("user");
    const targetUserId = userIdExtractor(c);
    await AuthorizationService.enforceUserAccess(user, targetUserId);
    await next();
  });
};

export const requireStoreAccess = (storeIdExtractor: (c: any) => string) => {
  return createMiddleware<Applications>(async (c, next) => {
    const user: User = c.get("user");
    const storeId = storeIdExtractor(c);
    await AuthorizationService.enforceStoreAccess(user, storeId);
    await next();
  });
};

export const requireCategoryAccess = (categoryIdExtractor: (c: any) => string) => {
  return createMiddleware<Applications>(async (c, next) => {
    const user: User = c.get("user");
    const categoryId = categoryIdExtractor(c);
    await AuthorizationService.enforceCategoryAccess(user, categoryId);
    await next();
  });
};

export const requireProductAccess = (productIdExtractor: (c: any) => string) => {
  return createMiddleware<Applications>(async (c, next) => {
    const user: User = c.get("user");
    const productId = productIdExtractor(c);
    await AuthorizationService.enforceProductAccess(user, productId);
    await next();
  });
};

export const requireTransactionAccess = (transactionIdExtractor: (c: any) => string) => {
  return createMiddleware<Applications>(async (c, next) => {
    const user: User = c.get("user");
    const transactionId = transactionIdExtractor(c);
    await AuthorizationService.enforceTransactionAccess(user, transactionId);
    await next();
  });
};

export const requireRoleHierarchy = (targetRoleExtractor: (c: any) => string) => {
  return createMiddleware<Applications>(async (c, next) => {
    const user: User = c.get("user");
    const targetRole = targetRoleExtractor(c);
    AuthorizationService.enforceRoleHierarchy(user, targetRole);
    await next();
  });
};

export const requireOwnerRole = () => {
  return createMiddleware<Applications>(async (c, next) => {
    const user: User = c.get("user");
    if (user.role !== "OWNER") {
      throw new HTTPException(403, { message: "Only OWNER can perform this action" });
    }
    await next();
  });
};

export const requireOwnerOrAdmin = () => {
  return createMiddleware<Applications>(async (c, next) => {
    const user: User = c.get("user");
    if (user.role !== "OWNER" && user.role !== "ADMIN") {
      throw new HTTPException(403, { message: "Only OWNER or ADMIN can perform this action" });
    }
    await next();
  });
};

export const requireMinRole = (minRole: "OWNER" | "ADMIN" | "STAFF" | "CASHIER") => {
  return createMiddleware<Applications>(async (c, next) => {
    const user: User = c.get("user");
    const roleHierarchy = ["OWNER", "ADMIN", "STAFF", "CASHIER"];
    const userRoleLevel = roleHierarchy.indexOf(user.role);
    const minRoleLevel = roleHierarchy.indexOf(minRole);
    
    if (userRoleLevel === -1 || userRoleLevel > minRoleLevel) {
      throw new HTTPException(403, { message: `Insufficient role. Required: ${minRole} or higher` });
    }
    await next();
  });
};

export const requireTransactionType = (transactionTypeExtractor: (c: any) => string) => {
  return createMiddleware<Applications>(async (c, next) => {
    const user: User = c.get("user");
    const transactionType = transactionTypeExtractor(c);
    AuthorizationService.enforceTransactionType(user, transactionType);
    await next();
  });
};

// Helper middleware creators for common patterns
export const createPermissionMiddleware = (permission: Permission) => requirePermission(permission);
export const createResourceMiddleware = (resource: Resource, action: Action) => requireResourceAccess(resource, action);

// Extractors for common use cases
export const extractParamId = (paramName: string) => (c: any) => c.req.param(paramName);
export const extractBodyField = (fieldName: string) => (c: any) => c.get("validatedBody")[fieldName];
export const extractQueryField = (fieldName: string) => (c: any) => c.req.query(fieldName);

// Common middleware combinations
export const requireUserManagement = () => requirePermission("CREATE_USER");
export const requireStoreManagement = () => requirePermission("CREATE_STORE");
export const requireProductManagement = () => requireResourceAccess("PRODUCT", "CREATE");
export const requireTransactionManagement = () => requireResourceAccess("TRANSACTION", "CREATE");

// Specific role-based middleware for common patterns
export const requireAdminCanOnlyCreateStaff = () => {
  return createMiddleware<Applications>(async (c, next) => {
    const user: User = c.get("user");
    const data = getValidated<any>(c, "validatedBody");
    
    if (user.role === "ADMIN" && data.role !== "STAFF") {
      throw new HTTPException(403, { message: "Admin can only create STAFF users" });
    }
    await next();
  });
};

export const requireAdminCanOnlySetStaffRole = () => {
  return createMiddleware<Applications>(async (c, next) => {
    const user: User = c.get("user");
    const data = getValidated<any>(c, "validatedBody");
    
    if (data.role && user.role === "ADMIN" && data.role !== "STAFF") {
      throw new HTTPException(403, { message: "Admin can only set role to STAFF" });
    }
    await next();
  });
};

export const requireStaffCannotCreateUsers = () => {
  return createMiddleware<Applications>(async (c, next) => {
    const user: User = c.get("user");
    
    if (user.role === "STAFF" || user.role === "CASHIER") {
      throw new HTTPException(403, { message: "STAFF and CASHIER cannot create users" });
    }
    await next();
  });
};