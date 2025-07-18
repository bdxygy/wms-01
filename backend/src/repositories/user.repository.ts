/**
 * User Repository - Data persistence layer
 * Handles user CRUD operations, owner association management, and role-based data filtering
 */

import { and, desc, eq, sql } from "drizzle-orm";
import { db } from "../config/database";
import { users, type NewUser, type User } from "../models/users";
import { DatabaseUtils } from "../utils/database";
import {
  ConflictError,
  InternalServerError,
  NotFoundError,
  ValidationError,
} from "../utils/errors";

/**
 * User repository interface for data persistence operations
 */
export interface IUserRepository {
  // Create operations
  create(userData: NewUser, tx?: any): Promise<User>;

  // Read operations
  findById(id: string, ownerId?: string): Promise<User | null>;
  findByIdOrThrow(id: string, ownerId?: string): Promise<User>;
  findByUsername(username: string): Promise<User | null>;
  findAll(ownerId: string, options?: ListUsersOptions): Promise<User[]>;
  count(ownerId: string, options?: CountUsersOptions): Promise<number>;

  // Update operations
  update(
    id: string,
    userData: Partial<User>,
    ownerId?: string,
    tx?: any
  ): Promise<User>;

  // Delete operations
  softDelete(id: string, ownerId?: string, tx?: any): Promise<void>;

  // Owner operations
  validateOwnerHierarchy(userId: string, ownerId: string): Promise<boolean>;

  // Validation operations
  validateUsernameUnique(username: string, excludeId?: string): Promise<void>;
}

/**
 * Options for listing users with filtering and pagination
 */
export interface ListUsersOptions {
  search?: string;
  searchName?: string;
  searchUsername?: string;
  searchRole?: string;
  isActive?: boolean;
  limit?: number;
  offset?: number;
  orderBy?: "name" | "username" | "createdAt" | "role";
  orderDirection?: "asc" | "desc";
}

/**
 * Options for counting users with filtering
 */
export interface CountUsersOptions {
  search?: string;
  searchName?: string;
  searchUsername?: string;
  searchRole?: string;
  isActive?: boolean;
}

/**
 * User repository implementation
 */
export class UserRepository implements IUserRepository {
  /**
   * Creates a new user record
   */
  async create(userData: NewUser, tx?: any): Promise<User> {
    const dbInstance = tx || db;

    try {
      // Validate username uniqueness
      await this.validateUsernameUnique(userData.username);

      // Validate owner exists if provided
      if (userData.ownerId) {
        await DatabaseUtils.validateForeignKeys([
          { table: users, id: userData.ownerId, name: "Owner" },
        ]);
      }

      // Generate ID if not provided
      const userWithId = {
        ...userData,
        id: userData.id || DatabaseUtils.generateId(),
        createdAt: userData.createdAt || DatabaseUtils.now(),
        updatedAt: userData.updatedAt || DatabaseUtils.now(),
      };

      const [newUser] = await dbInstance
        .insert(users)
        .values(userWithId)
        .returning();

      if (!newUser) {
        throw new InternalServerError("Failed to create user");
      }

      return newUser;
    } catch (error) {
      if (
        error instanceof NotFoundError ||
        error instanceof ConflictError ||
        error instanceof ValidationError
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
   * Finds a user by ID with optional owner scope validation
   */
  async findById(id: string, ownerId?: string): Promise<User | null> {
    try {
      let query = db
        .select()
        .from(users)
        .where(and(eq(users.id, id), DatabaseUtils.activeScope(users)))
        .limit(1);

      // Add owner scope if provided
      if (ownerId) {
        query = db
          .select()
          .from(users)
          .where(
            and(
              eq(users.id, id),
              DatabaseUtils.ownerActiveScope(users, ownerId)
            )
          )
          .limit(1);
      }

      const result = await query;
      return result[0] || null;
    } catch (error) {
      throw new InternalServerError(
        "Failed to find user",
        error instanceof Error ? error : undefined
      );
    }
  }

  /**
   * Finds a user by ID or throws NotFoundError
   */
  async findByIdOrThrow(id: string, ownerId?: string): Promise<User> {
    const user = await this.findById(id, ownerId);
    if (!user) {
      throw new NotFoundError("User");
    }
    return user;
  }

  /**
   * Finds a user by username (for authentication)
   */
  async findByUsername(username: string): Promise<User | null> {
    try {
      const result = await db
        .select()
        .from(users)
        .where(
          and(eq(users.username, username), DatabaseUtils.activeScope(users))
        )
        .limit(1);

      return result[0] || null;
    } catch (error) {
      throw new InternalServerError(
        "Failed to find user by username",
        error instanceof Error ? error : undefined
      );
    }
  }

  /**
   * Lists users with filtering, searching, and pagination
   */
  async findAll(
    ownerId: string,
    options: ListUsersOptions = {}
  ): Promise<User[]> {
    try {
      const {
        search,
        searchName,
        searchUsername,
        searchRole,
        isActive,
        limit = 10,
        offset = 0,
        orderBy = "createdAt",
        orderDirection = "desc",
      } = options;

      // Start with owner-scoped base query
      let query: any = db
        .select()
        .from(users)
        .where(DatabaseUtils.ownerActiveScope(users, ownerId));

      // Apply filters
      const conditions = [DatabaseUtils.ownerActiveScope(users, ownerId)];

      // Global search (searches across name, username, and role)
      if (search) {
        conditions.push(
          sql`(${users.name} LIKE ${`%${search}%`} OR ${
            users.username
          } LIKE ${`%${search}%`} OR ${users.role} LIKE ${`%${search}%`})`
        );
      }

      // Specific field searches
      if (searchName) {
        conditions.push(sql`${users.name} LIKE ${`%${searchName}%`}`);
      }

      if (searchUsername) {
        conditions.push(sql`${users.username} LIKE ${`%${searchUsername}%`}`);
      }

      if (searchRole) {
        conditions.push(eq(users.role, searchRole as any));
      }

      if (isActive !== undefined) {
        conditions.push(eq(users.isActive, isActive));
      }

      // Build final query with all conditions
      query = db
        .select()
        .from(users)
        .where(and(...conditions));

      // Apply ordering
      if (orderBy === "name") {
        query =
          orderDirection === "desc"
            ? query.orderBy(desc(users.name))
            : query.orderBy(users.name);
      } else if (orderBy === "username") {
        query =
          orderDirection === "desc"
            ? query.orderBy(desc(users.username))
            : query.orderBy(users.username);
      } else if (orderBy === "role") {
        query =
          orderDirection === "desc"
            ? query.orderBy(desc(users.role))
            : query.orderBy(users.role);
      } else {
        query =
          orderDirection === "desc"
            ? query.orderBy(desc(users.createdAt))
            : query.orderBy(users.createdAt);
      }

      // Apply pagination
      query = DatabaseUtils.paginate(query, offset, limit);

      return await query;
    } catch (error) {
      throw new InternalServerError(
        "Failed to list users",
        error instanceof Error ? error : undefined
      );
    }
  }

  /**
   * Counts users with filtering options
   */
  async count(
    ownerId: string,
    options: CountUsersOptions = {}
  ): Promise<number> {
    try {
      const { search, searchName, searchUsername, searchRole, isActive } =
        options;

      const conditions = [DatabaseUtils.ownerActiveScope(users, ownerId)];

      // Global search (searches across name, username, and role)
      if (search) {
        conditions.push(
          sql`(${users.name} LIKE ${`%${search}%`} OR ${
            users.username
          } LIKE ${`%${search}%`} OR ${users.role} LIKE ${`%${search}%`})`
        );
      }

      // Specific field searches
      if (searchName) {
        conditions.push(sql`${users.name} LIKE ${`%${searchName}%`}`);
      }

      if (searchUsername) {
        conditions.push(sql`${users.username} LIKE ${`%${searchUsername}%`}`);
      }

      if (searchRole) {
        conditions.push(eq(users.role, searchRole as any));
      }

      if (isActive !== undefined) {
        conditions.push(eq(users.isActive, isActive));
      }

      const result = await db
        // @ts-ignore
        .select({ count: sql<number>`count(*)` })
        .from(users)
        .where(and(...conditions));

      // @ts-ignore
      return result[0]?.count || 0;
    } catch (error) {
      throw new InternalServerError(
        "Failed to count users",
        error instanceof Error ? error : undefined
      );
    }
  }

  /**
   * Updates a user record
   */
  async update(
    id: string,
    userData: Partial<User>,
    ownerId?: string,
    tx?: any
  ): Promise<User> {
    const dbInstance = tx || db;

    try {
      // Verify user exists and is accessible
      await this.findByIdOrThrow(id, ownerId);

      // Validate username uniqueness if changing username
      if (userData.username) {
        await this.validateUsernameUnique(userData.username, id);
      }

      // Validate owner exists if changing ownerId
      if (userData.ownerId) {
        await DatabaseUtils.validateForeignKeys([
          { table: users, id: userData.ownerId, name: "Owner" },
        ]);
      }

      // Prepare update data
      const updateData = {
        ...userData,
        updatedAt: DatabaseUtils.now(),
      };

      // Remove undefined values
      const cleanUpdateData = Object.fromEntries(
        Object.entries(updateData).filter(([_, value]) => value !== undefined)
      );

      // Build update conditions
      const conditions = [eq(users.id, id), DatabaseUtils.activeScope(users)];
      if (ownerId) {
        conditions.push(DatabaseUtils.ownerScope(users, ownerId));
      }

      const [updatedUser] = await dbInstance
        .update(users)
        .set(cleanUpdateData)
        .where(and(...conditions))
        .returning();

      if (!updatedUser) {
        throw new NotFoundError("User");
      }

      return updatedUser;
    } catch (error) {
      if (
        error instanceof NotFoundError ||
        error instanceof ConflictError ||
        error instanceof ValidationError
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
   * Soft deletes a user (sets deletedAt timestamp)
   */
  async softDelete(id: string, ownerId?: string, tx?: any): Promise<void> {
    const dbInstance = tx || db;

    try {
      // Verify user exists and is accessible
      await this.findByIdOrThrow(id, ownerId);

      // Build delete conditions
      const conditions = [eq(users.id, id), DatabaseUtils.activeScope(users)];
      if (ownerId) {
        conditions.push(DatabaseUtils.ownerScope(users, ownerId));
      }

      await dbInstance
        .update(users)
        .set({
          deletedAt: DatabaseUtils.now(),
          updatedAt: DatabaseUtils.now(),
        })
        .where(and(...conditions));

      // Verify deletion succeeded by checking if user still exists
      const userStillExists = await this.findById(id, ownerId);
      if (userStillExists) {
        throw new NotFoundError("User");
      }
    } catch (error) {
      if (error instanceof NotFoundError) {
        throw error;
      }
      throw new InternalServerError(
        "Failed to delete user",
        error instanceof Error ? error : undefined
      );
    }
  }

  /**
   * Validates that a user belongs to the owner hierarchy
   */
  async validateOwnerHierarchy(
    userId: string,
    ownerId: string
  ): Promise<boolean> {
    try {
      const user = await this.findById(userId);
      if (!user) {
        return false;
      }

      // User belongs to owner hierarchy if:
      // 1. User is the owner themselves, OR
      // 2. User's ownerId matches the provided ownerId
      return user.id === ownerId || user.ownerId === ownerId;
    } catch (error) {
      throw new InternalServerError(
        "Failed to validate owner hierarchy",
        error instanceof Error ? error : undefined
      );
    }
  }

  /**
   * Validates that username is unique (excluding a specific user ID)
   */
  async validateUsernameUnique(
    username: string,
    excludeId?: string
  ): Promise<void> {
    try {
      const conditions = [
        eq(users.username, username),
        DatabaseUtils.activeScope(users),
      ];

      if (excludeId) {
        conditions.push(sql`${users.id} != ${excludeId}`);
      }

      const existingUser = await db
        // @ts-ignore
        .select({ id: users.id })
        .from(users)
        .where(and(...conditions))
        .limit(1);

      if (existingUser.length > 0) {
        throw new ConflictError("Username already exists");
      }
    } catch (error) {
      if (error instanceof ConflictError) {
        throw error;
      }
      throw new InternalServerError(
        "Failed to validate username uniqueness",
        error instanceof Error ? error : undefined
      );
    }
  }
}

/**
 * Singleton instance of UserRepository
 */
export const userRepository = new UserRepository();
