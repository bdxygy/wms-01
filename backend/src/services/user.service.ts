import bcrypt from "bcryptjs";
import { randomUUID } from "crypto";
import { db } from "../config/database";
import { users } from "../models/users";
import { eq, and, or, like, isNull, count } from "drizzle-orm";
import { HTTPException } from "hono/http-exception";
import type { CreateUserRequest, UpdateUserRequest, ListUsersQuery } from "../schemas/user.schemas";
import type { User } from "../models/users";

export class UserService {
  static async createUser(data: CreateUserRequest, createdBy: User) {
    // Check if user already exists
    const existingUser = await db
      .select()
      .from(users)
      .where(eq(users.username, data.username));
    
    if (existingUser.length > 0) {
      throw new HTTPException(400, { message: "Username already exists" });
    }


    // Determine owner ID based on creator's role
    let ownerId: string;
    if (createdBy.role === "OWNER") {
      ownerId = createdBy.id;
    } else {
      ownerId = createdBy.ownerId!;
    }

    // Hash password
    const passwordHash = await bcrypt.hash(data.password, 10);

    // Create user
    const userId = randomUUID();
    const user = await db.insert(users).values({
      id: userId,
      name: data.name,
      username: data.username,
      passwordHash,
      role: data.role,
      ownerId,
      isActive: true,
      createdAt: new Date(),
      updatedAt: new Date(),
    }).returning();

    if (!user[0]) {
      throw new HTTPException(500, { message: "Failed to create user" });
    }

    return {
      id: user[0].id,
      name: user[0].name,
      username: user[0].username,
      role: user[0].role,
      ownerId: user[0].ownerId,
      isActive: user[0].isActive,
      createdAt: user[0].createdAt,
      updatedAt: user[0].updatedAt,
    };
  }

  static async getUserById(id: string, requestingUser: User) {
    const user = await db
      .select()
      .from(users)
      .where(eq(users.id, id));

    if (!user[0]) {
      throw new HTTPException(404, { message: "User not found" });
    }


    return {
      id: user[0].id,
      name: user[0].name,
      username: user[0].username,
      role: user[0].role,
      ownerId: user[0].ownerId,
      isActive: user[0].isActive,
      createdAt: user[0].createdAt,
      updatedAt: user[0].updatedAt,
    };
  }

  static async listUsers(query: ListUsersQuery, requestingUser: User) {
    // Build where conditions
    const conditions = [];

    // Owner scoping
    if (requestingUser.role === "OWNER") {
      conditions.push(
        or(
          eq(users.ownerId, requestingUser.id),
          eq(users.id, requestingUser.id)
        )
      );
    } else {
      conditions.push(eq(users.ownerId, requestingUser.ownerId!));
    }

    // Search filter
    if (query.search) {
      conditions.push(
        or(
          like(users.name, `%${query.search}%`),
          like(users.username, `%${query.search}%`)
        )
      );
    }

    // Role filter
    if (query.role) {
      conditions.push(eq(users.role, query.role));
    }

    // Active filter
    if (query.isActive !== undefined) {
      conditions.push(eq(users.isActive, query.isActive));
    }

    // Exclude deleted users
    conditions.push(isNull(users.deletedAt));

    const whereClause = and(...conditions);

    // Get total count
    const totalResult = await db
      .select({ count: count() })
      .from(users)
      .where(whereClause);

    const total = totalResult[0].count;
    const totalPages = Math.ceil(total / query.limit);
    const offset = (query.page - 1) * query.limit;

    // Get users with pagination
    const userList = await db
      .select()
      .from(users)
      .where(whereClause)
      .limit(query.limit)
      .offset(offset)
      .orderBy(users.createdAt);

    const userResponse = userList.map(user => ({
      id: user.id,
      name: user.name,
      username: user.username,
      role: user.role,
      ownerId: user.ownerId,
      isActive: user.isActive,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    }));

    return {
      users: userResponse,
      pagination: {
        page: query.page,
        limit: query.limit,
        total,
        totalPages,
        hasNext: query.page < totalPages,
        hasPrev: query.page > 1,
      },
    };
  }

  static async updateUser(id: string, data: UpdateUserRequest, requestingUser: User) {
    // Find user to update
    const existingUser = await db
      .select()
      .from(users)
      .where(eq(users.id, id));

    if (!existingUser[0]) {
      throw new HTTPException(404, { message: "User not found" });
    }


    // Check username uniqueness if updating username
    if (data.username && data.username !== existingUser[0].username) {
      const usernameExists = await db
        .select()
        .from(users)
        .where(and(
          eq(users.username, data.username),
          eq(users.id, id) // Exclude current user
        ));

      if (usernameExists.length > 0) {
        throw new HTTPException(400, { message: "Username already exists" });
      }
    }

    // Prepare update data
    const updateData: any = {
      updatedAt: new Date(),
    };

    if (data.name) updateData.name = data.name;
    if (data.username) updateData.username = data.username;
    if (data.role) updateData.role = data.role;
    if (data.isActive !== undefined) updateData.isActive = data.isActive;

    // Hash password if provided
    if (data.password) {
      updateData.passwordHash = await bcrypt.hash(data.password, 10);
    }

    // Update user
    const updatedUser = await db
      .update(users)
      .set(updateData)
      .where(eq(users.id, id))
      .returning();

    if (!updatedUser[0]) {
      throw new HTTPException(500, { message: "Failed to update user" });
    }

    return {
      id: updatedUser[0].id,
      name: updatedUser[0].name,
      username: updatedUser[0].username,
      role: updatedUser[0].role,
      ownerId: updatedUser[0].ownerId,
      isActive: updatedUser[0].isActive,
      createdAt: updatedUser[0].createdAt,
      updatedAt: updatedUser[0].updatedAt,
    };
  }

  static async deleteUser(id: string, requestingUser: User) {

    // Find user to delete
    const existingUser = await db
      .select()
      .from(users)
      .where(eq(users.id, id));

    if (!existingUser[0]) {
      throw new HTTPException(404, { message: "User not found" });
    }


    // Cannot delete self
    if (existingUser[0].id === requestingUser.id) {
      throw new HTTPException(400, { message: "Cannot delete your own account" });
    }

    // Soft delete user
    await db
      .update(users)
      .set({ 
        deletedAt: new Date(),
        isActive: false,
        updatedAt: new Date(),
      })
      .where(eq(users.id, id));

    return { message: "User deleted successfully" };
  }
}