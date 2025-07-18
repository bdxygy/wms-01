import bcrypt from "bcryptjs";
import { db } from "../config/database";
import { users } from "../models/users";
import { JwtUtils } from "../utils/jwt";
import { eq } from "drizzle-orm";
import { HTTPException } from "hono/http-exception";
import type {
  DevRegisterRequest,
  RegisterRequest,
  LoginRequest,
  RefreshTokenRequest,
} from "../schemas/auth.schemas";
import { randomUUID } from "crypto";

export class AuthService {
  static async devRegister(data: DevRegisterRequest) {
    // Check if user already exists
    const existingUser = await db
      .select()
      .from(users)
      .where(eq(users.username, data.username));

    if (existingUser.length > 0) {
      throw new HTTPException(400, { message: "Username already exists" });
    }

    // Hash password
    const passwordHash = await bcrypt.hash(data.password, 10);

    // Create user with OWNER role (for dev registration)
    const userId = randomUUID();
    const user = await db
      .insert(users)
      .values({
        id: userId,
        name: data.name,
        username: data.username,
        passwordHash,
        role: "OWNER",
        ownerId: null, // OWNER has no owner
        isActive: true,
        createdAt: new Date(),
        updatedAt: new Date(),
      })
      .returning();

    if (!user[0]) {
      throw new HTTPException(500, { message: "Failed to create user" });
    }

    // Generate tokens
    const tokens = JwtUtils.generateTokenPair({
      userId: user[0].id,
      role: user[0].role,
      ownerId: user[0].ownerId || undefined,
    });

    return {
      user: {
        id: user[0].id,
        name: user[0].name,
        username: user[0].username,
        role: user[0].role,
        ownerId: user[0].ownerId,
        isActive: user[0].isActive,
        createdAt: user[0].createdAt,
        updatedAt: user[0].updatedAt,
      },
      tokens,
    };
  }

  static async register(data: RegisterRequest, createdBy: string) {
    // Check if user already exists
    const existingUser = await db
      .select()
      .from(users)
      .where(eq(users.username, data.username));

    if (existingUser.length > 0) {
      throw new HTTPException(400, { message: "Username already exists" });
    }

    // Get creator to determine ownership
    const creator = await db
      .select()
      .from(users)
      .where(eq(users.id, createdBy));

    if (!creator[0]) {
      throw new HTTPException(404, { message: "Creator not found" });
    }

    // Determine owner ID based on creator's role
    let ownerId: string;
    if (creator[0].role === "OWNER") {
      ownerId = creator[0].id;
    } else {
      ownerId = creator[0].ownerId!;
    }

    // Hash password
    const passwordHash = await bcrypt.hash(data.password, 10);

    // Create user
    const userId = randomUUID();
    const user = await db
      .insert(users)
      .values({
        id: userId,
        name: data.name,
        username: data.username,
        passwordHash,
        role: data.role,
        ownerId,
        isActive: true,
        createdAt: new Date(),
        updatedAt: new Date(),
      })
      .returning();

    if (!user[0]) {
      throw new HTTPException(500, { message: "Failed to create user" });
    }

    // Generate tokens
    const tokens = JwtUtils.generateTokenPair({
      userId: user[0].id,
      role: user[0].role,
      ownerId: user[0].ownerId || undefined,
    });

    return {
      user: {
        id: user[0].id,
        name: user[0].name,
        username: user[0].username,
        role: user[0].role,
        ownerId: user[0].ownerId,
        isActive: user[0].isActive,
        createdAt: user[0].createdAt,
        updatedAt: user[0].updatedAt,
      },
      tokens,
    };
  }

  static async login(data: LoginRequest) {
    // Find user by username
    const user = await db
      .select()
      .from(users)
      .where(eq(users.username, data.username));

    if (!user[0]) {
      throw new HTTPException(401, { message: "Invalid credentials" });
    }

    // Check if user is active
    if (!user[0].isActive) {
      throw new HTTPException(401, { message: "Account is deactivated" });
    }

    // Verify password
    const passwordMatch = await bcrypt.compare(
      data.password,
      user[0].passwordHash
    );

    if (!passwordMatch) {
      throw new HTTPException(401, { message: "Invalid credentials" });
    }

    // Generate tokens
    const tokens = JwtUtils.generateTokenPair({
      userId: user[0].id,
      role: user[0].role,
      ownerId: user[0].ownerId || undefined,
    });

    return {
      user: {
        id: user[0].id,
        name: user[0].name,
        username: user[0].username,
        role: user[0].role,
        ownerId: user[0].ownerId,
        isActive: user[0].isActive,
        createdAt: user[0].createdAt,
        updatedAt: user[0].updatedAt,
      },
      tokens,
    };
  }

  static async refresh(data: RefreshTokenRequest) {
    try {
      // Verify refresh token
      const decoded = JwtUtils.verifyRefreshToken(data.refreshToken);

      // Find user to ensure they still exist and are active
      const user = await db
        .select()
        .from(users)
        .where(eq(users.id, decoded.userId));

      if (!user[0]) {
        throw new HTTPException(401, { message: "User not found" });
      }

      if (!user[0].isActive) {
        throw new HTTPException(401, { message: "Account is deactivated" });
      }

      // Generate new tokens
      const tokens = JwtUtils.generateTokenPair({
        userId: user[0].id,
        role: user[0].role,
        ownerId: user[0].ownerId || undefined,
      });

      return {
        user: {
          id: user[0].id,
          name: user[0].name,
          username: user[0].username,
          role: user[0].role,
          ownerId: user[0].ownerId,
          isActive: user[0].isActive,
          createdAt: user[0].createdAt,
          updatedAt: user[0].updatedAt,
        },
        tokens,
      };
    } catch (error) {
      throw new HTTPException(401, { message: "Invalid refresh token" });
    }
  }
}
