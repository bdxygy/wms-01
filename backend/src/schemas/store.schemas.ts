import { z } from '@hono/zod-openapi';
import { createPaginatedRequestSchema } from '../utils/response';

// Base store schema without sensitive fields
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
  deletedAt: z.string().datetime().nullable().openapi({ description: 'When the store was deleted (if applicable)' }),
});

// Create store request schema
export const CreateStoreRequestSchema = z.object({
  name: z.string().min(1).openapi({ 
    description: 'Store name',
    example: 'Main Branch Store'
  }),
  address: z.string().optional().openapi({ 
    description: 'Store address',
    example: '123 Main Street, City, State'
  }),
  phone: z.string().optional().openapi({ 
    description: 'Store phone number',
    example: '+1-234-567-8900'
  }),
  email: z.string().email().optional().openapi({ 
    description: 'Store email address',
    example: 'mainbranch@store.com'
  }),
});

// Update store request schema
export const UpdateStoreRequestSchema = z.object({
  name: z.string().min(1).optional().openapi({ 
    description: 'Store name',
    example: 'Updated Store Name'
  }),
  address: z.string().optional().openapi({ 
    description: 'Store address',
    example: '456 New Address, City, State'
  }),
  phone: z.string().optional().openapi({ 
    description: 'Store phone number',
    example: '+1-234-567-8901'
  }),
  email: z.string().email().optional().openapi({ 
    description: 'Store email address',
    example: 'updated@store.com'
  }),
  isActive: z.boolean().optional().openapi({ 
    description: 'Whether the store is active'
  }),
});

// Store-specific filters schema
export const StoreFiltersSchema = z.object({
  isActive: z.string().optional().openapi({ 
    description: 'Filter by active status (true/false)',
    example: 'true'
  }),
  search: z.string().optional().openapi({ 
    description: 'Search by store name or address',
    example: 'Main Branch'
  }),
});

// Query parameters schema with pagination
export const StoreQueryParamsSchema = createPaginatedRequestSchema(StoreFiltersSchema).openapi({
  description: 'Query parameters for store list endpoints'
});

// Path parameters schemas
export const StoreIdParamSchema = z.object({
  id: z.string().openapi({ 
    description: 'Store ID',
    example: 'store_123'
  }),
});

export const OwnerIdParamSchema = z.object({
  ownerId: z.string().openapi({ 
    description: 'Owner ID',
    example: 'owner_123'
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

// Paginated response schema (matches createPaginatedResponse format)
export const PaginatedStoreResponseSchema = z.object({
  success: z.boolean().openapi({ description: 'Request success status' }),
  message: z.string().openapi({ description: 'Success message' }),
  data: z.array(StoreResponseSchema).optional().openapi({ description: 'Array of stores' }),
  timestamp: z.string().datetime().openapi({ description: 'Response timestamp' }),
  pagination: z.object({
    page: z.number().openapi({ description: 'Current page number' }),
    limit: z.number().openapi({ description: 'Number of items per page' }),
    total: z.number().openapi({ description: 'Total number of stores matching the criteria' }),
    totalPages: z.number().openapi({ description: 'Total number of pages' }),
    hasNext: z.boolean().openapi({ description: 'Whether there is a next page' }),
    hasPrev: z.boolean().openapi({ description: 'Whether there is a previous page' }),
  }).optional().openapi({ description: 'Pagination metadata' }),
});

// Common response schemas
export const StoreSuccessResponseSchema = ApiResponseSchema(StoreResponseSchema);
export const PaginatedStoreSuccessResponseSchema = PaginatedStoreResponseSchema;
export const DeleteSuccessResponseSchema = ApiResponseSchema(z.null());
export const ErrorResponseSchema = ApiResponseSchema(z.never());

// Type exports for use in controllers
export type CreateStoreRequest = z.infer<typeof CreateStoreRequestSchema>;
export type UpdateStoreRequest = z.infer<typeof UpdateStoreRequestSchema>;
export type StoreResponse = z.infer<typeof StoreResponseSchema>;