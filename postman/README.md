# WMS API Postman Collection

This directory contains Postman collections and environments for testing the Warehouse Management System (WMS) API.

## Files

### Collections
- **`WMS-API.postman_collection.json`** - Complete API collection with all endpoints

### Environments  
- **`WMS-Local.postman_environment.json`** - Local development environment
- **`WMS-Production.postman_environment.json`** - Production environment template

## Quick Start

### 1. Import Collection and Environment

1. Open Postman
2. Import the collection file: `WMS-API.postman_collection.json`
3. Import the environment file: `WMS-Local.postman_environment.json` (for local development)

### 2. Setup Local Environment

1. Select the "WMS Local Environment" from the environment dropdown
2. Make sure your local WMS backend server is running on `http://localhost:3000`
3. The environment variables will be automatically populated as you make requests

### 3. Basic Authentication Flow

1. **Developer Registration** (First time setup):
   ```
   POST /api/v1/auth/dev/register
   ```
   - Uses basic auth with credentials: `dev` / `dev123`
   - Creates the first OWNER user

2. **Login**:
   ```
   POST /api/v1/auth/login
   ```
   - Use the owner credentials to get JWT tokens
   - Access token is automatically saved to environment variables

3. **Start Making Requests**:
   - All subsequent requests will use the bearer token automatically
   - Create stores, products, categories, etc.

## Collection Structure

### 🏥 Health Check
- **GET** `/health` - API health status

### 🔐 Authentication
- **POST** `/auth/dev/register` - Developer registration (basic auth)
- **POST** `/auth/register` - User registration (requires auth)
- **POST** `/auth/login` - User login
- **POST** `/auth/refresh` - Refresh access token
- **POST** `/auth/logout` - User logout

### 👥 Users
- **POST** `/users` - Create user
- **GET** `/users` - List users (paginated)
- **GET** `/users/:id` - Get user by ID
- **PUT** `/users/:id` - Update user
- **DELETE** `/users/:id` - Delete user (OWNER only)

### 🏪 Stores
- **POST** `/stores` - Create store (OWNER only)
- **GET** `/stores` - List stores (paginated)
- **GET** `/stores/:id` - Get store by ID
- **PUT** `/stores/:id` - Update store (OWNER only)

### 📂 Categories
- **POST** `/categories` - Create category (OWNER/ADMIN)
- **GET** `/categories` - List categories (paginated)
- **GET** `/categories/:id` - Get category by ID
- **PUT** `/categories/:id` - Update category (OWNER/ADMIN)

### 📦 Products
- **POST** `/products` - Create product (OWNER/ADMIN)
- **GET** `/products` - List products (paginated)
- **GET** `/products/:id` - Get product by ID
- **GET** `/products/barcode/:barcode` - Get product by barcode
- **PUT** `/products/:id` - Update product (OWNER/ADMIN)

### 💰 Transactions
- **POST** `/transactions` - Create transaction (OWNER/ADMIN)
- **GET** `/transactions` - List transactions (paginated)
- **GET** `/transactions/:id` - Get transaction by ID
- **PUT** `/transactions/:id` - Update transaction (OWNER/ADMIN)

### 📱 IMEIs
- **POST** `/products/:id/imeis` - Add IMEI to product (OWNER/ADMIN)
- **GET** `/products/:id/imeis` - List product IMEIs
- **DELETE** `/imeis/:id` - Remove IMEI (OWNER/ADMIN)
- **POST** `/products/imeis` - Create product with IMEIs (OWNER/ADMIN)

## Environment Variables

The collection uses the following environment variables that are automatically managed:

### URLs
- `baseUrl` - API base URL (e.g., http://localhost:3000)
- `apiUrl` - API endpoint URL ({{baseUrl}}/api/v1)

### Authentication
- `accessToken` - JWT access token (auto-populated)
- `refreshToken` - JWT refresh token (auto-populated)

### Resource IDs (Auto-populated)
- `userId` - User ID from responses
- `storeId` - Store ID from responses  
- `productId` - Product ID from responses
- `categoryId` - Category ID from responses
- `transactionId` - Transaction ID from responses
- `imeiId` - IMEI ID from responses

### Credentials
- `devUsername` / `devPassword` - Developer registration credentials
- `ownerUsername` / `ownerPassword` - Owner login credentials
- `adminUsername` / `adminPassword` - Admin login credentials

## Role-Based Access Control

The API enforces strict role-based access control:

### OWNER Role
- ✅ Full access to all endpoints
- ✅ Can create/manage all users, stores, products, etc.
- ✅ Can delete users

### ADMIN Role  
- ✅ Can create/manage products, categories, transactions
- ✅ Can only create STAFF users
- ❌ Cannot delete users
- ❌ Cannot create/update stores

### STAFF Role
- ✅ Read-only access to most resources
- ✅ Can perform product checking
- ❌ Cannot create users or manage products

### CASHIER Role
- ✅ Can create SALE transactions only
- ✅ Read-only access to products/stores
- ❌ Limited access to other resources

## Testing Workflows

### 1. Complete Setup Workflow
1. Health Check
2. Developer Register (creates OWNER)
3. Login as OWNER
4. Create Store
5. Create Category
6. Create Product
7. Create Sale Transaction

### 2. User Management Workflow
1. Login as OWNER
2. Create ADMIN user
3. Create STAFF user
4. Test role restrictions

### 3. Product Management Workflow
1. Create Product
2. Add IMEIs (if applicable)
3. Create Sale Transaction
4. Update Product details

## Error Handling

All API responses follow a consistent format:

### Success Response
```json
{
  "success": true,
  "data": { ... },
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

### Error Response
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human readable error message"
  },
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

### Paginated Response
```json
{
  "success": true,
  "data": [...],
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

## Production Environment Setup

1. Import `WMS-Production.postman_environment.json`
2. Update the `baseUrl` to your production domain
3. Set appropriate credentials in the environment variables
4. Note: Developer registration is disabled in production

## Tips

1. **Auto-token management**: The collection automatically extracts and saves JWT tokens from login responses
2. **Auto-ID extraction**: Resource IDs are automatically saved when creating resources
3. **Environment switching**: Easily switch between local and production environments
4. **Query parameters**: Most list endpoints support optional query parameters for filtering
5. **Pagination**: All list endpoints support pagination with `page` and `limit` parameters

## Troubleshooting

### Common Issues

1. **401 Unauthorized**: Check if your access token is valid and not expired
2. **403 Forbidden**: Verify your user role has permission for the requested operation
3. **404 Not Found**: Ensure resource IDs are correct and resources exist
4. **400 Bad Request**: Check request body format and required fields

### Token Refresh
If you get 401 errors, use the "Refresh Token" request to get a new access token.

### Environment Variables Not Populating
Make sure you have the correct environment selected and the collection-level test scripts are enabled.