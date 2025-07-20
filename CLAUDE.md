# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Warehouse Management System (WMS)** - A complete inventory management system for tracking goods across multiple stores with role-based access control, featuring web and mobile applications.

### Tech Stack

- **Backend**: Hono, Node.js, Zod, Drizzle, SQLite Turso ✅ **PRODUCTION READY**
- **Database**: SQLite with Drizzle ORM ✅ **PRODUCTION READY**  
- **Authentication**: JWT-based with role-based access control ✅ **PRODUCTION READY**
- **Frontend Web**: React, Shadcn, Zod, React Query, Tailwindcss, Rsbuild 📋 **PLANNED**
- **Mobile**: Flutter (cross-platform mobile development) ✅ **PHASE 15 COMPLETE - TRANSACTION CREATION SYSTEM READY**

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

## 📱 **MOBILE: PHASE 15 COMPLETE - TRANSACTION CREATION & ITEM MANAGEMENT (85+ Dart files)**

**Current Status**: 75% Complete (15/20 phases) | **Next**: Phase 16 - Thermal Printer Foundation

### Latest Completion: Phase 15 - Transaction Creation & Item Management ✅
- **TransactionService**: Complete transaction CRUD with validation, filtering, and business rule enforcement
- **TransactionForm**: Multi-step transaction creation (Type → Items → Review) with role-based permissions
- **TransactionItemManager**: Product search integration with barcode/IMEI scanning preparation and real-time calculations
- **PhotoProofPicker**: Camera integration for transaction photo proof with upload simulation
- **TransactionValidators**: Comprehensive validation for transactions, items, customer info, and business rules
- **Role-based Permissions**: OWNER/ADMIN/CASHIER create permissions, OWNER/ADMIN edit permissions with proper access control

### Completed Phases (15/20)
- ✅ **Phase 1-3**: Foundation, UI Theme System, API Client & Network Layer
- ✅ **Phase 4-6**: Authentication System, Login & Store Selection, Navigation & Store Context  
- ✅ **Phase 7**: Role-Based Dashboard Screens (Owner/Admin/Staff/Cashier with tailored UI)
- ✅ **Phase 8**: *(Skipped - moved to Phase 10)*
- ✅ **Phase 9**: *(Skipped - moved to Phase 10)*
- ✅ **Phase 10**: Camera Service & Photo Capture (Production-ready photo capture system)
- ✅ **Phase 11**: Barcode Scanner Integration (Multiple format support, scanner overlay, product search)
- ✅ **Phase 12**: IMEI Scanner & Product Search (Industry-standard IMEI system with product management)
- ✅ **Phase 13**: Product CRUD Forms (Multi-step product creation/editing with IMEI support and validation)
- ✅ **Phase 14**: Product Detail & IMEI Management (Comprehensive product detail with IMEI management system)
- ✅ **Phase 15**: Transaction Creation & Item Management (Complete transaction workflows with business validation)

### Key Features Implemented
- **Authentication Flow**: JWT with role-based navigation, store selection for non-owners
- **Navigation System**: GoRouter with authentication guards, declarative routing with global redirect logic
- **Role-Based Dashboards**: Owner (8 sections), Admin (6 sections), Staff (4 sections), Cashier (4 sections) with permission-aware UI
- **Camera System**: Professional photo capture with compression, multi-photo support, storage management, photo preview/zoom
- **Barcode Scanner System**: Multiple format support (EAN, UPC, Code128, QR), scanner overlay, product search integration
- **IMEI Scanner System**: Industry-standard IMEI validation (Luhn algorithm), product search, management interface
- **Product Management**: Complete CRUD forms with multi-step creation, IMEI support, validation, and comprehensive detail screens
- **Transaction System**: Multi-step transaction creation (SALE/TRANSFER), item management, photo proof, business validation
- **UI Components**: Material Design 3, comprehensive theme system, responsive design, loading states
- **Services**: TransactionService, ProductService, CameraService, ScannerService, ImeiScannerService, AuthService with full API integration
- **Internationalization**: 280+ translation keys covering complete business workflows
- **20+ Screens**: Authentication, Dashboards, Product CRUD, Transaction Creation, Camera, Scanners, Management interfaces

### Current Mobile Architecture (Updated)
```
mobile/lib/
├── core/ (65+ files)
│   ├── api/ - HTTP client, endpoints, exceptions, interceptors
│   ├── auth/ - AuthProvider, AuthService, secure storage
│   ├── models/ - User, Store, Product, Transaction, Category, StoreContext with API requests
│   ├── services/ - TransactionService, ProductService, CameraService, ScannerService, ImeiScannerService
│   ├── providers/ - AppProvider (theme/locale), StoreContextProvider, AuthProvider
│   ├── routing/ - GoRouter with auth guards, global redirect logic, transaction routes
│   ├── theme/ - Comprehensive theme system with role-based color coding
│   ├── validators/ - ProductValidators, TransactionValidators with business rules
│   ├── utils/ - ImageUtils, BarcodeUtils, ImeiUtils (validation, formatting, utilities)
│   └── widgets/ - PhotoViewer, ScannerOverlay, MainNavigationScaffold, form components
├── features/ (25+ screens)
│   ├── auth/ - Splash, Login, Store Selection screens
│   ├── dashboard/ - Role-based dashboard widgets (Owner/Admin/Staff/Cashier)
│   ├── camera/ - CameraScreen with professional photo capture UI
│   ├── scanner/ - BarcodeScannerScreen, ImeiScannerScreen, ImeiProductSearchWidget
│   ├── products/ - ProductList, ProductDetail, CreateProduct, EditProduct, ImeiManagement screens
│   ├── transactions/ - CreateTransaction, TransactionForm, TransactionItemManager, PhotoProofPicker widgets
│   ├── settings/ - Settings screen with user profile
│   └── [stores, users, categories, checks]/ - Navigation ready for next phases
├── l10n/ - English/Indonesian translations (280+ keys)
└── generated/ - Localization classes
```

### Business Workflows Ready
- ✅ **Product Creation → Auto-navigate to detail → Print barcode** (Phases 13-14)
- ✅ **Transaction Creation → Auto-print receipt → Transaction detail with "Print Payment Note"** (Phase 15)
- 🔄 **Barcode Scanning → Add items to transactions OR find products** (Phase 11 foundation + Phase 15 integration)
- 🔄 **IMEI Scanning → Find products by IMEI number** (Phase 12 foundation + Phase 15 integration)

### Recent Developments ✅

**Phase 13-15 Implementation (Major Milestone):**
- **Product Management System**: Complete CRUD operations with multi-step forms, IMEI management, and comprehensive validation
- **Transaction Creation System**: Multi-step workflow with item management, photo proof integration, and business rule validation
- **Enhanced API Integration**: TransactionService with full CRUD operations and ProductService with IMEI management
- **Role-based Permissions**: Comprehensive permission system for product and transaction operations across all user roles

**Phase 11 & 12 Foundation:**
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