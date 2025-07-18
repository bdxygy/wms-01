import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { randomUUID } from 'crypto';
import { eq, and, isNull } from 'drizzle-orm';
import { db } from '@/config/database';
import { users, type User, type NewUser, type Role } from '@/models/users';
import { env } from '@/config/env';

export interface LoginCredentials {
  username: string;
  password: string;
}

export interface RegisterData {
  name: string;
  username: string;
  password: string;
  role: Role;
  ownerId?: string;
}

export interface AuthToken {
  token: string;
  user: Omit<User, 'passwordHash'>;
}

export interface JWTPayload {
  userId: string;
  username: string;
  role: Role;
  ownerId?: string;
}

export class AuthError extends Error {
  constructor(
    message: string,
    public code: string = 'AUTH_ERROR'
  ) {
    super(message);
    this.name = 'AuthError';
  }
}

export class AuthService {
  private static readonly SALT_ROUNDS = 12;
  private static readonly TOKEN_EXPIRES_IN = '24h';

  /**
   * Register a new user
   */
  static async register(data: RegisterData): Promise<AuthToken> {
    const { name, username, password, role, ownerId } = data;

    // Validate owner hierarchy for non-OWNER roles
    if (role !== 'OWNER' && !ownerId) {
      throw new AuthError('Non-OWNER users must have an ownerId', 'INVALID_OWNER');
    }

    // Check if username already exists
    const existingUser = await db
      .select()
      .from(users)
      .where(and(eq(users.username, username), isNull(users.deletedAt)))
      .limit(1);

    if (existingUser.length > 0) {
      throw new AuthError('Username already exists', 'USERNAME_EXISTS');
    }

    // Validate owner exists if ownerId provided
    if (ownerId) {
      const owner = await db
        .select()
        .from(users)
        .where(and(eq(users.id, ownerId), eq(users.role, 'OWNER'), isNull(users.deletedAt)))
        .limit(1);

      if (owner.length === 0) {
        throw new AuthError('Invalid owner', 'INVALID_OWNER');
      }
    }

    // Hash password
    const passwordHash = await bcrypt.hash(password, AuthService.SALT_ROUNDS);

    // Create new user
    const newUser: NewUser = {
      id: randomUUID(),
      name,
      username,
      passwordHash,
      role,
      ownerId: ownerId || null,
      isActive: true,
      createdAt: new Date(),
      updatedAt: new Date(),
      deletedAt: null,
    };

    const [createdUser] = await db.insert(users).values(newUser).returning();

    // Generate JWT token
    const token = AuthService.generateToken({
      userId: createdUser.id,
      username: createdUser.username,
      role: createdUser.role,
      ownerId: createdUser.ownerId || undefined,
    });

    // Return user without password hash
    const { passwordHash: _, ...userWithoutPassword } = createdUser;

    return {
      token,
      user: userWithoutPassword,
    };
  }

  /**
   * Login user with credentials
   */
  static async login(credentials: LoginCredentials): Promise<AuthToken> {
    const { username, password } = credentials;

    // Find user by username
    const [user] = await db
      .select()
      .from(users)
      .where(and(eq(users.username, username), isNull(users.deletedAt)))
      .limit(1);

    if (!user) {
      throw new AuthError('Invalid credentials', 'INVALID_CREDENTIALS');
    }

    // Check if user is active
    if (!user.isActive) {
      throw new AuthError('Account is disabled', 'ACCOUNT_DISABLED');
    }

    // Verify password
    const isPasswordValid = await bcrypt.compare(password, user.passwordHash);
    if (!isPasswordValid) {
      throw new AuthError('Invalid credentials', 'INVALID_CREDENTIALS');
    }

    // Generate JWT token
    const token = AuthService.generateToken({
      userId: user.id,
      username: user.username,
      role: user.role,
      ownerId: user.ownerId || undefined,
    });

    // Return user without password hash
    const { passwordHash: _, ...userWithoutPassword } = user;

    return {
      token,
      user: userWithoutPassword,
    };
  }

  /**
   * Verify JWT token and return payload
   */
  static verifyToken(token: string): JWTPayload {
    try {
      const payload = jwt.verify(token, env.JWT_SECRET) as JWTPayload;
      return payload;
    } catch (error) {
      if (error instanceof jwt.TokenExpiredError) {
        throw new AuthError('Token expired', 'TOKEN_EXPIRED');
      }
      if (error instanceof jwt.JsonWebTokenError) {
        throw new AuthError('Invalid token', 'INVALID_TOKEN');
      }
      throw new AuthError('Token verification failed', 'TOKEN_VERIFICATION_FAILED');
    }
  }

  /**
   * Get user by ID for token validation
   */
  static async getUserById(userId: string): Promise<User | null> {
    const [user] = await db
      .select()
      .from(users)
      .where(and(eq(users.id, userId), isNull(users.deletedAt)))
      .limit(1);

    return user || null;
  }

  /**
   * Validate user permissions based on role hierarchy
   */
  static validateRoleHierarchy(userRole: Role, requiredRole: Role): boolean {
    const roleHierarchy: Record<Role, number> = {
      OWNER: 4,
      ADMIN: 3,
      STAFF: 2,
      CASHIER: 1,
    };

    return roleHierarchy[userRole] >= roleHierarchy[requiredRole];
  }

  /**
   * Check if user can access owner's data
   */
  static canAccessOwnerData(currentUserId: string, currentUserOwnerId: string | null, targetOwnerId: string): boolean {
    // OWNER can access their own data
    if (currentUserId === targetOwnerId) {
      return true;
    }

    // Non-OWNER users can access data under the same owner
    if (currentUserOwnerId === targetOwnerId) {
      return true;
    }

    return false;
  }

  /**
   * Hash password utility
   */
  static async hashPassword(password: string): Promise<string> {
    return bcrypt.hash(password, AuthService.SALT_ROUNDS);
  }

  /**
   * Verify password utility
   */
  static async verifyPassword(password: string, hash: string): Promise<boolean> {
    return bcrypt.compare(password, hash);
  }

  /**
   * Generate JWT token
   */
  private static generateToken(payload: JWTPayload): string {
    return jwt.sign(payload, env.JWT_SECRET, {
      expiresIn: AuthService.TOKEN_EXPIRES_IN,
    });
  }
}