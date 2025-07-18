# Backend Implementation Checklist - MVP Prioritized

This checklist tracks the implementation progress of all backend services, organized by MVP priority and database models.

---

## 🎯 **MVP PHASES (1-3)** - Core Functionality

### **Phase 1: Foundation & Authentication** 🔐

**Priority**: Critical - Must be completed first

#### [P1.1] Infrastructure & Utilities

- [ ] **Error handling utilities** - Custom error classes (ValidationError, AuthorizationError, NotFoundError)
- [ ] **Response utilities** - Standardized API responses (BaseResponse, PaginatedResponse)

#### [P1.2] Authentication System

- [ ] **AuthService** - Core authentication logic
  - [ ] User registration (OWNER role initial setup)
  - [ ] User login with credentials validation
  - [ ] JWT token generation and validation
  - [ ] Password hashing with bcrypt
  - [ ] Token refresh handling
- [ ] **AuthRepository** - Authentication data access
  - [ ] User credential verification
  - [ ] Token storage and validation
  - [ ] Password hash management
- [ ] **AuthRoutes** - Authentication endpoints
  - [ ] POST /api/v1/auth/register - User registration
  - [ ] POST /api/v1/auth/login - User login
  - [ ] POST /api/v1/auth/refresh - Token refresh
- [ ] **Auth Middleware** - Request authentication
  - [ ] create middleware using `import` { createMiddleware } from 'hono/factory'`
  - [ ] JWT token verification
  - [ ] User context injection
  - [ ] Protected route handling
- [ ] **Auth Schemas** - Request/response validation
  - [ ] Registration request schema
  - [ ] Login request schema
  - [ ] Auth response schemas

### **Phase 2: User Management** 👥

**Priority**: Critical - Required for role-based access

#### [P2.1] User System (users table)

- [ ] **UserService** - Business logic for user operations
  - [ ] User CRUD operations with role management
  - [ ] Owner hierarchy assignment (users belong to owners)
  - [ ] Role-based access control (OWNER, ADMIN only in MVP)
  - [ ] Soft-delete with audit trail
  - [ ] User validation and business rules
- [ ] **UserRepository** - Data persistence layer
  - [ ] User data persistence
  - [ ] Owner association management
  - [ ] Soft delete implementation
  - [ ] User-owner relationship queries
  - [ ] Role-based data filtering
- [ ] **UserRoutes** - HTTP request handlers
  - [ ] POST /api/v1/users - Create user (OWNER or ADMIN (Admin just available to create user STAFF role))
  - [ ] GET /api/v1/users - List users (filtered by owner)
  - [ ] GET /api/v1/users/:id - Get user details
  - [ ] PUT /api/v1/users/:id - Update user
  - [ ] DELETE /api/v1/users/:id - Soft delete user (OWNER only)
- [ ] **User Schemas** - Request/response validation
  - [ ] Create user request schema
  - [ ] Update user request schema
  - [ ] User response schemas
  - [ ] User list with pagination

### **Phase 3: Product Management** 📦

**Priority**: Critical - Core business functionality

#### [P3.1] Category System (categories table)

- [ ] **CategoryService** - Product categorization logic
  - [ ] Category CRUD operations
  - [ ] Owner-scoped category management
  - [ ] Category validation and business rules
  - [ ] Soft-delete with audit trail
- [ ] **CategoryRepository** - Category data access
  - [ ] Category data persistence
  - [ ] Owner-category relationships
  - [ ] Category hierarchy support
- [ ] **CategoryRoutes** - Category management endpoints
  - [ ] POST /api/v1/categories - Create category
  - [ ] GET /api/v1/categories - List categories
  - [ ] GET /api/v1/categories/:id - Get category details
  - [ ] PUT /api/v1/categories/:id - Update category
- [ ] **Category Schemas** - Validation schemas
  - [ ] Create category request schema
  - [ ] Category response schemas

#### [P3.2] Product System (products table)

- [ ] **ProductService** - Core product business logic
  - [ ] Product CRUD operations (OWNER/ADMIN only)
  - [ ] Barcode generation with nanoid
  - [ ] Store-scoped product management
  - [ ] Category assignment
  - [ ] Inventory quantity management
  - [ ] Product validation and business rules
  - [ ] Barcode uniqueness validation (owner-scoped)
- [ ] **ProductRepository** - Product data persistence
  - [ ] Product data persistence
  - [ ] Barcode uniqueness validation
  - [ ] Category associations
  - [ ] Store-product relationships
  - [ ] Inventory tracking
- [ ] **ProductRoutes** - Product management endpoints
  - [ ] POST /api/v1/products - Create product (OWNER/ADMIN)
  - [ ] GET /api/v1/products - List products (filtered by owner/store)
  - [ ] GET /api/v1/products/:id - Get product details
  - [ ] PUT /api/v1/products/:id - Update product (OWNER/ADMIN)
  - [ ] GET /api/v1/products/barcode/:barcode - Find by barcode
- [ ] **Product Schemas** - Request/response validation
  - [ ] Create product request schema
  - [ ] Update product request schema
  - [ ] Product response schemas
  - [ ] Product list with pagination

---

## 🚀 **EXTENDED PHASES (4-6)** - MVP Enhancements

### **Phase 4: Sales Transactions** 💰

**Priority**: High - Core business functionality

#### [P4.1] Transaction System (transactions + transaction_items tables)

- [ ] **TransactionService** - Transaction business logic
  - [ ] SALE transaction creation (OWNER/ADMIN only)
  - [ ] Transaction item management
  - [ ] Photo proof handling
  - [ ] Transaction validation and business rules
  - [ ] Product quantity updates
  - [ ] Amount calculations
- [ ] **TransactionRepository** - Transaction data persistence
  - [ ] Transaction data persistence
  - [ ] Transaction items management
  - [ ] Photo proof storage references
  - [ ] Transaction status tracking
- [ ] **TransactionRoutes** - Sales endpoints
  - [ ] POST /api/v1/transactions - Create SALE transaction
  - [ ] GET /api/v1/transactions - List transactions
  - [ ] GET /api/v1/transactions/:id - Get transaction details
  - [ ] PUT /api/v1/transactions/:id - Update transaction
- [ ] **Transaction Schemas** - Validation schemas
  - [ ] Create transaction request schema
  - [ ] Transaction item schemas
  - [ ] Transaction response schemas

### **Phase 5: Store Management** 🏪

**Priority**: Medium - Multi-store support

#### [P5.1] Store System (stores table)

- [ ] **StoreService** - Store management logic
  - [ ] Store CRUD operations
  - [ ] Owner-store relationships
  - [ ] Store configuration management
  - [ ] User-store assignments
  - [ ] Store validation and business rules
- [ ] **StoreRepository** - Store data persistence
  - [ ] Store data persistence
  - [ ] Geographic and operational data
  - [ ] Store hierarchy management
  - [ ] Active/inactive status tracking
- [ ] **StoreRoutes** - Store management endpoints
  - [ ] POST /api/v1/stores - Create store
  - [ ] GET /api/v1/stores - List stores
  - [ ] GET /api/v1/stores/:id - Get store details
  - [ ] PUT /api/v1/stores/:id - Update store
- [ ] **Store Schemas** - Validation schemas
  - [ ] Create store request schema
  - [ ] Store response schemas

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

---

## 🔧 **FUTURE PHASES (7-10)** - Advanced Features

### **Phase 7: Advanced Product Features** 📱

**Priority**: Low - Enhanced functionality

#### [P7.1] IMEI Tracking (product_imeis table)

- [ ] **IMEIService** - IMEI management logic
  - [ ] IMEI registration and tracking
  - [ ] Product-IMEI associations
  - [ ] IMEI validation and business rules
- [ ] **IMEIRepository** - IMEI data persistence
  - [ ] IMEI data persistence
  - [ ] Product-IMEI relationships
  - [ ] IMEI uniqueness validation
- [ ] **IMEIRoutes** - IMEI management endpoints
  - [ ] POST /api/v1/products/:id/imeis - Add IMEI
  - [ ] GET /api/v1/products/:id/imeis - List product IMEIs
  - [ ] DELETE /api/v1/imeis/:id - Remove IMEI
- [ ] **IMEI Schemas** - Validation schemas

### **Phase 8: Product Checking** ✅

**Priority**: Low - Inventory verification

#### [P8.1] Product Check System (product_checks table)

- [ ] **ProductCheckService** - Product checking logic
  - [ ] Product status checking by barcode
  - [ ] Check history tracking
  - [ ] Status transition management (PENDING → OK/MISSING/BROKEN)
  - [ ] Staff role product checking
- [ ] **ProductCheckRepository** - Check data persistence
  - [ ] Check status persistence
  - [ ] Check history tracking
  - [ ] Status transition logging
- [ ] **ProductCheckRoutes** - Checking endpoints
  - [ ] POST /api/v1/product-checks - Create check
  - [ ] GET /api/v1/product-checks - List checks
  - [ ] PUT /api/v1/product-checks/:id - Update check status
- [ ] **ProductCheck Schemas** - Validation schemas

### **Phase 9: Advanced Transactions** 🔄

**Priority**: Low - Transfer functionality

#### [P9.1] Transfer Transactions

- [ ] **Transfer Transaction Support** - TRANSFER_IN/TRANSFER_OUT
  - [ ] Cross-store transfer logic
  - [ ] Transfer approval workflow
  - [ ] Transfer proof handling
  - [ ] Inventory synchronization
- [ ] **Advanced Transaction Features**
  - [ ] Transaction status workflows
  - [ ] Multi-step transaction approval
  - [ ] Transaction reversal/cancellation

### **Phase 10: Analytics & Reporting** 📊

**Priority**: Low - Business intelligence

#### [P10.1] Analytics System

- [ ] **AnalyticsService** - Business analytics
  - [ ] Revenue calculation and analysis
  - [ ] Inventory turnover analysis
  - [ ] Product performance metrics
  - [ ] Transaction volume analysis
  - [ ] Cross-store analytics and comparison
- [ ] **AnalyticsRepository** - Analytics data access
  - [ ] Aggregated data queries
  - [ ] Performance metrics calculation
  - [ ] Time-based analytics
  - [ ] Cross-store data correlation
- [ ] **AnalyticsRoutes** - Reporting endpoints
  - [ ] GET /api/v1/analytics/revenue - Revenue reports
  - [ ] GET /api/v1/analytics/inventory - Inventory reports
  - [ ] GET /api/v1/analytics/products - Product performance
- [ ] **Analytics Schemas** - Report schemas

---

## 🧪 **TESTING REQUIREMENTS** - Per Phase

### **Testing Standards**

- [ ] **Integration Tests** - HTTP endpoint testing for each route (Hono pattern)
- [ ] **Role-Based Testing** - OWNER, ADMIN access control validation
- [ ] **Cross-Owner Testing** - Data isolation verification
- [ ] **Validation Testing** - Schema validation and error handling
- [ ] **Business Rule Testing** - Domain logic validation
- [ ] **Security Testing** - Authentication and authorization

### **Test Implementation Priority**

1. **Phase 1-3 Tests**: Critical for MVP launch
2. **Phase 4-6 Tests**: Required for production
3. **Phase 7-10 Tests**: Enhanced quality assurance

### **Architecture Pattern**

- **Hono best practice** - No Routes layer, routes use service layer directly
- **Service layer** - Business logic implementation
- **Repository layer** - Data persistence abstraction

---

## 📝 **IMPLEMENTATION NOTES**

### **MVP Focus Areas**

- **Database Models**: All models already implemented ✅
- **API Layer**: Complete implementation needed ❌
- **Authentication**: JWT-based with role validation ❌
- **Authorization**: Owner-scoped RBAC ❌
- **Testing**: Comprehensive integration tests ❌

### **Business Rules Alignment**

- **Owner Scoping**: All data filtered by owner hierarchy
- **Role Restrictions**: OWNER (full access), ADMIN (limited CRU)
- **Soft Delete**: Audit trail for all deletions
- **Barcode Uniqueness**: Owner-scoped validation
- **Photo Proof**: Required for SALE transactions

### **Technology Stack**

- **API Framework**: Hono.js with OpenAPI/Swagger
- **Database ORM**: Drizzle with SQLite/Turso
- **Validation**: Zod schemas
- **Testing**: Vitest integration tests
- **Authentication**: JWT tokens with bcrypt hashing
- **Architecture Pattern**: Hono best practice - no Controllers layer, routes use service layer directly
