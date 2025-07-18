import { z } from "zod";
import { roles } from "../models/users";

// Create user schema
export const createUserSchema = z.object({
  name: z.string().min(1, "Name is required"),
  username: z.string().min(3, "Username must be at least 3 characters"),
  password: z.string().min(6, "Password must be at least 6 characters"),
  role: z.enum(roles),
});

// Update user schema
export const updateUserSchema = z.object({
  name: z.string().min(1, "Name is required").optional(),
  username: z.string().min(3, "Username must be at least 3 characters").optional(),
  password: z.string().min(6, "Password must be at least 6 characters").optional(),
  role: z.enum(roles).optional(),
  isActive: z.boolean().optional(),
});

// Query parameters for list users
export const listUsersQuerySchema = z.object({
  page: z.coerce.number().min(1).default(1),
  limit: z.coerce.number().min(1).max(100).default(10),
  search: z.string().optional(),
  role: z.enum(roles).optional(),
  isActive: z.coerce.boolean().optional(),
});

// User ID parameter schema
export const userIdParamSchema = z.object({
  id: z.string().uuid("Invalid user ID format"),
});

// User response schema
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

// User list response schema
export const userListResponseSchema = z.object({
  users: z.array(userResponseSchema),
  pagination: z.object({
    page: z.number(),
    limit: z.number(),
    total: z.number(),
    totalPages: z.number(),
    hasNext: z.boolean(),
    hasPrev: z.boolean(),
  }),
});

// Type exports
export type CreateUserRequest = z.infer<typeof createUserSchema>;
export type UpdateUserRequest = z.infer<typeof updateUserSchema>;
export type ListUsersQuery = z.infer<typeof listUsersQuerySchema>;
export type UserIdParam = z.infer<typeof userIdParamSchema>;
export type UserResponse = z.infer<typeof userResponseSchema>;
export type UserListResponse = z.infer<typeof userListResponseSchema>;