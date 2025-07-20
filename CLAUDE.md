# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Warehouse Management System (WMS)** - A complete inventory management system for tracking goods across multiple stores with role-based access control, featuring web and mobile applications.

### Tech Stack

- **Backend**: Hono, Node.js, Zod, Drizzle, SQLite Turso ✅ **PRODUCTION READY**
- **Database**: SQLite with Drizzle ORM ✅ **PRODUCTION READY**  
- **Authentication**: JWT-based with role-based access control ✅ **PRODUCTION READY**
- **Frontend Web**: React, Shadcn, Zod, React Query, Tailwindcss, Rsbuild 📋 **PLANNED**
- **Mobile**: Flutter (cross-platform mobile development) ✅ **PHASE 9 COMPLETE - PRODUCT MANAGEMENT READY**

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

## 🚀 **BACKEND: PRODUCTION READY (51 TypeScript files)**

**40+ API endpoints** fully implemented with JWT authentication, RBAC, IMEI tracking, barcode generation, photo proof, validation, error handling, pagination, filtering, and comprehensive testing.

### Key API Endpoints
```
Authentication: POST /api/v1/auth/{dev/register,register,login,refresh,logout}
Users: CRUD /api/v1/users (with pagination)
Stores: CRUD /api/v1/stores (OWNER only)
Categories: CRUD /api/v1/categories (OWNER/ADMIN)
Products: CRUD /api/v1/products + /api/v1/products/barcode/:barcode + /api/v1/products/imeis/:imei
Transactions: CRUD /api/v1/transactions (SALE/TRANSFER types)
IMEI Management: /api/v1/products/:id/imeis, /api/v1/imeis/:id
```

## 📱 **MOBILE: PHASE 9 COMPLETE (70+ Dart files)**

**Current Status**: 45% Complete (9/20 phases) | **Next**: Phase 10 - Camera Service & Photo Capture

### Completed Phases
- ✅ **Phase 1-3**: Foundation, UI Theme System, API Client & Network Layer
- ✅ **Phase 4-6**: Authentication System, Login & Store Selection, Navigation & Store Context
- ✅ **Phase 7-9**: Internationalization (202+ keys), Bottom Navigation, Product Management

### Key Features Implemented
- **Authentication Flow**: JWT with role-based navigation, store selection for non-owners
- **Navigation System**: GoRouter with authentication guards, role-based bottom navigation (8/7/4/4 tabs by role)
- **Product Management**: Infinite scroll list, real-time search, filtering, role-based actions, product detail view
- **UI Components**: Material Design 3, theme switcher (Light/Dark/System), responsive design
- **Services**: Typed API service layer (ProductService, CategoryService, StoreService, AuthService)
- **Internationalization**: English/Indonesian with parameterized messages
- **12+ Screens**: Splash, Login, Store Selection, Dashboard, Settings, Products (List/Detail), Transactions, Stores, Users, Categories, Checks

### Current Mobile Architecture
```
mobile/lib/
├── core/ (50+ files)
│   ├── api/ - HTTP client, endpoints, exceptions, interceptors
│   ├── auth/ - AuthProvider, AuthService, secure storage
│   ├── models/ - User, Store, Product, Transaction, Category + typed API requests
│   ├── services/ - ProductService, CategoryService, StoreService (typed models)
│   ├── providers/ - AppProvider (theme/locale), StoreContextProvider
│   ├── routing/ - GoRouter with auth guards, route protection
│   ├── theme/ - Comprehensive theme system with switcher
│   └── widgets/ - Reusable UI components, navigation scaffolds
├── features/ (12+ screens)
│   ├── auth/ - Splash, Login, Store Selection
│   ├── dashboard/ - Role-based dashboards with metrics
│   ├── products/ - List (infinite scroll, search, filter), Detail
│   ├── settings/ - Full settings with theme switcher
│   └── [transactions, stores, users, categories, checks]/ - Navigation placeholders
└── generated/ - i18n classes, JSON serialization
```

## 🔧 **Development Guidelines**

### Business Rules
- Products must have unique barcodes within owner scope
- SALE transactions require at least one product item and photo proof
- All data is owner-scoped (non-OWNER roles see data from same owner only)
- Soft delete for audit trail

### Code Standards
- **DRY & KISS**: Avoid duplication, keep solutions simple
- **Type Safety**: Use Zod schemas, typed models throughout
- **Security**: Never expose secrets/keys, validate all inputs
- **Testing**: Test at controller layer via HTTP endpoints
- **ID Generation**: `randomUUID()` for DB primary keys, `nanoid()` for barcodes only

### 🚫 **CRITICAL DATABASE MODEL PROTECTION** 🚫
**NEVER MODIFY** these files without explicit user request:
- `src/models/users.ts`, `src/models/stores.ts`, `src/models/categories.ts`
- `src/models/products.ts`, `src/models/transactions.ts`, `src/models/product_checks.ts`, `src/models/product_imeis.ts`

### API Response Standards
- **ALWAYS use `ResponseUtils`** from `src/utils/responses.ts`
- **ALWAYS use Zod schemas** for validation
- **Required format**: `BaseResponse<T>` or `PaginatedResponse<T>`

## 📊 **Next Steps**
1. **Mobile Phase 10**: Camera Service & Photo Capture (2-3 days)
2. **Mobile Phase 11**: Barcode Scanner Integration (3-4 days)
3. **Mobile Phase 12**: Transaction Management & Sales (4-5 days)
4. **Mobile Phase 13**: Product CRUD Forms (3-4 days)
5. **Mobile Phase 14**: Settings & User Profile (2-3 days)

## Development Commands

**Backend** (from `/backend`):
```bash
pnpm run dev          # Development server
pnpm run test         # Run tests
pnpm run db:migrate   # Database migrations
pnpm run lint         # Code quality
```

**Mobile** (from `/mobile`):
```bash
flutter run           # Development
flutter analyze       # Code analysis
flutter pub run build_runner build  # Generate code
flutter test          # Run tests
```