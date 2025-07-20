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

## 📱 **MOBILE: PHASE 10 COMPLETE - CAMERA SERVICE & PHOTO CAPTURE (65+ Dart files)**

**Current Status**: 50% Complete (10/20 phases) | **Next**: Phase 8 - Transaction Management & Sales

### Latest Completion: Phase 10 - Camera Service & Photo Capture ✅
- **CameraService**: Complete singleton camera management with initialization, photo capture, compression, storage management
- **ImageUtils**: Comprehensive image processing utilities with compression (up to 70% reduction), thumbnail creation, enhancement filters  
- **CameraScreen**: Professional Material Design 3 camera UI with single/multiple photo modes, flash control, camera switching
- **PhotoViewer**: Full-featured photo viewing with pinch-to-zoom, image info, delete functionality
- **Localization**: Added 20+ camera-related translation keys

### Completed Phases (10/20)
- ✅ **Phase 1-3**: Foundation, UI Theme System, API Client & Network Layer
- ✅ **Phase 4-6**: Authentication System, Login & Store Selection, Navigation & Store Context  
- ✅ **Phase 7**: Role-Based Dashboard Screens (Owner/Admin/Staff/Cashier with tailored UI)
- ✅ **Phase 8**: *(Skipped to Phase 10)*
- ✅ **Phase 9**: *(Skipped to Phase 10)*
- ✅ **Phase 10**: Camera Service & Photo Capture (Production-ready photo capture system)

### Key Features Implemented
- **Authentication Flow**: JWT with role-based navigation, store selection for non-owners
- **Navigation System**: GoRouter with authentication guards, declarative routing with global redirect logic
- **Role-Based Dashboards**: Owner (8 sections), Admin (6 sections), Staff (4 sections), Cashier (4 sections) with permission-aware UI
- **Camera System**: Professional photo capture with compression, multi-photo support, storage management, photo preview/zoom
- **UI Components**: Material Design 3, comprehensive theme system, responsive design, loading states
- **Services**: CameraService, AuthService, StoreContextProvider with persistence
- **Internationalization**: 220+ translation keys covering auth, navigation, camera functionality
- **12+ Screens**: Splash, Login, Store Selection, Dashboard, Camera, Photo Viewer, Settings, Error screens

### Current Mobile Architecture (Updated)
```
mobile/lib/
├── core/ (45+ files after cleanup)
│   ├── api/ - HTTP client, endpoints, exceptions, interceptors
│   ├── auth/ - AuthProvider, AuthService, secure storage
│   ├── models/ - User, Store, Product, Transaction, Category, StoreContext
│   ├── services/ - CameraService, ProductService, CategoryService, StoreService
│   ├── providers/ - AppProvider (theme/locale), StoreContextProvider, AuthProvider
│   ├── routing/ - GoRouter with auth guards, global redirect logic
│   ├── theme/ - Comprehensive theme system with role-based color coding
│   ├── utils/ - ImageUtils (compression, enhancement, thumbnails)
│   └── widgets/ - PhotoViewer, MainNavigationScaffold, form components, cards, buttons
├── features/ (15+ screens)
│   ├── auth/ - Splash, Login, Store Selection screens
│   ├── dashboard/ - Role-based dashboard widgets (Owner/Admin/Staff/Cashier)
│   ├── camera/ - CameraScreen with professional photo capture UI
│   ├── settings/ - Settings screen with user profile
│   └── [products, transactions, stores, users, categories, checks]/ - Navigation ready
├── l10n/ - English/Indonesian translations (220+ keys)
└── generated/ - Localization classes
```

### Recent Codebase Cleanup ✅
**Removed unused widgets and services:**
- camera_capture_widget.dart (duplicate)
- photo_preview_widget.dart (replaced by PhotoViewer)  
- photo_capture_helper.dart (unused utility)
- photo_service.dart (conflicting with CameraService)
- image_cache_manager.dart (unused cache manager)
- bottom_navigation.dart (unused navigation widget)

**Result**: Reduced flutter analyze issues from 216 → 198 by eliminating unused code and import conflicts.

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
1. ✅ **Mobile Phase 10**: Camera Service & Photo Capture *(COMPLETED - Professional photo capture system with compression)*
2. **Mobile Phase 8**: Transaction Management & Sales (4-5 days) *(Next Priority)*
3. **Mobile Phase 11**: Barcode Scanner Integration (3-4 days)
4. **Mobile Phase 13**: Product CRUD Forms (3-4 days)
5. **Mobile Phase 14**: Settings & User Profile (2-3 days)
6. **Web Frontend Development**: Build React UI using the complete API contract (optional)

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