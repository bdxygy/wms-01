/**
 * Auth Repository - Authentication data access layer
 * Handles authentication-specific database operations including user lookup,
 * password verification, and session management
 */

import { and, eq } from "drizzle-orm";
import { db } from "../config/database";
import { users, type User } from "../models/users";
import { DatabaseUtils } from "../utils/database";
import {
  InternalServerError,
  NotFoundError,
  AuthenticationError,
} from "../utils/errors";

/**
 * Authentication repository interface for data persistence operations
 */
export interface IAuthRepository {
  // User authentication operations
  findUserByUsername(username: string): Promise<User | null>;
  findUserByUsernameOrThrow(username: string): Promise<User>;
  findActiveUserById(id: string): Promise<User | null>;
  findActiveUserByIdOrThrow(id: string): Promise<User>;
  
  // Password verification (repository level - raw data access)
  getUserPasswordHash(username: string): Promise<string | null>;
  
  // User activation/deactivation
  updateUserActiveStatus(id: string, isActive: boolean, tx?: any): Promise<User>;
  
  // Owner hierarchy validation for authentication
  validateUserInOwnerHierarchy(userId: string, ownerId: string): Promise<boolean>;
  
  // Authentication session data
  updateUserLastLogin(id: string, tx?: any): Promise<void>;
}

/**
 * Auth repository implementation
 */
export class AuthRepository implements IAuthRepository {
  /**
   * Finds an active user by username (case-insensitive)
   */
  async findUserByUsername(username: string): Promise<User | null> {
    try {
      const result = await db
        .select()
        .from(users)
        .where(
          and(
            eq(users.username, username),
            DatabaseUtils.activeScope(users),
            eq(users.isActive, true)
          )
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
   * Finds an active user by username or throws NotFoundError
   */
  async findUserByUsernameOrThrow(username: string): Promise<User> {
    const user = await this.findUserByUsername(username);
    if (!user) {
      throw new AuthenticationError("Invalid username or password");
    }
    return user;
  }

  /**
   * Finds an active user by ID
   */
  async findActiveUserById(id: string): Promise<User | null> {
    try {
      const result = await db
        .select()
        .from(users)
        .where(
          and(
            eq(users.id, id),
            DatabaseUtils.activeScope(users),
            eq(users.isActive, true)
          )
        )
        .limit(1);

      return result[0] || null;
    } catch (error) {
      throw new InternalServerError(
        "Failed to find user by ID",
        error instanceof Error ? error : undefined
      );
    }
  }

  /**
   * Finds an active user by ID or throws NotFoundError
   */
  async findActiveUserByIdOrThrow(id: string): Promise<User> {
    const user = await this.findActiveUserById(id);
    if (!user) {
      throw new AuthenticationError("User not found or inactive");
    }
    return user;
  }

  /**
   * Gets user password hash for authentication (security-focused)
   */
  async getUserPasswordHash(username: string): Promise<string | null> {
    try {
      const result = await db
        .select()
        .from(users)
        .where(
          and(
            eq(users.username, username),
            DatabaseUtils.activeScope(users),
            eq(users.isActive, true)
          )
        )
        .limit(1);

      return result[0]?.passwordHash || null;
    } catch (error) {
      throw new InternalServerError(
        "Failed to retrieve user password hash",
        error instanceof Error ? error : undefined
      );
    }
  }

  /**
   * Updates user active status (for account activation/deactivation)
   */
  async updateUserActiveStatus(
    id: string,
    isActive: boolean,
    tx?: any
  ): Promise<User> {
    const dbInstance = tx || db;

    try {
      // Verify user exists (including inactive users for reactivation)
      const existingUser = await db
        .select()
        .from(users)
        .where(and(eq(users.id, id), DatabaseUtils.activeScope(users)))
        .limit(1);

      if (!existingUser[0]) {
        throw new NotFoundError("User");
      }

      const [updatedUser] = await dbInstance
        .update(users)
        .set({
          isActive,
          updatedAt: DatabaseUtils.now(),
        })
        .where(and(eq(users.id, id), DatabaseUtils.activeScope(users)))
        .returning();

      if (!updatedUser) {
        throw new NotFoundError("User");
      }

      return updatedUser;
    } catch (error) {
      if (error instanceof NotFoundError) {
        throw error;
      }
      throw new InternalServerError(
        "Failed to update user active status",
        error instanceof Error ? error : undefined
      );
    }
  }

  /**
   * Validates that a user belongs to the owner hierarchy for authentication
   */
  async validateUserInOwnerHierarchy(
    userId: string,
    ownerId: string
  ): Promise<boolean> {
    try {
      const user = await this.findActiveUserById(userId);
      if (!user) {
        return false;
      }

      // User belongs to owner hierarchy if:
      // 1. User is the owner themselves (user.id === ownerId), OR
      // 2. User's ownerId matches the provided ownerId (user.ownerId === ownerId)
      return user.id === ownerId || user.ownerId === ownerId;
    } catch (error) {
      throw new InternalServerError(
        "Failed to validate user in owner hierarchy",
        error instanceof Error ? error : undefined
      );
    }
  }

  /**
   * Updates user's last login timestamp (for session tracking)
   */
  async updateUserLastLogin(id: string, tx?: any): Promise<void> {
    const dbInstance = tx || db;

    try {
      await dbInstance
        .update(users)
        .set({
          updatedAt: DatabaseUtils.now(), // Using updatedAt as last activity indicator
        })
        .where(
          and(
            eq(users.id, id),
            DatabaseUtils.activeScope(users),
            eq(users.isActive, true)
          )
        );
    } catch (error) {
      throw new InternalServerError(
        "Failed to update user last login",
        error instanceof Error ? error : undefined
      );
    }
  }

  /**
   * Gets user with role and owner information for JWT payload
   */
  async getUserForToken(id: string): Promise<{
    id: string;
    username: string;
    role: string;
    ownerId: string | null;
    isActive: boolean;
  } | null> {
    try {
      const result = await db
        .select()
        .from(users)
        .where(
          and(
            eq(users.id, id),
            DatabaseUtils.activeScope(users),
            eq(users.isActive, true)
          )
        )
        .limit(1);

      if (!result[0]) {
        return null;
      }

      // Ensure isActive is boolean (handle potential null from database)
      const user = result[0];
      return {
        id: user.id,
        username: user.username,
        role: user.role,
        ownerId: user.ownerId,
        isActive: Boolean(user.isActive),
      };
    } catch (error) {
      throw new InternalServerError(
        "Failed to get user for token",
        error instanceof Error ? error : undefined
      );
    }
  }

  /**
   * Validates if user can authenticate based on role and status
   */
  async canUserAuthenticate(id: string): Promise<boolean> {
    try {
      const result = await db
        .select()
        .from(users)
        .where(eq(users.id, id))
        .limit(1);

      if (!result[0]) {
        return false;
      }

      const user = result[0];
      // User can authenticate if they are active and not soft-deleted
      return Boolean(user.isActive) && !user.deletedAt;
    } catch (error) {
      throw new InternalServerError(
        "Failed to validate user authentication eligibility",
        error instanceof Error ? error : undefined
      );
    }
  }

  /**
   * Gets owner ID for a user (used for owner-scoped operations)
   */
  async getUserOwnerId(userId: string): Promise<string | null> {
    try {
      const result = await db
        .select()
        .from(users)
        .where(
          and(
            eq(users.id, userId),
            DatabaseUtils.activeScope(users),
            eq(users.isActive, true)
          )
        )
        .limit(1);

      if (!result[0]) {
        return null;
      }

      // If user has ownerId, return it; if user IS the owner (no ownerId), return their own ID
      return result[0].ownerId || result[0].id;
    } catch (error) {
      throw new InternalServerError(
        "Failed to get user owner ID",
        error instanceof Error ? error : undefined
      );
    }
  }
}

/**
 * Singleton instance of AuthRepository
 */
export const authRepository = new AuthRepository();