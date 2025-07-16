import { z } from '@hono/zod-openapi';

/**
 * Base response structure for all API responses
 * Provides consistent response format across the API
 */
export const BaseResponseSchema = z.object({
  success: z.boolean().describe('Whether the request was successful'),
  message: z.string().describe('Human-readable message about the response'),
  data: z.any().optional().describe('Response data payload'),
  timestamp: z.string().datetime().describe('ISO 8601 timestamp of the response'),
});

export type BaseResponse = z.infer<typeof BaseResponseSchema>;

/**
 * Paginated response structure for list endpoints
 * Extends base response with pagination metadata
 */
export const PaginatedBaseResponseSchema = BaseResponseSchema.extend({
  pagination: z.object({
    page: z.number().int().min(1).describe('Current page number'),
    limit: z.number().int().min(1).max(100).describe('Number of items per page'),
    total: z.number().int().min(0).describe('Total number of items'),
    totalPages: z.number().int().min(0).describe('Total number of pages'),
    hasNext: z.boolean().describe('Whether there is a next page'),
    hasPrev: z.boolean().describe('Whether there is a previous page'),
  }),
});

export type PaginatedBaseResponse = z.infer<typeof PaginatedBaseResponseSchema>;

/**
 * Error response structure for API errors
 */
export const ErrorResponseSchema = z.object({
  success: z.literal(false),
  message: z.string().describe('Error message'),
  error: z.object({
    code: z.string().describe('Error code for client handling'),
    details: z.any().optional().describe('Additional error details'),
  }).optional(),
  timestamp: z.string().datetime(),
});

export type ErrorResponse = z.infer<typeof ErrorResponseSchema>;

/**
 * Paginated request structure for list endpoints
 * Standardizes pagination query parameters
 */
export const PaginatedBaseRequestSchema = z.object({
  page: z.string().optional().transform((val) => parseInt(val || '1')).pipe(z.number().int().min(1)).describe('Page number (default: 1)'),
  limit: z.string().optional().transform((val) => parseInt(val || '10')).pipe(z.number().int().min(1).max(100)).describe('Items per page (default: 10, max: 100)'),
  sortBy: z.string().optional().default('createdAt').describe('Field to sort by (default: createdAt)'),
  sortOrder: z.enum(['asc', 'desc']).optional().default('desc').describe('Sort order (default: desc)'),
});

export type PaginatedBaseRequest = z.infer<typeof PaginatedBaseRequestSchema>;

/**
 * Helper function to create a paginated request schema with custom filters
 */
export function createPaginatedRequestSchema<T extends z.ZodRawShape>(filtersSchema: z.ZodObject<T>) {
  return PaginatedBaseRequestSchema.extend(filtersSchema.shape);
}

/**
 * Helper function to parse and validate pagination options
 */
export function parsePaginationOptions(queryParams: any): PaginatedBaseRequest {
  const result = PaginatedBaseRequestSchema.safeParse(queryParams);
  if (!result.success) {
    throw new Error(`Invalid pagination parameters: ${result.error.message}`);
  }
  return result.data;
}

/**
 * Helper function to create a successful base response
 */
export function createSuccessResponse<T>(
  data: T,
  message: string = 'Success',
  timestamp: string = new Date().toISOString()
): BaseResponse {
  return {
    success: true,
    message,
    data,
    timestamp,
  };
}

/**
 * Helper function to create an error response
 */
export function createErrorResponse(
  message: string,
  code?: string,
  details?: any,
  timestamp: string = new Date().toISOString()
): ErrorResponse {
  return {
    success: false,
    message,
    timestamp,
    ...(code && {
      error: {
        code,
        details,
      },
    }),
  };
}

/**
 * Helper function to create a paginated response
 */
export function createPaginatedResponse<T>(
  data: T[],
  page: number,
  limit: number,
  total: number,
  message: string = 'Success',
  timestamp: string = new Date().toISOString()
): PaginatedBaseResponse {
  const totalPages = Math.ceil(total / limit);
  
  return {
    success: true,
    message,
    data,
    timestamp,
    pagination: {
      page,
      limit,
      total,
      totalPages,
      hasNext: page < totalPages,
      hasPrev: page > 1,
    },
  };
}