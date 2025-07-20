# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Warehouse Management System (WMS)** - A complete inventory management system for tracking goods across multiple stores with role-based access control, featuring web and mobile applications.

### Tech Stack

- **Backend**: Hono, Node.js, Zod, Drizzle, SQLite Turso ✅ **PRODUCTION READY**
- **Database**: SQLite with Drizzle ORM ✅ **PRODUCTION READY**  
- **Authentication**: JWT-based with role-based access control ✅ **PRODUCTION READY**
- **Frontend Web**: React, Shadcn, Zod, React Query, Tailwindcss, Rsbuild 📋 **PLANNED**
- **Mobile**: Flutter (cross-platform mobile development) ✅ **PHASE 12 COMPLETE - IMEI SCANNER SYSTEM READY**

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

## 📱 **MOBILE: PHASE 12 COMPLETE - IMEI SCANNER & PRODUCT SEARCH (75+ Dart files)**

**Current Status**: 60% Complete (12/20 phases) | **Next**: Phase 13 - Transaction Management & Sales

### Latest Completion: Phase 12 - IMEI Scanner & Product Search ✅
- **ImeiUtils**: Industry-standard IMEI validation with Luhn algorithm, formatting, TAC/serial extraction
- **ImeiScannerService**: IMEI-specific scanning service with product search integration and scan history
- **ImeiScannerScreen**: Professional IMEI scanner with real-time validation and automatic product lookup
- **ProductImeiManagementScreen**: Complete IMEI management interface for adding/removing IMEIs from products
- **ImeiProductSearchWidget**: Transaction workflow integration components for IMEI-based product selection
- **Enhanced ProductSearchService**: Priority IMEI search with detailed validation and auto-detection

### Completed Phases (12/20)
- ✅ **Phase 1-3**: Foundation, UI Theme System, API Client & Network Layer
- ✅ **Phase 4-6**: Authentication System, Login & Store Selection, Navigation & Store Context  
- ✅ **Phase 7**: Role-Based Dashboard Screens (Owner/Admin/Staff/Cashier with tailored UI)
- ✅ **Phase 8**: *(Skipped to Phase 10)*
- ✅ **Phase 9**: *(Skipped to Phase 10)*
- ✅ **Phase 10**: Camera Service & Photo Capture (Production-ready photo capture system)
- ✅ **Phase 11**: Barcode Scanner Integration (Multiple format support, scanner overlay, product search)
- ✅ **Phase 12**: IMEI Scanner & Product Search (Industry-standard IMEI system with product management)

### Key Features Implemented
- **Authentication Flow**: JWT with role-based navigation, store selection for non-owners
- **Navigation System**: GoRouter with authentication guards, declarative routing with global redirect logic
- **Role-Based Dashboards**: Owner (8 sections), Admin (6 sections), Staff (4 sections), Cashier (4 sections) with permission-aware UI
- **Camera System**: Professional photo capture with compression, multi-photo support, storage management, photo preview/zoom
- **Barcode Scanner System**: Multiple format support (EAN, UPC, Code128, QR), scanner overlay, product search integration
- **IMEI Scanner System**: Industry-standard IMEI validation (Luhn algorithm), product search, management interface
- **UI Components**: Material Design 3, comprehensive theme system, responsive design, loading states
- **Services**: CameraService, ScannerService, ImeiScannerService, AuthService, StoreContextProvider with persistence
- **Internationalization**: 220+ translation keys covering auth, navigation, camera, scanner functionality
- **15+ Screens**: Splash, Login, Store Selection, Dashboard, Camera, Photo Viewer, Barcode Scanner, IMEI Scanner, IMEI Management, Settings, Error screens

### Current Mobile Architecture (Updated)
```
mobile/lib/
├── core/ (55+ files)
│   ├── api/ - HTTP client, endpoints, exceptions, interceptors
│   ├── auth/ - AuthProvider, AuthService, secure storage
│   ├── models/ - User, Store, Product, Transaction, Category, StoreContext
│   ├── services/ - CameraService, ScannerService, ImeiScannerService, ProductSearchService
│   ├── providers/ - AppProvider (theme/locale), StoreContextProvider, AuthProvider
│   ├── routing/ - GoRouter with auth guards, global redirect logic, scanner routes
│   ├── theme/ - Comprehensive theme system with role-based color coding
│   ├── utils/ - ImageUtils, BarcodeUtils, ImeiUtils (validation, formatting, utilities)
│   └── widgets/ - PhotoViewer, ScannerOverlay, MainNavigationScaffold, form components
├── features/ (20+ screens)
│   ├── auth/ - Splash, Login, Store Selection screens
│   ├── dashboard/ - Role-based dashboard widgets (Owner/Admin/Staff/Cashier)
│   ├── camera/ - CameraScreen with professional photo capture UI
│   ├── scanner/ - BarcodeScannerScreen, ImeiScannerScreen, ImeiProductSearchWidget
│   ├── products/ - ProductImeiManagementScreen (IMEI management interface)
│   ├── settings/ - Settings screen with user profile
│   └── [transactions, stores, users, categories, checks]/ - Navigation ready
├── l10n/ - English/Indonesian translations (220+ keys)
└── generated/ - Localization classes
```

### Recent Developments ✅

**Phase 11 & 12 Implementation:**
- **BarcodeScannerScreen**: Professional scanner with multiple format support (EAN, UPC, Code128, QR)
- **ScannerService**: Complete barcode scanning service with validation and product search integration
- **ImeiScannerScreen**: Industry-standard IMEI scanner with Luhn algorithm validation
- **ImeiUtils**: Comprehensive IMEI validation, formatting, TAC/serial extraction utilities
- **ProductImeiManagementScreen**: Complete IMEI management interface for products
- **ImeiProductSearchWidget**: Transaction workflow integration components

**Code Quality**: Reduced flutter analyze issues from 172 → 158 by resolving IMEI implementation issues and type conflicts.

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
2. ✅ **Mobile Phase 11**: Barcode Scanner Integration *(COMPLETED - Multiple format support, scanner overlay, product search)*
3. ✅ **Mobile Phase 12**: IMEI Scanner & Product Search *(COMPLETED - Industry-standard IMEI system with product management)*
4. **Mobile Phase 13**: Transaction Management & Sales (4-5 days) *(Next Priority)*
5. **Mobile Phase 14**: Product CRUD Forms (3-4 days)
6. **Mobile Phase 15**: Settings & User Profile (2-3 days)
7. **Web Frontend Development**: Build React UI using the complete API contract (optional)

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