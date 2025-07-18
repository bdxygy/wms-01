/**
 * User Service - Business logic layer
 * Handles user operations, role validation, authentication, and owner hierarchy management
 */

import { hashPassword, verifyPassword } from "../utils/auth";
import {
  ValidationError,
  AuthenticationError,
  AuthorizationError,
  ConflictError,
  NotFoundError,
  InternalServerError,
} from "../utils/errors";
import { DatabaseUtils, DatabaseTransactionUtils } from "../utils/database";
import {
  userRepository,
  type IUserRepository,
  type ListUsersOptions,
  type CountUsersOptions,
} from "../repositories/user.repository";
import { users, type NewUser, type User, type Role } from "../models/users";

/**
 * Interface for user creation data
 */
export interface CreateUserData {
  name: string;
  username: string;
  password: string;
  role: Role;
  ownerId?: string;
  isActive?: boolean;
}

/**
 * Interface for user update data
 */
export interface UpdateUserData {
  name?: string;
  username?: string;
  password?: string;
  role?: Role;
  ownerId?: string;
  isActive?: boolean;
}

/**
 * Interface for user authentication
 */
export interface AuthenticateUserData {
  username: string;
  password: string;
}

/**
 * Interface for user authentication result
 */
export interface AuthenticationResult {
  user: Omit<User, "passwordHash">;
  token?: string;
}

/**
 * Interface for paginated user listing
 */
export interface PaginatedUsers {
  data: Omit<User, "passwordHash">[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
    hasNext: boolean;
    hasPrev: boolean;
  };
}

/**
 * User service interface for business logic operations
 */
export interface IUserService {
  // User creation and authentication
  create(
    userData: CreateUserData,
    createdBy?: string
  ): Promise<Omit<User, "passwordHash">>;
  authenticate(
    credentials: AuthenticateUserData
  ): Promise<AuthenticationResult>;

  // User retrieval
  findById(
    id: string,
    currentUserId?: string,
    currentUserRole?: Role
  ): Promise<Omit<User, "passwordHash">>;
  findByUsername(username: string): Promise<Omit<User, "passwordHash"> | null>;
  list(
    currentUserId: string,
    currentUserRole: Role,
    options?: ListUsersOptions
  ): Promise<PaginatedUsers>;

  // User management
  update(
    id: string,
    userData: UpdateUserData,
    currentUserId: string,
    currentUserRole: Role
  ): Promise<Omit<User, "passwordHash">>;
  delete(
    id: string,
    currentUserId: string,
    currentUserRole: Role
  ): Promise<void>;

  // Role and permission validation
  validateUserPermissions(
    currentUserId: string,
    currentUserRole: Role,
    targetUserId: string,
    operation: "read" | "update" | "delete"
  ): Promise<void>;
  validateRoleHierarchy(currentRole: Role, targetRole: Role): boolean;

  // Owner hierarchy management
  getOwnerIdForUser(userId: string): Promise<string>;
  validateOwnerAccess(userId: string, ownerId: string): Promise<boolean>;
}

/**
 * User service implementation
 */
export class UserService implements IUserService {
  constructor(private readonly userRepo: IUserRepository = userRepository) {}

  /**
   * Creates a new user with proper role validation and owner hierarchy
   */
  async create(
    userData: CreateUserData,
    createdBy?: string
  ): Promise<Omit<User, "passwordHash">> {
    try {
      // Validate input data
      this.validateCreateUserData(userData);

      // Validate role hierarchy if createdBy is provided
      if (createdBy) {
        const creatingUser = await this.userRepo.findByIdOrThrow(createdBy);
        if (
          !this.validateRoleHierarchy(creatingUser.role as Role, userData.role)
        ) {
          throw new AuthorizationError(
            `Users with role ${creatingUser.role} cannot create users with role ${userData.role}`
          );
        }

        // For non-OWNER roles, set the ownerId to the creating user's owner
        if (userData.role !== "OWNER") {
          userData.ownerId =
            creatingUser.role === "OWNER"
              ? creatingUser.id!
              : creatingUser.ownerId!;
        }
      }

      // Hash password
      const passwordHash = await hashPassword(userData.password);

      // Prepare user data for creation
      const newUserData: NewUser = {
        id: DatabaseUtils.generateId(),
        name: userData.name,
        username: userData.username,
        passwordHash,
        role: userData.role,
        ownerId: userData.ownerId || null,
        isActive: userData.isActive ?? true,
        createdAt: DatabaseUtils.now(),
        updatedAt: DatabaseUtils.now(),
      };

      // Create user in transaction
      const user = await DatabaseTransactionUtils.executeTransaction(
        async (tx) => {
          return await this.userRepo.create(newUserData, tx);
        }
      );

      // Return user without password hash
      return this.excludePasswordHash(user);
    } catch (error) {
      if (
        error instanceof ValidationError ||
        error instanceof AuthorizationError ||
        error instanceof ConflictError
      ) {
        throw error;
      }
      throw new InternalServerError(
        "Failed to create user",
        error instanceof Error ? error : undefined
      );
    }
  }

  /**
   * Authenticates a user with username and password
   */
  async authenticate(
    credentials: AuthenticateUserData
  ): Promise<AuthenticationResult> {
    try {
      // Validate credentials
      if (!credentials.username || !credentials.password) {
        throw new ValidationError("Username and password are required");
      }

      // Find user by username
      const user = await this.userRepo.findByUsername(credentials.username);
      if (!user) {
        throw new AuthenticationError("Invalid username or password");
      }

      // Check if user is active
      if (!user.isActive) {
        throw new AuthenticationError("User account is deactivated");
      }

      // Verify password
      const isPasswordValid = await verifyPassword(
        credentials.password,
        user.passwordHash
      );
      if (!isPasswordValid) {
        throw new AuthenticationError("Invalid username or password");
      }

      return {
        user: this.excludePasswordHash(user),
      };
    } catch (error) {
      if (
        error instanceof AuthenticationError ||
        error instanceof ValidationError
      ) {
        throw error;
      }
      throw new InternalServerError(
        "Authentication failed",
        error instanceof Error ? error : undefined
      );
    }
  }

  /**
   * Finds a user by ID with permission validation
   */
  async findById(
    id: string,
    currentUserId?: string,
    currentUserRole?: Role
  ): Promise<Omit<User, "passwordHash">> {
    try {
      // Validate permissions if current user context is provided
      if (currentUserId && currentUserRole) {
        await this.validateUserPermissions(
          currentUserId,
          currentUserRole,
          id,
          "read"
        );
      }

      // Get owner ID for scoping
      const ownerId = currentUserId
        ? await this.getOwnerIdForUser(currentUserId)
        : undefined;

      const user = await this.userRepo.findByIdOrThrow(id, ownerId);
      return this.excludePasswordHash(user);
    } catch (error) {
      if (
        error instanceof NotFoundError ||
        error instanceof AuthorizationError
      ) {
        throw error;
      }
      throw new InternalServerError(
        "Failed to find user",
        error instanceof Error ? error : undefined
      );
    }
  }

  /**
   * Finds a user by username (public method for authentication)
   */
  async findByUsername(
    username: string
  ): Promise<Omit<User, "passwordHash"> | null> {
    try {
      const user = await this.userRepo.findByUsername(username);
      return user ? this.excludePasswordHash(user) : null;
    } catch (error) {
      throw new InternalServerError(
        "Failed to find user by username",
        error instanceof Error ? error : undefined
      );
    }
  }

  /**
   * Lists users with role-based filtering and pagination
   */
  async list(
    currentUserId: string,
    currentUserRole: Role,
    options: ListUsersOptions = {}
  ): Promise<PaginatedUsers> {
    try {
      // Get owner ID for scoping
      const ownerId = await this.getOwnerIdForUser(currentUserId);

      // Set default pagination
      const page = Math.max(
        1,
        Math.floor((options.offset || 0) / (options.limit || 10)) + 1
      );
      const limit = Math.min(100, Math.max(1, options.limit || 10)); // Max 100 items per page
      const offset = (page - 1) * limit;

      // Get users and total count
      const [users, total] = await Promise.all([
        this.userRepo.findAll(ownerId, { ...options, limit, offset }),
        this.userRepo.count(ownerId, {
          search: options.search,
          searchName: options.searchName,
          searchUsername: options.searchUsername,
          searchRole: options.searchRole,
          isActive: options.isActive,
        }),
      ]);

      // Calculate pagination metadata
      const totalPages = Math.ceil(total / limit);
      const hasNext = page < totalPages;
      const hasPrev = page > 1;

      return {
        data: users.map((user) => this.excludePasswordHash(user)),
        pagination: {
          page,
          limit,
          total,
          totalPages,
          hasNext,
          hasPrev,
        },
      };
    } catch (error) {
      throw new InternalServerError(
        "Failed to list users",
        error instanceof Error ? error : undefined
      );
    }
  }

  /**
   * Updates a user with permission validation
   */
  async update(
    id: string,
    userData: UpdateUserData,
    currentUserId: string,
    currentUserRole: Role
  ): Promise<Omit<User, "passwordHash">> {
    try {
      // Validate permissions
      await this.validateUserPermissions(
        currentUserId,
        currentUserRole,
        id,
        "update"
      );

      // Validate role hierarchy if role is being changed
      if (userData.role) {
        if (!this.validateRoleHierarchy(currentUserRole, userData.role)) {
          throw new AuthorizationError(
            `Users with role ${currentUserRole} cannot assign role ${userData.role}`
          );
        }
      }

      // Get owner ID for scoping
      const ownerId = await this.getOwnerIdForUser(currentUserId);

      const { password, ...shouldUpdateData } = userData;

      // Prepare update data
      const updateData: Partial<User> = { ...shouldUpdateData };

      // Hash password if provided
      if (password) {
        updateData.passwordHash = await hashPassword(password);
      }

      // Update user in transaction
      const updatedUser = await DatabaseTransactionUtils.executeTransaction(
        async (tx) => {
          return await this.userRepo.update(id, updateData, ownerId, tx);
        }
      );

      return this.excludePasswordHash(updatedUser);
    } catch (error) {
      if (
        error instanceof NotFoundError ||
        error instanceof AuthorizationError ||
        error instanceof ValidationError ||
        error instanceof ConflictError
      ) {
        throw error;
      }
      throw new InternalServerError(
        "Failed to update user",
        error instanceof Error ? error : undefined
      );
    }
  }

  /**
   * Soft deletes a user with permission validation
   */
  async delete(
    id: string,
    currentUserId: string,
    currentUserRole: Role
  ): Promise<void> {
    try {
      // Validate permissions
      await this.validateUserPermissions(
        currentUserId,
        currentUserRole,
        id,
        "delete"
      );

      // Prevent users from deleting themselves
      if (id === currentUserId) {
        throw new ValidationError("Users cannot delete themselves");
      }

      // Get owner ID for scoping
      const ownerId = await this.getOwnerIdForUser(currentUserId);

      // Soft delete user in transaction
      await DatabaseTransactionUtils.executeTransaction(async (tx) => {
        await this.userRepo.softDelete(id, ownerId, tx);
      });
    } catch (error) {
      if (
        error instanceof NotFoundError ||
        error instanceof AuthorizationError ||
        error instanceof ValidationError
      ) {
        throw error;
      }
      throw new InternalServerError(
        "Failed to delete user",
        error instanceof Error ? error : undefined
      );
    }
  }

  /**
   * Validates user permissions for operations
   */
  async validateUserPermissions(
    currentUserId: string,
    currentUserRole: Role,
    targetUserId: string,
    operation: "read" | "update" | "delete"
  ): Promise<void> {
    try {
      // OWNER can access all users in their hierarchy
      if (currentUserRole === "OWNER") {
        const isInHierarchy = await this.userRepo.validateOwnerHierarchy(
          targetUserId,
          currentUserId
        );
        if (!isInHierarchy) {
          throw new AuthorizationError("User not found in your organization");
        }
        return;
      }

      // ADMIN can only read/update users, cannot delete
      if (currentUserRole === "ADMIN") {
        if (operation === "delete") {
          throw new AuthorizationError("Admins cannot delete users");
        }

        // ADMIN can only access users in same owner hierarchy
        const currentUserOwnerId = await this.getOwnerIdForUser(currentUserId);
        const isInHierarchy = await this.userRepo.validateOwnerHierarchy(
          targetUserId,
          currentUserOwnerId
        );
        if (!isInHierarchy) {
          throw new AuthorizationError("User not found in your organization");
        }

        // ADMIN can only manage STAFF and CASHIER roles
        const targetUser = await this.userRepo.findByIdOrThrow(targetUserId);
        if (targetUser.role === "OWNER" || targetUser.role === "ADMIN") {
          throw new AuthorizationError(
            "Admins cannot manage OWNER or ADMIN users"
          );
        }
        return;
      }

      // STAFF and CASHIER can only read their own profile
      if (currentUserRole === "STAFF" || currentUserRole === "CASHIER") {
        if (targetUserId !== currentUserId) {
          throw new AuthorizationError(
            "Insufficient permissions to access other users"
          );
        }

        if (operation === "delete") {
          throw new AuthorizationError("Users cannot delete their own account");
        }
        return;
      }

      throw new AuthorizationError("Invalid user role");
    } catch (error) {
      if (error instanceof AuthorizationError) {
        throw error;
      }
      throw new InternalServerError(
        "Failed to validate user permissions",
        error instanceof Error ? error : undefined
      );
    }
  }

  /**
   * Validates role hierarchy for user creation/updates
   */
  validateRoleHierarchy(currentRole: Role, targetRole: Role): boolean {
    const roleHierarchy: Record<Role, Role[]> = {
      OWNER: ["OWNER", "ADMIN", "STAFF", "CASHIER"],
      ADMIN: ["STAFF", "CASHIER"],
      STAFF: [],
      CASHIER: [],
    };

    return roleHierarchy[currentRole]?.includes(targetRole) || false;
  }

  /**
   * Gets the owner ID for a given user
   */
  async getOwnerIdForUser(userId: string): Promise<string> {
    try {
      const user = await this.userRepo.findByIdOrThrow(userId);

      // If user is OWNER, return their own ID
      if (user.role === "OWNER") {
        return user.id;
      }

      // Otherwise, return their ownerId
      if (!user.ownerId) {
        throw new ValidationError("User does not have an owner assigned");
      }

      return user.ownerId;
    } catch (error) {
      if (error instanceof NotFoundError || error instanceof ValidationError) {
        throw error;
      }
      throw new InternalServerError(
        "Failed to get owner ID for user",
        error instanceof Error ? error : undefined
      );
    }
  }

  /**
   * Validates if a user has access to resources owned by a specific owner
   */
  async validateOwnerAccess(userId: string, ownerId: string): Promise<boolean> {
    try {
      const userOwnerId = await this.getOwnerIdForUser(userId);
      return userOwnerId === ownerId;
    } catch (error) {
      return false;
    }
  }

  /**
   * Validates user creation data
   */
  private validateCreateUserData(userData: CreateUserData): void {
    if (!userData.name?.trim()) {
      throw new ValidationError("Name is required");
    }

    if (!userData.username?.trim()) {
      throw new ValidationError("Username is required");
    }

    if (userData.username.length < 3) {
      throw new ValidationError("Username must be at least 3 characters long");
    }

    if (!userData.password) {
      throw new ValidationError("Password is required");
    }

    if (userData.password.length < 6) {
      throw new ValidationError("Password must be at least 6 characters long");
    }

    if (!userData.role) {
      throw new ValidationError("Role is required");
    }

    const validRoles: Role[] = ["OWNER", "ADMIN", "STAFF", "CASHIER"];
    if (!validRoles.includes(userData.role)) {
      throw new ValidationError(
        `Invalid role. Must be one of: ${validRoles.join(", ")}`
      );
    }

    // OWNER role cannot have an ownerId
    if (userData.role === "OWNER" && userData.ownerId) {
      throw new ValidationError("OWNER role cannot have an owner assigned");
    }

    // Non-OWNER roles should have an ownerId (will be set automatically if not provided)
    if (userData.role !== "OWNER" && userData.ownerId === "") {
      throw new ValidationError("Non-OWNER roles must have an owner assigned");
    }
  }

  /**
   * Removes password hash from user object
   */
  private excludePasswordHash(user: User): Omit<User, "passwordHash"> {
    const { passwordHash, ...userWithoutPassword } = user;
    return userWithoutPassword;
  }
}

/**
 * Singleton instance of UserService
 */
export const userService = new UserService();
