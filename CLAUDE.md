# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Warehouse Management System (WMS)** - A complete inventory management system for tracking goods across multiple stores with role-based access control, featuring web and mobile applications.

### Tech Stack

- **Backend**: Hono, Node.js, Zod, Drizzle, SQLite Turso ✅ **PRODUCTION READY**
- **Database**: SQLite with Drizzle ORM ✅ **PRODUCTION READY**  
- **Authentication**: JWT-based with role-based access control ✅ **PRODUCTION READY**
- **Frontend Web**: React, Shadcn, Zod, React Query, Tailwindcss, Rsbuild 📋 **PLANNED**
- **Mobile**: Flutter (cross-platform mobile development) ✅ **PHASE 4 COMPLETE - CORE FOUNDATION READY**

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

### Key Features

- Multi-store inventory management
- Barcode scanning for product tracking
- Photo proof requirements for sales
- Product checking system (PENDING/OK/MISSING/BROKEN)
- Cross-store transfers
- Analytics and reporting
- Role-based dashboards

## 🎯 **MVP (Minimum Viable Product) Scope**

The MVP focuses on essential functionality to get the system operational quickly:

### **MVP Core Features**

1. **Authentication System** 🔐

   - User registration (OWNER role only for initial setup)
   - User login with JWT tokens
   - Basic role-based access control (OWNER, ADMIN)
   - Session management

2. **Product Management** 📦

   - OWNER and ADMIN can create products
   - Basic product information (name, barcode, price, quantity)
   - Category assignment
   - Store-scoped product management
   - Barcode generation with nanoid

3. **Sales Transactions** 💰
   - OWNER and ADMIN can create SALE transactions
   - Transaction items with product selection
   - Basic transaction recording
   - Photo proof upload capability
   - Transaction history

### **MVP User Roles (Simplified)**

- **OWNER**: Full access to all MVP features
- **ADMIN**: Limited access - can manage products and sales within assigned store
- **STAFF/CASHIER**: Not included in MVP (future enhancement)

### **MVP Business Rules**

- Products must have unique barcodes within owner scope
- SALE transactions require at least one product item
- Only OWNER and ADMIN roles can create products and transactions
- All data is owner-scoped (users only see data from their owner hierarchy)
- Soft delete for audit trail

### **🚀 FULLY IMPLEMENTED API ENDPOINTS (40+ endpoints)**

```
System:
GET  /health                            - Health check

Authentication:
POST /api/v1/auth/dev/register          - Dev register (creates OWNER)
POST /api/v1/auth/register              - Register user (role-based)
POST /api/v1/auth/login                 - User login
POST /api/v1/auth/refresh               - Refresh access token
POST /api/v1/auth/logout                - User logout

Users:
POST /api/v1/users                      - Create user (OWNER/ADMIN)
GET  /api/v1/users                      - List users (paginated)
GET  /api/v1/users/:id                  - Get user by ID
PUT  /api/v1/users/:id                  - Update user
DELETE /api/v1/users/:id                - Delete user (OWNER only)

Stores:
POST /api/v1/stores                     - Create store (OWNER only)
GET  /api/v1/stores                     - List stores (paginated)
GET  /api/v1/stores/:id                 - Get store by ID
PUT  /api/v1/stores/:id                 - Update store (OWNER only)

Categories:
POST /api/v1/categories                 - Create category (OWNER/ADMIN)
GET  /api/v1/categories                 - List categories (paginated)
GET  /api/v1/categories/:id             - Get category by ID
PUT  /api/v1/categories/:id             - Update category (OWNER/ADMIN)

Products:
POST /api/v1/products                   - Create product (OWNER/ADMIN)
GET  /api/v1/products                   - List products (paginated, filtered)
GET  /api/v1/products/:id               - Get product by ID
GET  /api/v1/products/barcode/:barcode  - Get product by barcode
PUT  /api/v1/products/:id               - Update product (OWNER/ADMIN)

Transactions:
POST /api/v1/transactions               - Create transaction (SALE/TRANSFER)
GET  /api/v1/transactions               - List transactions (paginated, filtered)
GET  /api/v1/transactions/:id           - Get transaction with items
PUT  /api/v1/transactions/:id           - Update transaction (OWNER/ADMIN)

IMEI Management:
POST /api/v1/products/:id/imeis         - Add IMEI to product (OWNER/ADMIN)
GET  /api/v1/products/:id/imeis         - List product IMEIs (paginated)
DELETE /api/v1/imeis/:id                - Remove IMEI (OWNER/ADMIN)
POST /api/v1/products/imeis             - Create product with IMEIs (OWNER/ADMIN)
GET  /api/v1/products/imeis/:imei       - Get product by IMEI (NEW!)
```

**🔍 Advanced Features:**
- **Pagination**: All list endpoints support `page`, `limit` parameters
- **Filtering**: Advanced filtering by store, category, price, IMEI, status, etc.
- **Search**: Text search across names and descriptions
- **Role-based access**: Automatic permission enforcement
- **Owner scoping**: Data isolation by owner hierarchy
- **Validation**: Comprehensive input validation with Zod schemas
- **Error handling**: Standardized error responses with proper HTTP codes

### **MVP Implementation Priority**

1. **Phase 1**: Authentication System

   - User registration/login
   - JWT token management
   - Basic middleware for auth

2. **Phase 2**: Product Management

   - Product CRUD operations
   - Category basic support
   - Barcode generation

3. **Phase 3**: Sales Transactions
   - SALE transaction creation
   - Transaction items management
   - Basic photo proof handling

### **🎯 CURRENT FEATURE STATUS**

**✅ FULLY IMPLEMENTED:**
- ✅ **All user roles** (OWNER/ADMIN/STAFF/CASHIER with proper permissions)
- ✅ **Complete IMEI tracking system** with product association
- ✅ **Cross-store transfers** (SALE and TRANSFER transaction types)
- ✅ **Complex store management** with full address and operational details
- ✅ **Product quantity tracking** with validation
- ✅ **Transaction workflows** with items management
- ✅ **Photo proof URL handling** for sales transactions
- ✅ **Advanced filtering and search** across all entities

**📋 IMPLEMENTATION READY (Models defined, services can be added):**
- 📋 **Product checking system** (models ready, UI/business logic needed)
- 📋 **Advanced analytics and reporting** (can query existing transaction data)
- 📋 **Advanced photo proof validation** (infrastructure ready)

**🚀 READY FOR FRONTEND DEVELOPMENT:**
The backend API is **production-ready** and fully functional. Frontend teams can immediately start building:
- **Web applications** (React, Vue, Angular)
- **Mobile applications** (Flutter, React Native)
- **Desktop applications** (Electron, Tauri)
- **Integration tools** (any HTTP client)

## 📱 **MOBILE APPLICATION STATUS - PHASE 7 COMPLETE + INTERNATIONALIZATION READY**

### **Flutter Mobile Development Status: Phase 7 Complete - Internationalization & Localization**

**Current Phase**: ✅ **Phase 7: Internationalization & Localization - COMPLETED**  
**Latest Update**: ✅ **Complete i18n implementation with 195+ localization keys across all UI screens**  
**Next Phase**: 📋 **Phase 8: Product Management & Scanning**  
**Overall Progress**: **35% Complete (7/20 phases)**

### **Phase 5 Implementation Summary - Login & Store Selection Flow**

**✅ Complete Authentication Flow Implementation:**
- **Login Screen**: Professional UI with real-time form validation, show/hide password, loading states
- **Store Selection Screen**: Role-based store selection for non-owner users with error handling
- **Dashboard Screen**: Role-specific welcome interface with quick actions and store context
- **Navigation Flow**: Proper routing - NON-OWNER (Login → Store Selection → Dashboard), OWNER (Login → Dashboard)

**✅ Technical Implementation:**
- **4 New Screens**: Login, Store Selection, Dashboard, plus enhanced Splash screen
- **Form Validation**: Real-time validation with flutter_form_builder and form_builder_validators
- **Error Handling**: Network errors, API errors, user-friendly messaging
- **State Management**: Integrated with AuthProvider and StoreContextProvider
- **Code Quality**: All critical errors resolved, flutter analyze passing

### **Latest Configuration Updates (January 2025)**
- ✅ **Android NDK Version**: Updated to `27.0.12077973`
- ✅ **Android MinSDK**: Updated to `33` for enhanced security and compatibility  
- ✅ **Thermal Printing Dependencies**: Updated to latest versions
  - `print_bluetooth_thermal: ^1.1.4` (replaces esc_pos_bluetooth)
  - `esc_pos_utils_plus: ^2.0.4` (replaces esc_pos_utils)
- ✅ **Authentication Flow**: Complete login and store selection implementation

### **Phase 6 Implementation Summary - Navigation System & Store Context**

**✅ Complete Navigation System Implementation:**
- **GoRouter Integration**: Declarative routing system with authentication guards and global redirect logic
- **Enhanced StoreContextProvider**: Comprehensive store management with StoreContext model for data persistence
- **Route Guards**: Role-based access control protecting routes based on authentication and store selection
- **Navigation Flow**: Proper back button handling through declarative routing system
- **Error Handling**: Global error screens and navigation error recovery

**✅ Technical Implementation:**
- **Store Context Model**: Robust data model with persistence helpers, validation methods, and JSON serialization
- **Authentication Guards**: Comprehensive route protection with auth state checking and store selection requirements
- **Global Redirect Logic**: Intelligent navigation flow based on user role and authentication state
- **Error Recovery**: ErrorScreen component with retry mechanisms and proper error routing
- **Code Quality**: Flutter analyze passing with 64 informational warnings (no critical errors)

**✅ Navigation Architecture:**
- **Protected Routes**: /dashboard, /products, /transactions, /settings, /categories, /stores, /users
- **Store-Required Routes**: /dashboard, /products, /transactions, /categories
- **Authentication Flow**: Splash → Login → (Store Selection if non-owner) → Dashboard
- **Route Helpers**: Static navigation methods for consistent routing throughout the app

### **Phase 7 Implementation Summary - Internationalization & Localization**

**✅ Complete i18n System Implementation:**
- **ARB File Expansion**: Expanded from 40 to 195+ localization keys covering all UI text across screens
- **Multi-language Support**: English (en) and Indonesian (id) translations with proper parameterization
- **AppLocalizations Integration**: Systematic replacement of hardcoded strings with localized equivalents
- **Configuration Cleanup**: Resolved conflicts between pubspec.yaml and l10n.yaml for consistent setup
- **Type-safe Access**: All screens use AppLocalizations.of(context)! pattern for compile-time safety

**✅ Technical Implementation:**
- **Parameterized Messages**: Dynamic content support with placeholders (e.g., welcomeBackUser(name))
- **Error Messages**: Comprehensive localization of error handling and validation messages
- **Form Validation**: All form fields, labels, hints, and error messages localized
- **Navigation Elements**: App bars, buttons, tooltips, and navigation components fully localized
- **Dialog Components**: Alert dialogs, confirmation dialogs, and snackbars with localized content

**✅ Localized Screens:**
- **Splash Screen**: App title, loading messages, error dialogs
- **Login Screen**: Form fields, validation messages, authentication errors (18+ keys)
- **Store Selection Screen**: Welcome messages, store selection UI, error handling
- **Dashboard Screen**: Role-based welcome messages, quick actions, tooltips, error states
- **Settings Screen**: All sections, buttons, dialogs, and preference screens
- **Error Screen**: Global error handling with parameterized error messages

**✅ Configuration Architecture:**
- **l10n.yaml**: Dedicated localization configuration with proper output directories
- **ARB Files**: Structured localization files with descriptive keys and proper naming conventions
- **Code Generation**: Automatic generation of AppLocalizations class with type safety
- **Flutter Integration**: Proper integration with Material Design localization delegates

### **Phase 4 Implementation Summary**

All Phase 4 requirements have been successfully implemented:

**✅ API Client Foundation**
- Complete Dio HTTP client with base configuration and interceptors
- Generic HTTP methods (GET, POST, PUT, DELETE) with type safety
- File upload and download capabilities with progress tracking
- Singleton pattern with secure configuration management

**✅ Security Interceptors**
- Certificate pinning configuration (disabled for development)
- API endpoint validation for trusted hosts only
- Bearer token injection with automatic refresh
- Security exception handling for certificate failures

**✅ Enhanced Error Handling Interceptors**
- Exponential backoff retry logic with jitter (1s, 2s, 4s, 8s...)
- Network connectivity monitoring with connectivity_plus
- Rate limiting support (429 status code handling)
- Comprehensive timeout handling (connection, send, receive)
- Performance monitoring with request duration tracking

**✅ Response Models with JSON Serialization**
- ApiResponse<T> for standard API responses
- PaginatedResponse<T> for paginated data
- ApiError for structured error information
- PaginationMeta for pagination metadata
- Complete JSON serialization with code generation

**✅ Data Models**
- User model with role-based permissions (OWNER/ADMIN/STAFF/CASHIER)
- Store model with address and operational details
- Product model with IMEI tracking support
- Category model for product organization
- Transaction model with items and photo proof
- All models include JSON serialization with build_runner

**✅ API Endpoints Integration**
- All 40+ backend endpoints mapped and typed
- Authentication endpoints (login, register, refresh, logout)
- CRUD operations for users, stores, categories, products, transactions
- Advanced filtering and pagination support
- IMEI management and product search capabilities

**✅ Comprehensive Error Handling System**
- Custom exception hierarchy (ApiException, NetworkException, etc.)
- Specific exceptions for auth, validation, security, server errors
- Detailed error codes and messages
- Error context preservation for debugging

### **Current Mobile Codebase Structure (Phase 7 Complete)**

```
mobile/
├── lib/
│   ├── core/                          # 41 Dart files - Core foundation
│   │   ├── api/
│   │   │   ├── api_client.dart         # Complete Dio API client
│   │   │   ├── api_endpoints.dart      # All 40+ endpoint definitions
│   │   │   ├── api_exceptions.dart     # Custom exception classes
│   │   │   └── api_interceptors.dart   # Auth, security, error interceptors
│   │   ├── auth/
│   │   │   ├── auth_provider.dart      # JWT authentication state management
│   │   │   ├── auth_service.dart       # Authentication service with getUserStores
│   │   │   └── secure_storage.dart     # Secure token storage
│   │   ├── constants/
│   │   │   ├── app_constants.dart      # App-wide constants
│   │   │   └── error_codes.dart        # Standardized error codes
│   │   ├── models/
│   │   │   ├── api_response.dart       # Base API response models
│   │   │   ├── user.dart              # User model with roles
│   │   │   ├── store.dart             # Store model with address helper
│   │   │   ├── store_context.dart     # Store context with persistence
│   │   │   ├── product.dart           # Product with IMEI support
│   │   │   ├── transaction.dart       # Transaction with items
│   │   │   └── category.dart          # Category model
│   │   ├── providers/
│   │   │   ├── app_provider.dart       # App settings (theme, locale)
│   │   │   └── store_context_provider.dart # Store selection with persistence
│   │   ├── routing/                    # Navigation System
│   │   │   ├── app_router.dart        # GoRouter with authentication guards
│   │   │   └── auth_guard.dart        # Route protection and access control
│   │   ├── theme/                      # Comprehensive Theme System
│   │   │   ├── app_theme.dart         # Main theme configuration
│   │   │   ├── theme_colors.dart      # WMS brand color palette
│   │   │   ├── typography.dart        # Text styles and font system
│   │   │   └── icons.dart             # Icon system and utilities
│   │   ├── widgets/                    # Core UI Components
│   │   │   ├── buttons.dart           # Custom button components
│   │   │   ├── loading.dart           # Loading indicators and skeletons
│   │   │   ├── cards.dart             # Card components for data display
│   │   │   ├── app_bars.dart          # Custom app bar variants
│   │   │   ├── form_components.dart   # Form fields and inputs
│   │   │   ├── layout.dart            # Layout utilities and responsive design
│   │   │   └── theme_switcher.dart    # Theme switching components
│   │   └── utils/
│   │       └── app_config.dart         # Environment configuration
│   ├── features/                       # Feature screens with i18n
│   │   ├── auth/
│   │   │   └── screens/
│   │   │       ├── splash_screen.dart      # ✅ i18n: App initialization screen
│   │   │       ├── login_screen.dart       # ✅ i18n: Professional login UI (18+ keys)
│   │   │       └── welcoming_choose_store_screen.dart # ✅ i18n: Store selection
│   │   ├── dashboard/
│   │   │   └── screens/
│   │   │       └── dashboard_screen.dart   # ✅ i18n: Role-based dashboard
│   │   └── settings/
│   │       └── screens/
│   │           └── settings_screen.dart    # ✅ i18n: Complete settings UI
│   ├── generated/                      # ✅ NEW: Generated localization files
│   │   └── app_localizations.dart      # ✅ Auto-generated AppLocalizations class
│   └── main.dart                       # ✅ i18n: App entry with localization support
├── l10n/                              # ✅ Enhanced: Internationalization system
│   ├── app_en.arb                     # ✅ 195+ English translation keys
│   ├── app_id.arb                     # Indonesian translations (ready for expansion)
│   └── l10n.yaml                      # ✅ Localization generation configuration
├── assets/
│   ├── fonts/                         # Poppins font files
│   ├── images/                        # App images
│   └── icons/                         # App icons
├── android/                           # Android configuration with permissions
├── ios/                              # iOS configuration with usage descriptions
├── test/
│   └── widget_test.dart              # Widget tests (passing)
└── pubspec.yaml                      # ✅ Dependencies with i18n support
```

### **Mobile Theme System Features**

**✅ Professional Design System**
- WMS brand colors with light/dark variants
- Material Design 3 components with custom styling
- Comprehensive typography hierarchy with Poppins font
- Role-based color coding (Owner: Purple, Admin: Blue, Staff: Green, Cashier: Orange)

**✅ Component Library**
- 7 button variants with loading states and icons
- 6 loading indicator types including skeleton loaders
- 5 card types for different data display needs
- 5 app bar variants for different contexts
- 8 form component types with validation
- Layout utilities for responsive design

**✅ Responsive Design**
- Breakpoint system (Mobile <600px, Tablet 600-900px, Desktop >900px)
- Adaptive layouts and spacing
- Safe area handling and keyboard behavior
- Grid systems for card display

### **Mobile Security Implementation**

**✅ Production-Ready Security System**
- Certificate pinning interceptor (disabled for development, production-ready)
- API endpoint validation preventing unauthorized hosts
- Secure token storage with FlutterSecureStorage encryption
- Automatic bearer token injection with refresh capability
- Environment-based security configurations
- Security exception handling with detailed error reporting
- Request timeout enforcement and connection monitoring

### **Mobile State Management Architecture**

**Provider Pattern Implementation:**
- `AppProvider`: Theme, locale, app settings management with persistence
- `AuthProvider`: JWT authentication, user state, permissions
- `StoreContextProvider`: Store selection for non-owner users

**Role-Based Access Control:**
- Owner: Full access, no store selection required
- Admin/Staff/Cashier: Must select store after login
- Permission helpers built into User model

### **Mobile User Flow Implementation**

**Authentication Flow:**
- Splash screen → Initialize providers → Check auth state
- If not authenticated → Login screen
- If authenticated but needs store selection → Store selection screen  
- If authenticated with store context → Dashboard

### Development Commands

Mobile commands (from `/mobile` directory):

```bash
# Development
flutter pub get          # Install dependencies
flutter run             # Start development on device/emulator
flutter build apk       # Build Android APK
flutter build ios       # Build iOS app

# Code Generation
flutter packages pub run build_runner build  # Generate JSON serialization
flutter gen-l10n        # Generate localization files

# Testing
flutter test            # Run unit and widget tests
flutter analyze         # Analyze code for issues
flutter test --coverage # Run tests with coverage

# Maintenance
flutter clean           # Clean build cache
flutter pub upgrade     # Upgrade dependencies
```

Backend commands (from `/backend` directory):

```bash
# Development
pnpm install
pnpm run dev          # Start development server with tsx watch
pnpm run build        # Build TypeScript to dist/
pnpm run start        # Start production server

# Testing
pnpm run test         # Run Vitest tests
pnpm run test:watch   # Run tests in watch mode
pnpm run test:coverage # Run tests with coverage
pnpm run test:ui      # Run tests with UI
pnpm run test:integration # Run integration tests

# Database
pnpm run db:generate  # Generate Drizzle client
pnpm run db:migrate   # Run database migrations
pnpm run db:seed      # Seed database with test data
pnpm run db:studio    # Open Drizzle Studio

# Code Quality
pnpm run lint         # Run ESLint
pnpm run lint:fix     # Fix ESLint issues
pnpm run typecheck    # Run TypeScript type checking

# Frontend setup (when implemented)
cd frontend
pnpm install
pnpm run dev          # Start frontend dev server
pnpm run build        # Build for production
pnpm run preview      # Preview production build
pnpm run test         # Run frontend tests
```

## 🎯 **CURRENT PROJECT STATUS SUMMARY - UPDATED JANUARY 2025**

**🚀 BACKEND: PRODUCTION READY (51 TypeScript files)**
- ✅ **40+ API endpoints** fully implemented and tested
- ✅ **Complete authentication system** with JWT and refresh tokens  
- ✅ **Full RBAC implementation** with owner-scoped data access
- ✅ **All CRUD operations** for users, stores, categories, products, transactions
- ✅ **Advanced features**: IMEI tracking, barcode generation, photo proof
- ✅ **Production infrastructure**: validation, error handling, pagination, filtering
- ✅ **Comprehensive testing** with integration test coverage
- ✅ **Latest dependencies**: Hono 4.5.0, Drizzle ORM 0.44.3, Zod 3.23.8

**📱 MOBILE: PHASE 7 COMPLETE - INTERNATIONALIZATION & LOCALIZATION (55+ Dart files)**
- ✅ **Phase 1**: Project Foundation & Setup completed
- ✅ **Phase 2**: UI Foundation & Theme System completed  
- ✅ **Phase 3**: API Client & Network Layer completed
- ✅ **Phase 4**: Core Authentication System completed
- ✅ **Phase 5**: Login & Store Selection Flow completed
- ✅ **Phase 6**: Navigation System & Store Context completed
- ✅ **Phase 7**: Internationalization & Localization completed
- ✅ **Professional Design System** with Material Design 3
- ✅ **Complete Authentication Flow** with role-based navigation
- ✅ **GoRouter Navigation System** with authentication guards and route protection
- ✅ **Enhanced Store Context Management** with data persistence and validation
- ✅ **Role-Based Dashboard System** with permission-aware UI components
- ✅ **Complete i18n Implementation** with 195+ localization keys across all screens
- ✅ **5 Fully Localized Screens**: Splash, Login, Store Selection, Dashboard, Settings, Error screens
- ✅ **Form Validation & Error Handling** with professional UI/UX and full localization
- ✅ **Multi-language Support**: English and Indonesian with parameterized messages
- ✅ **Updated Dependencies**: Latest thermal printing libs, Android NDK 27.0.12077973

**🎯 MOBILE DEVELOPMENT STATUS: Phase 7 Complete (35%)**
- 🚀 **Current Phase**: Ready for Phase 8 - Product Management & Search
- 📱 **Development Plan**: 13 remaining phases over 4-5 weeks
- 🏗️ **Architecture**: Clean Architecture with robust API foundation
- 📋 **API Integration**: Complete HTTP client with security and error handling
- 🔐 **Authentication System**: JWT token management and refresh mechanisms
- 🛡️ **Security**: Production-ready interceptors and validation
- 🔄 **Error Handling**: Comprehensive retry logic and network monitoring
- 📊 **Data Models**: All business entities with JSON serialization
- 🌐 **Internationalization**: Complete i18n system with type-safe localization
- 🖨️ **Business Workflows**: API client ready for UI implementation
- 📷 **Scanning**: Dependencies configured, ready for implementation
- 🔗 **Thermal Printing**: Dependencies configured, ready for implementation

**📊 NEXT STEPS:**
1. **Mobile Development Phase 8**: Product Management & Scanning (4-5 days)
2. **Mobile Development Phase 9**: Transaction Management & Sales (4-5 days)  
3. **Mobile Development Phase 10**: Settings & User Profile (2-3 days)
4. **Web Frontend Development**: Build UI using the API contract (optional)
5. **Testing**: Mobile app integration testing with backend API
6. **Deployment**: Backend is ready for production deployment

### Project Structure

When implementing, follow this structure:

```
/
├── backend/                 # ✅ Hono.js API server (FULLY IMPLEMENTED)
│   ├── src/
│   │   ├── models/          # ✅ Drizzle schema definitions
│   │   ├── middleware/      # ✅ Auth, validation, error handling
│   │   ├── routes/          # ✅ API route definitions and handlers
│   │   ├── services/        # ✅ Business logic services
│   │   ├── schemas/         # ✅ Zod validation schemas
│   │   ├── utils/           # ✅ Shared utilities
│   │   └── config/          # ✅ Configuration files
│   ├── tests/               # ✅ Backend test files
│   └── package.json
├── frontend/                # 📋 React frontend (READY TO IMPLEMENT)
│   ├── src/
│   │   ├── components/      # React components
│   │   ├── pages/           # Page components
│   │   ├── hooks/           # Custom React hooks
│   │   ├── services/        # API service layer
│   │   ├── stores/          # State management
│   │   └── utils/           # Frontend utilities
│   └── package.json
├── mobile/                  # ✅ Flutter mobile app (PHASE 7 COMPLETE)
│   ├── lib/
│   │   ├── core/            # ✅ API, auth, models, providers, theme, widgets, utils
│   │   ├── features/        # ✅ Feature-based architecture with full i18n
│   │   ├── generated/       # ✅ Auto-generated localization classes
│   │   └── main.dart        # ✅ App entry point with i18n support
│   ├── l10n/               # ✅ Internationalization with 195+ keys
│   ├── assets/             # ✅ Fonts, images, icons
│   ├── android/            # ✅ Platform configuration
│   ├── ios/                # ✅ Platform configuration
│   ├── test/               # ✅ Testing infrastructure
│   └── pubspec.yaml        # ✅ Dependencies with i18n configuration
├── docs/                    # ✅ Project documentation
│   ├── frontend-api-contract.md  # ✅ Complete API documentation
│   ├── backlogs/mobile/     # ✅ Mobile development backlog
│   └── erd.md               # Database schema documentation
├── postman/                 # ✅ API testing collections
│   ├── WMS-API.postman_collection.json
│   ├── IMEI_Product_Search.postman_collection.json
│   └── WMS-Local.postman_environment.json
└── CLAUDE.md               # ✅ This file
```

### Database Schema

Key entities defined in `docs/erd.md`:

- **users**: Role-based user management with owner hierarchy
- **stores**: Multi-store support per owner
- **products**: Inventory items with barcode tracking
- **transactions**: SALE and TRANSFER operations with photo proof
- **product_checks**: Regular inventory verification system

## 🚫 **CRITICAL DATABASE MODEL PROTECTION RULE** 🚫

**NEVER MODIFY ANY MODEL FILES WITHOUT EXPLICIT USER REQUEST**

The following model files are now **FROZEN** and cannot be changed without explicit user permission:

- `src/models/users.ts` - ✅ ERD Compliant
- `src/models/stores.ts` - ✅ ERD Compliant
- `src/models/categories.ts` - ✅ ERD Compliant
- `src/models/products.ts` - ✅ ERD Compliant
- `src/models/transactions.ts` - ✅ ERD Compliant
- `src/models/product_checks.ts` - ✅ ERD Compliant
- `src/models/product_imeis.ts` - ✅ ERD Compliant

**Protection Rules:**

- ❌ **NO schema changes** without clear user request
- ❌ **NO field additions/removals** without clear user request
- ❌ **NO type changes** without clear user request
- ❌ **NO relation modifications** without clear user request
- ✅ **ONLY bug fixes** in business logic are allowed
- ✅ **ONLY new files** can be created (controllers, services, tests)

### Business Rules to Enforce

- **Barcode uniqueness**: System-wide for OWNER, store-scoped for ADMIN
- **Photo proof**: Required for all SALE transactions
- **Soft delete**: All entities use soft delete for audit trail
- **Role restrictions**: Strict RBAC enforcement per user stories
- **Owner scoping**: Non-OWNER roles access all stores under same owner
- **Transaction types**: CASHIER restricted to SALE only
- **Delete permissions**: ADMIN cannot delete users, categories, products, transactions

### Testing Strategy

Based on `docs/features/backend_ut_checklist.md`:

- **Unit tests**: All service methods and business logic
- **Integration tests**: API endpoints and database operations
- **Role-based tests**: Comprehensive RBAC testing per user role
- **Validation tests**: Input validation and error handling
- **Security tests**: SQL injection, XSS prevention, authentication

### Coding Standards

- **DRY (Don't Repeat Yourself)**: Avoid code duplication, extract reusable functions
- **KISS (Keep It Simple, Stupid)**: Favor simple, straightforward solutions over complex ones
- **Modular**: Keep code organized in logical modules/files, even without strict Clean Architecture
- **Consistent naming**: Use clear, descriptive variable and function names
- **Zod imports**: Always use `z` from `Zod` instead of directly importing from `zod` package for OpenAPI compatibility
- **Testing scope**: Test services only at the controller layer - no separate service layer unit tests, focus on integration testing through HTTP endpoints
- **Drizzle ORM select statements**: Always use `.select()` without arguments to avoid TypeScript strict mode issues. Use `.select({ field: table.field })` pattern only when absolutely necessary for specific field selection, but prefer full record selection with `.select()` for consistency
- **🌐 MANDATORY INTERNATIONALIZATION RULE** 🌐:
  - **✅ ALWAYS use AppLocalizations.of(context)!** for ALL user-facing text in Flutter mobile app
  - **✅ NEVER use hardcoded strings** in UI components, screens, dialogs, or error messages
  - **✅ ALWAYS add new keys to app_en.arb** when creating new UI text
  - **✅ ALWAYS use parameterized messages** for dynamic content (e.g., `welcomeUser(name)`)
  - **❌ NEVER commit UI code with hardcoded English text** - all text MUST be localized
  - **✅ ALWAYS follow naming convention**: camelCase for ARB keys (e.g., `loginButton`, `welcomeMessage`)
- **🔑 ID Generation Rules**: 
  - **✅ ALWAYS use `randomUUID()` from `crypto` module** for all database table primary keys (id fields)
  - **✅ ALWAYS use `nanoid({ alphabet: '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ' })` for barcode generation** - numeric-alphabetical only
  - **❌ NEVER use `nanoid()` for database primary keys** - reserved for barcodes only
  - **❌ NEVER use sequential numbers or predictable IDs** for security reasons

### 🔧 **MANDATORY API RESPONSE STANDARDS** 🔧

**ALL API endpoints MUST follow these standardized response patterns:**

#### **Response Format Requirements:**

- **✅ ALWAYS use `ResponseUtils`** from `src/utils/responses.ts` for ALL API responses
- **✅ ALWAYS use Zod schemas** from `Zod` for request/response validation
- **✅ ALWAYS handle errors** through `ResponseUtils.sendError()` for consistent error formatting
- **✅ NEVER return raw data** - all responses must use `BaseResponse<T>` or `PaginatedResponse<T>` format

#### **Required Response Methods:**

```typescript
// ✅ SUCCESS responses
ResponseUtils.sendSuccess(c, data, 200); // Standard success
ResponseUtils.sendCreated(c, data); // 201 Created
ResponseUtils.sendSuccessNoData(c, 204); // 204 No Content
ResponseUtils.sendPaginated(c, data, pagination); // Paginated lists

// ✅ ERROR responses
ResponseUtils.sendError(c, error); // All errors
```

### ⚠️ CRITICAL TESTING RULE ⚠️

**NEVER IGNORE OR UNDERESTIMATE TESTS - NO MATTER WHAT**

- **Tests are MANDATORY**: Every feature implementation MUST include comprehensive tests in application layer in index.ts

**Critical Testing Requirements:**

- **Use proper test utilities**: Always import from `../utils` and use `createTestApp`, `createUserHierarchy`, etc.
- **Test all user roles**: OWNER, ADMIN, STAFF, CASHIER with appropriate permissions
- **Test cross-owner access**: Ensure users cannot access data from different owners
- **Test authentication**: Verify 401 responses for unauthenticated requests
- **Test validation**: Check 400 responses for invalid input data
- **Test error scenarios**: Cover all business rule violations and edge cases
- **Follow established patterns**: Copy patterns from working tests like `user.routes.test.ts` and `store.routes.test.ts`

## Next Implementation Steps

When implementing new modules (stores, products, transactions, etc.), follow these established patterns:

1. **Create Zod schemas** in `src/schemas/[entity].schemas.ts`
2. **Define routes** with OpenAPI documentation in `src/routes/[entity].routes.ts`
3. **Create service** with business logic and custom errors in `src/services/[entity].service.ts`
4. **Add integration tests** covering all roles and scenarios in `tests/routes/[entity].routes.test.ts`

# important-instruction-reminders
Do what has been asked; nothing more, nothing less.
NEVER create files unless they're absolutely necessary for achieving your goal.
ALWAYS prefer editing an existing file to creating a new one.
NEVER proactively create documentation files (*.md) or README files. Only create documentation files if explicitly requested by the User.
# important-instruction-reminders
Do what has been asked; nothing more, nothing less.
NEVER create files unless they're absolutely necessary for achieving your goal.
ALWAYS prefer editing an existing file to creating a new one.
NEVER proactively create documentation files (*.md) or README files. Only create documentation files if explicitly requested by the User.

      
      IMPORTANT: this context may or may not be relevant to your tasks. You should not respond to this context or otherwise consider it in your response unless it is highly relevant to your task. Most of the time, it is not relevant.