/**
 * Custom error classes for the WMS application
 * Provides standardized error handling with HTTP status codes
 */

import { ContentfulStatusCode } from "hono/utils/http-status";

export abstract class BaseError extends Error {
  abstract readonly statusCode: number;
  abstract readonly code: string;

  constructor(message: string, public readonly cause?: Error) {
    super(message);
    this.name = this.constructor.name;
    Error.captureStackTrace(this, this.constructor);
  }

  toJSON() {
    return {
      name: this.name,
      code: this.code,
      message: this.message,
      statusCode: this.statusCode,
      ...(this.cause && { cause: this.cause.message }),
    };
  }
}

export class ValidationError extends BaseError {
  readonly statusCode = 400;
  readonly code = "VALIDATION_ERROR";

  constructor(message: string, cause?: Error) {
    super(message, cause);
  }
}

export class AuthenticationError extends BaseError {
  readonly statusCode = 401;
  readonly code = "AUTHENTICATION_ERROR";

  constructor(message: string = "Authentication required", cause?: Error) {
    super(message, cause);
  }
}

export class AuthorizationError extends BaseError {
  readonly statusCode = 403;
  readonly code = "AUTHORIZATION_ERROR";

  constructor(message: string = "Insufficient permissions", cause?: Error) {
    super(message, cause);
  }
}

export class NotFoundError extends BaseError {
  readonly statusCode = 404;
  readonly code = "NOT_FOUND";

  constructor(resource: string = "Resource", cause?: Error) {
    super(`${resource} not found`, cause);
  }
}

export class ConflictError extends BaseError {
  readonly statusCode = 409;
  readonly code = "CONFLICT";

  constructor(message: string, cause?: Error) {
    super(message, cause);
  }
}

export class InternalServerError extends BaseError {
  readonly statusCode = 500;
  readonly code = "INTERNAL_SERVER_ERROR";

  constructor(message: string = "Internal server error", cause?: Error) {
    super(message, cause);
  }
}

/**
 * Error handling utility functions
 */
export class ErrorHandler {
  /**
   * Checks if an error is a known application error
   */
  static isAppError(error: unknown): error is BaseError {
    return error instanceof BaseError;
  }

  /**
   * Converts unknown errors to standardized format
   */
  static normalize(error: unknown): BaseError {
    if (this.isAppError(error)) {
      return error;
    }

    if (error instanceof Error) {
      return new InternalServerError(error.message, error);
    }

    return new InternalServerError("An unexpected error occurred");
  }

  /**
   * Extracts error details for API responses
   */
  static getErrorResponse(error: unknown) {
    const normalizedError = this.normalize(error);
    return {
      success: false,
      error: {
        code: normalizedError.code,
        message: normalizedError.message,
      },
      statusCode: normalizedError.statusCode as ContentfulStatusCode,
    };
  }
}
