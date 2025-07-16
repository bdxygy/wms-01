# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Warehouse Management System (WMS)** - A web-based inventory management system for tracking goods across multiple stores with role-based access control.

### Tech Stack

- **Frontend**: React, Shadcn, Zod, React Query, Tailwindcss, Rsbuild
- **Backend**: Hono, Node.js, @hono/swagger-ui, @hono/zod-openapi, Drizzle, SQLite Turso
- **Database**: SQLite with Drizzle ORM
- **Authentication**: JWT-based with role-based access control

### Architecture

- **Service layer** for business logic
- **Soft delete** for audit trail
- **Owner-scoped data access** for non-owner roles

### Role Hierarchy & Permissions

1. **OWNER**: Full system access, can manage multiple stores and all user roles
2. **ADMIN**: Store-scoped CRU access (no delete), can manage STAFF users only
3. **STAFF**: Read-only + product checking across owner's stores
4. **CASHIER**: SALE transactions only, read access to owner's stores

### Key Features

- Multi-store inventory management
- Barcode scanning for product tracking
- Photo proof requirements for sales
- Product checking system (PENDING/OK/MISSING/BROKEN)
- Cross-store transfers
- Analytics and reporting
- Role-based dashboards

### Development Commands

Backend commands (from `/backend` directory):

```bash
# Development
pnpm install
pnpm run dev          # Start development server with tsx watch
pnpm run build        # Build TypeScript to dist/
pnpm run start        # Start production server

# Testing
pnpm run test         # Run Vitest tests
pnpm run test:watch   # Run tests in watch mode
pnpm run test:coverage # Run tests with coverage
pnpm run test:ui      # Run tests with UI
pnpm run test:integration # Run integration tests

# Database
pnpm run db:generate  # Generate Drizzle client
pnpm run db:migrate   # Run database migrations
pnpm run db:seed      # Seed database with test data
pnpm run db:studio    # Open Drizzle Studio

# Code Quality
pnpm run lint         # Run ESLint
pnpm run lint:fix     # Fix ESLint issues
pnpm run typecheck    # Run TypeScript type checking

# Frontend setup (when implemented)
cd frontend
pnpm install
pnpm run dev          # Start frontend dev server
pnpm run build        # Build for production
pnpm run preview      # Preview production build
pnpm run test         # Run frontend tests
```

### Project Structure

When implementing, follow this structure:

```
/
├── backend/                 # Hono.js API server
│   ├── src/
│   │   ├── controllers/     # HTTP request handlers
│   │   ├── services/        # Business logic layer
│   │   ├── repositories/    # Data access layer
│   │   ├── models/          # Drizzle schema definitions
│   │   ├── middleware/      # Auth, validation, error handling
│   │   ├── routes/          # API route definitions
│   │   ├── utils/           # Shared utilities
│   │   └── config/          # Configuration files
│   ├── tests/               # Backend test files
│   └── package.json
├── frontend/                # React frontend
│   ├── src/
│   │   ├── components/      # React components
│   │   ├── pages/           # Page components
│   │   ├── hooks/           # Custom React hooks
│   │   ├── services/        # API service layer
│   │   ├── stores/          # State management
│   │   └── utils/           # Frontend utilities
│   └── package.json
├── docs/                    # Project documentation
└── CLAUDE.md               # This file
```

### Database Schema

Key entities defined in `docs/erd.md`:

- **users**: Role-based user management with owner hierarchy
- **stores**: Multi-store support per owner
- **products**: Inventory items with barcode tracking
- **transactions**: SALE and TRANSFER operations with photo proof
- **product_checks**: Regular inventory verification system

### Business Rules to Enforce

- **Barcode uniqueness**: System-wide for OWNER, store-scoped for ADMIN
- **Photo proof**: Required for all SALE transactions
- **Soft delete**: All entities use soft delete for audit trail
- **Role restrictions**: Strict RBAC enforcement per user stories
- **Owner scoping**: Non-OWNER roles access all stores under same owner
- **Transaction types**: CASHIER restricted to SALE only
- **Delete permissions**: ADMIN cannot delete users, categories, products, transactions

### Testing Strategy

Based on `docs/features/backend_ut_checklist.md`:

- **Unit tests**: All service methods and business logic
- **Integration tests**: API endpoints and database operations
- **Role-based tests**: Comprehensive RBAC testing per user role
- **Validation tests**: Input validation and error handling
- **Security tests**: SQL injection, XSS prevention, authentication

### Implementation Status

**Backend Infrastructure** ✅ **COMPLETED**
- Hono.js server setup with OpenAPI/Swagger documentation
- Environment configuration with Zod validation
- Database setup with Drizzle ORM (SQLite/Turso)
- Complete database schema with migrations
- Vitest testing framework configured
- Code quality tools (ESLint, TypeScript) configured

**Database Schema** ✅ **COMPLETED**
- **users**: Role-based user management (`OWNER`, `ADMIN`, `STAFF`, `CASHIER`)
- **stores**: Multi-store support with owner relationships
- **categories**: Product categorization system
- **products**: Full product management with barcode, pricing, stock levels
- **transactions**: Support for `SALE`, `TRANSFER`, `ADJUSTMENT`, `RESTOCK`
- **product_checks**: Inventory verification with status tracking

**Implementation Priority (Updated)**

1. **Phase 1**: API Controllers & Routes ✅ **COMPLETED**
   - ✅ **BaseResponse and PaginatedBaseResponse types completed**
   - ✅ **Response utilities with Zod validation completed**
   - ✅ **User management endpoints with full CRUD operations**
   - ✅ **Zod schema validation for all requests**
   - ✅ **Role-based authorization and error handling**
   - ✅ **OpenAPI documentation with Swagger UI**
   - Authentication endpoints
   - Store management endpoints
   - Product management endpoints
   - Transaction endpoints
   - Product checking endpoints

2. **Phase 2**: Business Logic & Services ✅ **COMPLETED** (User Module)
   - ✅ **Service layer implementation with business logic**
   - ✅ **Repository layer implementation with data access**
   - ✅ **Role-based authorization middleware**
   - ✅ **Business rule validation with custom error types**
   - ✅ **Comprehensive error handling system**

3. **Phase 3**: Testing & Documentation ✅ **COMPLETED** (User Module)
   - ✅ **Integration tests for API endpoints**
   - ✅ **Role-based access control testing**
   - ✅ **API documentation with OpenAPI/Swagger**
   - ✅ **Error handling standardization**

4. **Phase 4**: Frontend Implementation (⏳ **PENDING**)
   - React frontend with Shadcn UI
   - Authentication flow
   - Role-based dashboards
   - Product and inventory management
   - Transaction processing

### Key Development Notes

- Backend infrastructure is complete and ready for API development
- Database schema is fully implemented with proper relationships and constraints
- All database tables include soft delete functionality (`deletedAt` timestamp)
- Environment configuration supports development/production/test environments
- Testing framework (Vitest) is configured and ready for use
- API server has OpenAPI/Swagger documentation at `/ui` endpoint
- Next priority: Implement controllers, services, and routes for each entity
- Use existing Zod schemas from models for request/response validation
- Implement proper role-based access control in middleware
- Database connections configured for both SQLite (testing) and Turso (production)

### Coding Standards

- **DRY (Don't Repeat Yourself)**: Avoid code duplication, extract reusable functions
- **KISS (Keep It Simple, Stupid)**: Favor simple, straightforward solutions over complex ones
- **Modular**: Keep code organized in logical modules/files, even without strict Clean Architecture
- **Consistent naming**: Use clear, descriptive variable and function names
- **Zod imports**: Always use `z` from `@hono/zod-openapi` instead of directly importing from `zod` package for OpenAPI compatibility
- **Testing scope**: Test services only at the controller layer - no separate service layer unit tests, focus on integration testing through HTTP endpoints

## Standard Implementation Patterns

### Error Handling Pattern ✅ **REFERENCE IMPLEMENTATION**

All service methods should use custom error classes for proper HTTP status code mapping:

```typescript
// src/utils/errors.ts
export class BusinessError extends Error {
  constructor(
    message: string,
    public readonly statusCode: number = 400,
    public readonly code: string = 'BUSINESS_ERROR'
  ) {
    super(message);
    this.name = 'BusinessError';
  }
}

export class ValidationError extends BusinessError {
  constructor(message: string) {
    super(message, 400, 'VALIDATION_ERROR');
  }
}

export class AuthorizationError extends BusinessError {
  constructor(message: string) {
    super(message, 403, 'AUTHORIZATION_ERROR');
  }
}

export class NotFoundError extends BusinessError {
  constructor(message: string) {
    super(message, 404, 'NOT_FOUND');
  }
}

export function handleServiceError(error: unknown) {
  if (error instanceof BusinessError) {
    return {
      message: error.message,
      statusCode: error.statusCode,
      code: error.code,
    };
  }
  // Handle other error types...
}
```

### Controller Pattern ✅ **REFERENCE IMPLEMENTATION**

Controllers should handle HTTP concerns and delegate to services:

```typescript
// src/controllers/[entity].controller.ts
import { Context } from "hono";
import { EntityService } from "../services/entity.service";
import { CreateEntityRequest, UpdateEntityRequest } from "../schemas/entity.schemas";
import { createBaseResponse } from "../utils/response";
import { handleServiceError } from "../utils/errors";

export class EntityController {
  private entityService: EntityService;

  constructor() {
    this.entityService = new EntityService();
  }

  async createEntity(c: Context) {
    try {
      const requestingUser = c.get("user") as User;
      
      if (!requestingUser) {
        return c.json(
          createBaseResponse(false, "Unauthorized", null, {
            code: "UNAUTHORIZED",
            details: "Authentication required",
          }),
          401
        );
      }

      const data = (await c.req.json()) as CreateEntityRequest;
      const entity = await this.entityService.createEntity(data, requestingUser);

      return c.json(
        createBaseResponse(true, "Entity created successfully", entity),
        201
      );
    } catch (error) {
      const { message, statusCode, code, details } = handleServiceError(error);
      return c.json(
        createBaseResponse(false, message, null, { code, details }),
        statusCode
      );
    }
  }
}
```

### Service Pattern ✅ **REFERENCE IMPLEMENTATION**

Services contain business logic and throw custom errors:

```typescript
// src/services/[entity].service.ts
import { EntityRepository } from '../repositories/entity.repository';
import { ValidationError, AuthorizationError, NotFoundError } from '../utils/errors';
import { CreateEntityRequest, UpdateEntityRequest } from '../schemas/entity.schemas';

export class EntityService {
  private entityRepository: EntityRepository;

  constructor() {
    this.entityRepository = new EntityRepository();
  }

  async createEntity(data: CreateEntityRequest, requestingUser: User): Promise<Entity> {
    // Business validation
    this.validateEntityCreation(data, requestingUser);

    // Create entity
    const newEntity: NewEntity = {
      id: nanoid(),
      ...data,
      ownerId: this.determineOwnerId(requestingUser),
    };

    return await this.entityRepository.create(newEntity);
  }

  private validateEntityCreation(data: CreateEntityRequest, requestingUser: User): void {
    if (requestingUser.role === 'STAFF') {
      throw new AuthorizationError('Staff users cannot create entities');
    }
    
    if (!data.name || data.name.trim().length === 0) {
      throw new ValidationError('Entity name is required');
    }
  }
}
```

### Route Pattern ✅ **REFERENCE IMPLEMENTATION**

Routes define OpenAPI schemas and delegate to controllers:

```typescript
// src/routes/[entity].routes.ts
import { OpenAPIHono, createRoute } from '@hono/zod-openapi';
import { EntityController } from '../controllers/entity.controller';
import {
  CreateEntityRequestSchema,
  EntitySuccessResponseSchema,
  ErrorResponseSchema,
} from '../schemas/entity.schemas';

const entityRoutes = new OpenAPIHono();
const entityController = new EntityController();

const createEntityRoute = createRoute({
  method: 'post',
  path: '/',
  tags: ['Entities'],
  summary: 'Create a new entity',
  request: {
    body: {
      content: {
        'application/json': {
          schema: CreateEntityRequestSchema,
        },
      },
    },
  },
  responses: {
    201: {
      content: {
        'application/json': {
          schema: EntitySuccessResponseSchema,
        },
      },
      description: 'Entity created successfully',
    },
    400: {
      content: {
        'application/json': {
          schema: ErrorResponseSchema,
        },
      },
      description: 'Validation error',
    },
    401: {
      content: {
        'application/json': {
          schema: ErrorResponseSchema,
        },
      },
      description: 'Authentication required',
    },
  },
});

entityRoutes.openapi(createEntityRoute, async (c) => await entityController.createEntity(c));

export { entityRoutes };
```

### Schema Pattern ✅ **REFERENCE IMPLEMENTATION**

Schemas define Zod validation and TypeScript types:

```typescript
// src/schemas/[entity].schemas.ts
import { z } from '@hono/zod-openapi';

// Request schemas
export const CreateEntityRequestSchema = z.object({
  name: z.string().min(1).openapi({
    description: 'Entity name',
    example: 'Sample Entity'
  }),
  description: z.string().optional().openapi({
    description: 'Entity description'
  }),
});

// Response schemas
export const EntityResponseSchema = z.object({
  id: z.string().openapi({ description: 'Entity ID' }),
  name: z.string().openapi({ description: 'Entity name' }),
  ownerId: z.string().openapi({ description: 'Owner ID' }),
  createdAt: z.string().datetime(),
  updatedAt: z.string().datetime(),
});

// Type exports
export type CreateEntityRequest = z.infer<typeof CreateEntityRequestSchema>;
export type EntityResponse = z.infer<typeof EntityResponseSchema>;

// API response wrappers
export const EntitySuccessResponseSchema = ApiResponseSchema(EntityResponseSchema);
export const ErrorResponseSchema = ApiResponseSchema(z.never());
```

### Response Utilities ✅ **REFERENCE IMPLEMENTATION**

Standardized response creation:

```typescript
// src/utils/response.ts
export interface BaseResponse {
  success: boolean;
  message: string;
  data?: any;
  error?: { code: string; details?: any };
  timestamp: string;
}

export function createBaseResponse<T>(
  success: boolean,
  message: string,
  data?: T,
  error?: { code: string; details?: any },
  timestamp: string = new Date().toISOString()
): BaseResponse {
  return {
    success,
    message,
    data,
    error,
    timestamp,
  };
}

export function createPaginatedResponse<T>(
  data: T[],
  page: number,
  limit: number,
  total: number,
  message: string = "Data retrieved successfully"
) {
  const totalPages = Math.ceil(total / limit);
  return {
    success: true,
    message,
    data,
    timestamp: new Date().toISOString(),
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
```

### Validation & Error Mapping ✅ **ESTABLISHED STANDARDS**

- **400 Bad Request**: Input validation errors (handled by Zod automatically)
- **401 Unauthorized**: Authentication required
- **403 Forbidden**: Authorization/permission errors (use `AuthorizationError`)
- **404 Not Found**: Resource not found (use `NotFoundError`)
- **409 Conflict**: Resource conflicts like duplicate emails (use `ConflictError`)
- **500 Internal Server Error**: Unexpected errors

### Testing Pattern ✅ **REFERENCE IMPLEMENTATION**

Integration tests focus on HTTP endpoints with role-based scenarios:

```typescript
// tests/routes/[entity].routes.test.ts
import { testClient } from 'hono/testing';
import { app } from '../../src/index';

describe('Entity Routes', () => {
  it('should create entity as OWNER', async () => {
    const client = testClient(app);
    
    const response = await client.api.v1.entities.$post({
      json: {
        name: 'Test Entity',
        description: 'Test Description'
      }
    });
    
    expect(response.status).toBe(201);
    const body = await response.json();
    expect(body.success).toBe(true);
    expect(body.data.name).toBe('Test Entity');
  });

  it('should return 403 for unauthorized role', async () => {
    // Test with STAFF user
    const response = await client.api.v1.entities.$post({
      json: { name: 'Test' }
    });
    
    expect(response.status).toBe(403);
    const body = await response.json();
    expect(body.success).toBe(false);
    expect(body.error.code).toBe('AUTHORIZATION_ERROR');
  });
});
```

## Next Implementation Steps

When implementing new modules (stores, products, transactions, etc.), follow these established patterns:

1. **Create Zod schemas** in `src/schemas/[entity].schemas.ts`
2. **Define routes** with OpenAPI documentation in `src/routes/[entity].routes.ts`  
3. **Implement controller** with proper error handling in `src/controllers/[entity].controller.ts`
4. **Create service** with business logic and custom errors in `src/services/[entity].service.ts`
5. **Add integration tests** covering all roles and scenarios in `tests/routes/[entity].routes.test.ts`

All patterns are based on the **User module implementation** which serves as the reference standard.
