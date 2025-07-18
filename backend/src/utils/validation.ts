/**
 * Zod validation utilities and middleware for the WMS application
 * Provides schema helpers and validation middleware for request validation
 */

import { z } from '@hono/zod-openapi';
import type { Context, Next } from 'hono';
import { ValidationError } from './errors';
import { ResponseUtils } from './responses';

/**
 * Common Zod schema patterns for reuse across the application
 */
export const CommonSchemas = {
  /**
   * UUID string schema
   */
  uuid: z.string().uuid('Invalid UUID format'),

  /**
   * Non-empty string schema
   */
  nonEmptyString: z.string().min(1, 'This field is required').trim(),

  /**
   * Optional non-empty string schema
   */
  optionalNonEmptyString: z.string().min(1).trim().optional(),

  /**
   * Email schema
   */
  email: z.string().email('Invalid email format'),

  /**
   * Phone number schema (basic format)
   */
  phone: z.string().regex(/^\+?[\d\s\-\(\)]+$/, 'Invalid phone number format'),

  /**
   * Pagination query parameters
   */
  pagination: z.object({
    page: z
      .string()
      .optional()
      .transform((val) => (val ? Math.max(1, parseInt(val, 10)) : 1)),
    limit: z
      .string()
      .optional()
      .transform((val) => (val ? Math.min(100, Math.max(1, parseInt(val, 10))) : 10)),
  }),

  /**
   * Timestamp schema
   */
  timestamp: z.number().int().positive(),

  /**
   * Boolean from string schema (for query params)
   */
  booleanString: z
    .string()
    .transform((val) => val === 'true')
    .pipe(z.boolean()),

  /**
   * Positive number schema
   */
  positiveNumber: z.number().positive('Must be a positive number'),

  /**
   * Non-negative number schema
   */
  nonNegativeNumber: z.number().nonnegative('Must be a non-negative number'),

  /**
   * Currency amount schema (2 decimal places)
   */
  currency: z
    .number()
    .multipleOf(0.01, 'Currency amount must have at most 2 decimal places')
    .nonnegative('Amount must be non-negative'),
};

/**
 * Schema validation utilities
 */
export class ValidationUtils {
  /**
   * Creates a schema for updating existing resources (makes all fields optional)
   */
  static makeOptional<T extends z.ZodRawShape>(schema: z.ZodObject<T>) {
    return schema.partial();
  }

  /**
   * Creates a schema with only specified fields
   * Note: Use schema.pick() directly for better type safety in specific use cases
   */
  static pickFields<T extends z.ZodRawShape>(
    schema: z.ZodObject<T>,
    keys: (keyof T)[]
  ) {
    const pickObject: any = {};
    keys.forEach((key) => {
      pickObject[key] = true;
    });
    return schema.pick(pickObject);
  }

  /**
   * Creates a schema without specified fields
   * Note: Use schema.omit() directly for better type safety in specific use cases
   */
  static omitFields<T extends z.ZodRawShape>(
    schema: z.ZodObject<T>,
    keys: (keyof T)[]
  ) {
    const omitObject: any = {};
    keys.forEach((key) => {
      omitObject[key] = true;
    });
    return schema.omit(omitObject);
  }

  /**
   * Validates data against a schema and throws ValidationError on failure
   */
  static validate<T>(schema: z.ZodSchema<T>, data: unknown): T {
    try {
      return schema.parse(data);
    } catch (error) {
      if (error instanceof z.ZodError) {
        const errorMessage = error.errors
          .map((err) => `${err.path.join('.')}: ${err.message}`)
          .join(', ');
        throw new ValidationError(`Validation failed: ${errorMessage}`);
      }
      throw new ValidationError('Validation failed');
    }
  }

  /**
   * Safely validates data and returns success/error result
   */
  static safeValidate<T>(
    schema: z.ZodSchema<T>,
    data: unknown
  ): { success: true; data: T } | { success: false; error: string } {
    try {
      const result = schema.parse(data);
      return { success: true, data: result };
    } catch (error) {
      if (error instanceof z.ZodError) {
        const errorMessage = error.errors
          .map((err) => `${err.path.join('.')}: ${err.message}`)
          .join(', ');
        return { success: false, error: errorMessage };
      }
      return { success: false, error: 'Validation failed' };
    }
  }

  /**
   * Creates pagination parameters from query string
   */
  static parsePagination(query: Record<string, string | undefined>) {
    return CommonSchemas.pagination.parse({
      page: query.page,
      limit: query.limit,
    });
  }
}

/**
 * Validation middleware factory
 */
export class ValidationMiddleware {
  /**
   * Creates middleware for validating request body
   */
  static body<T>(schema: z.ZodSchema<T>) {
    return async (c: Context, next: Next) => {
      try {
        const body = await c.req.json();
        const validatedBody = ValidationUtils.validate(schema, body);
        c.set('validatedBody', validatedBody);
        await next();
      } catch (error) {
        return ResponseUtils.sendError(c, error);
      }
    };
  }

  /**
   * Creates middleware for validating query parameters
   */
  static query<T>(schema: z.ZodSchema<T>) {
    return async (c: Context, next: Next) => {
      try {
        const query = c.req.query();
        const validatedQuery = ValidationUtils.validate(schema, query);
        c.set('validatedQuery', validatedQuery);
        await next();
      } catch (error) {
        return ResponseUtils.sendError(c, error);
      }
    };
  }

  /**
   * Creates middleware for validating path parameters
   */
  static params<T>(schema: z.ZodSchema<T>) {
    return async (c: Context, next: Next) => {
      try {
        const params = c.req.param();
        const validatedParams = ValidationUtils.validate(schema, params);
        c.set('validatedParams', validatedParams);
        await next();
      } catch (error) {
        return ResponseUtils.sendError(c, error);
      }
    };
  }

  /**
   * Pagination middleware for list endpoints
   */
  static pagination() {
    return async (c: Context, next: Next) => {
      try {
        const query = c.req.query();
        const pagination = ValidationUtils.parsePagination(query);
        c.set('pagination', {
          ...pagination,
          offset: (pagination.page - 1) * pagination.limit,
        });
        await next();
      } catch (error) {
        return ResponseUtils.sendError(c, error);
      }
    };
  }
}

/**
 * Helper function to get validated data from context
 */
export function getValidated<T>(c: Context, key: 'validatedBody' | 'validatedQuery' | 'validatedParams'): T {
  const data = c.get(key);
  if (!data) {
    throw new ValidationError(`Missing validated ${key.replace('validated', '').toLowerCase()}`);
  }
  return data as T;
}

/**
 * Helper function to get pagination from context
 */
export function getPagination(c: Context): { page: number; limit: number; offset: number } {
  const pagination = c.get('pagination');
  if (!pagination) {
    throw new ValidationError('Missing pagination data');
  }
  return pagination;
}