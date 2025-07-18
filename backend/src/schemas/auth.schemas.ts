import { z } from '@hono/zod-openapi';
import { roles } from '@/models/users';

// Base user schema without sensitive data
export const UserSchema = z.object({
  id: z.string().uuid(),
  ownerId: z.string().uuid().nullable(),
  name: z.string(),
  username: z.string(),
  role: z.enum(roles),
  isActive: z.boolean(),
  createdAt: z.string().datetime(),
  updatedAt: z.string().datetime(),
  deletedAt: z.string().datetime().nullable(),
}).openapi({
  example: {
    id: "123e4567-e89b-12d3-a456-426614174000",
    ownerId: "123e4567-e89b-12d3-a456-426614174001",
    name: "John Doe",
    username: "johndoe",
    role: "ADMIN",
    isActive: true,
    createdAt: "2024-01-01T00:00:00.000Z",
    updatedAt: "2024-01-01T00:00:00.000Z",
    deletedAt: null,
  },
});

// Registration request schema
export const RegisterRequestSchema = z.object({
  name: z.string().min(1, "Name is required").max(100, "Name must be less than 100 characters"),
  username: z.string()
    .min(3, "Username must be at least 3 characters")
    .max(50, "Username must be less than 50 characters")
    .regex(/^[a-zA-Z0-9_]+$/, "Username can only contain letters, numbers, and underscores"),
  password: z.string()
    .min(8, "Password must be at least 8 characters")
    .max(100, "Password must be less than 100 characters")
    .regex(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/, "Password must contain at least one lowercase letter, one uppercase letter, and one number"),
  role: z.enum(roles),
  ownerId: z.string().uuid().optional(),
}).openapi({
  example: {
    name: "John Doe",
    username: "johndoe",
    password: "SecurePass123",
    role: "ADMIN",
    ownerId: "123e4567-e89b-12d3-a456-426614174001",
  },
});

// Login request schema
export const LoginRequestSchema = z.object({
  username: z.string().min(1, "Username is required"),
  password: z.string().min(1, "Password is required"),
}).openapi({
  example: {
    username: "johndoe",
    password: "SecurePass123",
  },
});

// Auth token response schema
export const AuthTokenSchema = z.object({
  token: z.string(),
  user: UserSchema,
}).openapi({
  example: {
    token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    user: {
      id: "123e4567-e89b-12d3-a456-426614174000",
      ownerId: "123e4567-e89b-12d3-a456-426614174001",
      name: "John Doe",
      username: "johndoe",
      role: "ADMIN",
      isActive: true,
      createdAt: "2024-01-01T00:00:00.000Z",
      updatedAt: "2024-01-01T00:00:00.000Z",
      deletedAt: null,
    },
  },
});

// JWT payload schema for token validation
export const JWTPayloadSchema = z.object({
  userId: z.string().uuid(),
  username: z.string(),
  role: z.enum(roles),
  ownerId: z.string().uuid().optional(),
  iat: z.number().optional(),
  exp: z.number().optional(),
}).openapi({
  example: {
    userId: "123e4567-e89b-12d3-a456-426614174000",
    username: "johndoe",
    role: "ADMIN",
    ownerId: "123e4567-e89b-12d3-a456-426614174001",
    iat: 1640995200,
    exp: 1641081600,
  },
});

// Error response schemas
export const AuthErrorSchema = z.object({
  success: z.literal(false),
  error: z.object({
    code: z.enum([
      'AUTH_ERROR',
      'INVALID_OWNER',
      'USERNAME_EXISTS',
      'INVALID_CREDENTIALS',
      'ACCOUNT_DISABLED',
      'TOKEN_EXPIRED',
      'INVALID_TOKEN',
      'TOKEN_VERIFICATION_FAILED',
      'VALIDATION_ERROR',
      'UNAUTHORIZED',
      'FORBIDDEN',
    ]),
    message: z.string(),
  }),
  timestamp: z.string().datetime(),
}).openapi({
  example: {
    success: false,
    error: {
      code: "INVALID_CREDENTIALS",
      message: "Invalid username or password",
    },
    timestamp: "2024-01-01T00:00:00.000Z",
  },
});

// Success response schemas
export const RegisterResponseSchema = z.object({
  success: z.literal(true),
  data: AuthTokenSchema,
  timestamp: z.string().datetime(),
}).openapi({
  example: {
    success: true,
    data: {
      token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      user: {
        id: "123e4567-e89b-12d3-a456-426614174000",
        ownerId: "123e4567-e89b-12d3-a456-426614174001",
        name: "John Doe",
        username: "johndoe",
        role: "ADMIN",
        isActive: true,
        createdAt: "2024-01-01T00:00:00.000Z",
        updatedAt: "2024-01-01T00:00:00.000Z",
        deletedAt: null,
      },
    },
    timestamp: "2024-01-01T00:00:00.000Z",
  },
});

export const LoginResponseSchema = z.object({
  success: z.literal(true),
  data: AuthTokenSchema,
  timestamp: z.string().datetime(),
}).openapi({
  example: {
    success: true,
    data: {
      token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      user: {
        id: "123e4567-e89b-12d3-a456-426614174000",
        ownerId: "123e4567-e89b-12d3-a456-426614174001",
        name: "John Doe",
        username: "johndoe",
        role: "ADMIN",
        isActive: true,
        createdAt: "2024-01-01T00:00:00.000Z",
        updatedAt: "2024-01-01T00:00:00.000Z",
        deletedAt: null,
      },
    },
    timestamp: "2024-01-01T00:00:00.000Z",
  },
});

// Type exports for TypeScript
export type RegisterRequest = z.infer<typeof RegisterRequestSchema>;
export type LoginRequest = z.infer<typeof LoginRequestSchema>;
export type AuthToken = z.infer<typeof AuthTokenSchema>;
export type JWTPayload = z.infer<typeof JWTPayloadSchema>;
export type User = z.infer<typeof UserSchema>;
export type RegisterResponse = z.infer<typeof RegisterResponseSchema>;
export type LoginResponse = z.infer<typeof LoginResponseSchema>;
export type AuthError = z.infer<typeof AuthErrorSchema>;