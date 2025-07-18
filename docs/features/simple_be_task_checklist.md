# Backend Unit Test Cases Checklist

This document consolidates all unit test cases from user stories organized by role-based access control patterns, eliminating redundancy.

---

## 🎯 **MVP PHASES (1-3)** - Core Functionality

### **Phase 1: Foundation & Authentication** 🔐

**Priority**: Critical - Must be completed first

- [x] **AuthRoutes** - Authentication endpoints
  - [x] POST /api/v1/dev/register - User Registration just for developer access must use basic auth
  - [x] POST /api/v1/auth/register - User registration
  - [x] POST /api/v1/auth/login - User login
  - [x] POST /api/v1/auth/refresh - Token refresh
- [x] **Auth Middleware** - Request authentication
  - [x] create middleware using `import` { createMiddleware } from 'hono/factory'`
  - [x] JWT token verification
  - [x] User context injection
  - [x] Protected route handling
- [x] **Auth Schemas** - Request/response validation
  - [x] Registration request schema
  - [x] Login request schema
  - [x] Auth response schemas

### **Phase 2: User Management** 👥

**Priority**: Critical - Required for role-based access

#### [P2.1] User System (users table)

- [x]  **UserRoutes** - HTTP request handlers
  - [x]  POST /api/v1/users - Create user (OWNER or ADMIN (Admin just available to create user STAFF role))
  - [x]  GET /api/v1/users - List users (filtered by owner)
  - [x]  GET /api/v1/users/:id - Get user details
  - [x]  PUT /api/v1/users/:id - Update user
  - [x]  DELETE /api/v1/users/:id - Soft delete user (OWNER only)
- [x]  **User Schemas** - Request/response validation
  - [x]  Create user request schema
  - [x]  Update user request schema
  - [x]  User response schemas
  - [x]  User list with pagination

### **Phase 3: Product Management** 📦

**Priority**: Critical - Core business functionality

#### [P3.1] Category System (categories table)

- [x] **CategoryRoutes** - Category management endpoints
  - [x] POST /api/v1/categories - Create category
  - [x] GET /api/v1/categories - List categories
  - [x] GET /api/v1/categories/:id - Get category details
  - [x] PUT /api/v1/categories/:id - Update category
- [x] **Category Schemas** - Validation schemas
  - [x] Create category request schema
  - [x] Update category request schema
  - [x] Category response schemas

#### [P3.2] Product System (products table)

- [x] **ProductRoutes** - Product management endpoints
  - [x] POST /api/v1/products - Create product (OWNER/ADMIN)
  - [x] GET /api/v1/products - List products (filtered by owner/store)
  - [x] GET /api/v1/products/:id - Get product details
  - [x] PUT /api/v1/products/:id - Update product (OWNER/ADMIN)
  - [x] GET /api/v1/products/barcode/:barcode - Find by barcode
- [x] **Product Schemas** - Request/response validation
  - [x] Create product request schema (without barcode)
  - [x] Update product request schema (without barcode)
  - [x] Product response schemas
  - [x] Product list with pagination

## 🚀 **EXTENDED PHASES (4-6)** - MVP Enhancements

### **Phase 4: Sales Transactions** 💰

**Priority**: High - Core business functionality

#### [P4.1] Transaction System (transactions + transaction_items tables)

- [x] **TransactionRoutes** - Sales endpoints
  - [x] POST /api/v1/transactions - Create SALE transaction
  - [x] GET /api/v1/transactions - List transactions
  - [x] GET /api/v1/transactions/:id - Get transaction details
  - [x] PUT /api/v1/transactions/:id - Update transaction
- [x] **Transaction Schemas** - Validation schemas
  - [x] Create transaction request schema
  - [x] Update transaction request schema
  - [x] Transaction item schemas
  - [x] Transaction response schemas

### **Phase 5: Store Management** 🏪

**Priority**: Medium - Multi-store support

#### [P5.1] Store System (stores table)

- [x] **StoreRoutes** - Store management endpoints
  - [x] POST /api/v1/stores - Create store
  - [x] GET /api/v1/stores - List stores
  - [x] GET /api/v1/stores/:id - Get store details
  - [x] PUT /api/v1/stores/:id - Update store
- [x] **Store Schemas** - Validation schemas
  - [x] Create store request schema
  - [x] Update store request schema
  - [x] Store response schemas

  ### **Phase 6: Authorization & Middleware** 🛡️

**Priority**: High - Security and access control

#### [P6.1] Role-Based Access Control

- [ ] **AuthorizationService** - RBAC implementation
  - [ ] Owner-scoped permissions
  - [ ] Role-based resource access
  - [ ] Hierarchical permission validation
  - [ ] API endpoint protection
- [ ] **Authorization Middleware** - Request authorization
  - [ ] Role verification
  - [ ] Owner scope validation
  - [ ] Resource access control
  - [ ] Permission-based route protection
