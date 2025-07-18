/**
 * Standardized API response utilities for the WMS application
 * Provides consistent response formats across all endpoints
 */

import type { Context } from 'hono';
import { ErrorHandler } from './errors';

/**
 * Base response interface for all API responses
 */
export interface BaseResponse<T = unknown> {
  success: boolean;
  data?: T;
  error?: {
    code: string;
    message: string;
  };
  timestamp: string;
}

/**
 * Paginated response interface for list endpoints
 */
export interface PaginatedResponse<T = unknown> extends BaseResponse<T[]> {
  pagination: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
    hasNext: boolean;
    hasPrev: boolean;
  };
}

/**
 * Pagination parameters interface
 */
export interface PaginationParams {
  page: number;
  limit: number;
  total: number;
}

/**
 * Response utility class for creating standardized API responses
 */
export class ResponseUtils {
  /**
   * Creates a successful response with data
   */
  static success<T>(data: T, statusCode: number = 200): BaseResponse<T> {
    return {
      success: true,
      data,
      timestamp: new Date().toISOString(),
    };
  }

  /**
   * Creates a successful response without data
   */
  static successNoData(statusCode: number = 200): BaseResponse {
    return {
      success: true,
      timestamp: new Date().toISOString(),
    };
  }

  /**
   * Creates an error response
   */
  static error(error: unknown): BaseResponse {
    const errorResponse = ErrorHandler.getErrorResponse(error);
    return {
      success: false,
      error: errorResponse.error,
      timestamp: new Date().toISOString(),
    };
  }

  /**
   * Creates a paginated response
   */
  static paginated<T>(
    data: T[],
    pagination: PaginationParams
  ): PaginatedResponse<T> {
    const { page, limit, total } = pagination;
    const totalPages = Math.ceil(total / limit);

    return {
      success: true,
      data,
      pagination: {
        page,
        limit,
        total,
        totalPages,
        hasNext: page < totalPages,
        hasPrev: page > 1,
      },
      timestamp: new Date().toISOString(),
    };
  }

  /**
   * Sends a successful JSON response
   */
  static sendSuccess<T>(
    c: Context,
    data: T,
    statusCode: number = 200
  ): Response {
    return c.json(this.success(data, statusCode), statusCode as any);
  }

  /**
   * Sends a successful response without data
   */
  static sendSuccessNoData(c: Context, statusCode: number = 200): Response {
    return c.json(this.successNoData(statusCode), statusCode as any);
  }

  /**
   * Sends an error JSON response
   */
  static sendError(c: Context, error: unknown): Response {
    const errorResponse = ErrorHandler.getErrorResponse(error);
    return c.json(this.error(error), errorResponse.statusCode as any);
  }

  /**
   * Sends a paginated JSON response
   */
  static sendPaginated<T>(
    c: Context,
    data: T[],
    pagination: PaginationParams,
    statusCode: number = 200
  ): Response {
    return c.json(this.paginated(data, pagination), statusCode as any);
  }

  /**
   * Sends a created response (201)
   */
  static sendCreated<T>(c: Context, data: T): Response {
    return c.json(this.success(data, 201), 201 as any);
  }

  /**
   * Sends a no content response (204)
   */
  static sendNoContent(c: Context): Response {
    return c.body(null, 204);
  }
}

/**
 * Pagination helper utilities
 */
export class PaginationUtils {
  /**
   * Calculates pagination parameters from query params
   */
  static getParams(page?: string, limit?: string) {
    const pageNum = Math.max(1, parseInt(page || '1', 10));
    const limitNum = Math.min(100, Math.max(1, parseInt(limit || '10', 10)));
    const offset = (pageNum - 1) * limitNum;

    return {
      page: pageNum,
      limit: limitNum,
      offset,
    };
  }

  /**
   * Creates pagination metadata
   */
  static createPagination(
    page: number,
    limit: number,
    total: number
  ): PaginationParams {
    return { page, limit, total };
  }
}