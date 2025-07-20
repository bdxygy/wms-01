# Mobile Development Backlog - 20 Phases

Complete Flutter mobile application development from zero with focus on business workflows, thermal printing, and barcode/IMEI scanning integration.

---

## 📋 **Project Overview**

**Status**: Starting from scratch (mobile project deleted)  
**Target**: Complete WMS Flutter mobile application  
**Platform**: Flutter (iOS & Android)  
**Backend Integration**: 40+ production-ready API endpoints  
**Timeline**: 20 phases over 8-10 weeks  
**Architecture**: Clean Architecture folder structures with feature-based structure

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
- [x] **Flutter Project Setup**
  - [x] Create new Flutter project with proper package name
  - [x] Configure clean architecture folder structure (`core/`, `features/`, `ui/`)
  - [x] Set up environment configuration (dev, staging, prod)
  - [x] **Platform-Specific Configurations**
    - [x] Android permissions (Camera, Bluetooth, Location)
    - [x] iOS usage descriptions (Camera, Bluetooth)
    - [x] SDK constraints (Flutter >=3.10.0, Dart >=3.0.0)
    - [x] ProGuard rules for release builds
  - [x] **Security Foundation**
    - [x] Certificate pinning configuration
    - [x] API endpoint validation setup
    - [x] Secure token storage preparation
    - [x] Biometric authentication foundation

- [x] **Dependencies Configuration**
  - [x] **Core Dependencies**
    - [x] HTTP client: `dio: ^5.3.2` with interceptors
    - [x] State management: `provider: ^6.0.5`
    - [x] Navigation: `go_router: ^12.1.1`
    - [x] Forms: `flutter_form_builder: ^9.1.1`, `form_builder_validators: ^9.1.0`
    - [x] Storage: `flutter_secure_storage: ^9.0.0`, `shared_preferences: ^2.2.2`
  - [x] **Platform Integration**
    - [x] Permissions: `permission_handler: ^11.0.1` (Camera/Bluetooth)
    - [x] Device info: `device_info_plus: ^9.1.0`
    - [x] Connectivity: `connectivity_plus: ^5.0.1`
    - [x] App info: `package_info_plus: ^4.2.0`
    - [x] File paths: `path_provider: ^2.1.1`
  - [x] **Scanning & Camera**
    - [x] Barcode scanning: `mobile_scanner: ^3.5.2`
    - [x] Camera: `camera: ^0.10.5`
    - [x] Image picker: `image_picker: ^1.0.4`
  - [x] **Thermal Printing (Choose Strategy)**
    - [x] Primary: `esc_pos_bluetooth: ^0.4.1`
    - [x] Fallback: `blue_thermal_printer: ^2.1.1`
    - [x] Utilities: `esc_pos_utils: ^1.1.0`
  - [x] **Serialization & UI**
    - [x] JSON: `json_annotation: ^4.8.1`, `json_serializable: ^6.7.1`
    - [x] Theme: `flex_color_scheme: ^7.3.1` (Material Design 3)
    - [x] Fonts: `google_fonts: ^6.1.0`
    - [x] i18n: `flutter_localizations: ^0.1.0`, `intl: ^0.18.1`

- [x] **Development Tools**
  - [x] Code generation: `build_runner: ^2.4.6`
  - [x] Linting: `flutter_lints: ^3.0.1`
  - [x] Testing: `flutter_test`, `integration_test`
  - [x] **Testing Infrastructure**
    - [x] Mock data generators: `mockito: ^5.4.2`
    - [x] Network mocking: `http_mock_adapter: ^0.4.4`
    - [x] Widget testing utilities: `flutter_test`
    - [x] Integration testing: `integration_test`

- [x] **API Integration Setup**
  - [x] Set up API client with Dio configuration
  - [x] Configure authentication interceptors
  - [x] Create base response models (ApiResponse, PaginatedResponse)
  - [x] Set up JSON serialization with json_serializable
  - [x] Create core models (User, Product, Transaction, Store)

- [x] **Basic App Structure**
  - [x] Main app entry point with environment configuration
  - [x] Basic MaterialApp with theme setup
  - [x] Initial route configuration
  - [x] Provider setup for state management
  - [x] Authentication provider initialization

- [x] **Internationalization Setup**
  - [x] Configure Flutter localization delegates
  - [x] Set up ARB file structure for translations
  - [x] Create English and Indonesian language files
  - [x] Implement AppLocalizations delegate
  - [x] Add language switching functionality
  - [x] Configure MaterialApp with localizationsDelegates

- [x] **Poppins Font Configuration**
  - [x] Download and configure Poppins font files
  - [x] Set up font assets in pubspec.yaml
  - [x] Create custom text theme with Poppins font
  - [x] Configure font weights (Regular, Medium, Bold, SemiBold)
  - [x] Implement font fallback system
  - [x] Test font rendering across different devices

### **Technical Implementation**
```dart
// Project structure with enhanced architecture:
lib/
├── core/
│   ├── api/
│   │   ├── api_client.dart         // Complete API client from contract
│   │   ├── api_endpoints.dart      // All 40+ endpoint definitions
│   │   ├── api_response.dart       // Base response models
│   │   ├── api_interceptors.dart   // Auth, error, retry interceptors
│   │   └── certificate_pinning.dart // Security implementation
│   ├── auth/
│   │   ├── auth_service.dart       // JWT authentication service
│   │   ├── auth_provider.dart      // State management
│   │   └── secure_storage.dart     // Token storage
│   ├── models/
│   │   ├── user.dart              // User model with roles
│   │   ├── product.dart           // Product with IMEI support
│   │   ├── transaction.dart       // Transaction with items
│   │   ├── store.dart             // Store model
│   │   └── api_error.dart         // Error handling models
│   ├── services/
│   │   ├── camera_service.dart     // Photo capture
│   │   ├── scanner_service.dart    // Barcode/IMEI scanning
│   │   ├── printer_service.dart    // Thermal printing
│   │   ├── connectivity_service.dart // Network monitoring
│   │   └── cache_service.dart      // Data caching
│   ├── providers/
│   │   ├── store_context_provider.dart  // Store context
│   │   ├── printer_status_provider.dart // Printer status
│   │   └── app_config_provider.dart     // App configuration
│   ├── utils/
│   │   ├── image_utils.dart       // Image processing
│   │   ├── validation_utils.dart  // Form validation
│   │   ├── error_handler.dart     // Global error handling
│   │   └── performance_monitor.dart // Performance tracking
│   └── constants/
│       ├── app_constants.dart     // App-wide constants
│       └── error_codes.dart       // Error code definitions
├── features/
│   ├── auth/
│   │   ├── screens/
│   │   ├── widgets/
│   │   └── tests/                 // Feature-specific tests
│   ├── dashboard/
│   ├── products/
│   ├── transactions/
│   ├── scanner/
│   └── settings/
├── test/
│   ├── unit/                      // Unit tests
│   ├── widget/                    // Widget tests
│   ├── integration/               // Integration tests
│   └── mocks/                     // Mock data and services
└── main.dart
```

### **API Contract Integration**
- **Complete Flutter API Contract**: Refer to `docs/flutter-api-contract.md`
- **40+ endpoints**: All backend endpoints mapped to Flutter services
- **Authentication**: JWT with refresh tokens and secure storage
- **Error handling**: Comprehensive error handling with user-friendly messages
- **Mobile features**: Barcode scanning, camera integration, thermal printing

### **Platform-Specific Configuration Details**

**Android Configuration (android/app/src/main/AndroidManifest.xml)**
```xml
<!-- Camera and Bluetooth permissions -->
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

**iOS Configuration (ios/Runner/Info.plist)**
```xml
<!-- Usage descriptions -->
<key>NSCameraUsageDescription</key>
<string>Camera access required for product photos and barcode scanning</string>
<key>NSBluetoothAlwaysUsageDescription</key>
<string>Bluetooth access required for thermal printer connectivity</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Location access for Bluetooth device discovery</string>
```

**Environment Configuration (pubspec.yaml)**
```yaml
name: wms_mobile
description: Warehouse Management System Mobile App
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: ">=3.10.0"
```

### **Success Criteria**
- ✅ Flutter project builds and runs on both iOS and Android
- ✅ All dependencies configured and working without conflicts
- ✅ Platform-specific permissions and configurations complete
- ✅ Security foundation and certificate pinning ready
- ✅ Clean architecture structure established
- ✅ Testing infrastructure setup complete
- ✅ Development environment ready for feature development

---

## 🎨 **Phase 2: UI Foundation & Theme System**
*Duration: 2-3 days | Priority: CRITICAL*

### **Objective**
Create comprehensive design system with Material Design 3, dark/light themes, and reusable UI components.

### **Features to Implement**
- [x] **Theme System**
  - [x] Material Design 3 with `flex_color_scheme`
  - [x] Light and dark theme configurations
  - [x] WMS brand colors and custom color scheme
  - [x] Typography system with proper text styles
  - [x] System theme detection and manual toggle

- [x] **Core UI Components**
  - [x] Custom app bars with role-based actions
  - [x] Loading indicators and skeleton screens
  - [x] Error states and empty state widgets
  - [x] Custom buttons (primary, secondary, icon)
  - [x] Form field components and validation displays
  - [x] Cards and list item templates

- [x] **Layout Foundation**
  - [x] Responsive breakpoint system
  - [x] Safe area handling utilities
  - [x] Keyboard behavior management
  - [x] Bottom sheet and dialog templates
  - [x] Scaffold templates for different screen types

- [x] **Icon System**
  - [x] Material Design icons
  - [x] Custom WMS-specific icons
  - [x] Status indicators and badges
  - [x] Role-based icon variations

### **Success Criteria**
- ✅ Complete theme system with light/dark modes
- ✅ Reusable component library established
- ✅ Responsive design foundation ready
- ✅ Consistent visual language across app

---

## 🌐 **Phase 3: API Client & Network Layer**
*Duration: 3-4 days | Priority: CRITICAL*

### **Objective**
Create comprehensive API client with proper error handling, response wrappers, and integration with all 40+ backend endpoints.

**Note: API Client must be implemented before Authentication Service to provide HTTP foundation.**

### **Features to Implement**
- [x] **Authentication Models**
  - [x] User model with role enumeration (OWNER, ADMIN, STAFF, CASHIER)
  - [x] Auth response models (login, refresh, register)
  - [x] JWT token models with expiry handling
  - [x] Permission model for RBAC

- [x] **Secure Storage Service**
  - [x] Token storage with `flutter_secure_storage`
  - [x] Encrypted token management
  - [x] Biometric authentication preparation
  - [x] Secure logout with complete token cleanup

- [x] **Authentication Service**
  - [x] Login with username/password
  - [x] JWT token refresh mechanism
  - [x] Logout with backend token invalidation
  - [x] Token expiry detection and auto-refresh
  - [x] Error handling for auth failures

- [x] **Authentication State Management**
  - [x] AuthProvider with Provider pattern
  - [x] Authentication state persistence
  - [x] Role-based permission checking
  - [x] Auto-login on app startup

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

## 🔐 **Phase 4: Core Authentication System**
*Duration: 3-4 days | Priority: CRITICAL*

### **Objective**
Implement JWT-based authentication with secure storage and role-based access control foundation.

**Note: Authentication Service depends on API Client from Phase 3.**

### **Features to Implement**
- [x] **API Client Foundation**
  - [x] Dio HTTP client with base configuration
  - [x] **Security Interceptors**
    - [x] Certificate pinning implementation, (still set up but DISABLED after it)
    - [x] API endpoint validation
    - [x] Bearer token injection
  - [x] **Error Handling Interceptors**
    - [x] Custom exception handling with retry logic
    - [x] Network timeout handling (>30 seconds)
    - [x] Connection loss recovery
    - [x] Rate limiting and throttling
  - [x] **Monitoring Interceptors**
    - [x] Request/response logging
    - [x] Performance monitoring
    - [x] Network connectivity detection

- [x] **Response Models**
  - [x] BaseResponse<T> wrapper for single items
  - [x] PaginatedResponse<T> for list endpoints
  - [x] ErrorResponse for API error handling
  - [x] Generic response handling utilities

- [x] **Data Models with JSON Serialization**
  - [x] User model with role-based properties
  - [x] Store model with complete address structure
  - [x] Product model with IMEI support
  - [x] Category model
  - [x] Transaction model with items
  - [x] ProductImei model
  - [x] Pagination model

- [x] **API Endpoints Integration**
  - [x] Authentication endpoints (login, refresh, logout, register)
  - [x] User management (CRUD with role restrictions)
  - [x] Store management (OWNER operations)
  - [x] Product management (full CRUD + barcode/IMEI search)
  - [x] Category management
  - [x] Transaction management (SALE/TRANSFER)
  - [x] IMEI management (add, remove, search)

- [x] **Comprehensive Error Handling System**
  - [x] **Core Error Classes**
    - [x] ApiException with standardized error codes
    - [x] NetworkException for connectivity issues
    - [x] AuthException for authentication failures
    - [x] ValidationException for input errors
  - [x] **Error Scenarios Coverage**
    - [x] Network timeout (>30 seconds)
    - [x] Connection lost during requests
    - [x] Invalid API responses
    - [x] Server maintenance mode
    - [x] Storage full scenarios
  - [x] **Retry Mechanisms**
    - [x] Exponential backoff for failed requests
    - [x] Token refresh retry on 401 errors
    - [x] Network reconnection retry
    - [x] User-guided retry with feedback

### **Security Implementation Details**

**Certificate Pinning Setup**
```dart
// core/api/certificate_pinning.dart
class CertificatePinning {
  static const String API_FINGERPRINT = 'SHA256:...'; // Production API cert
  static const String DEV_FINGERPRINT = 'SHA256:...'; // Development API cert
  
  static bool validateCertificate(X509Certificate cert, String host, int port) {
    // Implement certificate validation logic
  }
}
```

**API Endpoint Validation**
```dart
// Ensure all API calls go to trusted endpoints
class ApiValidator {
  static final List<String> TRUSTED_HOSTS = [
    'api.wms.example.com',
    'dev-api.wms.example.com'
  ];
  
  static bool isValidEndpoint(String url) {
    // Validate endpoint against whitelist
  }
}
```

### **Success Criteria**
- ✅ Complete API client covering all backend endpoints
- ✅ Certificate pinning and endpoint validation working
- ✅ Comprehensive error handling with retry mechanisms
- ✅ Network monitoring and connectivity detection
- ✅ Type-safe models with JSON serialization
- ✅ Performance monitoring and logging active
- ✅ Bearer token authentication with secure refresh

---

## 🔑 **Phase 5: Login & Store Selection Flow**
*Duration: 3-4 days | Priority: CRITICAL*

### **Objective**
Create complete authentication flow including login screen and store selection for non-owner users.

### **Features to Implement**
- [x] **Login Screen**
  - [x] Username/password form with validation
  - [x] Show/hide password functionality
  - [x] Loading states during authentication
  - [x] Error display with proper messaging
  - [x] Remember login option preparation

- [x] **Welcoming Choose Store Screen** (`WelcomingChooseStoreScreen`)
  - [x] Display available stores for non-owner users
  - [x] Store list with name, address, and status
  - [x] Store selection with confirmation
  - [x] Error handling for users with no stores
  - [x] Loading states while fetching stores

- [x] **Authentication Flow**
  - [x] Splash screen with auth state checking
  - [x] Auto-login with stored tokens
  - [x] Role-based navigation:
    - [x] NON-OWNER: Login → Store Selection → Dashboard
    - [x] OWNER: Login → Full Dashboard (bypass store selection)
  - [x] Token refresh on app resume
  - [x] Session timeout handling

- [x] **Form Validation**
  - [x] Real-time field validation
  - [x] Username format validation
  - [x] Password requirements checking
  - [x] Network error handling
  - [x] API error display

- [x] **UI/UX Polish**
  - [x] Professional login screen design
  - [x] Proper keyboard handling
  - [x] Loading animations
  - [x] Error state animations
  - [x] Accessibility support

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

- [x] **Store Context Management**
  - [x] StoreContextProvider for selected store
  - [x] Store context persistence across app sessions
  - [x] Store switching logic for OWNER users
  - [x] Store-scoped data filtering

- [x] **Navigation System with GoRouter**
  - [x] Declarative route configuration
  - [x] Authentication route guards
  - [x] Store selection requirement guards
  - [x] Role-based route access control
  - [x] Deep linking preparation

- [x] **User Flow Implementation**
  - [x] NON-OWNER: Login → Store Selection → Dashboard
  - [x] OWNER: Login → Full Dashboard (skip store selection)
  - [x] Proper navigation state management
  - [x] Back button handling

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
- [x] **OWNER Dashboard**
  - [x] Multi-store overview with store switcher panel
  - [x] Store performance metrics
  - [x] Quick actions (Add Store, Manage Users, View Reports)
  - [x] Recent activity across all stores
  - [x] Store management shortcuts
  - [x] For go to selecting store page, owner can go to settings page

- [x] **ADMIN Dashboard**
  - [x] Single-store view (based on selected store)
  - [x] Store-specific metrics and overview
  - [x] Quick actions (Add Product, Create Transaction, Manage Staff)
  - [x] Store inventory overview
  - [x] Recent transactions

- [x] **STAFF Dashboard**
  - [x] Read-only store overview
  - [x] Product search and viewing
  - [x] Product checking interface preparation
  - [x] Limited quick actions
  - [x] Recent product checks

- [x] **CASHIER Dashboard**
  - [x] Transaction-focused interface
  - [x] Quick Sale creation
  - [x] Recent transactions view
  - [x] Simple product search
  - [x] Daily sales summary

- [x] **Dashboard Components**
  - [x] Metric cards with data visualization
  - [x] Quick action buttons with role-based filtering
  - [x] Recent activity lists
  - [x] Navigation shortcuts
  - [x] Refresh functionality

### **Success Criteria**
- ✅ Role-specific dashboards working correctly
- ✅ Proper data display based on permissions
- ✅ Quick actions navigate to relevant screens
- ✅ Professional dashboard UI/UX

### **🧪 Testing Milestone: Authentication & Basic UI**
*Duration: 1 day | After Phase 7*

**Critical Testing Requirements:**
- [ ] **Authentication Flow Testing**
  - [ ] Login with all user roles (OWNER, ADMIN, STAFF, CASHIER)
  - [ ] Store selection flow for non-owner users
  - [ ] Token refresh mechanism validation
  - [ ] Session timeout handling
- [ ] **Role-Based Dashboard Testing**
  - [ ] Verify role-specific dashboard content
  - [ ] Test navigation restrictions per role
  - [ ] Validate store context switching (OWNER)
  - [ ] Confirm data scoping works correctly
- [ ] **API Integration Testing**
  - [ ] All authentication endpoints working
  - [ ] Error handling for network failures
  - [ ] Certificate pinning validation
  - [ ] Bearer token injection verification

---

## 📱 **Phase 8: Bottom Navigation & Screen Structure**
*Duration: 2-3 days | Priority: HIGH*

### **Objective**
Implement bottom navigation with role-based tabs and screen structure foundation.

### **Features to Implement**
- [x] **Bottom Navigation System**
  - [x] Dynamic tabs based on user role
  - [x] Role-specific navigation items
  - [x] Badge notifications for tabs
  - [x] Persistent navigation shell

- [x] **Navigation Tabs by Role**
  - [x] OWNER: Dashboard, Stores, Users, Products, Checks, Transactions, Categories, Settings
  - [x] ADMIN: Dashboard, Products, Checks, Transactions, Users, Categories, Settings
  - [x] STAFF: Dashboard, Products, Checks, Settings
  - [x] CASHIER: Dashboard, Transactions, Products, Settings

- [x] **Screen Scaffolding**
  - [x] Base screen templates for each feature
  - [x] Consistent app bar structure
  - [x] Floating action buttons (context-aware)
  - [x] Search functionality integration
  - [x] Pull-to-refresh setup

- [x] **Navigation State Management**
  - [x] Tab state persistence
  - [x] Deep linking support
  - [x] Back button handling
  - [x] Tab switching animations

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
- [x] **Product List Screen**
  - [x] Paginated product listing with infinite scroll
  - [x] Pull-to-refresh functionality
  - [x] Loading states and error handling
  - [x] Empty state for no products

- [x] **Search & Filtering**
  - [x] Real-time search by product name
  - [x] Search by SKU and barcode
  - [x] Category-based filtering
  - [x] Store-based filtering (for OWNER)
  - [x] Price range filtering

- [x] **Product List Items**
  - [x] Product cards with image placeholder
  - [x] Product name, SKU, and barcode display
  - [x] Price information (purchase/sale)
  - [x] Stock level indicators
  - [x] IMEI product badges

- [x] **Role-Based Actions**
  - [x] Add Product FAB (OWNER/ADMIN only)
  - [x] Edit Product access (OWNER/ADMIN only)
  - [x] View-only mode for STAFF/CASHIER
  - [x] Quick actions menu

- [x] **Navigation Integration**
  - [x] Tap to view product details
  - [x] Context menu for quick actions
  - [x] Search results navigation
  - [x] Filter state management

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
- [x] **Camera Service**
  - [x] Camera initialization and configuration
  - [x] Photo capture with quality settings
  - [x] Front/back camera switching
  - [x] Flash control and settings
  - [x] **Enhanced Camera Features**
    - [x] Camera permissions handling with user guidance
    - [x] Memory management during photo capture
    - [x] Camera failure recovery mechanisms
    - [x] Photo quality optimization
    - [x] Background camera task handling

- [x] **Photo Capture Screen**
  - [x] Custom camera UI with controls
  - [x] Photo preview and confirmation
  - [x] Retake photo functionality
  - [x] Multiple photo capture mode
  - [x] Photo gallery preview

- [x] **Advanced Image Management**
  - [x] **Compression & Optimization**
    - [x] Intelligent image compression algorithms
    - [x] Size optimization for different use cases
    - [x] Quality vs file size balancing
    - [x] Format conversion (JPEG, PNG, WebP)
  - [x] **Storage & Cache Management**
    - [x] Local image storage in app directory
    - [x] Image cache with LRU eviction
    - [x] Storage full detection and cleanup
    - [x] Image metadata management
    - [x] Automatic cleanup of old images
  - [x] **Performance Optimization**
    - [x] Lazy image loading
    - [x] Image preloading strategies
    - [x] Memory leak prevention
    - [x] Background image processing

- [x] **Integration Preparation**
  - [x] Product photo capture workflow
  - [x] Transaction proof photo workflow
  - [x] Photo picker from gallery option
  - [x] Photo viewing and zoom functionality

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
- [x] **Barcode Scanner Service**
  - [x] Multiple format support (EAN, UPC, Code128, QR)
  - [x] Real-time barcode detection
  - [x] Camera controls (torch, zoom, focus)
  - [x] Scanner performance optimization

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
  - [ ] **Enhanced Error Handling**
    - [ ] Invalid barcode format detection
    - [ ] Scanner retry on detection failure
    - [ ] Camera permission denied handling
    - [ ] Low light scanning optimization
    - [ ] Manual barcode entry fallback

- [ ] **Scanner Utilities**
  - [ ] Barcode validation and formatting
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
- [x] **IMEI Scanner**
  - [x] IMEI barcode detection (specific formats)
  - [x] Manual IMEI entry with validation
  - [x] IMEI formatting and display

- [x] **IMEI Product Search**
  - [x] Search products by IMEI number
  - [x] Display product associated with IMEI
  - [x] Navigate to product detail from IMEI
  - [x] IMEI search history

- [x] **IMEI Integration**
  - [x] IMEI scanning in transaction workflows
  - [x] IMEI-based inventory checking
  - [x] IMEI product verification
  - [x] Duplicate IMEI detection

- [x] **IMEI Management Preparation**
  - [x] Add IMEI to products workflow
  - [x] IMEI list display
  - [x] IMEI removal functionality
  - [x] IMEI validation rules

### **Success Criteria**
- ✅ IMEI scanning and validation working
- ✅ Product search by IMEI functional
- ✅ IMEI integration with product workflows
- ✅ Proper IMEI validation and formatting

### **🧪 Testing Milestone: Scanning Integration**
*Duration: 1 day | After Phase 12*

**Critical Testing Requirements:** (Skipped)
- [ ] **Barcode Scanner Testing**
  - [ ] Multiple format support (EAN, UPC, Code128, QR)
  - [ ] Real-time detection accuracy
  - [ ] Camera controls (torch, zoom, focus)
  - [ ] Performance under different lighting
- [ ] **IMEI Scanner Testing**
  - [ ] IMEI format validation (15-16 digits)
  - [ ] Luhn algorithm validation
  - [ ] Duplicate IMEI detection
  - [ ] Integration with product search
- [ ] **Camera Service Testing**
  - [ ] Photo capture quality and compression
  - [ ] Front/back camera switching
  - [ ] Permission handling validation
  - [ ] Memory management during capture
- [ ] **Integration Testing**
  - [ ] Scanner results with product search
  - [ ] Navigation flow from scanning
  - [ ] Error handling for invalid scans

---

## 📝 **Phase 13: Product CRUD Forms**
*Duration: 4-5 days | Priority: CRITICAL*

### **Objective**
Implement complete product creation and editing forms with validation and business rules.

### **Features to Implement**
- [x] **Create Product Form**
  - [x] Multi-step form with `flutter_form_builder`
  - [x] Product details (name, SKU, prices, quantity)
  - [x] Store and category selection dropdowns
  - [x] IMEI checkbox (if checked, then appear dynamic array form for inserting IMEI's number)
  - [x] Photo upload integration
  - [x] Form validation with business rules

- [x] **Edit Product Form**
  - [x] Pre-populated form with existing data
  - [x] Partial update capability
  - [x] Photo replacement functionality
  - [x] Change tracking and confirmation
  - [x] Optimistic UI updates

- [x] **Form Components**
  - [x] Reusable form field widgets
  - [x] Custom validators for products
  - [x] Dropdown selectors with data loading
  - [x] Photo picker integration
  - [x] Price input with currency formatting

- [x] **Form Validation**
  - [x] Real-time field validation
  - [x] Cross-field validation (sale vs purchase price)
  - [x] Server-side validation integration
  - [x] Business rule enforcement
  - [x] Error display and user guidance

- [x] **Product Creation Workflow**
  - [x] Auto-navigation to ProductDetailScreen after creation
  - [x] Success feedback with product information
  - [x] Print Barcode button preparation
  - [x] Form state management

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
- [x] **Product Detail Screen**
  - [x] Complete product information display
  - [ ] Product photo gallery with zoom (Skipped)
  - [x] Stock level and pricing information
  - [x] Store and category information
  - [x] Creation and update timestamps

- [x] **IMEI Management** (for IMEI products)
  - [x] IMEI list display with pagination
  - [x] Add IMEI functionality with validation
  - [x] Remove IMEI with confirmation
  - [x] IMEI search within product
  - [x] Bulk IMEI operations

- [x] **Product Actions**
  - [x] Edit Product button (role-based)
  - [x] **Print Barcode Button** (prepare for thermal printing)
  - [x] Share Product functionality
  - [x] Delete Product (OWNER only)

- [x] **Enhanced Features**
  - [ ] Product history/audit trail (Skipped)
  - [x] Related products suggestions
  - [ ] Product performance metrics (Skipped)
  - [x] Quick actions menu

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
- [x] **Transaction Creation Form**
  - [x] Transaction type selection (SALE/TRANSFER)
  - [x] Customer information for SALE transactions
  - [x] Store selection for TRANSFER transactions
  - [x] Photo proof capture integration
  - [x] Transaction summary and calculation

- [x] **Transaction Item Management**
  - [x] Add items via barcode scanning integration
  - [x] Add items via IMEI scanning integration
  - [x] Manual product selection from list
  - [x] Quantity adjustment with validation
  - [x] Price override (role-based)
  - [x] Remove items from transaction

- [x] **Barcode Scanner Integration**
  - [x] Scan to add products to transaction
  - [x] Real-time product lookup during scanning
  - [x] Quantity prompt after scan
  - [x] Duplicate item handling
  - [x] Scanner integration within transaction flow

- [x] **Transaction Calculation**
  - [x] Automatic amount calculation
  - [x] Tax calculation (if applicable)
  - [x] Discount application (role-based)
  - [x] Total amount display
  - [x] Item subtotals

- [x] **Transaction Completion**
  - [x] Transaction validation before submission
  - [x] Photo proof requirement enforcement
  - [x] Transaction status management
  - [x] Auto-print receipt preparation
  - [x] Navigation to transaction detail

### **Success Criteria**
- ✅ Transaction creation workflow complete
- ✅ Barcode scanning integration for items working
- ✅ IMEI scanning integration working
- ✅ Auto-navigation to detail after creation

### **🧪 Testing Milestone: Core Business Workflows**
*Duration: 1-2 days | After Phase 15*

**Critical Testing Requirements:**
- [ ] **Product Workflow Testing**
  - [ ] Complete product creation flow
  - [ ] Auto-navigation to product detail
  - [ ] Photo capture integration
  - [ ] Form validation and error handling
  - [ ] Role-based access control (OWNER/ADMIN)
- [ ] **Transaction Workflow Testing**
  - [ ] SALE transaction creation with items
  - [ ] TRANSFER transaction between stores
  - [ ] Barcode scanning item addition
  - [ ] IMEI scanning item addition
  - [ ] Photo proof capture requirement
  - [ ] Amount calculation accuracy
- [ ] **End-to-End Business Flow Testing**
  - [ ] Product creation → Detail → Edit workflow
  - [ ] Transaction creation → Items → Completion
  - [ ] Cross-role workflow testing
  - [ ] Store context validation
- [ ] **Data Validation Testing**
  - [ ] Form validation rules
  - [ ] Business rule enforcement
  - [ ] API data consistency
  - [ ] Error recovery mechanisms

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

- [ ] **Comprehensive Print Error Handling**
  - [ ] **Connection Issues**
    - [ ] Bluetooth connection lost during print
    - [ ] Printer device not found errors
    - [ ] Pairing failure recovery
    - [ ] Auto-reconnection with exponential backoff
  - [ ] **Hardware Issues**
    - [ ] Paper out detection and user notification
    - [ ] Printer jam detection
    - [ ] Low battery warnings
    - [ ] Overheating protection
  - [ ] **Print Job Management**
    - [ ] Print queue with job prioritization
    - [ ] Failed print job retry mechanisms
    - [ ] Print job cancellation
    - [ ] Print status tracking and user feedback
  - [ ] **Offline Printing**
    - [ ] Local print job storage
    - [ ] Retry when connection restored
    - [ ] Print job expiration handling

### **Success Criteria**
- ✅ Auto-receipt printing after transaction creation
- ✅ "Print Payment Note" button working in detail screen
- ✅ Receipt templates formatted correctly
- ✅ Comprehensive print error handling

### **🧪 Testing Milestone: Thermal Printing Integration**
*Duration: 1-2 days | After Phase 18*

**Critical Testing Requirements:**
- [ ] **Bluetooth Printer Testing**
  - [ ] Device discovery and pairing
  - [ ] Connection stability testing
  - [ ] Multiple printer device support
  - [ ] Auto-reconnection functionality
- [ ] **Print Job Testing**
  - [ ] Barcode printing from product detail
  - [ ] Auto-receipt printing after transactions
  - [ ] Print queue management
  - [ ] Print job retry mechanisms
- [ ] **Error Scenario Testing**
  - [ ] Printer paper out detection
  - [ ] Bluetooth connection loss during print
  - [ ] Print job failure recovery
  - [ ] User feedback for print errors
- [ ] **Template and Format Testing**
  - [ ] Barcode template formatting
  - [ ] Receipt template layout
  - [ ] ESC/POS command generation
  - [ ] Print quality validation
- [ ] **Integration Testing**
  - [ ] Product creation → Auto-print barcode
  - [ ] Transaction completion → Auto-print receipt
  - [ ] "Print Payment Note" functionality
  - [ ] Print settings persistence

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

- [ ] **Production Polish & Performance**
  - [ ] **UI/UX Enhancements**
    - [ ] Loading skeleton screens
    - [ ] Smooth animations and transitions
    - [ ] Accessibility improvements (screen readers, high contrast)
    - [ ] Responsive design validation
  - [ ] **Performance Optimizations**
    - [ ] App startup time optimization
    - [ ] Memory usage profiling and optimization
    - [ ] Battery usage optimization
    - [ ] Network request optimization
    - [ ] Image loading and caching optimization
  - [ ] **Memory Management**
    - [ ] Memory leak detection and fixes
    - [ ] Large dataset pagination optimization
    - [ ] Background task memory management
    - [ ] Cache size limits and cleanup
  - [ ] **Advanced Error Handling**
    - [ ] Global error boundary implementation
    - [ ] User-friendly error messages
    - [ ] Error reporting and analytics
    - [ ] Offline error handling

- [ ] **Testing & Quality Assurance**
  - [ ] Critical path testing
  - [ ] Role-based access testing
  - [ ] Device compatibility testing
  - [ ] Performance testing
  - [ ] Error scenario testing

### **🧪 Final Testing Milestone: Production Readiness**
*Duration: 2-3 days | After Phase 20*

**Critical Production Testing:**
- [ ] **Performance Testing**
  - [ ] App startup time (target: <3 seconds)
  - [ ] Memory usage under load
  - [ ] Battery consumption monitoring
  - [ ] Network efficiency testing
- [ ] **Device Compatibility Testing**
  - [ ] Multiple Android versions (API 21+)
  - [ ] iOS versions (iOS 12+)
  - [ ] Different screen sizes and densities
  - [ ] Low-end device performance
- [ ] **Stress Testing**
  - [ ] Large dataset handling (1000+ products)
  - [ ] Multiple concurrent users
  - [ ] Extended usage sessions
  - [ ] Memory leak detection
- [ ] **Security Testing**
  - [ ] Certificate pinning validation
  - [ ] Token security and refresh
  - [ ] Local data encryption
  - [ ] Permission handling
- [ ] **Integration Testing**
  - [ ] All API endpoints functional
  - [ ] Offline/online mode transitions
  - [ ] Cross-role workflow validation
  - [ ] Thermal printer compatibility

### **Success Criteria**
- ✅ Complete user and store management
- ✅ Category management functional
- ✅ Enhanced settings screen with performance monitoring
- ✅ Production-ready application with comprehensive polish
- ✅ Performance benchmarks met
- ✅ Device compatibility validated
- ✅ Security measures verified
- ✅ Comprehensive testing completed

---

## 📊 **Phase Dependencies & Critical Path**

### **Critical Path (Must Complete in Order)**
1. **Phases 1-5**: Foundation → Theme → API → Auth → Login
2. **Phase 6**: Store Selection (enables user flows)
3. **Phases 7-12**: Core UI → Scanning Integration
4. **Phases 13-15**: Product & Transaction Forms
5. **Phases 16-18**: Thermal Printing Integration
6. **Phases 19-20**: Management & Polish

**Note**: Phase order corrected - API Client (Phase 3) now comes before Authentication (Phase 4)

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
- ✅ **Performance**: Optimized for mobile devices with monitoring
- ✅ **Memory Management**: Leak prevention and efficient resource usage
- ✅ **Error Handling**: Comprehensive error management with user guidance
- ✅ **Offline Capability**: Essential functions work without connectivity
- ✅ **User Experience**: Professional UI/UX with accessibility support
- ✅ **Security**: Certificate pinning and secure data handling
- ✅ **Integration**: Complete API integration with backend and monitoring
- ✅ **Device Compatibility**: Tested across multiple platforms and devices

---

*Last Updated: 2025-01-19*  
*Status: Ready to start Phase 1 - Enhanced with security, performance, and testing*  
*Total Phases: 20 + 4 Testing Milestones*  
*Estimated Duration: 8-10 weeks + 1 week testing*  
*Fixed Issues: Phase dependencies, security implementation, comprehensive error handling*