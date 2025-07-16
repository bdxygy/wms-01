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

1. **Phase 1**: API Controllers & Routes (⏳ **IN PROGRESS**)
   - ✅ **BaseResponse and PaginatedBaseResponse types completed**
   - ✅ **Response utilities with zod validation completed**
   - Authentication endpoints
   - User management endpoints
   - Store management endpoints
   - Product management endpoints
   - Transaction endpoints
   - Product checking endpoints

2. **Phase 2**: Business Logic & Services (⏳ **PENDING**)
   - Service layer implementation
   - Repository layer implementation
   - Role-based authorization middleware
   - Business rule validation

3. **Phase 3**: Testing & Documentation (⏳ **PENDING**)
   - Unit tests for all services
   - Integration tests for API endpoints
   - API documentation completion
   - Error handling standardization

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
