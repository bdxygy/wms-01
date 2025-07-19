# Frontend API Contract Documentation

**Warehouse Management System (WMS) API v1.0**

This document provides a comprehensive API contract for frontend developers to integrate with the WMS backend system.

> **📢 IMPORTANT**: This API is **FULLY IMPLEMENTED** and production-ready. All endpoints documented below are currently available and functional in the backend codebase.

## 🏗️ **Tech Stack Support**

This API contract supports multiple frontend platforms:

- **🌐 Web Frontend**: React
- **📱 Mobile Apps**: Flutter
- **🔧 API Integration**: Any HTTP client or programming language

## Table of Contents

1. [Environment Configuration](#environment-configuration)
2. [Authentication](#authentication)
3. [API Endpoints](#api-endpoints)
4. [Data Models](#data-models)
5. [Error Handling](#error-handling)
6. [Web Frontend Integration Guide](#web-frontend-integration-guide)
7. [Flutter/Mobile Integration Guide](#fluttermobile-integration-guide)

---

## Environment Configuration

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
  userId?: string;
  storeId?: string;
  productId?: string;
  categoryId?: string;
  transactionId?: string;
  imeiId?: string;
}
```

---

## Authentication

### JWT Token Management

The API uses JWT-based authentication with access and refresh tokens.

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

### Authentication Flow

1. **Login** → Get access/refresh tokens
2. **Use access token** for API requests
3. **Refresh tokens** when access token expires
4. **Logout** to invalidate tokens

### Role-Based Access Control (RBAC)

| Role | Permissions |
|------|-------------|
| **OWNER** | Full system access, can manage all entities |
| **ADMIN** | Store-scoped CRU access (no delete), can manage STAFF users |
| **STAFF** | Read-only + product checking (MVP: Not implemented) |
| **CASHIER** | SALE transactions only (MVP: Not implemented) |

---

## API Endpoints

### 🔐 Authentication Endpoints

#### POST `/api/v1/auth/dev/register`
**Development Only** - Register first owner user

```typescript
// Request
interface DevRegisterRequest {
  name: string;
  username: string;
  password: string;
}

// Headers
headers: {
  'Authorization': 'Basic ' + btoa('dev:dev123'),
  'Content-Type': 'application/json'
}

// Response
interface DevRegisterResponse {
  success: true;
  data: AuthUser;
  timestamp: string;
}
```

#### POST `/api/v1/auth/login`
User login

```typescript
// Request
interface LoginRequest {
  username: string;
  password: string;
}

// Response
interface LoginResponse {
  success: true;
  data: {
    accessToken: string;
    refreshToken: string;
    user: AuthUser;
  };
  timestamp: string;
}
```

#### POST `/api/v1/auth/register`
Register new user (requires authentication)

```typescript
// Request
interface RegisterRequest {
  name: string;
  username: string;
  password: string;
  role: 'ADMIN' | 'STAFF' | 'CASHIER';
}

// Headers
headers: {
  'Authorization': 'Bearer ' + accessToken,
  'Content-Type': 'application/json'
}
```

#### POST `/api/v1/auth/refresh`
Refresh access token

```typescript
// Request (Body OR Cookie)
interface RefreshRequest {
  refreshToken: string;  // Optional if using cookies
}

// Alternative: Cookie-based refresh
// The API supports refresh tokens via secure HttpOnly cookies
// If refresh token is in cookies, no body is required

// Response
interface RefreshResponse {
  success: true;
  data: {
    accessToken: string;
  };
  timestamp: string;
}
```

#### POST `/api/v1/auth/logout`
Logout current user

```typescript
// Headers only - clears refresh token cookies automatically
headers: {
  'Authorization': 'Bearer ' + accessToken
}

// Response
interface LogoutResponse {
  success: true;
  data: { message: 'Logged out successfully' };
  timestamp: string;
}
```

---

### 👥 Users Management

#### POST `/api/v1/users`
Create new user

```typescript
// Request
interface CreateUserRequest {
  name: string;
  username: string;
  password: string;
  role: 'ADMIN' | 'STAFF' | 'CASHIER';
}

// Response
interface CreateUserResponse {
  success: true;
  data: AuthUser;
  timestamp: string;
}
```

#### GET `/api/v1/users`
Get paginated users list

```typescript
// Query Parameters
interface GetUsersQuery {
  page?: number;        // default: 1
  limit?: number;       // default: 10, max: 100
  search?: string;      // search name/username
  role?: 'OWNER' | 'ADMIN' | 'STAFF' | 'CASHIER';
  isActive?: boolean;
}

// Response
interface GetUsersResponse {
  success: true;
  data: AuthUser[];
  pagination: PaginationInfo;
  timestamp: string;
}
```

#### GET `/api/v1/users/{userId}`
Get specific user

```typescript
// Response
interface GetUserResponse {
  success: true;
  data: AuthUser;
  timestamp: string;
}
```

#### PUT `/api/v1/users/{userId}`
Update user

```typescript
// Request
interface UpdateUserRequest {
  name?: string;
  isActive?: boolean;
}
```

#### DELETE `/api/v1/users/{userId}`
Delete user (OWNER only)

---

### 🏪 Stores Management

#### POST `/api/v1/stores`
Create new store (OWNER only)

```typescript
// Request
interface CreateStoreRequest {
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
  timezone?: string;     // default: "Asia/Jakarta"
  openTime?: string;     // ISO timestamp
  closeTime?: string;    // ISO timestamp
  mapLocation?: string;
}

// Response
interface Store {
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
```

#### GET `/api/v1/stores`
Get paginated stores list

```typescript
// Query Parameters
interface GetStoresQuery {
  page?: number;
  limit?: number;
  search?: string;
  type?: string;
  isActive?: boolean;
  city?: string;
  province?: string;
}
```

#### GET `/api/v1/stores/{storeId}`
Get specific store

#### PUT `/api/v1/stores/{storeId}`
Update store (OWNER only)

---

### 📂 Categories Management

#### POST `/api/v1/categories`
Create new category (OWNER/ADMIN only)

```typescript
// Request
interface CreateCategoryRequest {
  name: string;
  storeId: string;
}

// Response
interface Category {
  id: string;
  storeId: string;
  name: string;
  createdBy: string;
  createdAt: string;
  updatedAt: string;
}
```

#### GET `/api/v1/categories`
Get paginated categories list

```typescript
// Query Parameters
interface GetCategoriesQuery {
  page?: number;
  limit?: number;
  search?: string;
  storeId?: string;
}
```

#### GET `/api/v1/categories/{categoryId}`
Get specific category

#### PUT `/api/v1/categories/{categoryId}`
Update category (OWNER/ADMIN only)

---

### 📦 Products Management

#### POST `/api/v1/products`
Create new product (OWNER/ADMIN only)

```typescript
// Request
interface CreateProductRequest {
  name: string;
  storeId: string;
  categoryId?: string;
  sku: string;
  isImei?: boolean;      // default: false
  quantity: number;
  purchasePrice: number;
  salePrice?: number;
}

// Response
interface Product {
  id: string;
  name: string;
  storeId: string;
  categoryId?: string;
  sku: string;
  isImei: boolean;
  barcode: string;       // auto-generated
  quantity: number;
  purchasePrice: number;
  salePrice?: number;
  createdBy: string;
  createdAt: string;
  updatedAt: string;
}
```

#### GET `/api/v1/products`
Get paginated products list

```typescript
// Query Parameters
interface GetProductsQuery {
  page?: number;
  limit?: number;
  search?: string;
  storeId?: string;
  categoryId?: string;
  isImei?: boolean;
  minPrice?: number;
  maxPrice?: number;
}
```

#### GET `/api/v1/products/{productId}`
Get specific product

#### GET `/api/v1/products/barcode/{barcode}`
Get product by barcode

#### PUT `/api/v1/products/{productId}`
Update product (OWNER/ADMIN only)

---

### 💰 Transactions Management

#### POST `/api/v1/transactions`
Create new transaction (OWNER/ADMIN only)

```typescript
// Request - SALE Transaction
interface CreateSaleTransactionRequest {
  type: 'SALE';
  fromStoreId: string;
  customerPhone?: string;
  photoProofUrl?: string;  // Required for SALE
  items: TransactionItem[];
}

// Request - TRANSFER Transaction
interface CreateTransferTransactionRequest {
  type: 'TRANSFER';
  fromStoreId: string;
  toStoreId: string;
  transferProofUrl?: string;
  items: TransactionItem[];
}

interface TransactionItem {
  productId: string;
  name: string;
  price: number;
  quantity: number;
  amount: number;
}

// Response
interface Transaction {
  id: string;
  type: 'SALE' | 'TRANSFER';
  createdBy?: string;
  approvedBy?: string;
  fromStoreId?: string;
  toStoreId?: string;
  photoProofUrl?: string;
  transferProofUrl?: string;
  to?: string;
  customerPhone?: string;
  amount?: number;
  isFinished: boolean;
  createdAt: string;
  items?: TransactionItem[];
}
```

#### GET `/api/v1/transactions`
Get paginated transactions list

```typescript
// Query Parameters
interface GetTransactionsQuery {
  page?: number;
  limit?: number;
  type?: 'SALE' | 'TRANSFER';
  fromStoreId?: string;
  toStoreId?: string;
  isFinished?: boolean;
}
```

#### GET `/api/v1/transactions/{transactionId}`
Get specific transaction with items

#### PUT `/api/v1/transactions/{transactionId}`
Update transaction (OWNER/ADMIN only)

---

### 📱 IMEI Management

#### POST `/api/v1/products/{productId}/imeis`
Add IMEI to product (OWNER/ADMIN only)

```typescript
// Request
interface AddImeiRequest {
  imei: string;          // 15-17 characters
}

// Response
interface ProductImei {
  id: string;
  productId: string;
  imei: string;
  createdBy: string;
  createdAt: string;
  updatedAt: string;
}
```

#### GET `/api/v1/products/{productId}/imeis`
Get product IMEIs

```typescript
// Query Parameters
interface GetProductImeisQuery {
  page?: number;
  limit?: number;
}
```

#### DELETE `/api/v1/imeis/{imeiId}`
Remove IMEI (OWNER/ADMIN only)

#### POST `/api/v1/products/imeis`
Create product with multiple IMEIs (OWNER/ADMIN only)

```typescript
// Request
interface CreateProductWithImeisRequest {
  name: string;
  storeId: string;
  categoryId?: string;
  sku: string;
  isImei: boolean;       // should be true
  quantity: number;
  purchasePrice: number;
  salePrice?: number;
  imeis: string[];       // array of IMEI numbers
}
```

#### GET `/api/v1/products/imeis/{imeiNumber}`
🆕 Search product by IMEI number

```typescript
// Response
interface ProductWithImeisResponse {
  success: true;
  data: Product & {
    imeis: string[];     // all IMEIs for this product
  };
  timestamp: string;
}

// Example Response
{
  "success": true,
  "data": {
    "id": "product-123-uuid",
    "name": "iPhone 15 Pro",
    "storeId": "store-123-uuid",
    "categoryId": "category-123-uuid",
    "sku": "IPHONE15PRO",
    "isImei": true,
    "barcode": "ABCD1234567890",
    "quantity": 1,
    "purchasePrice": 999.99,
    "salePrice": 1299.99,
    "createdBy": "user-123-uuid",
    "createdAt": "2024-01-01T00:00:00.000Z",
    "updatedAt": "2024-01-01T00:00:00.000Z",
    "imeis": ["123456789012345", "123456789012346"]
  },
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

---

## Data Models

### Common Interfaces

```typescript
interface PaginationInfo {
  page: number;
  limit: number;
  total: number;
  totalPages: number;
  hasNext: boolean;
  hasPrev: boolean;
}

interface BaseResponse<T> {
  success: true;
  data: T;
  timestamp: string;
}

interface PaginatedResponse<T> {
  success: true;
  data: T[];
  pagination: PaginationInfo;
  timestamp: string;
}

interface ErrorResponse {
  success: false;
  error: {
    code: string;
    message: string;
  };
  timestamp: string;
}
```

### Entity IDs
All entity IDs are **UUID v4** format:
```typescript
type UUID = string; // e.g., "550e8400-e29b-41d4-a716-446655440000"
```

### Barcode Format
Product barcodes are **alphanumeric nanoid**:
```typescript
type Barcode = string; // e.g., "ABCD1234567890"
```

---

## Error Handling

### HTTP Status Codes

| Status | Description | Usage |
|--------|-------------|-------|
| **200** | OK | Successful GET, PUT requests |
| **201** | Created | Successful POST requests |
| **400** | Bad Request | Validation errors, invalid input |
| **401** | Unauthorized | Authentication required or invalid token |
| **403** | Forbidden | Insufficient permissions |
| **404** | Not Found | Resource not found |
| **500** | Internal Server Error | Server-side errors |

### Error Response Format

```typescript
interface ApiError {
  success: false;
  error: {
    code: string;
    message: string;
  };
  timestamp: string;
}

// Common Error Codes
type ErrorCode = 
  | 'VALIDATION_ERROR'
  | 'UNAUTHORIZED'
  | 'FORBIDDEN'
  | 'NOT_FOUND'
  | 'INTERNAL_ERROR'
  | 'INVALID_CREDENTIALS'
  | 'TOKEN_EXPIRED'
  | 'DUPLICATE_ENTRY'
  | 'INSUFFICIENT_PERMISSIONS';
```

### Error Handling Best Practices

```typescript
// Frontend error handling example
async function apiCall<T>(endpoint: string, options: RequestInit): Promise<T> {
  try {
    const response = await fetch(endpoint, options);
    const data = await response.json();
    
    if (!response.ok) {
      throw new ApiError(data.error.code, data.error.message, response.status);
    }
    
    return data.data; // Return just the data portion
  } catch (error) {
    if (error instanceof ApiError) {
      // Handle specific API errors
      switch (error.code) {
        case 'UNAUTHORIZED':
        case 'TOKEN_EXPIRED':
          // Redirect to login or refresh token
          await refreshTokenOrRedirect();
          break;
        case 'FORBIDDEN':
          // Show access denied message
          showAccessDeniedMessage();
          break;
        case 'VALIDATION_ERROR':
          // Show validation errors to user
          showValidationErrors(error.message);
          break;
        default:
          // Show generic error
          showGenericError(error.message);
      }
    }
    throw error;
  }
}

class ApiError extends Error {
  constructor(
    public code: string,
    message: string,
    public status: number
  ) {
    super(message);
    this.name = 'ApiError';
  }
}
```

---

## Web Frontend Integration Guide

### 1. HTTP Client Setup

```typescript
class WmsApiClient {
  private baseUrl: string;
  private accessToken?: string;

  constructor(baseUrl: string) {
    this.baseUrl = baseUrl;
  }

  setAccessToken(token: string) {
    this.accessToken = token;
  }

  private async request<T>(
    endpoint: string, 
    options: RequestInit = {}
  ): Promise<T> {
    const url = `${this.baseUrl}${endpoint}`;
    
    const headers: HeadersInit = {
      'Content-Type': 'application/json',
      ...options.headers,
    };

    if (this.accessToken) {
      headers.Authorization = `Bearer ${this.accessToken}`;
    }

    const response = await fetch(url, {
      ...options,
      headers,
    });

    const data = await response.json();

    if (!response.ok) {
      throw new ApiError(data.error.code, data.error.message, response.status);
    }

    return data;
  }

  // Auth methods
  async login(credentials: LoginRequest): Promise<LoginResponse> {
    return this.request('/api/v1/auth/login', {
      method: 'POST',
      body: JSON.stringify(credentials),
    });
  }

  async refreshToken(refreshToken: string): Promise<RefreshResponse> {
    return this.request('/api/v1/auth/refresh', {
      method: 'POST',
      body: JSON.stringify({ refreshToken }),
    });
  }

  // Products methods
  async getProducts(query?: GetProductsQuery): Promise<PaginatedResponse<Product>> {
    const queryString = query ? `?${new URLSearchParams(query as any)}` : '';
    return this.request(`/api/v1/products${queryString}`);
  }

  async createProduct(product: CreateProductRequest): Promise<BaseResponse<Product>> {
    return this.request('/api/v1/products', {
      method: 'POST',
      body: JSON.stringify(product),
    });
  }

  async getProductByImei(imei: string): Promise<BaseResponse<Product & { imeis: string[] }>> {
    return this.request(`/api/v1/products/imeis/${imei}`);
  }

  // Add other methods as needed...
}
```

### 2. Authentication State Management

```typescript
interface AuthState {
  user: AuthUser | null;
  accessToken: string | null;
  refreshToken: string | null;
  isAuthenticated: boolean;
  isLoading: boolean;
}

// Example with React Context
const AuthContext = createContext<{
  state: AuthState;
  login: (credentials: LoginRequest) => Promise<void>;
  logout: () => void;
  refreshAuth: () => Promise<void>;
}>({} as any);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [state, setState] = useState<AuthState>({
    user: null,
    accessToken: null,
    refreshToken: null,
    isAuthenticated: false,
    isLoading: true,
  });

  const apiClient = new WmsApiClient(process.env.REACT_APP_API_URL!);

  const login = async (credentials: LoginRequest) => {
    try {
      setState(prev => ({ ...prev, isLoading: true }));
      
      const response = await apiClient.login(credentials);
      const { accessToken, refreshToken, user } = response.data;
      
      // Store tokens
      localStorage.setItem('accessToken', accessToken);
      localStorage.setItem('refreshToken', refreshToken);
      
      // Update state
      setState({
        user,
        accessToken,
        refreshToken,
        isAuthenticated: true,
        isLoading: false,
      });

      // Set token in API client
      apiClient.setAccessToken(accessToken);
      
    } catch (error) {
      setState(prev => ({ ...prev, isLoading: false }));
      throw error;
    }
  };

  const logout = () => {
    localStorage.removeItem('accessToken');
    localStorage.removeItem('refreshToken');
    setState({
      user: null,
      accessToken: null,
      refreshToken: null,
      isAuthenticated: false,
      isLoading: false,
    });
  };

  const refreshAuth = async () => {
    const storedRefreshToken = localStorage.getItem('refreshToken');
    if (!storedRefreshToken) {
      logout();
      return;
    }

    try {
      const response = await apiClient.refreshToken(storedRefreshToken);
      const newAccessToken = response.data.accessToken;
      
      localStorage.setItem('accessToken', newAccessToken);
      apiClient.setAccessToken(newAccessToken);
      
      setState(prev => ({
        ...prev,
        accessToken: newAccessToken,
      }));
    } catch (error) {
      logout();
    }
  };

  // Initialize auth state on mount
  useEffect(() => {
    const initAuth = async () => {
      const storedAccessToken = localStorage.getItem('accessToken');
      const storedRefreshToken = localStorage.getItem('refreshToken');
      
      if (storedAccessToken && storedRefreshToken) {
        apiClient.setAccessToken(storedAccessToken);
        // Optionally verify token validity
        await refreshAuth();
      } else {
        setState(prev => ({ ...prev, isLoading: false }));
      }
    };

    initAuth();
  }, []);

  return (
    <AuthContext.Provider value={{ state, login, logout, refreshAuth }}>
      {children}
    </AuthContext.Provider>
  );
}
```

### 3. Role-Based Component Rendering

```typescript
interface RoleGuardProps {
  allowedRoles: UserRole[];
  children: ReactNode;
  fallback?: ReactNode;
}

export function RoleGuard({ allowedRoles, children, fallback }: RoleGuardProps) {
  const { state } = useContext(AuthContext);
  
  if (!state.isAuthenticated || !state.user) {
    return <Navigate to="/login" />;
  }
  
  if (!allowedRoles.includes(state.user.role)) {
    return fallback || <div>Access Denied</div>;
  }
  
  return <>{children}</>;
}

// Usage example
<RoleGuard allowedRoles={['OWNER', 'ADMIN']}>
  <CreateProductButton />
</RoleGuard>
```

### 4. API Query Hooks (React Query Example)

```typescript
// Custom hooks for data fetching
export function useProducts(query?: GetProductsQuery) {
  const { state } = useContext(AuthContext);
  
  return useQuery({
    queryKey: ['products', query],
    queryFn: () => apiClient.getProducts(query),
    enabled: state.isAuthenticated,
  });
}

export function useProductByImei(imei: string) {
  const { state } = useContext(AuthContext);
  
  return useQuery({
    queryKey: ['product', 'imei', imei],
    queryFn: () => apiClient.getProductByImei(imei),
    enabled: state.isAuthenticated && Boolean(imei),
  });
}

export function useCreateProduct() {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: (product: CreateProductRequest) => 
      apiClient.createProduct(product),
    onSuccess: () => {
      // Invalidate and refetch products list
      queryClient.invalidateQueries({ queryKey: ['products'] });
    },
  });
}
```

### 5. Form Validation

```typescript
// Zod schemas for frontend validation (mirror backend schemas)
import { z } from 'zod';

export const createProductSchema = z.object({
  name: z.string().min(1, 'Product name is required'),
  storeId: z.string().uuid('Please select a store'),
  categoryId: z.string().uuid().optional(),
  sku: z.string().min(1, 'SKU is required'),
  isImei: z.boolean().default(false),
  quantity: z.number().positive('Quantity must be positive'),
  purchasePrice: z.number().positive('Purchase price must be positive'),
  salePrice: z.number().positive('Sale price must be positive').optional(),
});

export type CreateProductFormData = z.infer<typeof createProductSchema>;

// Usage with react-hook-form
function CreateProductForm() {
  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<CreateProductFormData>({
    resolver: zodResolver(createProductSchema),
  });

  const createProductMutation = useCreateProduct();

  const onSubmit = async (data: CreateProductFormData) => {
    try {
      await createProductMutation.mutateAsync(data);
      // Handle success
    } catch (error) {
      // Handle error
    }
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input
        {...register('name')}
        placeholder="Product Name"
      />
      {errors.name && <span>{errors.name.message}</span>}
      
      {/* Other form fields */}
      
      <button 
        type="submit" 
        disabled={createProductMutation.isPending}
      >
        {createProductMutation.isPending ? 'Creating...' : 'Create Product'}
      </button>
    </form>
  );
}
```

---

## Summary

This API contract provides:

- **🔐 Complete Authentication System** with JWT tokens and role-based access
- **📦 Full CRUD Operations** for all entities (Users, Stores, Categories, Products, Transactions, IMEIs)
- **🔍 Advanced Search & Filtering** capabilities
- **📄 Consistent Pagination** across all list endpoints
- **📱 IMEI Management** for product tracking
- **💰 Transaction Management** for SALE and TRANSFER operations
- **🛡️ Role-Based Security** with owner scoping
- **⚡ Real-time Token Management** with refresh capabilities

### Key Frontend Implementation Notes:

1. **Always use Bearer tokens** for authenticated requests
2. **Implement token refresh logic** to handle expired tokens
3. **Use role-based rendering** to show/hide UI elements
4. **Validate forms client-side** using the same schemas as backend
5. **Handle errors gracefully** with user-friendly messages
6. **Cache data appropriately** using React Query or similar
7. **Follow pagination patterns** for large data sets
8. **Implement optimistic updates** for better UX

This contract ensures type safety, consistent error handling, and efficient data management for frontend applications integrating with the WMS API.

---

## Flutter/Mobile Integration Guide

### 🏗️ **Flutter Project Setup**

#### 1. Project Structure

```
lib/
├── core/
│   ├── api/
│   │   ├── api_client.dart
│   │   ├── api_endpoints.dart
│   │   └── api_response.dart
│   ├── auth/
│   │   ├── auth_service.dart
│   │   ├── auth_provider.dart
│   │   └── secure_storage.dart
│   ├── models/
│   │   ├── user.dart
│   │   ├── store.dart
│   │   ├── product.dart
│   │   ├── transaction.dart
│   │   └── pagination.dart
│   ├── services/
│   │   ├── user_service.dart
│   │   ├── product_service.dart
│   │   ├── transaction_service.dart
│   │   └── imei_service.dart
│   └── utils/
│       ├── constants.dart
│       ├── validators.dart
│       └── formatters.dart
├── features/
│   ├── auth/
│   ├── dashboard/
│   ├── products/
│   ├── transactions/
│   └── settings/
└── main.dart
```

#### 2. Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # HTTP & API
  dio: ^5.3.2                    # HTTP client
  json_annotation: ^4.8.1       # JSON serialization
  
  # State Management
  provider: ^6.0.5               # State management
  # OR riverpod: ^2.4.0         # Alternative state management
  
  # Storage & Security
  flutter_secure_storage: ^9.0.0 # Secure token storage
  shared_preferences: ^2.2.2     # Local preferences
  
  # UI & Navigation
  go_router: ^12.1.1             # Navigation
  flutter_form_builder: ^9.1.1   # Form handling
  form_builder_validators: ^9.1.0 # Form validation
  
  # Scanning & Camera
  mobile_scanner: ^3.5.2         # Barcode/QR scanning
  camera: ^0.10.5                # Camera access
  image_picker: ^1.0.4           # Photo selection
  
  # Utilities
  equatable: ^2.0.5              # Value equality
  uuid: ^4.1.0                   # UUID generation
  intl: ^0.18.1                  # Internationalization

dev_dependencies:
  build_runner: ^2.4.6           # Code generation
  json_serializable: ^6.7.1     # JSON code generation
  flutter_lints: ^3.0.1         # Linting
```

### 📡 **API Client Implementation**

#### 1. API Response Models

```dart
// lib/core/api/api_response.dart
import 'package:json_annotation/json_annotation.dart';

part 'api_response.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  final bool success;
  final T? data;
  final ApiError? error;
  final String timestamp;

  const ApiResponse({
    required this.success,
    this.data,
    this.error,
    required this.timestamp,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$ApiResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$ApiResponseToJson(this, toJsonT);
}

@JsonSerializable()
class PaginatedResponse<T> {
  final bool success;
  final List<T> data;
  final Pagination pagination;
  final String timestamp;

  const PaginatedResponse({
    required this.success,
    required this.data,
    required this.pagination,
    required this.timestamp,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => PaginatedResponse<T>(
    success: json['success'] as bool,
    data: (json['data'] as List).map((e) => fromJsonT(e)).toList(),
    pagination: Pagination.fromJson(json['pagination']),
    timestamp: json['timestamp'] as String,
  );
}

@JsonSerializable()
class ApiError {
  final String code;
  final String message;

  const ApiError({required this.code, required this.message});

  factory ApiError.fromJson(Map<String, dynamic> json) =>
      _$ApiErrorFromJson(json);

  Map<String, dynamic> toJson() => _$ApiErrorToJson(this);
}

@JsonSerializable()
class Pagination {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  const Pagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) =>
      _$PaginationFromJson(json);

  Map<String, dynamic> toJson() => _$PaginationToJson(this);
}
```

#### 2. API Client

```dart
// lib/core/api/api_client.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../auth/secure_storage.dart';
import 'api_response.dart';
import 'api_endpoints.dart';

class ApiClient {
  late final Dio _dio;
  final SecureStorage _storage;

  ApiClient({
    required String baseUrl,
    required SecureStorage storage,
  }) : _storage = storage {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.addAll([
      _authInterceptor(),
      _errorInterceptor(),
      LogInterceptor(requestBody: true, responseBody: true),
    ]);
  }

  // Auth interceptor to add Bearer token
  Interceptor _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Try to refresh token
          final refreshed = await _refreshToken();
          if (refreshed) {
            // Retry the original request
            final token = await _storage.getAccessToken();
            error.requestOptions.headers['Authorization'] = 'Bearer $token';
            final response = await _dio.fetch(error.requestOptions);
            handler.resolve(response);
            return;
          }
        }
        handler.next(error);
      },
    );
  }

  Interceptor _errorInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) {
        throw ApiException.fromDioError(error);
      },
    );
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await _dio.post(
        ApiEndpoints.refresh,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          response.data,
          (json) => json as Map<String, dynamic>,
        );

        if (apiResponse.success && apiResponse.data != null) {
          await _storage.setAccessToken(apiResponse.data!['accessToken']);
          return true;
        }
      }
    } catch (e) {
      // Refresh failed, clear tokens
      await _storage.clearTokens();
    }
    return false;
  }

  // Generic GET method
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic) fromJson,
  }) async {
    final response = await _dio.get(path, queryParameters: queryParameters);
    return ApiResponse<T>.fromJson(response.data, fromJson);
  }

  // Generic POST method
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    required T Function(dynamic) fromJson,
  }) async {
    final response = await _dio.post(path, data: data);
    return ApiResponse<T>.fromJson(response.data, fromJson);
  }

  // Generic PUT method
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    required T Function(dynamic) fromJson,
  }) async {
    final response = await _dio.put(path, data: data);
    return ApiResponse<T>.fromJson(response.data, fromJson);
  }

  // Generic DELETE method
  Future<ApiResponse<T>> delete<T>(
    String path, {
    required T Function(dynamic) fromJson,
  }) async {
    final response = await _dio.delete(path);
    return ApiResponse<T>.fromJson(response.data, fromJson);
  }

  // Paginated GET method
  Future<PaginatedResponse<T>> getPaginated<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic) fromJson,
  }) async {
    final response = await _dio.get(path, queryParameters: queryParameters);
    return PaginatedResponse<T>.fromJson(response.data, fromJson);
  }
}

class ApiException implements Exception {
  final String code;
  final String message;
  final int? statusCode;

  const ApiException({
    required this.code,
    required this.message,
    this.statusCode,
  });

  factory ApiException.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const ApiException(
          code: 'TIMEOUT',
          message: 'Connection timeout. Please check your internet connection.',
        );
      case DioExceptionType.badResponse:
        final data = error.response?.data;
        if (data is Map<String, dynamic> && data['error'] != null) {
          final apiError = ApiError.fromJson(data['error']);
          return ApiException(
            code: apiError.code,
            message: apiError.message,
            statusCode: error.response?.statusCode,
          );
        }
        return ApiException(
          code: 'HTTP_${error.response?.statusCode}',
          message: 'Server error occurred',
          statusCode: error.response?.statusCode,
        );
      case DioExceptionType.cancel:
        return const ApiException(
          code: 'CANCELLED',
          message: 'Request was cancelled',
        );
      default:
        return const ApiException(
          code: 'NETWORK_ERROR',
          message: 'Network error occurred. Please try again.',
        );
    }
  }

  @override
  String toString() => 'ApiException($code): $message';
}
```

#### 3. API Endpoints

```dart
// lib/core/api/api_endpoints.dart
class ApiEndpoints {
  static const String _apiVersion = '/api/v1';

  // Auth endpoints
  static const String devRegister = '$_apiVersion/auth/dev/register';
  static const String register = '$_apiVersion/auth/register';
  static const String login = '$_apiVersion/auth/login';
  static const String refresh = '$_apiVersion/auth/refresh';
  static const String logout = '$_apiVersion/auth/logout';

  // User endpoints
  static const String users = '$_apiVersion/users';
  static String userById(String id) => '$users/$id';

  // Store endpoints
  static const String stores = '$_apiVersion/stores';
  static String storeById(String id) => '$stores/$id';

  // Category endpoints
  static const String categories = '$_apiVersion/categories';
  static String categoryById(String id) => '$categories/$id';

  // Product endpoints
  static const String products = '$_apiVersion/products';
  static String productById(String id) => '$products/$id';
  static String productByBarcode(String barcode) => '$products/barcode/$barcode';
  static String productByImei(String imei) => '$products/imeis/$imei';
  static const String productsWithImeis = '$products/imeis';

  // Transaction endpoints
  static const String transactions = '$_apiVersion/transactions';
  static String transactionById(String id) => '$transactions/$id';

  // IMEI endpoints
  static String productImeis(String productId) => '$products/$productId/imeis';
  static String imeiById(String id) => '$_apiVersion/imeis/$id';

  // System endpoints
  static const String health = '/health';
}
```

### 🔐 **Authentication Service**

#### 1. Secure Storage

```dart
// lib/core/auth/secure_storage.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainItemAccessibility.first_unlock_this_device,
    ),
  );

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userDataKey = 'user_data';

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  Future<void> setAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<void> setRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  Future<void> setTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      setAccessToken(accessToken),
      setRefreshToken(refreshToken),
    ]);
  }

  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
      _storage.delete(key: _userDataKey),
    ]);
  }

  Future<String?> getUserData() async {
    return await _storage.read(key: _userDataKey);
  }

  Future<void> setUserData(String userData) async {
    await _storage.write(key: _userDataKey, value: userData);
  }
}
```

#### 2. Auth Service

```dart
// lib/core/auth/auth_service.dart
import 'dart:convert';
import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/user.dart';
import 'secure_storage.dart';

class AuthService {
  final ApiClient _apiClient;
  final SecureStorage _storage;

  AuthService({
    required ApiClient apiClient,
    required SecureStorage storage,
  }) : _apiClient = apiClient, _storage = storage;

  Future<AuthResult> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.login,
        data: {'username': username, 'password': password},
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        final accessToken = data['accessToken'] as String;
        final refreshToken = data['refreshToken'] as String;
        final user = User.fromJson(data['user']);

        // Store tokens and user data securely
        await _storage.setTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
        await _storage.setUserData(jsonEncode(user.toJson()));

        return AuthResult.success(user);
      }

      return AuthResult.failure('Login failed');
    } on ApiException catch (e) {
      return AuthResult.failure(e.message);
    } catch (e) {
      return AuthResult.failure('Unexpected error occurred');
    }
  }

  Future<AuthResult> register({
    required String name,
    required String username,
    required String password,
    required UserRole role,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.register,
        data: {
          'name': name,
          'username': username,
          'password': password,
          'role': role.name.toUpperCase(),
        },
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final user = User.fromJson(response.data!);
        return AuthResult.success(user);
      }

      return AuthResult.failure('Registration failed');
    } on ApiException catch (e) {
      return AuthResult.failure(e.message);
    } catch (e) {
      return AuthResult.failure('Unexpected error occurred');
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.post(
        ApiEndpoints.logout,
        fromJson: (json) => json,
      );
    } catch (e) {
      // Ignore logout errors, clear local storage anyway
    }

    await _storage.clearTokens();
  }

  Future<User?> getCurrentUser() async {
    try {
      final userData = await _storage.getUserData();
      if (userData != null) {
        return User.fromJson(jsonDecode(userData));
      }
    } catch (e) {
      // Invalid stored user data
      await _storage.clearTokens();
    }
    return null;
  }

  Future<bool> isLoggedIn() async {
    final accessToken = await _storage.getAccessToken();
    return accessToken != null;
  }
}

class AuthResult {
  final bool isSuccess;
  final User? user;
  final String? error;

  AuthResult._(this.isSuccess, this.user, this.error);

  factory AuthResult.success(User user) => AuthResult._(true, user, null);
  factory AuthResult.failure(String error) => AuthResult._(false, null, error);
}
```

### 📊 **Data Models**

#### 1. User Model

```dart
// lib/core/models/user.dart
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'user.g.dart';

@JsonSerializable()
class User extends Equatable {
  final String id;
  final String? ownerId;
  final String name;
  final String username;
  final UserRole role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    this.ownerId,
    required this.name,
    required this.username,
    required this.role,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  bool get isOwner => role == UserRole.owner;
  bool get isAdmin => role == UserRole.admin;
  bool get isStaff => role == UserRole.staff;
  bool get isCashier => role == UserRole.cashier;

  @override
  List<Object?> get props => [
        id,
        ownerId,
        name,
        username,
        role,
        isActive,
        createdAt,
        updatedAt,
      ];
}

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum UserRole {
  owner,
  admin,
  staff,
  cashier;

  String get displayName {
    switch (this) {
      case UserRole.owner:
        return 'Owner';
      case UserRole.admin:
        return 'Admin';
      case UserRole.staff:
        return 'Staff';
      case UserRole.cashier:
        return 'Cashier';
    }
  }
}
```

#### 2. Product Model

```dart
// lib/core/models/product.dart
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'product.g.dart';

@JsonSerializable()
class Product extends Equatable {
  final String id;
  final String name;
  final String storeId;
  final String? categoryId;
  final String sku;
  final bool isImei;
  final String barcode;
  final int quantity;
  final double purchasePrice;
  final double? salePrice;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String>? imeis; // Only present in IMEI search response

  const Product({
    required this.id,
    required this.name,
    required this.storeId,
    this.categoryId,
    required this.sku,
    required this.isImei,
    required this.barcode,
    required this.quantity,
    required this.purchasePrice,
    this.salePrice,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.imeis,
  });

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
  Map<String, dynamic> toJson() => _$ProductToJson(this);

  double get profit => (salePrice ?? 0) - purchasePrice;
  double get profitMargin => salePrice != null ? (profit / salePrice!) * 100 : 0;

  @override
  List<Object?> get props => [
        id,
        name,
        storeId,
        categoryId,
        sku,
        isImei,
        barcode,
        quantity,
        purchasePrice,
        salePrice,
        createdBy,
        createdAt,
        updatedAt,
        imeis,
      ];
}
```

### 🔄 **State Management with Provider**

#### 1. Auth Provider

```dart
// lib/core/auth/auth_provider.dart
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import 'auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  User? _currentUser;
  bool _isLoading = false;
  bool _isInitialized = false;

  AuthProvider({required AuthService authService}) : _authService = authService;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  bool get isInitialized => _isInitialized;

  // Role-based getters
  bool get isOwner => _currentUser?.isOwner ?? false;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isStaff => _currentUser?.isStaff ?? false;
  bool get isCashier => _currentUser?.isCashier ?? false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    _isLoading = true;
    notifyListeners();

    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        _currentUser = await _authService.getCurrentUser();
      }
    } catch (e) {
      debugPrint('Auth initialization error: $e');
    }

    _isLoading = false;
    _isInitialized = true;
    notifyListeners();
  }

  Future<AuthResult> login({
    required String username,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authService.login(
      username: username,
      password: password,
    );

    if (result.isSuccess) {
      _currentUser = result.user;
    }

    _isLoading = false;
    notifyListeners();

    return result;
  }

  Future<AuthResult> register({
    required String name,
    required String username,
    required String password,
    required UserRole role,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authService.register(
      name: name,
      username: username,
      password: password,
      role: role,
    );

    _isLoading = false;
    notifyListeners();

    return result;
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _authService.logout();
    _currentUser = null;

    _isLoading = false;
    notifyListeners();
  }
}
```

### 📱 **Mobile-Specific Features**

#### 1. Barcode Scanner Service

```dart
// lib/core/services/scanner_service.dart
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerService {
  static Future<String?> scanBarcode() async {
    // This would typically be called from a scanner screen
    // Returns the scanned barcode value
    return null; // Implementation depends on UI integration
  }
}

// Example scanner screen widget
class BarcodeScannerScreen extends StatefulWidget {
  final Function(String) onBarcodeDetected;

  const BarcodeScannerScreen({
    Key? key,
    required this.onBarcodeDetected,
  }) : super(key: key);

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  late MobileScannerController controller;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode'),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: controller.torchState,
              builder: (context, state, child) {
                switch (state) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off);
                  case TorchState.on:
                    return const Icon(Icons.flash_on);
                }
              },
            ),
            onPressed: () => controller.toggleTorch(),
          ),
        ],
      ),
      body: MobileScanner(
        controller: controller,
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            if (barcode.rawValue != null) {
              widget.onBarcodeDetected(barcode.rawValue!);
              Navigator.of(context).pop();
              break;
            }
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
```

#### 2. Camera Service for Photo Proof

```dart
// lib/core/services/camera_service.dart
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CameraService {
  static final ImagePicker _picker = ImagePicker();

  static Future<File?> capturePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      return image != null ? File(image.path) : null;
    } catch (e) {
      return null;
    }
  }

  static Future<File?> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      return image != null ? File(image.path) : null;
    } catch (e) {
      return null;
    }
  }
}
```

### 🎨 **Flutter UI Examples**

#### 1. Login Screen

```dart
// lib/features/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/auth/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo
                Container(
                  height: 100,
                  child: const Icon(
                    Icons.warehouse,
                    size: 80,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Title
                Text(
                  'WMS Login',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                // Username field
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                // Login button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return ElevatedButton(
                      onPressed: authProvider.isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: authProvider.isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Login'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final result = await authProvider.login(
      username: _usernameController.text.trim(),
      password: _passwordController.text,
    );

    if (mounted) {
      if (result.isSuccess) {
        // Navigate to main app
        Navigator.of(context).pushReplacementNamed('/dashboard');
      } else {
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Login failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
```

#### 2. Product List with Barcode Scanner

```dart
// lib/features/products/product_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/product.dart';
import '../../core/services/product_service.dart';
import '../scanner/barcode_scanner_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _searchController = TextEditingController();
  List<Product> _products = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    
    try {
      final productService = Provider.of<ProductService>(context, listen: false);
      final response = await productService.getProducts();
      
      if (response.success) {
        setState(() => _products = response.data);
      }
    } catch (e) {
      _showError('Failed to load products');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _scanBarcode() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => BarcodeScannerScreen(
          onBarcodeDetected: (barcode) => Navigator.of(context).pop(barcode),
        ),
      ),
    );

    if (result != null) {
      await _searchByBarcode(result);
    }
  }

  Future<void> _searchByBarcode(String barcode) async {
    try {
      final productService = Provider.of<ProductService>(context, listen: false);
      final response = await productService.getProductByBarcode(barcode);
      
      if (response.success && response.data != null) {
        // Navigate to product details
        _showProductDetails(response.data!);
      } else {
        _showError('Product not found');
      }
    } catch (e) {
      _showError('Failed to search product');
    }
  }

  void _showProductDetails(Product product) {
    Navigator.of(context).pushNamed('/product-details', arguments: product);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _scanBarcode,
            tooltip: 'Scan Barcode',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: _scanBarcode,
                ),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                // Implement search
              },
            ),
          ),
          
          // Product list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _products.isEmpty
                    ? const Center(
                        child: Text('No products found'),
                      )
                    : ListView.builder(
                        itemCount: _products.length,
                        itemBuilder: (context, index) {
                          final product = _products[index];
                          return ProductCard(
                            product: product,
                            onTap: () => _showProductDetails(product),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/add-product');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({
    Key? key,
    required this.product,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: product.isImei ? Colors.blue : Colors.grey,
          child: Icon(
            product.isImei ? Icons.phone_android : Icons.inventory,
            color: Colors.white,
          ),
        ),
        title: Text(product.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SKU: ${product.sku}'),
            Text('Barcode: ${product.barcode}'),
            Text('Qty: ${product.quantity}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${product.salePrice?.toStringAsFixed(2) ?? 'N/A'}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Cost: ${product.purchasePrice.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
```

### 🚀 **Flutter App Initialization**

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/api/api_client.dart';
import 'core/auth/auth_provider.dart';
import 'core/auth/auth_service.dart';
import 'core/auth/secure_storage.dart';
import 'core/services/product_service.dart';
import 'features/auth/login_screen.dart';
import 'features/dashboard/dashboard_screen.dart';

void main() {
  runApp(const WmsApp());
}

class WmsApp extends StatelessWidget {
  const WmsApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const baseUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://localhost:3000',
    );

    return MultiProvider(
      providers: [
        // Core services
        Provider<SecureStorage>(
          create: (_) => SecureStorage(),
        ),
        ProxyProvider<SecureStorage, ApiClient>(
          update: (_, storage, __) => ApiClient(
            baseUrl: baseUrl,
            storage: storage,
          ),
        ),
        ProxyProvider2<ApiClient, SecureStorage, AuthService>(
          update: (_, apiClient, storage, __) => AuthService(
            apiClient: apiClient,
            storage: storage,
          ),
        ),
        
        // State providers
        ChangeNotifierProxyProvider<AuthService, AuthProvider>(
          create: (context) => AuthProvider(
            authService: Provider.of<AuthService>(context, listen: false),
          ),
          update: (_, authService, previous) =>
              previous ?? AuthProvider(authService: authService),
        ),
        
        // Feature services
        ProxyProvider<ApiClient, ProductService>(
          update: (_, apiClient, __) => ProductService(apiClient: apiClient),
        ),
      ],
      child: MaterialApp(
        title: 'WMS Mobile',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const AppInitializer(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/dashboard': (context) => const DashboardScreen(),
        },
      ),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({Key? key}) : super(key: key);

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.initialize();

    if (mounted) {
      if (authProvider.isLoggedIn) {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      } else {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
```

### 📋 **Flutter Development Checklist**

#### 1. **Setup & Configuration**
- [ ] Create Flutter project with proper dependencies
- [ ] Configure environment variables for different stages
- [ ] Set up proper folder structure
- [ ] Configure code generation (json_serializable)
- [ ] Set up linting and formatting rules

#### 2. **Authentication Implementation**
- [ ] Implement secure token storage
- [ ] Create auth service with login/logout
- [ ] Set up auth provider for state management
- [ ] Implement automatic token refresh
- [ ] Add role-based access control

#### 3. **API Integration**
- [ ] Create API client with Dio
- [ ] Implement all data models with JSON serialization
- [ ] Add error handling and network interceptors
- [ ] Create service classes for each feature
- [ ] Add offline capabilities (optional)

#### 4. **Mobile Features**
- [ ] Implement barcode scanner
- [ ] Add camera integration for photo proof
- [ ] Create responsive UI for different screen sizes
- [ ] Add pull-to-refresh functionality
- [ ] Implement proper navigation

#### 5. **Production Readiness**
- [ ] Add proper error logging
- [ ] Implement analytics (optional)
- [ ] Add crash reporting
- [ ] Configure app signing
- [ ] Set up CI/CD pipeline

### 🎯 **Key Flutter Advantages for WMS**

1. **📱 Cross-Platform**: Single codebase for iOS and Android
2. **📷 Camera Integration**: Built-in barcode scanning and photo capture
3. **⚡ Performance**: Near-native performance for mobile operations
4. **🔄 Offline Support**: Can implement local database for offline operations
5. **🔒 Security**: Secure storage for authentication tokens
6. **📊 Rich UI**: Material Design and Cupertino widgets
7. **🔧 Hardware Access**: Camera, flashlight, and device sensors

This Flutter integration provides a complete mobile solution for the WMS system with proper authentication, API integration, and mobile-specific features like barcode scanning and photo capture.