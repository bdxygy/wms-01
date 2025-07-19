# React Frontend API Contract Documentation

**Warehouse Management System (WMS) React API Integration Guide v1.0**

> **📢 IMPORTANT**: This API is **FULLY IMPLEMENTED** and production-ready. All endpoints documented below are currently available and functional in the backend codebase.

## 🏗️ **Tech Stack**

- **Frontend**: React 18+ with TypeScript
- **HTTP Client**: Fetch API or Axios
- **State Management**: React Query (TanStack Query)
- **Forms**: React Hook Form with Zod validation
- **UI**: Tailwind CSS with Shadcn/ui components
- **Routing**: React Router v6
- **Authentication**: JWT with refresh tokens

## 📋 **Environment Configuration**

### Base URLs

| Environment | Base URL | API URL |
|-------------|----------|---------|
| **Local Development** | `http://localhost:3000` | `http://localhost:3000/api/v1` |
| **Production** | `https://your-production-domain.com` | `https://your-production-domain.com/api/v1` |

### Environment Variables

```typescript
interface Environment {
  baseUrl: string;
  apiUrl: string;
  accessToken?: string;
  refreshToken?: string;
}
```

## 🔐 Authentication Integration

### JWT Token Management

```typescript
interface AuthTokens {
  accessToken: string;
  refreshToken: string;
}

interface AuthUser {
  id: string;
  name: string;
  username: string;
  role: 'OWNER' | 'ADMIN' | 'STAFF' | 'CASHIER';
  ownerId?: string;
  isActive: boolean;
}
```

### React Query Setup

```typescript
// src/lib/api/queryClient.ts
import { QueryClient } from '@tanstack/react-query';

export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 5 * 60 * 1000, // 5 minutes
      retry: 3,
    },
  },
});
```

### HTTP Client

```typescript
// src/lib/api/client.ts
import axios from 'axios';

const api = axios.create({
  baseURL: process.env.REACT_APP_API_URL || 'http://localhost:3000/api/v1',
});

// Request interceptor for auth token
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('accessToken');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Response interceptor for token refresh
api.interceptors.response.use(
  (response) => response,
  async (error) => {
    if (error.response?.status === 401) {
      await refreshToken();
      return api.request(error.config);
    }
    return Promise.reject(error);
  }
);
```

## 📦 Data Models (TypeScript)

```typescript
// src/types/models.ts

export interface BaseResponse<T> {
  success: boolean;
  data: T;
  timestamp: string;
}

export interface PaginatedResponse<T> {
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

export interface User {
  id: string;
  ownerId?: string;
  name: string;
  username: string;
  role: 'OWNER' | 'ADMIN' | 'STAFF' | 'CASHIER';
  isActive: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface Store {
  id: string;
  ownerId: string;
  name: string;
  type: string;
  addressLine1: string;
  addressLine2?: string;
  city: string;
  province: string;
  postalCode: string;
  country: string;
  phoneNumber: string;
  email?: string;
  isActive: boolean;
  openTime?: string;
  closeTime?: string;
  timezone: string;
  mapLocation?: string;
  createdBy: string;
  createdAt: string;
  updatedAt: string;
}

export interface Product {
  id: string;
  name: string;
  storeId: string;
  categoryId?: string;
  sku: string;
  isImei: boolean;
  barcode: string;
  quantity: number;
  purchasePrice: number;
  salePrice?: number;
  createdBy: string;
  createdAt: string;
  updatedAt: string;
}

export interface Transaction {
  id: string;
  type: 'SALE' | 'TRANSFER';
  createdBy?: string;
  approvedBy?: string;
  fromStoreId?: string;
  toStoreId?: string;
  photoProofUrl?: string;
  transferProofUrl?: string;
  customerPhone?: string;
  amount?: number;
  isFinished: boolean;
  createdAt: string;
  items?: TransactionItem[];
}

export interface TransactionItem {
  id: string;
  productId: string;
  name: string;
  price: number;
  quantity: number;
  amount: number;
}
```

## 📋 **Complete API Endpoints with Request/Response Schemas**

## 📋 **Zod Schemas & TypeScript Interfaces**

### Base Response Schemas

```typescript
// src/schemas/common.schema.ts
import { z } from 'zod';

export const BaseResponseSchema = z.object({
  success: z.boolean(),
  data: z.any(),
  timestamp: z.string(),
});

export const PaginatedResponseSchema = z.object({
  success: z.boolean(),
  data: z.array(z.any()),
  pagination: z.object({
    page: z.number(),
    limit: z.number(),
    total: z.number(),
    totalPages: z.number(),
    hasNext: z.boolean(),
    hasPrev: z.boolean(),
  }),
  timestamp: z.string(),
});

export const ApiErrorSchema = z.object({
  success: z.boolean().default(false),
  error: z.object({
    code: z.string(),
    message: z.string(),
  }),
  timestamp: z.string(),
});

export type BaseResponse<T> = z.infer<typeof BaseResponseSchema> & { data: T };
export type PaginatedResponse<T> = z.infer<typeof PaginatedResponseSchema> & { data: T[] };
```

### Authentication Schemas

```typescript
// src/schemas/auth.schema.ts
import { z } from 'zod';

export const UserRoleSchema = z.enum(['OWNER', 'ADMIN', 'STAFF', 'CASHIER']);

export const UserSchema = z.object({
  id: z.string().uuid(),
  ownerId: z.string().uuid().optional(),
  name: z.string(),
  username: z.string(),
  role: UserRoleSchema,
  isActive: z.boolean(),
  createdAt: z.string(),
  updatedAt: z.string(),
});

export const AuthTokensSchema = z.object({
  accessToken: z.string(),
  refreshToken: z.string(),
});

// Request Schemas
export const DevRegisterRequestSchema = z.object({
  name: z.string().min(2, 'Name must be at least 2 characters'),
  username: z.string().min(3, 'Username must be at least 3 characters'),
  password: z.string().min(6, 'Password must be at least 6 characters'),
});

export const RegisterRequestSchema = z.object({
  name: z.string().min(2, 'Name must be at least 2 characters'),
  username: z.string().min(3, 'Username must be at least 3 characters'),
  password: z.string().min(6, 'Password must be at least 6 characters'),
  role: z.enum(['ADMIN', 'STAFF', 'CASHIER']),
  storeId: z.string().uuid().optional(),
});

export const LoginRequestSchema = z.object({
  username: z.string().min(1, 'Username is required'),
  password: z.string().min(1, 'Password is required'),
});

export const RefreshTokenRequestSchema = z.object({
  refreshToken: z.string(),
});

// Response Schemas
export const AuthResponseSchema = z.object({
  user: UserSchema,
  accessToken: z.string(),
  refreshToken: z.string(),
});

export type DevRegisterRequest = z.infer<typeof DevRegisterRequestSchema>;
export type RegisterRequest = z.infer<typeof RegisterRequestSchema>;
export type LoginRequest = z.infer<typeof LoginRequestSchema>;
export type RefreshTokenRequest = z.infer<typeof RefreshTokenRequestSchema>;
export type AuthResponse = z.infer<typeof AuthResponseSchema>;
```

### Store Schemas

```typescript
// src/schemas/store.schema.ts
import { z } from 'zod';

export const StoreSchema = z.object({
  id: z.string().uuid(),
  ownerId: z.string().uuid(),
  name: z.string(),
  type: z.string(),
  addressLine1: z.string(),
  addressLine2: z.string().optional(),
  city: z.string(),
  province: z.string(),
  postalCode: z.string(),
  country: z.string(),
  phoneNumber: z.string(),
  email: z.string().email().optional(),
  isActive: z.boolean(),
  openTime: z.string().optional(),
  closeTime: z.string().optional(),
  timezone: z.string(),
  mapLocation: z.string().optional(),
  createdBy: z.string().uuid(),
  createdAt: z.string(),
  updatedAt: z.string(),
});

export const CreateStoreRequestSchema = z.object({
  name: z.string().min(1, 'Store name is required'),
  type: z.string().min(1, 'Store type is required'),
  addressLine1: z.string().min(1, 'Address is required'),
  addressLine2: z.string().optional(),
  city: z.string().min(1, 'City is required'),
  province: z.string().min(1, 'Province is required'),
  postalCode: z.string().min(1, 'Postal code is required'),
  country: z.string().min(1, 'Country is required'),
  phoneNumber: z.string().min(1, 'Phone number is required'),
  email: z.string().email().optional(),
  openTime: z.string().optional(),
  closeTime: z.string().optional(),
  timezone: z.string().optional(),
  mapLocation: z.string().optional(),
});

export const UpdateStoreRequestSchema = CreateStoreRequestSchema.partial();

export type CreateStoreRequest = z.infer<typeof CreateStoreRequestSchema>;
export type UpdateStoreRequest = z.infer<typeof UpdateStoreRequestSchema>;
export type Store = z.infer<typeof StoreSchema>;
```

### Category Schemas

```typescript
// src/schemas/category.schema.ts
import { z } from 'zod';

export const CategorySchema = z.object({
  id: z.string().uuid(),
  storeId: z.string().uuid(),
  name: z.string(),
  createdBy: z.string().uuid(),
  createdAt: z.string(),
  updatedAt: z.string(),
});

export const CreateCategoryRequestSchema = z.object({
  name: z.string().min(1, 'Category name is required'),
  storeId: z.string().uuid('Invalid store ID'),
});

export const UpdateCategoryRequestSchema = z.object({
  name: z.string().min(1, 'Category name is required'),
});

export type CreateCategoryRequest = z.infer<typeof CreateCategoryRequestSchema>;
export type UpdateCategoryRequest = z.infer<typeof UpdateCategoryRequestSchema>;
export type Category = z.infer<typeof CategorySchema>;
```

### Product Schemas

```typescript
// src/schemas/product.schema.ts
import { z } from 'zod';

export const ProductSchema = z.object({
  id: z.string().uuid(),
  name: z.string(),
  storeId: z.string().uuid(),
  categoryId: z.string().uuid().optional(),
  sku: z.string(),
  isImei: z.boolean(),
  barcode: z.string(),
  quantity: z.number().int().min(0),
  purchasePrice: z.number().positive(),
  salePrice: z.number().positive().optional(),
  createdBy: z.string().uuid(),
  createdAt: z.string(),
  updatedAt: z.string(),
});

export const CreateProductRequestSchema = z.object({
  name: z.string().min(1, 'Product name is required'),
  storeId: z.string().uuid('Invalid store ID'),
  categoryId: z.string().uuid().optional(),
  sku: z.string().min(1, 'SKU is required'),
  isImei: z.boolean(),
  barcode: z.string().min(1, 'Barcode is required'),
  quantity: z.number().int().min(0, 'Quantity must be non-negative'),
  purchasePrice: z.number().positive('Purchase price must be positive'),
  salePrice: z.number().positive('Sale price must be positive').optional(),
});

export const UpdateProductRequestSchema = CreateProductRequestSchema.partial();

export const ListProductsQuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(10),
  storeId: z.string().uuid().optional(),
  categoryId: z.string().uuid().optional(),
  search: z.string().optional(),
  minPrice: z.coerce.number().positive().optional(),
  maxPrice: z.coerce.number().positive().optional(),
  hasImei: z.coerce.boolean().optional(),
});

export type CreateProductRequest = z.infer<typeof CreateProductRequestSchema>;
export type UpdateProductRequest = z.infer<typeof UpdateProductRequestSchema>;
export type ListProductsQuery = z.infer<typeof ListProductsQuerySchema>;
export type Product = z.infer<typeof ProductSchema>;
```

### Transaction Schemas

```typescript
// src/schemas/transaction.schema.ts
import { z } from 'zod';

export const TransactionTypeSchema = z.enum(['SALE', 'TRANSFER']);

export const TransactionItemSchema = z.object({
  id: z.string().uuid(),
  productId: z.string().uuid(),
  name: z.string(),
  price: z.number().positive(),
  quantity: z.number().int().positive(),
  amount: z.number().positive(),
});

export const TransactionSchema = z.object({
  id: z.string().uuid(),
  type: TransactionTypeSchema,
  createdBy: z.string().uuid().optional(),
  approvedBy: z.string().uuid().optional(),
  fromStoreId: z.string().uuid().optional(),
  toStoreId: z.string().uuid().optional(),
  photoProofUrl: z.string().url().optional(),
  transferProofUrl: z.string().url().optional(),
  customerPhone: z.string().optional(),
  amount: z.number().positive().optional(),
  isFinished: z.boolean().default(false),
  createdAt: z.string(),
  items: z.array(TransactionItemSchema).optional(),
});

export const CreateTransactionRequestSchema = z.object({
  type: TransactionTypeSchema,
  fromStoreId: z.string().uuid().optional(),
  toStoreId: z.string().uuid().optional(),
  customerPhone: z.string().optional(),
  items: z.array(z.object({
    productId: z.string().uuid(),
    quantity: z.number().int().positive('Quantity must be positive'),
    price: z.number().positive('Price must be positive'),
  })).min(1, 'At least one item is required'),
});

export const UpdateTransactionRequestSchema = z.object({
  photoProofUrl: z.string().url().optional(),
  transferProofUrl: z.string().url().optional(),
  isFinished: z.boolean().optional(),
  approvedBy: z.string().uuid().optional(),
});

export const ListTransactionsQuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(10),
  type: TransactionTypeSchema.optional(),
  storeId: z.string().uuid().optional(),
  fromStoreId: z.string().uuid().optional(),
  toStoreId: z.string().uuid().optional(),
  isFinished: z.coerce.boolean().optional(),
});

export type CreateTransactionRequest = z.infer<typeof CreateTransactionRequestSchema>;
export type UpdateTransactionRequest = z.infer<typeof UpdateTransactionRequestSchema>;
export type ListTransactionsQuery = z.infer<typeof ListTransactionsQuerySchema>;
export type Transaction = z.infer<typeof TransactionSchema>;
export type TransactionItem = z.infer<typeof TransactionItemSchema>;
```

### IMEI Schemas

```typescript
// src/schemas/imei.schema.ts
import { z } from 'zod';

export const ImeiSchema = z.object({
  id: z.string().uuid(),
  productId: z.string().uuid(),
  imei: z.string().regex(/^\d{15,17}$/, 'IMEI must be 15-17 digits'),
});

export const CreateImeiRequestSchema = z.object({
  imei: z.string().regex(/^\d{15,17}$/, 'IMEI must be 15-17 digits'),
});

export const CreateProductWithImeisRequestSchema = z.object({
  name: z.string().min(1, 'Product name is required'),
  storeId: z.string().uuid('Invalid store ID'),
  categoryId: z.string().uuid().optional(),
  sku: z.string().min(1, 'SKU is required'),
  barcode: z.string().min(1, 'Barcode is required'),
  purchasePrice: z.number().positive('Purchase price must be positive'),
  salePrice: z.number().positive('Sale price must be positive').optional(),
  imeis: z.array(z.string().regex(/^\d{15,17}$/, 'IMEI must be 15-17 digits')).min(1, 'At least one IMEI is required'),
});

export type CreateImeiRequest = z.infer<typeof CreateImeiRequestSchema>;
export type CreateProductWithImeisRequest = z.infer<typeof CreateProductWithImeisRequestSchema>;
export type Imei = z.infer<typeof ImeiSchema>;
```

### User Management Schemas

```typescript
// src/schemas/user.schema.ts
import { z } from 'zod';

export const CreateUserRequestSchema = z.object({
  name: z.string().min(2, 'Name must be at least 2 characters'),
  username: z.string().min(3, 'Username must be at least 3 characters'),
  password: z.string().min(6, 'Password must be at least 6 characters'),
  role: z.enum(['ADMIN', 'STAFF', 'CASHIER']),
  storeId: z.string().uuid().optional(),
});

export const UpdateUserRequestSchema = z.object({
  name: z.string().min(2, 'Name must be at least 2 characters').optional(),
  username: z.string().min(3, 'Username must be at least 3 characters').optional(),
  password: z.string().min(6, 'Password must be at least 6 characters').optional(),
  role: z.enum(['ADMIN', 'STAFF', 'CASHIER']).optional(),
  isActive: z.boolean().optional(),
});

export const ListUsersQuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(10),
  search: z.string().optional(),
  role: z.enum(['OWNER', 'ADMIN', 'STAFF', 'CASHIER']).optional(),
});

export type CreateUserRequest = z.infer<typeof CreateUserRequestSchema>;
export type UpdateUserRequest = z.infer<typeof UpdateUserRequestSchema>;
export type ListUsersQuery = z.infer<typeof ListUsersQuerySchema>;
```

## 📋 **Complete API Endpoints with Request/Response Schemas**

### **System Health**
- **GET** `/health`
  - **Response**: `{ success: true, data: { status: "ok", timestamp: string }, timestamp: string }`

---

### **Authentication Endpoints** (`/api/v1/auth`)

#### **POST** `/api/v1/auth/dev/register`
- **Purpose**: Developer registration (creates OWNER with basic auth)
- **Request Body**:
  ```typescript
  {
    name: string,
    username: string,
    password: string
  }
  ```
- **Response**:
  ```typescript
  {
    success: true,
    data: {
      user: User,
      accessToken: string,
      refreshToken: string
    }
  }
  ```

#### **POST** `/api/v1/auth/register`
- **Purpose**: Register new users (requires authentication)
- **Request Body**:
  ```typescript
  {
    name: string,
    username: string,
    password: string,
    role: 'ADMIN' | 'STAFF' | 'CASHIER',
    storeId?: string
  }
  ```
- **Response**:
  ```typescript
  {
    success: true,
    data: User
  }
  ```

#### **POST** `/api/v1/auth/login`
- **Purpose**: User login
- **Request Body**:
  ```typescript
  {
    username: string,
    password: string
  }
  ```
- **Response**:
  ```typescript
  {
    success: true,
    data: {
      user: User,
      accessToken: string,
      refreshToken: string
    }
  }
  ```

#### **POST** `/api/v1/auth/refresh`
- **Purpose**: Refresh access token
- **Request Body**:
  ```typescript
  {
    refreshToken: string
  }
  ```
- **Response**:
  ```typescript
  {
    success: true,
    data: {
      accessToken: string
    }
  }
  ```

#### **POST** `/api/v1/auth/logout`
- **Purpose**: User logout
- **Request**: No body required
- **Response**:
  ```typescript
  {
    success: true,
    data: null
  }
  ```

---

### **User Management** (`/api/v1/users`)

#### **POST** `/api/v1/users`
- **Purpose**: Create new user (OWNER/ADMIN only)
- **Request Body**:
  ```typescript
  {
    name: string,
    username: string,
    password: string,
    role: 'ADMIN' | 'STAFF' | 'CASHIER',
    storeId?: string
  }
  ```
- **Response**:
  ```typescript
  {
    success: true,
    data: User
  }
  ```

#### **GET** `/api/v1/users`
- **Purpose**: List users with pagination (filtered by owner scope)
- **Query Parameters**:
  ```typescript
  {
    page?: number,      // default: 1
    limit?: number,     // default: 10, max: 100
    search?: string,    // search in name or username
    role?: string       // filter by role
  }
  ```
- **Response**: `PaginatedResponse<User[]>`

#### **GET** `/api/v1/users/:id`
- **Purpose**: Get user by ID
- **Response**:
  ```typescript
  {
    success: true,
    data: User
  }
  ```

#### **PUT** `/api/v1/users/:id`
- **Purpose**: Update user information
- **Request Body**:
  ```typescript
  {
    name?: string,
    username?: string,
    password?: string,
    role?: 'ADMIN' | 'STAFF' | 'CASHIER',
    isActive?: boolean
  }
  ```
- **Response**:
  ```typescript
  {
    success: true,
    data: User
  }
  ```

#### **DELETE** `/api/v1/users/:id`
- **Purpose**: Delete user (OWNER only)
- **Response**:
  ```typescript
  {
    success: true,
    data: null
  }
  ```

---

### **Store Management** (`/api/v1/stores`)

#### **POST** `/api/v1/stores`
- **Purpose**: Create new store (OWNER only)
- **Request Body**:
  ```typescript
  {
    name: string,
    type: string,
    addressLine1: string,
    addressLine2?: string,
    city: string,
    province: string,
    postalCode: string,
    country: string,
    phoneNumber: string,
    email?: string,
    openTime?: string,
    closeTime?: string,
    timezone?: string,
    mapLocation?: string
  }
  ```
- **Response**:
  ```typescript
  {
    success: true,
    data: Store
  }
  ```

#### **GET** `/api/v1/stores`
- **Purpose**: List stores with pagination (filtered by owner)
- **Query Parameters**:
  ```typescript
  {
    page?: number,
    limit?: number,
    search?: string
  }
  ```
- **Response**: `PaginatedResponse<Store[]>`

#### **GET** `/api/v1/stores/:id`
- **Purpose**: Get store by ID
- **Response**:
  ```typescript
  {
    success: true,
    data: Store
  }
  ```

#### **PUT** `/api/v1/stores/:id`
- **Purpose**: Update store information (OWNER only)
- **Request Body**: Same as POST, all fields optional
- **Response**:
  ```typescript
  {
    success: true,
    data: Store
  }
  ```

---

### **Category Management** (`/api/v1/categories`)

#### **POST** `/api/v1/categories`
- **Purpose**: Create new category (OWNER/ADMIN only)
- **Request Body**:
  ```typescript
  {
    name: string,
    storeId: string
  }
  ```
- **Response**:
  ```typescript
  {
    success: true,
    data: Category
  }
  ```

#### **GET** `/api/v1/categories`
- **Purpose**: List categories with pagination
- **Query Parameters**:
  ```typescript
  {
    page?: number,
    limit?: number,
    storeId?: string,
    search?: string
  }
  ```
- **Response**: `PaginatedResponse<Category[]>`

#### **GET** `/api/v1/categories/:id`
- **Purpose**: Get category by ID
- **Response**:
  ```typescript
  {
    success: true,
    data: Category
  }
  ```

#### **PUT** `/api/v1/categories/:id`
- **Purpose**: Update category (OWNER/ADMIN only)
- **Request Body**:
  ```typescript
  {
    name: string
  }
  ```
- **Response**:
  ```typescript
  {
    success: true,
    data: Category
  }
  ```

---

### **Product Management** (`/api/v1/products`)

#### **POST** `/api/v1/products`
- **Purpose**: Create new product (OWNER/ADMIN only)
- **Request Body**:
  ```typescript
  {
    name: string,
    storeId: string,
    categoryId?: string,
    sku: string,
    isImei: boolean,
    barcode: string,
    quantity: number,
    purchasePrice: number,
    salePrice?: number
  }
  ```
- **Response**:
  ```typescript
  {
    success: true,
    data: Product
  }
  ```

#### **GET** `/api/v1/products`
- **Purpose**: List products with pagination and filtering
- **Query Parameters**:
  ```typescript
  {
    page?: number,
    limit?: number,
    storeId?: string,
    categoryId?: string,
    search?: string,
    minPrice?: number,
    maxPrice?: number,
    hasImei?: boolean
  }
  ```
- **Response**: `PaginatedResponse<Product[]>`

#### **GET** `/api/v1/products/barcode/:barcode`
- **Purpose**: Get product by barcode
- **Response**:
  ```typescript
  {
    success: true,
    data: Product
  }
  ```

#### **GET** `/api/v1/products/:id`
- **Purpose**: Get product by ID
- **Response**:
  ```typescript
  {
    success: true,
    data: Product
  }
  ```

#### **PUT** `/api/v1/products/:id`
- **Purpose**: Update product information (OWNER/ADMIN only)
- **Request Body**: All fields from POST, optional
- **Response**:
  ```typescript
  {
    success: true,
    data: Product
  }
  ```

---

### **Transaction Management** (`/api/v1/transactions`)

#### **POST** `/api/v1/transactions`
- **Purpose**: Create new transaction (SALE/TRANSFER)
- **Request Body**:
  ```typescript
  {
    type: 'SALE' | 'TRANSFER',
    fromStoreId?: string,
    toStoreId?: string,
    customerPhone?: string,
    items: Array<{
      productId: string,
      quantity: number,
      price: number
    }>
  }
  ```
- **Response**:
  ```typescript
  {
    success: true,
    data: Transaction
  }
  ```

#### **GET** `/api/v1/transactions`
- **Purpose**: List transactions with pagination and filtering
- **Query Parameters**:
  ```typescript
  {
    page?: number,
    limit?: number,
    type?: 'SALE' | 'TRANSFER',
    storeId?: string,
    fromStoreId?: string,
    toStoreId?: string,
    isFinished?: boolean
  }
  ```
- **Response**: `PaginatedResponse<Transaction[]>`

#### **GET** `/api/v1/transactions/:id`
- **Purpose**: Get transaction by ID with items
- **Response**:
  ```typescript
  {
    success: true,
    data: Transaction & { items: TransactionItem[] }
  }
  ```

#### **PUT** `/api/v1/transactions/:id`
- **Purpose**: Update transaction (OWNER/ADMIN only)
- **Request Body**:
  ```typescript
  {
    photoProofUrl?: string,
    transferProofUrl?: string,
    isFinished?: boolean,
    approvedBy?: string
  }
  ```
- **Response**:
  ```typescript
  {
    success: true,
    data: Transaction
  }
  ```

---

### **IMEI Management** (`/api/v1`)

#### **POST** `/api/v1/products/:id/imeis`
- **Purpose**: Add IMEI to existing product
- **Request Body**:
  ```typescript
  {
    imei: string
  }
  ```
- **Response**:
  ```typescript
  {
    success: true,
    data: { id: string, imei: string }
  }
  ```

#### **GET** `/api/v1/products/:id/imeis`
- **Purpose**: List IMEIs for specific product
- **Query Parameters**:
  ```typescript
  {
    page?: number,
    limit?: number
  }
  ```
- **Response**: `PaginatedResponse<{ id: string, imei: string }[]>`

#### **DELETE** `/api/v1/imeis/:id`
- **Purpose**: Remove IMEI
- **Response**:
  ```typescript
  {
    success: true,
    data: null
  }
  ```

#### **POST** `/api/v1/products/imeis`
- **Purpose**: Create product with IMEIs
- **Request Body**:
  ```typescript
  {
    name: string,
    storeId: string,
    categoryId?: string,
    sku: string,
    barcode: string,
    purchasePrice: number,
    salePrice?: number,
    imeis: string[]
  }
  ```
- **Response**:
  ```typescript
  {
    success: true,
    data: Product
  }
  ```

#### **GET** `/api/v1/products/imeis/:imei`
- **Purpose**: Get product by IMEI number
- **Response**:
  ```typescript
  {
    success: true,
    data: Product
  }
  ```

## 🎯 React Hooks & Queries

### Authentication Hooks

```typescript
// src/hooks/useAuth.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import api from '../lib/api/client';

export const useAuth = () => {
  const queryClient = useQueryClient();

  const loginMutation = useMutation({
    mutationFn: async (credentials: { username: string; password: string }) => {
      const response = await api.post('/auth/login', credentials);
      return response.data.data;
    },
    onSuccess: (data) => {
      localStorage.setItem('accessToken', data.accessToken);
      localStorage.setItem('refreshToken', data.refreshToken);
      queryClient.invalidateQueries(['currentUser']);
    },
  });

  const logoutMutation = useMutation({
    mutationFn: () => api.post('/auth/logout'),
    onSuccess: () => {
      localStorage.removeItem('accessToken');
      localStorage.removeItem('refreshToken');
      queryClient.clear();
    },
  });

  return { loginMutation, logoutMutation };
};

export const useCurrentUser = () => {
  return useQuery({
    queryKey: ['currentUser'],
    queryFn: async () => {
      const response = await api.get('/users/me');
      return response.data.data;
    },
    enabled: !!localStorage.getItem('accessToken'),
  });
};
```

### Data Query Hooks

```typescript
// src/hooks/useProducts.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import api from '../lib/api/client';

export const useProducts = (params?: {
  page?: number;
  limit?: number;
  search?: string;
  storeId?: string;
}) => {
  return useQuery({
    queryKey: ['products', params],
    queryFn: async () => {
      const response = await api.get('/products', { params });
      return response.data;
    },
  });
};

export const useCreateProduct = () => {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: async (product: Omit<Product, 'id' | 'createdAt' | 'updatedAt'>) => {
      const response = await api.post('/products', product);
      return response.data.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries(['products']);
    },
  });
};
```

## 🎨 Component Examples

### Protected Route Component

```typescript
// src/components/ProtectedRoute.tsx
import { useCurrentUser } from '../hooks/useAuth';
import { Navigate } from 'react-router-dom';

interface ProtectedRouteProps {
  allowedRoles?: string[];
  children: React.ReactNode;
}

export const ProtectedRoute: React.FC<ProtectedRouteProps> = ({
  allowedRoles,
  children,
}) => {
  const { data: user, isLoading } = useCurrentUser();

  if (isLoading) return <div>Loading...</div>;
  if (!user) return <Navigate to="/login" replace />;
  
  if (allowedRoles && !allowedRoles.includes(user.role)) {
    return <Navigate to="/unauthorized" replace />;
  }

  return <>{children}</>;
};
```

### Product List Component

```typescript
// src/components/ProductList.tsx
import { useProducts } from '../hooks/useProducts';
import { DataTable } from './ui/data-table';

export const ProductList: React.FC = () => {
  const { data, isLoading, error } = useProducts();

  if (isLoading) return <div>Loading products...</div>;
  if (error) return <div>Error loading products</div>;

  return (
    <div>
      <DataTable
        data={data?.data || []}
        columns={[
          { accessorKey: 'name', header: 'Name' },
          { accessorKey: 'sku', header: 'SKU' },
          { accessorKey: 'barcode', header: 'Barcode' },
          { accessorKey: 'quantity', header: 'Stock' },
          { accessorKey: 'salePrice', header: 'Price' },
        ]}
      />
    </div>
  );
};
```

## 📋 Form Validation with Zod

```typescript
// src/schemas/product.schema.ts
import { z } from 'zod';

export const productSchema = z.object({
  name: z.string().min(1, 'Product name is required'),
  sku: z.string().min(1, 'SKU is required'),
  purchasePrice: z.number().positive('Purchase price must be positive'),
  salePrice: z.number().positive('Sale price must be positive').optional(),
  quantity: z.number().int().positive('Quantity must be positive'),
  storeId: z.string().uuid('Please select a store'),
  categoryId: z.string().uuid().optional(),
  isImei: z.boolean().default(false),
});

export type ProductFormData = z.infer<typeof productSchema>;
```

## 🚨 Error Handling

```typescript
// src/lib/api/errorHandler.ts
import { AxiosError } from 'axios';

export const handleApiError = (error: AxiosError) => {
  if (error.response) {
    switch (error.response.status) {
      case 401:
        localStorage.removeItem('accessToken');
        window.location.href = '/login';
        break;
      case 403:
        throw new Error('You do not have permission to perform this action');
      case 404:
        throw new Error('Resource not found');
      case 422:
        throw new Error('Validation error: ' + error.response.data?.error?.message);
      default:
        throw new Error('An error occurred');
    }
  }
  throw error;
};
```

## 🚀 Getting Started

1. **Install dependencies**:
```bash
npm install @tanstack/react-query axios zod react-hook-form tailwindcss
```

2. **Configure environment**:
```bash
# .env
REACT_APP_API_URL=http://localhost:3000/api/v1
```

3. **Setup providers**:
```typescript
// src/App.tsx
import { QueryClientProvider } from '@tanstack/react-query';
import { queryClient } from './lib/api/queryClient';

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      {/* Your app components */}
    </QueryClientProvider>
  );
}
```

This React-specific API contract provides a complete foundation for building the WMS frontend with modern React patterns and best practices.