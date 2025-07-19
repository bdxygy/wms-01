# Mobile Development Backlog - 20 Phases

Complete Flutter mobile application development from zero with focus on business workflows, thermal printing, and barcode/IMEI scanning integration.

---

## 📋 **Project Overview**

**Status**: Starting from scratch (mobile project deleted)  
**Target**: Complete WMS Flutter mobile application  
**Platform**: Flutter (iOS & Android)  
**Backend Integration**: 40+ production-ready API endpoints  
**Timeline**: 20 phases over 8-10 weeks  
**Architecture**: Clean Architecture with feature-based structure

---

## 🎯 **User Flow Requirements**

### **Authentication Flow Based on Role**
- **NON-OWNER Users**: Login → "Welcoming Choose Store" screen → Select store → Role-based dashboard (no store panel)
- **OWNER Users**: Login → Full dashboard with store management capabilities

### **Key Business Workflows**
1. **Product Creation** → Auto-navigate to detail → Print barcode
2. **Transaction Creation** → Auto-print receipt → Transaction detail with "Print Payment Note"
3. **Barcode Scanning** → Add items to transactions OR find products
4. **IMEI Scanning** → Find products by IMEI number

---

## 🏗️ **Phase 1: Project Foundation & Setup**
*Duration: 2-3 days | Priority: CRITICAL*

### **Objective**
Set up Flutter project from scratch with complete architecture, dependencies, and development environment using the comprehensive Flutter API contract.

### **API Contract Reference**
**📋 Use the Flutter API Contract**: [docs/flutter-api-contract.md](flutter-api-contract.md) - This provides complete integration guide for all 40+ backend endpoints.

### **Features to Implement**
- [ ] **Flutter Project Setup**
  - [ ] Create new Flutter project with proper package name
  - [ ] Configure clean architecture folder structure (`core/`, `features/`, `ui/`)
  - [ ] Set up environment configuration (dev, staging, prod)
  - [ ] Configure Android and iOS project settings

- [ ] **Dependencies Configuration**
  - [ ] HTTP client: `dio: ^5.3.2` with interceptors
  - [ ] State management: `provider: ^6.0.5`
  - [ ] Navigation: `go_router: ^12.1.1`
  - [ ] Forms: `flutter_form_builder: ^9.1.1`, `form_builder_validators: ^9.1.0`
  - [ ] Storage: `flutter_secure_storage: ^9.0.0`, `shared_preferences: ^2.2.2`
  - [ ] Scanning: `mobile_scanner: ^3.5.2` (barcode/QR)
  - [ ] Camera: `camera: ^0.10.5`, `image_picker: ^1.0.4`
  - [ ] Thermal printing: `blue_thermal_printer: ^2.1.1`, `esc_pos_bluetooth: ^0.4.1`
  - [ ] Serialization: `json_annotation: ^4.8.1`, `json_serializable: ^6.7.1`
  - [ ] UI: `flex_color_scheme: ^7.3.1` (Material Design 3)

- [ ] **Development Tools**
  - [ ] Code generation: `build_runner: ^2.4.6`
  - [ ] Linting: `flutter_lints: ^3.0.1`
  - [ ] Testing: `flutter_test`, `integration_test`

- [ ] **API Integration Setup**
  - [ ] Set up API client with Dio configuration
  - [ ] Configure authentication interceptors
  - [ ] Create base response models (ApiResponse, PaginatedResponse)
  - [ ] Set up JSON serialization with json_serializable
  - [ ] Create core models (User, Product, Transaction, Store)

- [ ] **Basic App Structure**
  - [ ] Main app entry point with environment configuration
  - [ ] Basic MaterialApp with theme setup
  - [ ] Initial route configuration
  - [ ] Provider setup for state management
  - [ ] Authentication provider initialization

### **Technical Implementation**
```dart
// Project structure (aligned with Flutter API Contract):
lib/
├── core/
│   ├── api/
│   │   ├── api_client.dart      // Complete API client from contract
│   │   ├── api_endpoints.dart   // All 40+ endpoint definitions
│   │   └── api_response.dart    // Base response models
│   ├── auth/
│   │   ├── auth_service.dart    // JWT authentication service
│   │   └── auth_provider.dart   // State management
│   ├── models/
│   │   ├── user.dart           // User model with roles
│   │   ├── product.dart        // Product with IMEI support
│   │   ├── transaction.dart    // Transaction with items
│   │   └── store.dart          // Store model
│   ├── services/
│   │   ├── camera_service.dart    // Photo capture
│   │   ├── scanner_service.dart   // Barcode/IMEI scanning
│   │   └── printer_service.dart   // Thermal printing
│   └── utils/
│       └── image_utils.dart
├── features/
│   ├── auth/
│   │   ├── screens/
│   │   └── widgets/
│   ├── dashboard/
│   ├── products/
│   ├── transactions/
│   ├── scanner/
│   └── settings/
└── main.dart
```

### **API Contract Integration**
- **Complete Flutter API Contract**: Refer to `docs/flutter-api-contract.md`
- **40+ endpoints**: All backend endpoints mapped to Flutter services
- **Authentication**: JWT with refresh tokens and secure storage
- **Error handling**: Comprehensive error handling with user-friendly messages
- **Mobile features**: Barcode scanning, camera integration, thermal printing

### **Success Criteria**
- ✅ Flutter project builds and runs on both iOS and Android
- ✅ All dependencies configured and working
- ✅ Clean architecture structure established
- ✅ Development environment ready for feature development

---

## 🎨 **Phase 2: UI Foundation & Theme System**
*Duration: 2-3 days | Priority: CRITICAL*

### **Objective**
Create comprehensive design system with Material Design 3, dark/light themes, and reusable UI components.

### **Features to Implement**
- [ ] **Theme System**
  - [ ] Material Design 3 with `flex_color_scheme`
  - [ ] Light and dark theme configurations
  - [ ] WMS brand colors and custom color scheme
  - [ ] Typography system with proper text styles
  - [ ] System theme detection and manual toggle

- [ ] **Core UI Components**
  - [ ] Custom app bars with role-based actions
  - [ ] Loading indicators and skeleton screens
  - [ ] Error states and empty state widgets
  - [ ] Custom buttons (primary, secondary, icon)
  - [ ] Form field components and validation displays
  - [ ] Cards and list item templates

- [ ] **Layout Foundation**
  - [ ] Responsive breakpoint system
  - [ ] Safe area handling utilities
  - [ ] Keyboard behavior management
  - [ ] Bottom sheet and dialog templates
  - [ ] Scaffold templates for different screen types

- [ ] **Icon System**
  - [ ] Material Design icons
  - [ ] Custom WMS-specific icons
  - [ ] Status indicators and badges
  - [ ] Role-based icon variations

### **Success Criteria**
- ✅ Complete theme system with light/dark modes
- ✅ Reusable component library established
- ✅ Responsive design foundation ready
- ✅ Consistent visual language across app

---

## 🔐 **Phase 3: Core Authentication System**
*Duration: 3-4 days | Priority: CRITICAL*

### **Objective**
Implement JWT-based authentication with secure storage and role-based access control foundation.

### **Features to Implement**
- [ ] **Authentication Models**
  - [ ] User model with role enumeration (OWNER, ADMIN, STAFF, CASHIER)
  - [ ] Auth response models (login, refresh, register)
  - [ ] JWT token models with expiry handling
  - [ ] Permission model for RBAC

- [ ] **Secure Storage Service**
  - [ ] Token storage with `flutter_secure_storage`
  - [ ] Encrypted token management
  - [ ] Biometric authentication preparation
  - [ ] Secure logout with complete token cleanup

- [ ] **Authentication Service**
  - [ ] Login with username/password
  - [ ] JWT token refresh mechanism
  - [ ] Logout with backend token invalidation
  - [ ] Token expiry detection and auto-refresh
  - [ ] Error handling for auth failures

- [ ] **Authentication State Management**
  - [ ] AuthProvider with Provider pattern
  - [ ] Authentication state persistence
  - [ ] Role-based permission checking
  - [ ] Auto-login on app startup

### **Technical Implementation**
```dart
// Key files:
- lib/core/auth/auth_service.dart
- lib/core/auth/auth_provider.dart
- lib/core/auth/secure_storage.dart
- lib/core/models/user.dart
- lib/core/models/auth_response.dart
```

### **Success Criteria**
- ✅ Secure JWT authentication working
- ✅ Token management with auto-refresh
- ✅ Role-based permission system ready
- ✅ Authentication state properly managed

---

## 🌐 **Phase 4: API Client & Network Layer**
*Duration: 3-4 days | Priority: CRITICAL*

### **Objective**
Create comprehensive API client with proper error handling, response wrappers, and integration with all 40+ backend endpoints.

### **Features to Implement**
- [ ] **API Client Foundation**
  - [ ] Dio HTTP client with base configuration
  - [ ] Authentication interceptor (Bearer token injection)
  - [ ] Error handling interceptor with custom exceptions
  - [ ] Request/response logging interceptor
  - [ ] Retry logic and timeout configuration

- [ ] **Response Models**
  - [ ] BaseResponse<T> wrapper for single items
  - [ ] PaginatedResponse<T> for list endpoints
  - [ ] ErrorResponse for API error handling
  - [ ] Generic response handling utilities

- [ ] **Data Models with JSON Serialization**
  - [ ] User model with role-based properties
  - [ ] Store model with complete address structure
  - [ ] Product model with IMEI support
  - [ ] Category model
  - [ ] Transaction model with items
  - [ ] ProductImei model
  - [ ] Pagination model

- [ ] **API Endpoints Integration**
  - [ ] Authentication endpoints (login, refresh, logout, register)
  - [ ] User management (CRUD with role restrictions)
  - [ ] Store management (OWNER operations)
  - [ ] Product management (full CRUD + barcode/IMEI search)
  - [ ] Category management
  - [ ] Transaction management (SALE/TRANSFER)
  - [ ] IMEI management (add, remove, search)

- [ ] **Error Handling System**
  - [ ] ApiException class with error codes
  - [ ] Network error detection
  - [ ] API error response parsing
  - [ ] User-friendly error messages

### **Success Criteria**
- ✅ Complete API client covering all backend endpoints
- ✅ Proper error handling and user feedback
- ✅ Type-safe models with JSON serialization
- ✅ Bearer token authentication working

---

## 🔑 **Phase 5: Login & Store Selection Flow**
*Duration: 3-4 days | Priority: CRITICAL*

### **Objective**
Create complete authentication flow including login screen and store selection for non-owner users.

### **Features to Implement**
- [ ] **Login Screen**
  - [ ] Username/password form with validation
  - [ ] Show/hide password functionality
  - [ ] Loading states during authentication
  - [ ] Error display with proper messaging
  - [ ] Remember login option preparation

- [ ] **Welcoming Choose Store Screen** (`WelcomingChooseStoreScreen`)
  - [ ] Display available stores for non-owner users
  - [ ] Store list with name, address, and status
  - [ ] Store selection with confirmation
  - [ ] Error handling for users with no stores
  - [ ] Loading states while fetching stores

- [ ] **Authentication Flow**
  - [ ] Splash screen with auth state checking
  - [ ] Auto-login with stored tokens
  - [ ] Role-based navigation:
    - [ ] NON-OWNER: Login → Store Selection → Dashboard
    - [ ] OWNER: Login → Full Dashboard (bypass store selection)
  - [ ] Token refresh on app resume
  - [ ] Session timeout handling

- [ ] **Form Validation**
  - [ ] Real-time field validation
  - [ ] Username format validation
  - [ ] Password requirements checking
  - [ ] Network error handling
  - [ ] API error display

- [ ] **UI/UX Polish**
  - [ ] Professional login screen design
  - [ ] Proper keyboard handling
  - [ ] Loading animations
  - [ ] Error state animations
  - [ ] Accessibility support

### **Success Criteria**
- ✅ Functional login screen with validation
- ✅ Store selection screen for non-owner users
- ✅ Role-based navigation flow working
- ✅ Proper error handling and user feedback
- ✅ Professional UI/UX design

---

## 🌐 **Phase 6: Navigation System & Store Context**
*Duration: 2-3 days | Priority: CRITICAL*

### **Objective**
Set up comprehensive navigation system and store context management after authentication.

- [ ] **Store Context Management**
  - [ ] StoreContextProvider for selected store
  - [ ] Store context persistence across app sessions
  - [ ] Store switching logic for OWNER users
  - [ ] Store-scoped data filtering

- [ ] **Navigation System with GoRouter**
  - [ ] Declarative route configuration
  - [ ] Authentication route guards
  - [ ] Store selection requirement guards
  - [ ] Role-based route access control
  - [ ] Deep linking preparation

- [ ] **User Flow Implementation**
  - [ ] NON-OWNER: Login → Store Selection → Dashboard
  - [ ] OWNER: Login → Full Dashboard (skip store selection)
  - [ ] Proper navigation state management
  - [ ] Back button handling

### **Technical Implementation**
```dart
// Key files:
- lib/features/auth/screens/welcoming_choose_store_screen.dart
- lib/core/providers/store_context_provider.dart
- lib/core/models/store_context.dart
- lib/core/routing/app_router.dart
- lib/core/routing/auth_guard.dart
```

### **Success Criteria**
- ✅ Non-owner users guided through store selection
- ✅ OWNER users bypass store selection
- ✅ Store context maintained throughout app
- ✅ Navigation system with proper guards

---

## 📊 **Phase 7: Role-Based Dashboard Screens**
*Duration: 3-4 days | Priority: HIGH*

### **Objective**
Create role-specific dashboard screens with relevant widgets, quick actions, and navigation.

### **Features to Implement**
- [ ] **OWNER Dashboard**
  - [ ] Multi-store overview with store switcher panel
  - [ ] Store performance metrics
  - [ ] Quick actions (Add Store, Manage Users, View Reports)
  - [ ] Recent activity across all stores
  - [ ] Store management shortcuts

- [ ] **ADMIN Dashboard**
  - [ ] Single-store view (based on selected store)
  - [ ] Store-specific metrics and overview
  - [ ] Quick actions (Add Product, Create Transaction, Manage Staff)
  - [ ] Store inventory overview
  - [ ] Recent transactions

- [ ] **STAFF Dashboard**
  - [ ] Read-only store overview
  - [ ] Product search and viewing
  - [ ] Product checking interface preparation
  - [ ] Limited quick actions
  - [ ] Recent product checks

- [ ] **CASHIER Dashboard**
  - [ ] Transaction-focused interface
  - [ ] Quick Sale creation
  - [ ] Recent transactions view
  - [ ] Simple product search
  - [ ] Daily sales summary

- [ ] **Dashboard Components**
  - [ ] Metric cards with data visualization
  - [ ] Quick action buttons with role-based filtering
  - [ ] Recent activity lists
  - [ ] Navigation shortcuts
  - [ ] Refresh functionality

### **Success Criteria**
- ✅ Role-specific dashboards working correctly
- ✅ Proper data display based on permissions
- ✅ Quick actions navigate to relevant screens
- ✅ Professional dashboard UI/UX

---

## 📱 **Phase 8: Bottom Navigation & Screen Structure**
*Duration: 2-3 days | Priority: HIGH*

### **Objective**
Implement bottom navigation with role-based tabs and screen structure foundation.

### **Features to Implement**
- [ ] **Bottom Navigation System**
  - [ ] Dynamic tabs based on user role
  - [ ] Role-specific navigation items
  - [ ] Badge notifications for tabs
  - [ ] Persistent navigation shell

- [ ] **Navigation Tabs by Role**
  - [ ] OWNER: Dashboard, Stores, Users, Products, Transactions, Settings
  - [ ] ADMIN: Dashboard, Products, Transactions, Users, Settings
  - [ ] STAFF: Dashboard, Products, Checks, Settings
  - [ ] CASHIER: Dashboard, Transactions, Products, Settings

- [ ] **Screen Scaffolding**
  - [ ] Base screen templates for each feature
  - [ ] Consistent app bar structure
  - [ ] Floating action buttons (context-aware)
  - [ ] Search functionality integration
  - [ ] Pull-to-refresh setup

- [ ] **Navigation State Management**
  - [ ] Tab state persistence
  - [ ] Deep linking support
  - [ ] Back button handling
  - [ ] Tab switching animations

### **Success Criteria**
- ✅ Role-based bottom navigation working
- ✅ Proper tab filtering based on permissions
- ✅ Consistent screen structure across app
- ✅ Smooth navigation experience

---

## 📦 **Phase 9: Product List & Basic Search**
*Duration: 3-4 days | Priority: HIGH*

### **Objective**
Implement product listing with pagination, search, and role-based actions.

### **Features to Implement**
- [ ] **Product List Screen**
  - [ ] Paginated product listing with infinite scroll
  - [ ] Pull-to-refresh functionality
  - [ ] Loading states and error handling
  - [ ] Empty state for no products

- [ ] **Search & Filtering**
  - [ ] Real-time search by product name
  - [ ] Search by SKU and barcode
  - [ ] Category-based filtering
  - [ ] Store-based filtering (for OWNER)
  - [ ] Price range filtering

- [ ] **Product List Items**
  - [ ] Product cards with image placeholder
  - [ ] Product name, SKU, and barcode display
  - [ ] Price information (purchase/sale)
  - [ ] Stock level indicators
  - [ ] IMEI product badges

- [ ] **Role-Based Actions**
  - [ ] Add Product FAB (OWNER/ADMIN only)
  - [ ] Edit Product access (OWNER/ADMIN only)
  - [ ] View-only mode for STAFF/CASHIER
  - [ ] Quick actions menu

- [ ] **Navigation Integration**
  - [ ] Tap to view product details
  - [ ] Context menu for quick actions
  - [ ] Search results navigation
  - [ ] Filter state management

### **Success Criteria**
- ✅ Product listing with pagination working
- ✅ Search and filtering functional
- ✅ Role-based access control enforced
- ✅ Professional list UI with proper performance

---

## 📷 **Phase 10: Camera Service & Photo Capture**
*Duration: 2-3 days | Priority: HIGH*

### **Objective**
Implement camera functionality for product photos and transaction proof capture.

### **Features to Implement**
- [ ] **Camera Service**
  - [ ] Camera initialization and configuration
  - [ ] Photo capture with quality settings
  - [ ] Front/back camera switching
  - [ ] Flash control and settings
  - [ ] Camera permissions handling

- [ ] **Photo Capture Screen**
  - [ ] Custom camera UI with controls
  - [ ] Photo preview and confirmation
  - [ ] Retake photo functionality
  - [ ] Multiple photo capture mode
  - [ ] Photo gallery preview

- [ ] **Image Management**
  - [ ] Image compression and optimization
  - [ ] Local image storage in app directory
  - [ ] Image upload preparation (for API)
  - [ ] Image cache management
  - [ ] Image deletion and cleanup

- [ ] **Integration Preparation**
  - [ ] Product photo capture workflow
  - [ ] Transaction proof photo workflow
  - [ ] Photo picker from gallery option
  - [ ] Photo viewing and zoom functionality

### **Technical Implementation**
```dart
// Key files:
- lib/core/services/camera_service.dart
- lib/features/camera/screens/camera_screen.dart
- lib/core/utils/image_utils.dart
- lib/core/widgets/photo_viewer.dart
```

### **Success Criteria**
- ✅ Camera functionality working on both platforms
- ✅ Photo capture and preview working
- ✅ Image optimization and storage working
- ✅ Professional camera UI/UX

---

## 🔍 **Phase 11: Barcode Scanner Integration**
*Duration: 3-4 days | Priority: HIGH*

### **Objective**
Implement comprehensive barcode scanning for product search and transaction item addition.

### **Features to Implement**
- [ ] **Barcode Scanner Service**
  - [ ] Multiple format support (EAN, UPC, Code128, QR)
  - [ ] Real-time barcode detection
  - [ ] Camera controls (torch, zoom, focus)
  - [ ] Scanner performance optimization

- [ ] **Barcode Scanner Screen**
  - [ ] Custom scanner UI with overlay
  - [ ] Scan result display and confirmation
  - [ ] Manual barcode entry fallback
  - [ ] Scan history tracking
  - [ ] Scanner settings

- [ ] **Scanner Integration Points**
  - [ ] Product search by barcode
  - [ ] Add products to transactions via scan
  - [ ] Quick product lookup from any screen
  - [ ] Inventory checking via scan

- [ ] **Scanner Utilities**
  - [ ] Barcode validation and formatting
  - [ ] QR code generation for sharing
  - [ ] Deep link handling from QR codes
  - [ ] Scanner result processing

### **Technical Implementation**
```dart
// Key files:
- lib/core/services/scanner_service.dart
- lib/features/scanner/screens/barcode_scanner_screen.dart
- lib/core/utils/barcode_utils.dart
- lib/core/widgets/scanner_overlay.dart
```

### **Success Criteria**
- ✅ Barcode scanning working reliably
- ✅ Multiple format support functional
- ✅ Integration with product search working
- ✅ Professional scanner UI with good UX

---

## 🔢 **Phase 12: IMEI Scanner & Product Search**
*Duration: 2-3 days | Priority: HIGH*

### **Objective**
Implement IMEI-specific scanning and product search functionality.

### **Features to Implement**
- [ ] **IMEI Scanner**
  - [ ] IMEI barcode detection (specific formats)
  - [ ] IMEI validation with Luhn algorithm
  - [ ] Manual IMEI entry with validation
  - [ ] IMEI formatting and display

- [ ] **IMEI Product Search**
  - [ ] Search products by IMEI number
  - [ ] Display product associated with IMEI
  - [ ] Navigate to product detail from IMEI
  - [ ] IMEI search history

- [ ] **IMEI Integration**
  - [ ] IMEI scanning in transaction workflows
  - [ ] IMEI-based inventory checking
  - [ ] IMEI product verification
  - [ ] Duplicate IMEI detection

- [ ] **IMEI Management Preparation**
  - [ ] Add IMEI to products workflow
  - [ ] IMEI list display
  - [ ] IMEI removal functionality
  - [ ] IMEI validation rules

### **Success Criteria**
- ✅ IMEI scanning and validation working
- ✅ Product search by IMEI functional
- ✅ IMEI integration with product workflows
- ✅ Proper IMEI validation and formatting

---

## 📝 **Phase 13: Product CRUD Forms**
*Duration: 4-5 days | Priority: CRITICAL*

### **Objective**
Implement complete product creation and editing forms with validation and business rules.

### **Features to Implement**
- [ ] **Create Product Form**
  - [ ] Multi-step form with `flutter_form_builder`
  - [ ] Product details (name, SKU, prices, quantity)
  - [ ] Store and category selection dropdowns
  - [ ] IMEI checkbox for electronic products
  - [ ] Photo upload integration
  - [ ] Form validation with business rules

- [ ] **Edit Product Form**
  - [ ] Pre-populated form with existing data
  - [ ] Partial update capability
  - [ ] Photo replacement functionality
  - [ ] Change tracking and confirmation
  - [ ] Optimistic UI updates

- [ ] **Form Components**
  - [ ] Reusable form field widgets
  - [ ] Custom validators for products
  - [ ] Dropdown selectors with data loading
  - [ ] Photo picker integration
  - [ ] Price input with currency formatting

- [ ] **Form Validation**
  - [ ] Real-time field validation
  - [ ] Cross-field validation (sale vs purchase price)
  - [ ] Server-side validation integration
  - [ ] Business rule enforcement
  - [ ] Error display and user guidance

- [ ] **Product Creation Workflow**
  - [ ] Auto-navigation to ProductDetailScreen after creation
  - [ ] Success feedback with product information
  - [ ] Print Barcode button preparation
  - [ ] Form state management

### **Technical Implementation**
```dart
// Key files:
- lib/features/products/screens/create_product_screen.dart
- lib/features/products/screens/edit_product_screen.dart
- lib/features/products/widgets/product_form.dart
- lib/core/validators/product_validators.dart
- lib/core/widgets/form_components.dart
```

### **Success Criteria**
- ✅ Product creation form working with validation
- ✅ Product editing with proper data loading
- ✅ Auto-navigation after creation working
- ✅ Form validation and error handling complete

---

## 📋 **Phase 14: Product Detail & IMEI Management**
*Duration: 3-4 days | Priority: HIGH*

### **Objective**
Create comprehensive product detail screen with IMEI management and print preparation.

### **Features to Implement**
- [ ] **Product Detail Screen**
  - [ ] Complete product information display
  - [ ] Product photo gallery with zoom
  - [ ] Stock level and pricing information
  - [ ] Store and category information
  - [ ] Creation and update timestamps

- [ ] **IMEI Management** (for IMEI products)
  - [ ] IMEI list display with pagination
  - [ ] Add IMEI functionality with validation
  - [ ] Remove IMEI with confirmation
  - [ ] IMEI search within product
  - [ ] Bulk IMEI operations

- [ ] **Product Actions**
  - [ ] Edit Product button (role-based)
  - [ ] **Print Barcode Button** (prepare for thermal printing)
  - [ ] Share Product functionality
  - [ ] Delete Product (OWNER only)

- [ ] **Enhanced Features**
  - [ ] Product history/audit trail
  - [ ] Related products suggestions
  - [ ] Product performance metrics
  - [ ] Quick actions menu

### **Success Criteria**
- ✅ Complete product detail display
- ✅ IMEI management functionality
- ✅ Print Barcode button ready for printing integration
- ✅ Role-based actions working correctly

---

## 💰 **Phase 15: Transaction Creation & Item Management**
*Duration: 4-5 days | Priority: CRITICAL*

### **Objective**
Implement complete transaction creation workflow with barcode scanning for item addition.

### **Features to Implement**
- [ ] **Transaction Creation Form**
  - [ ] Transaction type selection (SALE/TRANSFER)
  - [ ] Customer information for SALE transactions
  - [ ] Store selection for TRANSFER transactions
  - [ ] Photo proof capture integration
  - [ ] Transaction summary and calculation

- [ ] **Transaction Item Management**
  - [ ] Add items via barcode scanning integration
  - [ ] Add items via IMEI scanning integration
  - [ ] Manual product selection from list
  - [ ] Quantity adjustment with validation
  - [ ] Price override (role-based)
  - [ ] Remove items from transaction

- [ ] **Barcode Scanner Integration**
  - [ ] Scan to add products to transaction
  - [ ] Real-time product lookup during scanning
  - [ ] Quantity prompt after scan
  - [ ] Duplicate item handling
  - [ ] Scanner integration within transaction flow

- [ ] **Transaction Calculation**
  - [ ] Automatic amount calculation
  - [ ] Tax calculation (if applicable)
  - [ ] Discount application (role-based)
  - [ ] Total amount display
  - [ ] Item subtotals

- [ ] **Transaction Completion**
  - [ ] Transaction validation before submission
  - [ ] Photo proof requirement enforcement
  - [ ] Transaction status management
  - [ ] Auto-print receipt preparation
  - [ ] Navigation to transaction detail

### **Success Criteria**
- ✅ Transaction creation workflow complete
- ✅ Barcode scanning integration for items working
- ✅ IMEI scanning integration working
- ✅ Auto-navigation to detail after creation

---

## 🖨️ **Phase 16: Thermal Printer Foundation**
*Duration: 3-4 days | Priority: CRITICAL*

### **Objective**
Implement Bluetooth thermal printer connectivity and basic printing infrastructure.

### **Features to Implement**
- [ ] **Bluetooth Printer Service**
  - [ ] Bluetooth device discovery and scanning
  - [ ] Printer pairing and connection management
  - [ ] Connection status monitoring
  - [ ] Multiple printer support

- [ ] **Printer Settings Screen**
  - [ ] Available printer listing
  - [ ] Printer connection interface
  - [ ] Connection status display
  - [ ] Test print functionality
  - [ ] Default printer selection and storage

- [ ] **Printer Configuration**
  - [ ] Save selected printer to SharedPreferences
  - [ ] Printer connection persistence
  - [ ] Auto-reconnect functionality
  - [ ] Printer settings management

- [ ] **Basic Print Infrastructure**
  - [ ] ESC/POS command foundation
  - [ ] Print job queue system
  - [ ] Print status feedback
  - [ ] Error handling and retry logic

### **Technical Implementation**
```dart
// Key files:
- lib/core/services/bluetooth_printer_service.dart
- lib/core/services/thermal_printer_service.dart
- lib/features/settings/screens/printer_settings_screen.dart
- lib/core/models/printer_device.dart
```

### **Dependencies**
```yaml
blue_thermal_printer: ^2.1.1
esc_pos_bluetooth: ^0.4.1
esc_pos_utils: ^1.1.0
```

### **Success Criteria**
- ✅ Bluetooth printer discovery working
- ✅ Printer connection and pairing functional
- ✅ Settings screen for printer management
- ✅ Basic print infrastructure ready

---

## 🏷️ **Phase 17: Product Barcode Printing**
*Duration: 3-4 days | Priority: CRITICAL*

### **Objective**
Implement barcode printing functionality for products with proper templates and formatting.

### **Features to Implement**
- [ ] **Barcode Printing Service**
  - [ ] ESC/POS command generation for barcodes
  - [ ] Barcode template system
  - [ ] Product information formatting
  - [ ] Print layout optimization for thermal printers

- [ ] **Barcode Templates**
  - [ ] Standard product label template
  - [ ] Product name and SKU formatting
  - [ ] Barcode generation and formatting
  - [ ] Price display (optional)
  - [ ] Store branding integration

- [ ] **Print Integration in Product Detail**
  - [ ] "Print Barcode" button functionality
  - [ ] Print confirmation dialog
  - [ ] Print preview functionality
  - [ ] Print quantity selection
  - [ ] Print status feedback

- [ ] **Auto-Print After Product Creation**
  - [ ] Print prompt after product creation
  - [ ] Auto-navigate to product detail
  - [ ] Print success/failure handling
  - [ ] User preference for auto-print

### **Success Criteria**
- ✅ Barcode printing working with proper formatting
- ✅ Print button in product detail functional
- ✅ Auto-print after product creation working
- ✅ Print preview and confirmation working

---

## 🧾 **Phase 18: Transaction Receipt Printing**
*Duration: 3-4 days | Priority: CRITICAL*

### **Objective**
Implement receipt printing for transactions with auto-print and manual print options.

### **Features to Implement**
- [ ] **Receipt Template System**
  - [ ] Transaction receipt template
  - [ ] Store header with logo and contact info
  - [ ] Transaction details (type, date, ID)
  - [ ] Item list with quantities and prices
  - [ ] Subtotal, tax, and total amounts
  - [ ] Customer information (for SALE)
  - [ ] Footer with thank you message

- [ ] **Auto-Print After Transaction**
  - [ ] Automatic receipt printing after transaction completion
  - [ ] Print success/failure handling
  - [ ] Auto-navigate to transaction detail after printing
  - [ ] Transaction status update based on print result

- [ ] **Transaction Detail Print Integration**
  - [ ] "Print Payment Note" button in transaction detail
  - [ ] Receipt reprint functionality
  - [ ] Print history tracking
  - [ ] Print job status display

- [ ] **Print Error Handling**
  - [ ] Printer connectivity error handling
  - [ ] Paper out detection and user notification
  - [ ] Print queue management
  - [ ] Retry mechanisms with user feedback

### **Success Criteria**
- ✅ Auto-receipt printing after transaction creation
- ✅ "Print Payment Note" button working in detail screen
- ✅ Receipt templates formatted correctly
- ✅ Comprehensive print error handling

---

## 📊 **Phase 19: Transaction List & Management**
*Duration: 3-4 days | Priority: HIGH*

### **Objective**
Implement transaction listing with filtering, search, and role-based management.

### **Features to Implement**
- [ ] **Transaction List Screen**
  - [ ] Paginated transaction listing
  - [ ] Transaction type filtering (SALE/TRANSFER)
  - [ ] Date range filtering
  - [ ] Status filtering (pending/completed)
  - [ ] Search by transaction ID or customer

- [ ] **Transaction List Items**
  - [ ] Transaction summary cards
  - [ ] Transaction status indicators
  - [ ] Amount and date display
  - [ ] Customer information (for SALE)
  - [ ] Store information (for TRANSFER)
  - [ ] Photo proof indicators

- [ ] **Transaction Actions**
  - [ ] View transaction details
  - [ ] Edit transaction (role-based)
  - [ ] Complete/finalize transactions
  - [ ] Print receipt from list
  - [ ] Transaction sharing

- [ ] **Role-Based Access Control**
  - [ ] OWNER: All transactions across stores
  - [ ] ADMIN: Store-scoped transactions
  - [ ] STAFF: Read-only transaction access
  - [ ] CASHIER: Own transactions + create new

### **Success Criteria**
- ✅ Transaction listing with proper filtering
- ✅ Role-based access control enforced
- ✅ Transaction actions working correctly
- ✅ Professional UI with good performance

---

## 👥 **Phase 20: User & Store Management + Production Polish**
*Duration: 4-5 days | Priority: MEDIUM*

### **Objective**
Complete administrative features and polish the application for production deployment.

### **Features to Implement**
- [ ] **User Management (OWNER/ADMIN)**
  - [ ] User list screen with role filtering
  - [ ] Create user form with role assignment
  - [ ] Edit user form with restrictions
  - [ ] User activation/deactivation
  - [ ] Password reset functionality

- [ ] **Store Management (OWNER)**
  - [ ] Store list screen
  - [ ] Create store form with full address
  - [ ] Edit store form with operational settings
  - [ ] Store activation status management
  - [ ] Store assignment for users

## 📁 **Phase 20b: Category Management Screens**
*Duration: 2-3 days | Priority: MEDIUM*

### **Objective**
Implement complete category management system with CRUD operations and store associations.

### **Features to Implement**
- [ ] **Category List Screen**
  - [ ] Display categories in store-scoped list
  - [ ] Category search and filtering
  - [ ] Category count display (products per category)
  - [ ] Empty state for no categories
  - [ ] Pull-to-refresh functionality

- [ ] **Create Category Screen**
  - [ ] Simple form with category name input
  - [ ] Store selection (OWNER sees all stores, ADMIN sees assigned store)
  - [ ] Form validation for duplicate category names
  - [ ] Success feedback and navigation to category list

- [ ] **Edit Category Screen**
  - [ ] Pre-populated form with existing category data
  - [ ] Name update with validation
  - [ ] Update success confirmation
  - [ ] Navigation back to category list

- [ ] **Category Detail Screen**
  - [ ] Display category information
  - [ ] Show products count in category
  - [ ] Access to edit/delete actions (role-based)
  - [ ] Navigation to products filtered by category

- [ ] **Role-Based Access Control**
  - [ ] OWNER: Full CRUD across all stores
  - [ ] ADMIN: CRUD for assigned store only
  - [ ] STAFF/CASHIER: Read-only access
  - [ ] Proper error messages for unauthorized actions

### **Technical Implementation**
```dart
// Key files:
- lib/features/categories/screens/category_list_screen.dart
- lib/features/categories/screens/create_category_screen.dart
- lib/features/categories/screens/edit_category_screen.dart
- lib/features/categories/screens/category_detail_screen.dart
- lib/core/services/category_service.dart
- lib/core/models/category.dart
```

### **API Integration**
- **GET** `/api/v1/categories` - List categories with pagination
- **POST** `/api/v1/categories` - Create new category
- **GET** `/api/v1/categories/:id` - Get category by ID
- **PUT** `/api/v1/categories/:id` - Update category name
- **DELETE** `/api/v1/categories/:id` - Delete category (with confirmation)

### **Success Criteria**
- ✅ Complete category CRUD operations working
- ✅ Role-based access control enforced
- ✅ Store-scoped category management
- ✅ Integration with product creation (category selection)
- ✅ Professional UI with proper validation

---

- [ ] **Category Management**
  - [ ] Category list screen
  - [ ] Create/edit category forms
  - [ ] Category-store associations
  - [ ] Category organization

- [ ] **Enhanced Settings Screen**
  - [ ] User profile management
  - [ ] App configuration settings
  - [ ] Theme selection (dark/light)
  - [ ] API endpoint configuration
  - [ ] Printer settings integration

- [ ] **Production Polish**
  - [ ] Loading skeleton screens
  - [ ] Advanced error handling with retry
  - [ ] Performance optimizations
  - [ ] Memory management
  - [ ] Accessibility improvements

- [ ] **Testing & Quality Assurance**
  - [ ] Critical path testing
  - [ ] Role-based access testing
  - [ ] Device compatibility testing
  - [ ] Performance testing
  - [ ] Error scenario testing

### **Success Criteria**
- ✅ Complete user and store management
- ✅ Category management functional
- ✅ Enhanced settings screen
- ✅ Production-ready application with polish
- ✅ Comprehensive testing completed

---

## 📊 **Phase Dependencies & Critical Path**

### **Critical Path (Must Complete in Order)**
1. **Phases 1-5**: Foundation → Theme → Auth → API → Login
2. **Phase 6**: Store Selection (enables user flows)
3. **Phases 7-12**: Core UI → Scanning Integration
4. **Phases 13-15**: Product & Transaction Forms
5. **Phases 16-18**: Thermal Printing Integration
6. **Phases 19-20**: Management & Polish

### **Parallel Development Opportunities**
- **Phase 10** (Camera) can be parallel with Phase 9 (Product List)
- **Phase 19** (Transaction List) can be parallel with Phase 16-17
- **Phase 20** (Management) can start after Phase 15

### **Total Timeline**
- **Weeks 1-2**: Phases 1-6 (Foundation + Auth + Store Selection)
- **Weeks 3-4**: Phases 7-12 (UI + Scanning Integration)  
- **Weeks 5-6**: Phases 13-15 (Forms + Transaction Creation)
- **Weeks 7-8**: Phases 16-18 (Thermal Printing)
- **Weeks 9-10**: Phases 19-20 (Management + Polish)

---

## 🎯 **Success Criteria Summary**

### **Core Business Workflows**
- ✅ **Product Creation** → Auto-navigate to detail → Print barcode
- ✅ **Transaction Creation** → Auto-print receipt → "Print Payment Note" in detail
- ✅ **Barcode Scanning** → Add items to transactions OR find products
- ✅ **IMEI Scanning** → Find products by IMEI number

### **User Flow Implementation**
- ✅ **NON-OWNER**: Login → Store Selection → Store-scoped Dashboard
- ✅ **OWNER**: Login → Full Dashboard with store management

### **Technical Requirements**
- ✅ **Thermal Printing**: Bluetooth connectivity + barcode/receipt printing
- ✅ **Barcode Scanner**: Multi-format scanning for products and transactions
- ✅ **IMEI Scanner**: Specialized IMEI scanning and product search
- ✅ **Role-Based Access**: Complete RBAC with store context

### **Production Readiness**
- ✅ **Performance**: Optimized for mobile devices
- ✅ **Error Handling**: Comprehensive error management
- ✅ **User Experience**: Professional UI/UX with proper feedback
- ✅ **Integration**: Complete API integration with backend

---

*Last Updated: 2025-01-19*  
*Status: Ready to start Phase 1*  
*Total Phases: 20*  
*Estimated Duration: 8-10 weeks*