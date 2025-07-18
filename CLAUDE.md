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
- **Hono best practice pattern** - no controller layer, routes use service layer directly

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

## 🎯 **MVP (Minimum Viable Product) Scope**

The MVP focuses on essential functionality to get the system operational quickly:

### **MVP Core Features**

1. **Authentication System** 🔐
   - User registration (OWNER role only for initial setup)
   - User login with JWT tokens
   - Basic role-based access control (OWNER, ADMIN)
   - Session management

2. **Product Management** 📦
   - OWNER and ADMIN can create products
   - Basic product information (name, barcode, price, quantity)
   - Category assignment
   - Store-scoped product management
   - Barcode generation with nanoid

3. **Sales Transactions** 💰
   - OWNER and ADMIN can create SALE transactions
   - Transaction items with product selection
   - Basic transaction recording
   - Photo proof upload capability
   - Transaction history

### **MVP User Roles (Simplified)**

- **OWNER**: Full access to all MVP features
- **ADMIN**: Limited access - can manage products and sales within assigned store
- **STAFF/CASHIER**: Not included in MVP (future enhancement)

### **MVP Business Rules**

- Products must have unique barcodes within owner scope
- SALE transactions require at least one product item
- Only OWNER and ADMIN roles can create products and transactions
- All data is owner-scoped (users only see data from their owner hierarchy)
- Soft delete for audit trail

### **MVP API Endpoints**

```
Authentication:
POST /api/v1/auth/register - Register new user (OWNER only)
POST /api/v1/auth/login    - User login

Products:
POST /api/v1/products      - Create product (OWNER/ADMIN)
GET  /api/v1/products      - List products (OWNER/ADMIN)
GET  /api/v1/products/:id  - Get product details (OWNER/ADMIN)
PUT  /api/v1/products/:id  - Update product (OWNER/ADMIN)

Transactions:
POST /api/v1/transactions  - Create SALE transaction (OWNER/ADMIN)
GET  /api/v1/transactions  - List transactions (OWNER/ADMIN)
GET  /api/v1/transactions/:id - Get transaction details (OWNER/ADMIN)
```

### **MVP Implementation Priority**

1. **Phase 1**: Authentication System
   - User registration/login
   - JWT token management
   - Basic middleware for auth

2. **Phase 2**: Product Management
   - Product CRUD operations
   - Category basic support
   - Barcode generation

3. **Phase 3**: Sales Transactions
   - SALE transaction creation
   - Transaction items management
   - Basic photo proof handling

### **MVP Exclusions (Future Features)**

- ❌ STAFF and CASHIER roles (simplified to OWNER/ADMIN only)
- ❌ Product checking system
- ❌ Cross-store transfers (TRANSFER_IN/TRANSFER_OUT)
- ❌ Advanced analytics and reporting
- ❌ IMEI tracking
- ❌ Complex store management
- ❌ Advanced photo proof validation
- ❌ Product quantity tracking updates
- ❌ Transaction status workflows

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

## 🚫 **CRITICAL DATABASE MODEL PROTECTION RULE** 🚫

**NEVER MODIFY ANY MODEL FILES WITHOUT EXPLICIT USER REQUEST**

The following model files are now **FROZEN** and cannot be changed without explicit user permission:

- `src/models/users.ts` - ✅ ERD Compliant
- `src/models/stores.ts` - ✅ ERD Compliant  
- `src/models/categories.ts` - ✅ ERD Compliant
- `src/models/products.ts` - ✅ ERD Compliant
- `src/models/transactions.ts` - ✅ ERD Compliant
- `src/models/product_checks.ts` - ✅ ERD Compliant
- `src/models/product_imeis.ts` - ✅ ERD Compliant

**Protection Rules:**
- ❌ **NO schema changes** without clear user request
- ❌ **NO field additions/removals** without clear user request
- ❌ **NO type changes** without clear user request
- ❌ **NO relation modifications** without clear user request
- ✅ **ONLY bug fixes** in business logic are allowed
- ✅ **ONLY new files** can be created (controllers, services, tests)

**Current ERD-Compliant Model Definitions:**

### Users Model (FROZEN)
```typescript
export const users = sqliteTable('users', {
  id: text('id').primaryKey(),
  ownerId: text('owner_id').references(() => users.id),
  name: text('name').notNull(),
  username: text('username').notNull().unique(),
  passwordHash: text('password_hash').notNull(),
  role: text('role', { enum: userRoles }).notNull(),
  storeId: text('store_id').references(() => stores.id),
  isActive: integer('is_active', { mode: 'boolean' }).default(true),
  createdAt: integer('created_at', { mode: 'timestamp' }).notNull().$defaultFn(() => new Date()),
  updatedAt: integer('updated_at', { mode: 'timestamp' }).notNull().$defaultFn(() => new Date()),
  deletedAt: integer('deleted_at', { mode: 'timestamp' }),
});
```

### Stores Model (FROZEN)
```typescript
export const stores = sqliteTable('stores', {
  id: text('id').primaryKey(),
  ownerId: text('owner_id').notNull().references(() => users.id),
  name: text('name').notNull(),
  code: text('code').notNull().unique(),
  type: text('type').notNull(),
  addressLine1: text('address_line1').notNull(),
  addressLine2: text('address_line2'),
  city: text('city').notNull(),
  province: text('province').notNull(),
  postalCode: text('postal_code').notNull(),
  country: text('country').notNull(),
  phoneNumber: text('phone_number').notNull(),
  email: text('email'),
  isActive: integer('is_active', { mode: 'boolean' }).default(true),
  openTime: integer('open_time', { mode: 'timestamp' }),
  closeTime: integer('close_time', { mode: 'timestamp' }),
  timezone: text('timezone').default('Asia/Jakarta'),
  mapLocation: text('map_location'),
  createdBy: text('created_by').notNull().references(() => users.id),
  createdAt: integer('created_at', { mode: 'timestamp' }).notNull().$defaultFn(() => new Date()),
  updatedAt: integer('updated_at', { mode: 'timestamp' }).notNull().$defaultFn(() => new Date()),
  deletedAt: integer('deleted_at', { mode: 'timestamp' }),
});
```

### Categories Model (FROZEN)
```typescript
export const categories = sqliteTable('categories', {
  id: text('id').primaryKey(),
  createdBy: text('created_by').notNull().references(() => users.id),
  name: text('name').notNull(),
  description: text('description'),
  createdAt: integer('created_at', { mode: 'timestamp' }).notNull().$defaultFn(() => new Date()),
  updatedAt: integer('updated_at', { mode: 'timestamp' }).notNull().$defaultFn(() => new Date()),
  deletedAt: integer('deleted_at', { mode: 'timestamp' }),
});
```

### Products Model (FROZEN)
```typescript
export const products = sqliteTable('products', {
  id: text('id').primaryKey(),
  createdBy: text('created_by').notNull().references(() => users.id),
  storeId: text('store_id').notNull().references(() => stores.id),
  name: text('name').notNull(),
  categoryId: text('category_id').references(() => categories.id),
  sku: text('sku').notNull(),
  isImei: integer('is_imei', { mode: 'boolean' }).default(false),
  barcode: text('barcode').notNull(),
  quantity: integer('quantity').default(1).notNull(),
  purchasePrice: real('purchase_price').notNull(),
  salePrice: real('sale_price'),
  createdAt: integer('created_at', { mode: 'timestamp' }).notNull().$defaultFn(() => new Date()),
  updatedAt: integer('updated_at', { mode: 'timestamp' }).notNull().$defaultFn(() => new Date()),
  deletedAt: integer('deleted_at', { mode: 'timestamp' }),
});
```

### Transactions Model (FROZEN)
```typescript
export const transactionTypes = ['SALE', 'TRANSFER_IN', 'TRANSFER_OUT'] as const;

export const transactions = sqliteTable('transactions', {
  id: text('id').primaryKey(),
  type: text('type', { enum: transactionTypes }).notNull(),
  createdBy: text('created_by').references(() => users.id),
  approvedBy: text('approved_by').references(() => users.id),
  fromStoreId: text('from_store_id').references(() => stores.id),
  toStoreId: text('to_store_id').references(() => stores.id),
  photoProofUrl: text('photo_proof_url'),
  transferProofUrl: text('transfer_proof_url'),
  to: text('to'),
  customerPhone: text('customer_phone'),
  amount: real('amount'),
  isFinished: integer('is_finished', { mode: 'boolean' }).default(false),
  createdAt: integer('created_at', { mode: 'timestamp' }).notNull().$defaultFn(() => new Date()),
});

export const transactionItems = sqliteTable('transaction_items', {
  id: text('id').primaryKey().$defaultFn(() => randomUUID()),
  transactionId: text('transaction_id').notNull().references(() => transactions.id),
  productId: text('product_id').notNull().references(() => products.id),
  name: text('name').notNull(),
  price: real('price').notNull(),
  quantity: integer('quantity').notNull(),
  amount: real('amount'),
  createdAt: integer('created_at', { mode: 'timestamp' }).notNull().$defaultFn(() => new Date()),
});
```

### Product Checks Model (FROZEN)
```typescript
export const checkStatus = ['PENDING', 'OK', 'MISSING', 'BROKEN'] as const;

export const productChecks = sqliteTable('product_checks', {
  id: text('id').primaryKey(),
  productId: text('product_id').notNull().references(() => products.id),
  checkedBy: text('checked_by').notNull().references(() => users.id),
  storeId: text('store_id').notNull().references(() => stores.id),
  status: text('status', { enum: checkStatus }).notNull(),
  note: text('note'),
  checkedAt: integer('checked_at', { mode: 'timestamp' }).notNull().$defaultFn(() => new Date()),
});
```

### Product IMEIs Model (FROZEN)
```typescript
export const productImeis = sqliteTable('product_imeis', {
  id: text('id').primaryKey(),
  productId: text('product_id').notNull().references(() => products.id),
  imei: text('imei').notNull(),
  createdBy: text('created_by').notNull().references(() => users.id),
  createdAt: integer('created_at', { mode: 'timestamp' }).notNull().$defaultFn(() => new Date()),
  updatedAt: integer('updated_at', { mode: 'timestamp' }).notNull().$defaultFn(() => new Date()),
});
```

**⚠️ VIOLATION WARNING**: Any attempt to modify these models without explicit user request will be REFUSED.

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
- **transactions**: Support for `SALE`, `TRANSFER_IN`, `TRANSFER_OUT`
- **product_checks**: Inventory verification with status tracking
- **product_imeis**: IMEI tracking for electronic products

**MVP Implementation Priority (Current Status)**

1. **MVP Phase 1**: Authentication System ❌ **NOT IMPLEMENTED**
   - ❌ **Auth controllers (register/login)**
   - ❌ **JWT token management**
   - ❌ **Auth middleware**
   - ❌ **User registration/login routes**
   - ❌ **Password hashing utilities**
   - ❌ **Auth schemas and validation**

2. **MVP Phase 2**: Product Management ❌ **NOT IMPLEMENTED**
   - ❌ **Product controllers (CRUD)**
   - ❌ **Product services and repositories**
   - ❌ **Product routes with OWNER/ADMIN access**
   - ❌ **Product schemas and validation**
   - ❌ **Barcode generation with nanoid**
   - ❌ **Category basic support**

3. **MVP Phase 3**: Sales Transactions ❌ **NOT IMPLEMENTED**
   - ❌ **Transaction controllers (SALE only)**
   - ❌ **Transaction services and repositories**
   - ❌ **Transaction routes with OWNER/ADMIN access**
   - ❌ **Transaction schemas and validation**
   - ❌ **Transaction items management**
   - ❌ **Photo proof upload handling**

**Foundation Status:**
- ✅ **Database models (all entities defined)**
- ✅ **Server infrastructure (Hono + OpenAPI)**
- ✅ **Test framework configuration**
- ❌ **All API implementation layers missing**

### Key Development Notes

- ✅ Backend infrastructure is complete and ready for API development
- ✅ Database schema is fully implemented with proper relationships and constraints
- ✅ All database tables include soft delete functionality (`deletedAt` timestamp)
- ✅ Environment configuration supports development/production/test environments
- ✅ Testing framework (Vitest) is configured and ready for use
- ✅ API server has OpenAPI/Swagger documentation at `/ui` endpoint
- ✅ Database connections configured for both SQLite (testing) and Turso (production)
- ❌ **CRITICAL**: All implementation layers are missing (controllers, services, repositories, routes, schemas)
- ❌ **URGENT**: API only serves health check - no functional endpoints exist
- **Next priority**: Build complete API implementation from scratch following established patterns

### Coding Standards

- **DRY (Don't Repeat Yourself)**: Avoid code duplication, extract reusable functions
- **KISS (Keep It Simple, Stupid)**: Favor simple, straightforward solutions over complex ones
- **Modular**: Keep code organized in logical modules/files, even without strict Clean Architecture
- **Consistent naming**: Use clear, descriptive variable and function names
- **Zod imports**: Always use `z` from `@hono/zod-openapi` instead of directly importing from `zod` package for OpenAPI compatibility
- **Testing scope**: Test services only at the controller layer - no separate service layer unit tests, focus on integration testing through HTTP endpoints
- **Drizzle ORM select statements**: Always use `.select()` without arguments to avoid TypeScript strict mode issues. Use `.select({ field: table.field })` pattern only when absolutely necessary for specific field selection, but prefer full record selection with `.select()` for consistency

### 🔧 **MANDATORY API RESPONSE STANDARDS** 🔧

**ALL API endpoints MUST follow these standardized response patterns:**

#### **Response Format Requirements:**
- **✅ ALWAYS use `ResponseUtils`** from `src/utils/responses.ts` for ALL API responses
- **✅ ALWAYS use Zod schemas** from `@hono/zod-openapi` for request/response validation
- **✅ ALWAYS handle errors** through `ResponseUtils.sendError()` for consistent error formatting
- **✅ NEVER return raw data** - all responses must use `BaseResponse<T>` or `PaginatedResponse<T>` format

#### **Required Response Methods:**
```typescript
// ✅ SUCCESS responses
ResponseUtils.sendSuccess(c, data, 200)           // Standard success
ResponseUtils.sendCreated(c, data)                // 201 Created
ResponseUtils.sendSuccessNoData(c, 204)           // 204 No Content
ResponseUtils.sendPaginated(c, data, pagination)  // Paginated lists

// ✅ ERROR responses
ResponseUtils.sendError(c, error)                 // All errors
```

#### **Required Response Structure:**
```typescript
// ✅ Success Response Format
{
  "success": true,
  "data": T,                    // Actual response data
  "timestamp": "2024-01-01T00:00:00.000Z"
}

// ✅ Error Response Format  
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",  // Standardized error code
    "message": "Descriptive error message"
  },
  "timestamp": "2024-01-01T00:00:00.000Z"
}

// ✅ Paginated Response Format
{
  "success": true,
  "data": T[],                  // Array of items
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 50,
    "totalPages": 5,
    "hasNext": true,
    "hasPrev": false
  },
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

#### **Schema Validation Requirements:**
- **✅ Request validation**: Use `ValidationMiddleware.body()`, `ValidationMiddleware.query()`, `ValidationMiddleware.params()`
- **✅ Response schemas**: Define OpenAPI response schemas using `z.object()` patterns
- **✅ Error handling**: All validation errors automatically formatted through `ValidationError` class
- **✅ Type safety**: Use `getValidated<T>(c, 'validatedBody')` helper to extract validated data

#### **Example Implementation Pattern:**
```typescript
// ✅ CORRECT Implementation
export const createProduct = async (c: Context) => {
  try {
    const validatedData = getValidated<CreateProductRequest>(c, 'validatedBody');
    const product = await ProductService.create(validatedData);
    return ResponseUtils.sendCreated(c, product);
  } catch (error) {
    return ResponseUtils.sendError(c, error);
  }
};

// ❌ INCORRECT - Never do this
export const createProduct = async (c: Context) => {
  try {
    const product = await ProductService.create(data);
    return c.json({ data: product, status: 'ok' }); // ❌ Wrong format
  } catch (error) {
    return c.json({ error: error.message }, 500);   // ❌ Wrong format
  }
};
```

#### **Enforcement Rules:**
- **🚫 NO direct `c.json()` calls** - always use `ResponseUtils` methods
- **🚫 NO custom response formats** - stick to `BaseResponse`/`PaginatedResponse` interfaces
- **🚫 NO manual error formatting** - always use `ResponseUtils.sendError()`
- **🚫 NO skipping validation** - all endpoints must validate input with Zod schemas
- **✅ CONSISTENT timestamps** - all responses include standardized timestamp
- **✅ PROPER HTTP status codes** - use semantic status codes (200, 201, 400, 401, 403, 404, 500)

**⚠️ VIOLATION WARNING**: Any endpoint that doesn't follow these response standards will be REFUSED and must be refactored.

### ⚠️ CRITICAL TESTING RULE ⚠️

**NEVER IGNORE OR UNDERESTIMATE TESTS - NO MATTER WHAT**

- **Tests are MANDATORY**: Every feature implementation MUST include comprehensive tests
- **Test failures are CRITICAL**: All test failures must be investigated and fixed thoroughly  
- **No shortcuts on testing**: Never dismiss tests as "working enough" or skip proper test implementation
- **Follow established patterns**: Always use the proven test utilities and patterns from existing working tests
- **Role-based testing is essential**: All business logic must be tested across all user roles (OWNER, ADMIN, STAFF, CASHIER)
- **Test before deployment**: Code is not considered complete until all tests pass
- **Quality over speed**: Take time to write proper, comprehensive tests rather than rushing implementations

**Critical Testing Requirements:**
- **Use proper test utilities**: Always import from `../utils` and use `createTestApp`, `createUserHierarchy`, etc.
- **Test all user roles**: OWNER, ADMIN, STAFF, CASHIER with appropriate permissions
- **Test cross-owner access**: Ensure users cannot access data from different owners
- **Test authentication**: Verify 401 responses for unauthenticated requests
- **Test validation**: Check 400 responses for invalid input data
- **Test error scenarios**: Cover all business rule violations and edge cases
- **Follow established patterns**: Copy patterns from working tests like `user.routes.test.ts` and `store.routes.test.ts`

## Next Implementation Steps

When implementing new modules (stores, products, transactions, etc.), follow these established patterns:

1. **Create Zod schemas** in `src/schemas/[entity].schemas.ts`
2. **Define routes** with OpenAPI documentation in `src/routes/[entity].routes.ts`  
3. **Implement controller** with proper error handling in `src/controllers/[entity].controller.ts`
4. **Create service** with business logic and custom errors in `src/services/[entity].service.ts`
5. **Add integration tests** covering all roles and scenarios in `tests/routes/[entity].routes.test.ts`
