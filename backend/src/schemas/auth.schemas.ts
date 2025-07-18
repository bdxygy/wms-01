import { z } from "zod";
import { roles } from "../models/users";

// Registration schemas
export const devRegisterSchema = z.object({
  name: z.string().min(1, "Name is required"),
  username: z.string().min(3, "Username must be at least 3 characters"),
  password: z.string().min(6, "Password must be at least 6 characters"),
});

export const registerSchema = z.object({
  name: z.string().min(1, "Name is required"),
  username: z.string().min(3, "Username must be at least 3 characters"),
  password: z.string().min(6, "Password must be at least 6 characters"),
  role: z.enum(roles).default("ADMIN"),
});

// Login schema
export const loginSchema = z.object({
  username: z.string().min(1, "Username is required"),
  password: z.string().min(1, "Password is required"),
});

// Refresh token schema
export const refreshTokenSchema = z.object({
  refreshToken: z.string().min(1, "Refresh token is required").optional(),
});

// Response schemas
export const authResponseSchema = z.object({
  user: z.object({
    id: z.string(),
    name: z.string(),
    username: z.string(),
    role: z.enum(roles),
    ownerId: z.string().nullable(),
    isActive: z.boolean(),
    createdAt: z.date(),
    updatedAt: z.date(),
  }),
  tokens: z.object({
    accessToken: z.string(),
    refreshToken: z.string().optional(),
  }),
});

export const userResponseSchema = z.object({
  id: z.string(),
  name: z.string(),
  username: z.string(),
  role: z.enum(roles),
  ownerId: z.string().nullable(),
  isActive: z.boolean(),
  createdAt: z.date(),
  updatedAt: z.date(),
});

// Type exports
export type DevRegisterRequest = z.infer<typeof devRegisterSchema>;
export type RegisterRequest = z.infer<typeof registerSchema>;
export type LoginRequest = z.infer<typeof loginSchema>;
export type RefreshTokenRequest = z.infer<typeof refreshTokenSchema>;
export type AuthResponse = z.infer<typeof authResponseSchema>;
export type UserResponse = z.infer<typeof userResponseSchema>;