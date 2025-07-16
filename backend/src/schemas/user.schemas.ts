import { z } from '@hono/zod-openapi';
import { roles } from '../models/users';
import { createPaginatedRequestSchema } from '../utils/response';

// Base user schema without sensitive fields
export const UserResponseSchema = z.object({
  id: z.string().openapi({ description: 'Unique user identifier' }),
  email: z.string().email().openapi({ description: 'User email address' }),
  name: z.string().openapi({ description: 'User full name' }),
  role: z.enum(roles).openapi({ description: 'User role in the system' }),
  ownerId: z.string().nullable().openapi({ description: 'ID of the owner this user belongs to' }),
  storeId: z.string().nullable().openapi({ description: 'ID of the default store for this user' }),
  isActive: z.boolean().openapi({ description: 'Whether the user account is active' }),
  createdAt: z.string().datetime().openapi({ description: 'When the user was created' }),
  updatedAt: z.string().datetime().openapi({ description: 'When the user was last updated' }),
  deletedAt: z.string().datetime().nullable().openapi({ description: 'When the user was deleted (if applicable)' }),
});

// Create user request schema
export const CreateUserRequestSchema = z.object({
  email: z.string().email().openapi({ 
    description: 'User email address',
    example: 'john.doe@example.com'
  }),
  password: z.string().min(8).openapi({ 
    description: 'User password (minimum 8 characters)',
    example: 'securePassword123'
  }),
  name: z.string().min(1).openapi({ 
    description: 'User full name',
    example: 'John Doe'
  }),
  role: z.enum(roles).openapi({ 
    description: 'User role in the system',
    example: 'STAFF'
  }),
  ownerId: z.string().optional().openapi({ 
    description: 'ID of the owner this user belongs to (optional, auto-assigned based on requesting user)'
  }),
  storeId: z.string().optional().openapi({ 
    description: 'ID of the default store for this user (optional)'
  }),
});

// Update user request schema
export const UpdateUserRequestSchema = z.object({
  email: z.string().email().optional().openapi({ 
    description: 'User email address',
    example: 'john.doe@example.com'
  }),
  password: z.string().min(8).optional().openapi({ 
    description: 'User password (minimum 8 characters)',
    example: 'newSecurePassword123'
  }),
  name: z.string().min(1).optional().openapi({ 
    description: 'User full name',
    example: 'John Doe'
  }),
  role: z.enum(roles).optional().openapi({ 
    description: 'User role in the system',
    example: 'STAFF'
  }),
  storeId: z.string().optional().openapi({ 
    description: 'ID of the default store for this user'
  }),
  isActive: z.boolean().optional().openapi({ 
    description: 'Whether the user account is active'
  }),
});

// Update current user request schema (limited fields)
export const UpdateCurrentUserRequestSchema = z.object({
  email: z.string().email().optional().openapi({ 
    description: 'User email address',
    example: 'john.doe@example.com'
  }),
  name: z.string().min(1).optional().openapi({ 
    description: 'User full name',
    example: 'John Doe'
  }),
});

// Paginated response schema (matches createPaginatedResponse format)
export const PaginatedUserResponseSchema = z.object({
  success: z.boolean().openapi({ description: 'Request success status' }),
  message: z.string().openapi({ description: 'Success message' }),
  data: z.array(UserResponseSchema).optional().openapi({ description: 'Array of users' }),
  timestamp: z.string().datetime().openapi({ description: 'Response timestamp' }),
  pagination: z.object({
    page: z.number().openapi({ description: 'Current page number' }),
    limit: z.number().openapi({ description: 'Number of items per page' }),
    total: z.number().openapi({ description: 'Total number of users matching the criteria' }),
    totalPages: z.number().openapi({ description: 'Total number of pages' }),
    hasNext: z.boolean().openapi({ description: 'Whether there is a next page' }),
    hasPrev: z.boolean().openapi({ description: 'Whether there is a previous page' }),
  }).optional().openapi({ description: 'Pagination metadata' }),
});

// Store response schema (for user stores endpoint)
export const StoreResponseSchema = z.object({
  id: z.string().openapi({ description: 'Unique store identifier' }),
  name: z.string().openapi({ description: 'Store name' }),
  address: z.string().nullable().openapi({ description: 'Store address' }),
  phone: z.string().nullable().openapi({ description: 'Store phone number' }),
  email: z.string().nullable().openapi({ description: 'Store email address' }),
  ownerId: z.string().openapi({ description: 'ID of the owner this store belongs to' }),
  isActive: z.boolean().openapi({ description: 'Whether the store is active' }),
  createdAt: z.string().datetime().openapi({ description: 'When the store was created' }),
  updatedAt: z.string().datetime().openapi({ description: 'When the store was last updated' }),
});

// User-specific filters schema
export const UserFiltersSchema = z.object({
  role: z.enum(roles).optional().openapi({ 
    description: 'Filter by user role'
  }),
  isActive: z.string().optional().openapi({ 
    description: 'Filter by active status (true/false)',
    example: 'true'
  }),
});

// Query parameters schema with pagination
export const UserQueryParamsSchema = createPaginatedRequestSchema(UserFiltersSchema).openapi({
  description: 'Query parameters for user list endpoints'
});

// Path parameters schemas
export const UserIdParamSchema = z.object({
  id: z.string().openapi({ 
    description: 'User ID',
    example: 'user_123'
  }),
});

export const OwnerIdParamSchema = z.object({
  ownerId: z.string().openapi({ 
    description: 'Owner ID',
    example: 'owner_123'
  }),
});

export const RoleParamSchema = z.object({
  role: z.enum(roles).openapi({ 
    description: 'User role',
    example: 'STAFF'
  }),
});

export const UserIdForStoresParamSchema = z.object({
  userId: z.string().openapi({ 
    description: 'User ID to get stores for',
    example: 'user_123'
  }),
});

// Base response wrapper (matches createBaseResponse format) 
export const ApiResponseSchema = <T extends z.ZodTypeAny>(dataSchema: T) =>
  z.object({
    success: z.boolean().openapi({ description: 'Request success status' }),
    message: z.string().openapi({ description: 'Response message' }),
    data: dataSchema.optional().openapi({ description: 'Response data' }),
    error: z.object({
      code: z.string().openapi({ description: 'Error code for client handling' }),
      details: z.any().optional().openapi({ description: 'Additional error details' }),
    }).optional().openapi({ description: 'Error information when success is false' }),
    timestamp: z.string().datetime().openapi({ description: 'Response timestamp' }),
  });

// Common response schemas
export const UserSuccessResponseSchema = ApiResponseSchema(UserResponseSchema);
export const PaginatedUserSuccessResponseSchema = PaginatedUserResponseSchema; // This is already a complete response
export const StoresSuccessResponseSchema = ApiResponseSchema(z.array(StoreResponseSchema));
export const DeleteSuccessResponseSchema = ApiResponseSchema(z.null());
export const ErrorResponseSchema = ApiResponseSchema(z.never());

// Type exports for use in controllers
export type CreateUserRequest = z.infer<typeof CreateUserRequestSchema>;
export type UpdateUserRequest = z.infer<typeof UpdateUserRequestSchema>;
export type UpdateCurrentUserRequest = z.infer<typeof UpdateCurrentUserRequestSchema>;
export type UserResponse = z.infer<typeof UserResponseSchema>;
export type StoreResponse = z.infer<typeof StoreResponseSchema>;