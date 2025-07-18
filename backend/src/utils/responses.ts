import { Context } from "hono";
import { HTTPException } from "hono/http-exception";
import { z } from "zod";

export interface BaseResponse<T = unknown> {
  success: true;
  data: T;
  timestamp: string;
}

export interface ErrorResponse {
  success: false;
  error: {
    code: string;
    message: string;
  };
  timestamp: string;
}

export interface PaginatedResponse<T = unknown> {
  success: true;
  data: T[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
    hasNext: boolean;
    hasPrev: boolean;
  };
  timestamp: string;
}

export type ApiResponse<T = unknown> =
  | BaseResponse<T>
  | ErrorResponse
  | PaginatedResponse<T>;

export class ResponseUtils {
  static sendSuccess<T>(c: Context, data: T, status: number = 200): Response {
    return c.json(
      {
        success: true,
        data,
        timestamp: new Date().toISOString(),
      } as BaseResponse<T>,
      { status: status as any }
    );
  }

  static sendCreated<T>(c: Context, data: T): Response {
    return c.json(
      {
        success: true,
        data,
        timestamp: new Date().toISOString(),
      } as BaseResponse<T>,
      { status: 201 }
    );
  }

  static sendSuccessNoData(c: Context, status: number = 204): Response {
    return c.json(
      {
        success: true,
        data: null,
        timestamp: new Date().toISOString(),
      } as BaseResponse<null>,
      { status: status as any }
    );
  }

  static sendPaginated<T>(
    c: Context,
    data: T[],
    pagination: {
      page: number;
      limit: number;
      total: number;
      totalPages: number;
      hasNext: boolean;
      hasPrev: boolean;
    }
  ): Response {
    return c.json(
      {
        success: true,
        data,
        pagination,
        timestamp: new Date().toISOString(),
      } as PaginatedResponse<T>,
      { status: 200 }
    );
  }

  static sendError(c: Context, error: unknown): Response {
    const timestamp = new Date().toISOString();

    if (error instanceof HTTPException) {
      return c.json(
        {
          success: false,
          error: {
            code: `HTTP_${error.status}`,
            message: error.message,
          },
          timestamp,
        } as ErrorResponse,
        { status: error.status as any }
      );
    }

    if (error instanceof z.ZodError) {
      return c.json(
        {
          success: false,
          error: {
            code: "VALIDATION_ERROR",
            message: error.errors
              .map((e) => `${e.path.join(".")}: ${e.message}`)
              .join(", "),
          },
          timestamp,
        } as ErrorResponse,
        { status: 400 }
      );
    }

    if (error instanceof Error) {
      return c.json(
        {
          success: false,
          error: {
            code: "INTERNAL_ERROR",
            message: error.message,
          },
          timestamp,
        } as ErrorResponse,
        { status: 500 }
      );
    }

    return c.json(
      {
        success: false,
        error: {
          code: "UNKNOWN_ERROR",
          message: "An unknown error occurred",
        },
        timestamp,
      } as ErrorResponse,
      { status: 500 }
    );
  }

  static unauthorized(c: Context, message: string = "Unauthorized"): Response {
    return c.json(
      {
        success: false,
        error: {
          code: "UNAUTHORIZED",
          message,
        },
        timestamp: new Date().toISOString(),
      } as ErrorResponse,
      { status: 401 }
    );
  }
}

export const responses = ResponseUtils;
