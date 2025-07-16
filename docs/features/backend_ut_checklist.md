# Backend Unit Test Cases Checklist

This document consolidates all unit test cases from user stories organized by role-based access control patterns, eliminating redundancy.

---

## Authentication & Authorization Core Tests

- [ ] **AUTH-001: Authentication Required**
  - Verify all protected endpoints require valid JWT token
  - Test invalid/missing/expired token scenarios

- [ ] **AUTH-002: Role-Based Access Control**
  - Verify each role can only access permitted operations
  - Test cross-role access violations are blocked

- [ ] **AUTH-003: Owner-Based Access Control**
  - Verify non-OWNER roles can only access stores owned by their assigned owner
  - Test access to any store owned by the same owner is allowed
  - Test attempts to access stores owned by different owners are blocked

- [ ] **AUTH-004: Token Validation**
  - Test JWT signature validation
  - Test token payload structure validation
  - Test refresh token functionality

---

## Owner Role Tests (Full System Access)

### Store Management
- [ ] **OWNER-STORE-001: Full CRUD operations on any store**
  - Create store with valid payload
  - Read any store details
  - Update any store information
  - Soft delete any store
  - List all stores across system

### User Management  
- [ ] **OWNER-USER-001: Full CRUD operations on all user roles**
  - Create ADMIN/STAFF/CASHIER users
  - Read any user details
  - Update any user (including role changes)
  - Soft delete any user
  - List all users across all stores

### Category Management
- [ ] **OWNER-CAT-001: Full CRUD operations on categories**
  - Create/read/update/soft delete categories
  - Manage categories across all stores
  - Verify category visibility in list and detail views

### Product Management
- [ ] **OWNER-PROD-001: Full CRUD operations on products**
  - Create products with barcode validation
  - Create products with IMEI for electronics
  - Read/update/soft delete any product
  - Manage products across all stores
  - Ensure barcode uniqueness system-wide

### Transaction Management
- [ ] **OWNER-TRANS-001: Full CRUD operations on all transaction types**
  - Create SALE/TRANSFER_IN/TRANSFER_OUT transactions
  - Read/update/soft delete any transaction
  - Cross-store transaction management
  - Photo proof required for SALE transactions

### Analytics Access
- [ ] **OWNER-ANALYTICS-001: Full analytics access**
  - View store-specific analytics (in/out items, revenue, profit)
  - View cross-store aggregated analytics
  - Access revenue calculations and inventory turnover

### Product Checking
- [ ] **OWNER-CHECK-001: Product checking across all stores**
  - View product check lists for any store
  - Scan barcodes to mark products as checked
  - Move products between PENDING/OK/MISSING/BROKEN states

---

## Admin Role Tests (Store-Scoped CRU Access)

### Store Access Control
- [ ] **ADMIN-STORE-001: Owner-based store access**
  - Read any store owned by their assigned owner
  - Cannot create/update/delete stores
  - Cannot access stores owned by different owners

### User Management (STAFF Only)
- [ ] **ADMIN-USER-001: Limited user management**
  - Create STAFF users only (within owner's organization)
  - Cannot create ADMIN/CASHIER/OWNER users
  - Read/update STAFF users (within same owner)
  - Cannot delete any users (soft delete blocked)
  - Cannot manage users outside their owner's organization
  - Verify proper error responses for blocked user creation attempts

### Category Management (Owner-Scoped)
- [ ] **ADMIN-CAT-001: Owner-scoped category management**
  - Create/read/update categories (any store owned by same owner)
  - Cannot delete categories (soft delete blocked)
  - Cannot access categories from stores owned by different owners
  - Verify proper error responses for delete attempts

### Product Management (Owner-Scoped)
- [ ] **ADMIN-PROD-001: Owner-scoped product management**
  - Create/read/update products (any store owned by same owner)
  - Cannot delete products (soft delete blocked)
  - Cannot access products from stores owned by different owners
  - Ensure barcode uniqueness within owner's organization
  - Verify proper error responses for delete attempts

### Transaction Management (Owner-Scoped)
- [ ] **ADMIN-TRANS-001: Owner-scoped transaction management**
  - Create/read/update SALE/TRANSFER transactions (any store owned by same owner)
  - Cannot delete transactions (soft delete blocked)
  - Cannot access transactions from stores owned by different owners
  - Photo proof required for SALE transactions
  - Verify proper error responses for delete attempts

### Product Checking (Owner-Scoped)
- [ ] **ADMIN-CHECK-001: Owner-scoped product checking**
  - View product check lists (any store owned by same owner)
  - Scan barcodes to mark as checked (any store owned by same owner)
  - Cannot access checks from stores owned by different owners

### Access Restrictions
- [ ] **ADMIN-RESTRICT-001: Analytics access blocked**
  - Cannot access any analytics dashboards
  - Verify proper error responses for analytics endpoints

---

## Staff Role Tests (Read-Only + Product Checks)

### Dashboard & Store Navigation
- [ ] **STAFF-DASH-001: Dashboard store list functionality**
  - View list of all stores owned by their assigned owner
  - Select any store from available options within owner's organization
  - Verify store access permissions per owner assignment
  - Cannot access stores owned by different owners

### Read-Only Access (Owner-Scoped)
- [ ] **STAFF-READ-001: Read-only access to owner's store data**
  - Read store details (any store owned by same owner)
  - Read categories/products/transactions (any store owned by same owner)
  - Cannot create/update/delete any entities
  - Cannot access data from stores owned by different owners

### User Profile Access
- [ ] **STAFF-USER-001: Limited user access**
  - Read own profile only
  - Cannot manage any other users

### Product Checking (Owner-Scoped)
- [ ] **STAFF-CHECK-001: Product checking capabilities**
  - View product check lists (any store owned by same owner)
  - Scan barcodes to mark products as checked (any store owned by same owner)
  - Cannot access checks from stores owned by different owners

### Access Restrictions
- [ ] **STAFF-RESTRICT-001: Management operations blocked**
  - Cannot create/update/delete stores/users/categories/products/transactions
  - Cannot access analytics
  - Verify proper error responses for blocked operations

---

## Cashier Role Tests (SALE Transactions Only)

### Dashboard & Transaction Navigation
- [ ] **CASHIER-DASH-001: Dashboard transaction functionality**
  - View transaction tab on dashboard for all stores owned by same owner
  - Access transaction management interface for any owner store
  - Navigate to SALE transaction creation at any owner store
  - Cannot access other business management features

### Read-Only Access (Owner-Scoped)
- [ ] **CASHIER-READ-001: Read-only access to owner's store data**
  - Read store details (any store owned by same owner)
  - Read categories/products (any store owned by same owner)
  - Cannot access data from stores owned by different owners

### SALE Transaction Management
- [ ] **CASHIER-TRANS-001: SALE transaction operations**
  - Create SALE transactions only (any store owned by same owner)
  - Cannot create TRANSFER_IN/TRANSFER_OUT transactions
  - Read SALE transactions (any store owned by same owner)
  - Cannot update any transactions (create and read only)
  - Cannot delete any transactions
  - Photo proof required for SALE transactions
  - Verify proper error responses for blocked transaction types

### User Profile Access
- [ ] **CASHIER-USER-001: Limited user access**
  - Read own profile only
  - Cannot manage any other users

### Access Restrictions
- [ ] **CASHIER-RESTRICT-001: Blocked operations**
  - Cannot manage stores/users/categories/products
  - Cannot access product checks
  - Cannot access analytics
  - Verify proper error responses for blocked operations

---

## Cross-Role Business Rule Tests

### Barcode Validation
- [ ] **BARCODE-001: Barcode uniqueness enforcement**
  - System-wide uniqueness for OWNER operations
  - Store-scoped uniqueness for ADMIN operations
  - Proper error handling for duplicate barcodes

### IMEI Tracking
- [ ] **IMEI-001: IMEI tracking for electronics**
  - IMEI field validation for applicable products
  - IMEI uniqueness constraints
  - Proper handling when IMEI not required

### Photo Proof Requirements
- [ ] **PHOTO-001: Photo proof for SALE transactions**
  - Photo upload validation for all SALE transactions
  - Proper error handling when photo missing
  - Photo format and size validation

### Soft Delete Operations
- [ ] **SOFT-DELETE-001: Soft delete audit trail**
  - All delete operations are soft deletes with timestamps
  - Deleted entities excluded from normal queries
  - Audit trail preservation for deleted entities

---

## Input Validation Tests

- [ ] **VALID-001: Request payload validation**
  - Required fields validation for all endpoints
  - Data type validation (string, number, boolean, array)
  - Email format validation for user creation/updates

- [ ] **VALID-002: Query parameter validation**
  - Pagination parameters (page, limit) validation
  - Search/filter parameter validation
  - Sort parameter validation

- [ ] **VALID-003: Path parameter validation**
  - UUID format validation for entity IDs
  - Store ID validation for store-scoped operations
  - Barcode format validation

- [ ] **VALID-004: Business rule validation**
  - Phone number format validation
  - Barcode format and uniqueness validation
  - Role hierarchy validation (OWNER > ADMIN > STAFF/CASHIER)

---

## Error Handling Tests

- [ ] **ERROR-001: HTTP error responses**
  - 400 Bad Request for validation errors
  - 401 Unauthorized for auth failures
  - 403 Forbidden for role/scope violations
  - 404 Not Found for missing resources
  - 500 Internal Server Error for system failures

- [ ] **ERROR-002: Error response format**
  - Consistent error response structure
  - Meaningful error messages
  - Error code mapping
  - Timestamp inclusion

- [ ] **ERROR-003: Database error handling**
  - Connection failure handling
  - Constraint violation handling
  - Transaction rollback on errors

---

## Pagination Tests

- [ ] **PAGE-001: Pagination functionality**
  - Default pagination (page=1, limit=10)
  - Custom page size (min=10, max=100)
  - Page navigation (next/previous)
  - Pagination metadata (total, totalPages, hasNext, hasPrevious)

- [ ] **PAGE-002: Pagination edge cases**
  - Empty result sets
  - Single page results
  - Out of bounds page numbers

---

## Performance & Security Tests

- [ ] **PERF-001: Response time requirements**
  - API response times under acceptable limits
  - Large dataset handling efficiency
  - Concurrent request handling

- [ ] **SEC-001: Security validations**
  - SQL injection prevention
  - XSS prevention through data sanitization
  - Password security (hashing, complexity)
  - Input sanitization for all user data

- [ ] **SEC-002: Authentication security**
  - JWT secret protection
  - Token expiration handling
  - Refresh token security
  - Rate limiting on auth endpoints

---

## Integration Tests

- [ ] **INTEGRATION-001: End-to-end workflows**
  - Complete user registration and authentication flow
  - Product creation, transaction, and checking workflow
  - Multi-store transfer operation workflow
  - Analytics data aggregation workflow

- [ ] **INTEGRATION-002: Database integration**
  - Database schema compliance
  - Foreign key constraint enforcement
  - Transaction isolation and consistency
  - Connection pooling and management

---

## Audit Trail Tests

- [ ] **AUDIT-001: Operation logging**
  - Create operations logged with user/timestamp
  - Update operations logged with changes and user
  - Delete operations logged with user/timestamp
  - Failed operations logged with error details

- [ ] **AUDIT-002: Audit data integrity**
  - Audit logs cannot be modified by users
  - Audit log retention and archival
  - Audit log query capabilities for compliance