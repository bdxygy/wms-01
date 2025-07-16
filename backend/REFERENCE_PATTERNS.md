# WMS Backend - Reference Implementation Patterns

This document provides the standard implementation patterns established in the User module that should be followed for all other modules (stores, products, transactions, etc.).

## 🎯 Complete Implementation Example

The **User module** serves as the reference implementation demonstrating all established patterns:

- **Schema**: `src/schemas/user.schemas.ts`
- **Routes**: `src/routes/user.routes.ts`
- **Controller**: `src/controllers/user.controller.ts`
- **Service**: `src/services/user.service.ts`
- **Repository**: `src/repositories/user.repository.ts`
- **Tests**: `tests/routes/user.routes.test.ts`
- **Error Handling**: `src/utils/errors.ts`

## 📚 Layer Responsibilities

### 1. **Schema Layer** (`src/schemas/`)
- Define Zod validation schemas for requests and responses
- Export TypeScript types derived from schemas
- Include OpenAPI documentation metadata
- Create API response wrapper schemas

### 2. **Route Layer** (`src/routes/`)
- Define OpenAPI route specifications
- Map HTTP methods to controller actions
- Specify request/response schemas
- Handle automatic Zod validation

### 3. **Controller Layer** (`src/controllers/`)
- Handle HTTP concerns (request/response)
- Extract and validate user authentication
- Delegate business logic to services
- Transform service errors to HTTP responses

### 4. **Service Layer** (`src/services/`)
- Implement business logic and rules
- Enforce role-based authorization
- Validate business constraints
- Throw custom error types for proper HTTP mapping

### 5. **Repository Layer** (`src/repositories/`)
- Handle data access and persistence
- Implement database queries
- Manage transactions and relationships
- Abstract database operations

## 🚨 Error Handling Standards

### Custom Error Classes
```typescript
// Use specific error types for proper HTTP status mapping
throw new ValidationError('Invalid input data');      // 400
throw new AuthorizationError('Insufficient permissions'); // 403
throw new NotFoundError('Resource not found');        // 404
throw new ConflictError('Resource already exists');   // 409
```

### Controller Error Handling
```typescript
try {
  // Business logic
} catch (error) {
  const { message, statusCode, code, details } = handleServiceError(error);
  return c.json(
    createBaseResponse(false, message, null, { code, details }),
    statusCode
  );
}
```

## 📝 HTTP Status Code Standards

| Status | Use Case | Error Type |
|--------|----------|------------|
| 400 | Input validation errors | Handled by Zod automatically |
| 401 | Authentication required | Manual check in controller |
| 403 | Authorization/permission errors | `AuthorizationError` |
| 404 | Resource not found | `NotFoundError` |
| 409 | Resource conflicts | `ConflictError` |
| 500 | Unexpected errors | Any unhandled error |

## 🔒 Role-Based Authorization Pattern

### Service-Level Validation
```typescript
private validateUserAccess(resource: Resource, requestingUser: User): void {
  if (requestingUser.role === 'OWNER') {
    if (resource.ownerId !== requestingUser.id) {
      throw new AuthorizationError('Access denied: Resource not under your ownership');
    }
  } else if (requestingUser.role === 'ADMIN') {
    if (resource.ownerId !== requestingUser.ownerId) {
      throw new AuthorizationError('Access denied: Resource not under same owner');
    }
  } else {
    throw new AuthorizationError('Insufficient permissions');
  }
}
```

## 📊 Response Format Standards

### Success Response
```typescript
{
  "success": true,
  "message": "Operation completed successfully",
  "data": { /* resource data */ },
  "timestamp": "2025-01-16T12:00:00.000Z"
}
```

### Error Response
```typescript
{
  "success": false,
  "message": "Error description",
  "data": null,
  "error": {
    "code": "ERROR_CODE",
    "details": "Additional error information"
  },
  "timestamp": "2025-01-16T12:00:00.000Z"
}
```

### Paginated Response
```typescript
{
  "success": true,
  "message": "Data retrieved successfully",
  "data": [/* array of resources */],
  "timestamp": "2025-01-16T12:00:00.000Z",
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 100,
    "totalPages": 10,
    "hasNext": true,
    "hasPrev": false
  }
}
```

## 🧪 Testing Standards

### Integration Test Pattern
```typescript
describe('Entity Routes', () => {
  it('should create entity as OWNER', async () => {
    const response = await testClient(app).api.v1.entities.$post({
      json: { name: 'Test Entity' }
    });
    
    expect(response.status).toBe(201);
    const body = await response.json();
    expect(body.success).toBe(true);
  });

  it('should return 403 for insufficient permissions', async () => {
    // Test with STAFF user
    expect(response.status).toBe(403);
    expect(body.error.code).toBe('AUTHORIZATION_ERROR');
  });
});
```

### Required Test Scenarios
- ✅ **Create operations** for each role (OWNER, ADMIN, STAFF, CASHIER)
- ✅ **Read operations** with proper scoping
- ✅ **Update operations** with permission validation
- ✅ **Delete operations** with role restrictions
- ✅ **Authorization errors** (403)
- ✅ **Validation errors** (400)
- ✅ **Not found errors** (404)
- ✅ **Conflict errors** (409)

## 🔄 Implementation Checklist

When creating a new module:

### 1. Schema Definition
- [ ] Create request schemas with Zod validation
- [ ] Create response schemas with OpenAPI metadata
- [ ] Export TypeScript types
- [ ] Define API response wrappers

### 2. Route Configuration
- [ ] Define OpenAPI route specifications
- [ ] Map all CRUD operations
- [ ] Include proper response status codes
- [ ] Add request/response schema references

### 3. Controller Implementation
- [ ] Handle authentication checks
- [ ] Extract request data with proper typing
- [ ] Delegate to service layer
- [ ] Use standardized error handling

### 4. Service Implementation
- [ ] Implement business logic
- [ ] Add role-based authorization
- [ ] Use custom error types
- [ ] Validate business constraints

### 5. Testing Coverage
- [ ] Test all CRUD operations
- [ ] Test all user roles
- [ ] Test error scenarios
- [ ] Test edge cases and boundaries

## 📁 File Naming Conventions

- **Schemas**: `[entity].schemas.ts`
- **Routes**: `[entity].routes.ts`
- **Controllers**: `[entity].controller.ts`
- **Services**: `[entity].service.ts`
- **Repositories**: `[entity].repository.ts`
- **Tests**: `[entity].routes.test.ts`

## 🎯 Key Benefits

- **Consistency**: All modules follow the same patterns
- **Type Safety**: Full TypeScript support with Zod validation
- **Documentation**: Automatic OpenAPI/Swagger generation
- **Error Handling**: Proper HTTP status codes and error messages
- **Testing**: Comprehensive integration test coverage
- **Maintainability**: Clear separation of concerns
- **Scalability**: Easy to extend and modify

---

**Reference Implementation**: See the User module for complete examples of all patterns.