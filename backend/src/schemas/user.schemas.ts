/**
 * User schemas for request/response validation
 * Provides Zod schemas for user-related API endpoints
 */

import { z } from '@hono/zod-openapi';
import { CommonSchemas } from '../utils/validation';
import { roles } from '../models/users';

/**
 * User role enum schema
 */
export const UserRoleSchema = z.enum(roles);

/**
 * Base user data schema (common fields for requests)
 */
export const BaseUserSchema = z.object({
  name: CommonSchemas.nonEmptyString.max(100, 'Name must be 100 characters or less'),
  username: CommonSchemas.nonEmptyString
    .min(3, 'Username must be at least 3 characters')
    .max(50, 'Username must be 50 characters or less')
    .regex(/^[a-zA-Z0-9_-]+$/, 'Username can only contain letters, numbers, hyphens, and underscores'),
  role: UserRoleSchema,
});

/**
 * User response schema (what gets returned from API)
 */
export const UserResponseSchema = z.object({
  id: CommonSchemas.uuid,
  ownerId: CommonSchemas.uuid.nullable(),
  name: z.string(),
  username: z.string(),
  role: UserRoleSchema,
  isActive: z.boolean(),
  createdAt: z.string().datetime(),
  updatedAt: z.string().datetime(),
  deletedAt: z.string().datetime().nullable(),
});

/**
 * Create user request schema
 */
export const CreateUserRequestSchema = BaseUserSchema.extend({
  password: CommonSchemas.nonEmptyString
    .min(8, 'Password must be at least 8 characters')
    .max(100, 'Password must be 100 characters or less'),
  ownerId: CommonSchemas.uuid.optional(),
});

/**
 * Update user request schema (all fields optional except constraints)
 */
export const UpdateUserRequestSchema = z.object({
  name: CommonSchemas.nonEmptyString.max(100, 'Name must be 100 characters or less').optional(),
  username: CommonSchemas.nonEmptyString
    .min(3, 'Username must be at least 3 characters')
    .max(50, 'Username must be 50 characters or less')
    .regex(/^[a-zA-Z0-9_-]+$/, 'Username can only contain letters, numbers, hyphens, and underscores')
    .optional(),
  password: CommonSchemas.nonEmptyString
    .min(8, 'Password must be at least 8 characters')
    .max(100, 'Password must be 100 characters or less')
    .optional(),
  role: UserRoleSchema.optional(),
  isActive: z.boolean().optional(),
});

/**
 * User list query parameters schema
 */
export const UserListQuerySchema = CommonSchemas.pagination.extend({
  role: UserRoleSchema.optional(),
  isActive: CommonSchemas.booleanString.optional(),
  search: z.string().min(1).max(100).optional(),
});

/**
 * User ID parameter schema
 */
export const UserIdParamsSchema = z.object({
  id: CommonSchemas.uuid,
});

/**
 * Paginated user list response schema
 */
export const UserListResponseSchema = z.object({
  success: z.literal(true),
  data: z.array(UserResponseSchema),
  pagination: z.object({
    page: z.number().int().positive(),
    limit: z.number().int().positive(),
    total: z.number().int().nonnegative(),
    totalPages: z.number().int().nonnegative(),
    hasNext: z.boolean(),
    hasPrev: z.boolean(),
  }),
  timestamp: z.string().datetime(),
});

/**
 * Single user response schema
 */
export const SingleUserResponseSchema = z.object({
  success: z.literal(true),
  data: UserResponseSchema,
  timestamp: z.string().datetime(),
});

/**
 * Error response schema
 */
export const ErrorResponseSchema = z.object({
  success: z.literal(false),
  error: z.object({
    code: z.string(),
    message: z.string(),
  }),
  timestamp: z.string().datetime(),
});

/**
 * Type exports for use in controllers and services
 */
export type UserRole = z.infer<typeof UserRoleSchema>;
export type UserResponse = z.infer<typeof UserResponseSchema>;
export type CreateUserRequest = z.infer<typeof CreateUserRequestSchema>;
export type UpdateUserRequest = z.infer<typeof UpdateUserRequestSchema>;
export type UserListQuery = z.infer<typeof UserListQuerySchema>;
export type UserIdParams = z.infer<typeof UserIdParamsSchema>;
export type UserListResponse = z.infer<typeof UserListResponseSchema>;
export type SingleUserResponse = z.infer<typeof SingleUserResponseSchema>;
export type ErrorResponse = z.infer<typeof ErrorResponseSchema>;

/**
 * Schema collections for easy import in routes
 */
export const UserSchemas = {
  // Request schemas
  createUser: CreateUserRequestSchema,
  updateUser: UpdateUserRequestSchema,
  userListQuery: UserListQuerySchema,
  userIdParams: UserIdParamsSchema,
  
  // Response schemas  
  userResponse: UserResponseSchema,
  userListResponse: UserListResponseSchema,
  singleUserResponse: SingleUserResponseSchema,
  errorResponse: ErrorResponseSchema,
} as const;