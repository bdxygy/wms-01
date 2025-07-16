import { describe, it, expect } from 'vitest';
import {
  BaseResponseSchema,
  PaginatedBaseResponseSchema,
  ErrorResponseSchema,
  createSuccessResponse,
  createErrorResponse,
  createPaginatedResponse,
} from '@/utils/response';

describe('Response Types', () => {
  describe('BaseResponse', () => {
    it('should validate a valid base response', () => {
      const response = {
        success: true,
        message: 'Data retrieved successfully',
        data: { id: '123', name: 'Test Item' },
        timestamp: new Date().toISOString(),
      };

      const result = BaseResponseSchema.safeParse(response);
      expect(result.success).toBe(true);
    });

    it('should require success and message fields', () => {
      const invalidResponse = {
        data: { id: '123' },
        timestamp: new Date().toISOString(),
      };

      const result = BaseResponseSchema.safeParse(invalidResponse);
      expect(result.success).toBe(false);
    });

    it('should allow optional data field', () => {
      const response = {
        success: true,
        message: 'Operation completed',
        timestamp: new Date().toISOString(),
      };

      const result = BaseResponseSchema.safeParse(response);
      expect(result.success).toBe(true);
    });
  });

  describe('PaginatedBaseResponse', () => {
    it('should validate a valid paginated response', () => {
      const response = {
        success: true,
        message: 'Items retrieved successfully',
        data: [{ id: '1', name: 'Item 1' }, { id: '2', name: 'Item 2' }],
        timestamp: new Date().toISOString(),
        pagination: {
          page: 1,
          limit: 10,
          total: 25,
          totalPages: 3,
          hasNext: true,
          hasPrev: false,
        },
      };

      const result = PaginatedBaseResponseSchema.safeParse(response);
      expect(result.success).toBe(true);
    });

    it('should validate pagination constraints', () => {
      const invalidResponse = {
        success: true,
        message: 'Test',
        timestamp: new Date().toISOString(),
        pagination: {
          page: 0, // invalid - should be >= 1
          limit: 0, // invalid - should be >= 1
          total: -1, // invalid - should be >= 0
          totalPages: 1,
          hasNext: false,
          hasPrev: false,
        },
      };

      const result = PaginatedBaseResponseSchema.safeParse(invalidResponse);
      expect(result.success).toBe(false);
    });
  });

  describe('ErrorResponse', () => {
    it('should validate a valid error response', () => {
      const errorResponse = {
        success: false,
        message: 'Resource not found',
        timestamp: new Date().toISOString(),
        error: {
          code: 'NOT_FOUND',
          details: { resource: 'user', id: '123' },
        },
      };

      const result = ErrorResponseSchema.safeParse(errorResponse);
      expect(result.success).toBe(true);
    });

    it('should allow error without details', () => {
      const errorResponse = {
        success: false,
        message: 'Bad request',
        timestamp: new Date().toISOString(),
      };

      const result = ErrorResponseSchema.safeParse(errorResponse);
      expect(result.success).toBe(true);
    });
  });

  describe('Helper Functions', () => {
    describe('createSuccessResponse', () => {
      it('should create a valid success response', () => {
        const data = { id: '123', name: 'Test' };
        const response = createSuccessResponse(data, 'Test created');

        expect(response.success).toBe(true);
        expect(response.message).toBe('Test created');
        expect(response.data).toEqual(data);
        expect(response.timestamp).toBeDefined();
        expect(new Date(response.timestamp)).toBeInstanceOf(Date);
      });

      it('should use default message when not provided', () => {
        const data = { id: '123' };
        const response = createSuccessResponse(data);

        expect(response.message).toBe('Success');
      });
    });

    describe('createErrorResponse', () => {
      it('should create a valid error response', () => {
        const response = createErrorResponse('Validation failed', 'VALIDATION_ERROR', { field: 'email' });

        expect(response.success).toBe(false);
        expect(response.message).toBe('Validation failed');
        expect(response.error?.code).toBe('VALIDATION_ERROR');
        expect(response.error?.details).toEqual({ field: 'email' });
        expect(response.timestamp).toBeDefined();
      });

      it('should create error response without code and details', () => {
        const response = createErrorResponse('Something went wrong');

        expect(response.success).toBe(false);
        expect(response.message).toBe('Something went wrong');
        expect(response.error).toBeUndefined();
      });
    });

    describe('createPaginatedResponse', () => {
      it('should create a valid paginated response', () => {
        const items = [{ id: '1' }, { id: '2' }, { id: '3' }];
        const response = createPaginatedResponse(items, 2, 10, 25);

        expect(response.success).toBe(true);
        expect(response.data).toEqual(items);
        expect(response.pagination.page).toBe(2);
        expect(response.pagination.limit).toBe(10);
        expect(response.pagination.total).toBe(25);
        expect(response.pagination.totalPages).toBe(3);
        expect(response.pagination.hasNext).toBe(true);
        expect(response.pagination.hasPrev).toBe(true);
      });

      it('should calculate pagination correctly for first page', () => {
        const items = [{ id: '1' }, { id: '2' }];
        const response = createPaginatedResponse(items, 1, 10, 15);

        expect(response.pagination.hasPrev).toBe(false);
        expect(response.pagination.hasNext).toBe(true);
        expect(response.pagination.totalPages).toBe(2);
      });

      it('should calculate pagination correctly for last page', () => {
        const items = [{ id: '1' }];
        const response = createPaginatedResponse(items, 3, 10, 25);

        expect(response.pagination.hasPrev).toBe(true);
        expect(response.pagination.hasNext).toBe(false);
        expect(response.pagination.totalPages).toBe(3);
      });

      it('should handle empty results', () => {
        const response = createPaginatedResponse([], 1, 10, 0);

        expect(response.pagination.totalPages).toBe(0);
        expect(response.pagination.hasNext).toBe(false);
        expect(response.pagination.hasPrev).toBe(false);
      });

      it('should handle single page results', () => {
        const items = [{ id: '1' }, { id: '2' }];
        const response = createPaginatedResponse(items, 1, 10, 2);

        expect(response.pagination.totalPages).toBe(1);
        expect(response.pagination.hasNext).toBe(false);
        expect(response.pagination.hasPrev).toBe(false);
      });
    });
  });
});