# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Warehouse Management System (WMS)** - A complete inventory management system for tracking goods across multiple stores with role-based access control, featuring web and mobile applications.

### Tech Stack

- **Backend**: Hono, Node.js, Zod, Drizzle, SQLite Turso ✅ **PRODUCTION READY**
- **Database**: SQLite with Drizzle ORM ✅ **PRODUCTION READY**  
- **Authentication**: JWT-based with role-based access control ✅ **PRODUCTION READY**
- **Frontend Web**: React, Shadcn, Zod, React Query, Tailwindcss, Rsbuild 📋 **PLANNED**
- **Mobile**: Flutter (cross-platform mobile development) ✅ **PHASE 15+ COMPLETE - FULL BUSINESS WORKFLOWS READY**

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

## 📱 **MOBILE: PHASE 16+ COMPLETE - MODERN UI/UX REDESIGN (95+ Dart files)**

**Current Status**: 90% Complete (16+/20 phases) | **Production Ready** | **Next**: Phase 17 - Thermal Printer Integration

### Latest Completion: Phase 16+ - Modern UI/UX Redesign & Internationalization ✅
- **✅ Modern Design System**: Complete Material Design 3 implementation with gradient backgrounds, shadows, and contemporary styling
- **✅ Product Detail Redesign**: Hero card layout with transparent app bar, floating action buttons, and visual hierarchy
- **✅ Transaction List Redesign**: Modern search bar, statistics hero cards, contemporary transaction cards with visual indicators
- **✅ Transaction Detail Redesign**: Complete hero card system, modern information cards, proof documentation, and audit trails
- **✅ Internationalization Framework**: Mandatory i18n usage with AppLocalizations throughout all user-facing components
- **✅ Guard Clause Patterns**: Comprehensive implementation across all screens with early returns and clean error handling
- **✅ Responsive UI System**: Mobile-first design with proper text overflow, flexible layouts, and touch-friendly interfaces
- **✅ WMSCard Migration**: Removed legacy card components, replaced with modern Container-based designs
- **✅ Performance Optimizations**: ProductForm lazy loading eliminating unnecessary API calls in create mode
- **✅ Route Ordering Fix**: GoRouter route order corrected to prevent dynamic routes from intercepting specific routes
- **✅ Currency Management**: Global currency system with settings configuration and consistent formatting
- **✅ Single-Step Forms**: Converted all forms from multi-step to single scrollable layouts with sections
- **✅ Theme Integration**: Complete theme-aware components with proper color schemes and Material Design 3 compliance
- **✅ Barcode Scanning Integration**: Product search functionality with automatic navigation to product details

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
- **Navigation System**: GoRouter with authentication guards, proper route ordering, declarative routing with global redirect logic
- **Role-Based Dashboards**: Owner (8 sections), Admin (6 sections), Staff (4 sections), Cashier (4 sections) with permission-aware UI
- **Camera System**: Professional photo capture with compression, multi-photo support, storage management, photo preview/zoom
- **Barcode Scanner System**: Multiple format support (EAN, UPC, Code128, QR), scanner overlay, product search integration with automatic navigation
- **IMEI Scanner System**: Industry-standard IMEI validation (Luhn algorithm), product search, management interface
- **Product Management**: Complete CRUD forms with single-step creation using guard clauses, lazy loading optimization, IMEI support, validation, barcode search
- **Transaction System**: Multi-step transaction creation (SALE/TRANSFER), item management, photo proof, business validation
- **Currency Management**: Global currency system with 8 supported currencies, configurable in settings, consistent formatting
- **Performance**: Lazy loading forms, optimized API calls, proper route handling eliminating unnecessary requests
- **UI Components**: Material Design 3, comprehensive theme system, responsive design, loading states, overflow-free layouts
- **Services**: TransactionService, ProductService, CameraService, ScannerService, ImeiScannerService, AuthService with full API integration
- **Internationalization**: 280+ translation keys covering complete business workflows
- **25+ Screens**: Authentication, Dashboards, Product CRUD, Transaction Creation, Camera, Scanners, Management interfaces

### Critical Bug Fixes & Optimizations
- **✅ Route Ordering Issue**: Fixed GoRouter route order where `/:id` was intercepting `/create`, causing ProductDetailScreen to make GET requests to `/api/v1/products/create`
- **✅ Performance Optimization**: Implemented lazy loading in ProductForm to eliminate unnecessary API calls during form initialization in create mode
- **✅ Form Optimization**: Added `_setCreateModeDefaults()` for instant form availability and `_loadStoreAndCategoryData()` for on-demand data loading
- **✅ API Call Reduction**: Removed redundant store/category API calls when accessing product create form, improving performance and reducing server load
- **✅ Currency System**: Global currency management with SharedPreferences persistence and consistent formatting across all price displays
- **✅ Form Validation**: Fixed Next button remaining disabled in product forms by implementing proper IMEI validation logic
- **✅ Layout Fixes**: Resolved RenderFlex overflow issues in product detail screens by implementing flexible layouts
- **✅ Theme Consistency**: Fixed dropdown field text colors and deprecated API usage for complete theme support
- **✅ Enhanced Product Detail**: Display store names and category names instead of IDs with proper API integration
- **✅ Barcode Integration**: Complete barcode scanning workflow from product list to product detail with error handling

### Current Mobile Architecture (Updated)
```
mobile/lib/
├── core/ (75+ files)
│   ├── api/ - HTTP client, endpoints, exceptions, interceptors
│   ├── auth/ - AuthProvider, AuthService, secure storage
│   ├── models/ - User, Store, Product, Transaction, Category, StoreContext, Currency with API requests
│   ├── services/ - TransactionService, ProductService, CameraService, ScannerService, ImeiScannerService, CategoryService, StoreService
│   ├── providers/ - AppProvider (theme/locale/currency), StoreContextProvider, AuthProvider
│   ├── routing/ - GoRouter with auth guards, global redirect logic, scanner routes
│   ├── theme/ - Comprehensive theme system with role-based color coding, overflow-free layouts
│   ├── validators/ - ProductValidators, TransactionValidators with business rules
│   ├── utils/ - ImageUtils, BarcodeUtils, ImeiUtils (validation, formatting, utilities)
│   └── widgets/ - PhotoViewer, ScannerOverlay, MainNavigationScaffold, form components, currency selector
├── features/ (30+ screens)
│   ├── auth/ - Splash, Login, Store Selection screens
│   ├── dashboard/ - Role-based dashboard widgets (Owner/Admin/Staff/Cashier)
│   ├── camera/ - CameraScreen with professional photo capture UI
│   ├── scanner/ - BarcodeScannerScreen, ImeiScannerScreen, ImeiProductSearchWidget
│   ├── products/ - ProductList, ProductDetail, CreateProduct, EditProduct, ImeiManagement screens with barcode integration
│   ├── transactions/ - CreateTransaction, TransactionForm, TransactionItemManager, PhotoProofPicker widgets
│   ├── settings/ - Settings screen with user profile and currency management
│   └── [stores, users, categories, checks]/ - Navigation ready for next phases
├── l10n/ - English/Indonesian translations (280+ keys)
└── generated/ - Localization classes
```

### Business Workflows Ready
- ✅ **Product Creation → Auto-navigate to detail → Print barcode** (Phases 13-14)
- ✅ **Transaction Creation → Auto-print receipt → Transaction detail with "Print Payment Note"** (Phase 15)
- ✅ **Barcode Scanning → Find products → Navigate to product detail** (Complete integration)
- ✅ **Product Search by Barcode → Real-time search integration** (Phase 11 + Product List integration)
- ✅ **Currency Management → Global currency system → Configurable in settings** (Complete system)
- 🔄 **IMEI Scanning → Find products by IMEI number** (Phase 12 foundation + Phase 15 integration ready)

### Recent Developments ✅

**Phase 15+ Implementation (Major Milestone + UI/UX Polish):**
- **Complete Transaction System**: Multi-step workflow with item management, photo proof integration, and business rule validation
- **Currency Management**: Global currency system with 8 supported currencies, configurable in settings, persistent storage
- **Enhanced Product Management**: Barcode scanning integration, store/category name display, optimized form validation
- **Performance Optimizations**: Lazy loading, reduced API calls, proper route handling, overflow-free layouts
- **Theme & UI Polish**: Fixed theme inconsistencies, layout overflow issues, proper color schemes across all components
- **Enhanced API Integration**: TransactionService, CategoryService, StoreService with full CRUD operations
- **Role-based Permissions**: Comprehensive permission system for all operations across user roles

**Phase 11-14 Foundation (Scanner & Product Systems):**
- **BarcodeScannerScreen**: Professional scanner with multiple format support and product search integration
- **ScannerService**: Complete barcode scanning service with validation and automatic navigation
- **ImeiScannerScreen**: Industry-standard IMEI scanner with Luhn algorithm validation
- **Product CRUD System**: Multi-step forms with IMEI management and comprehensive validation
- **ProductImeiManagementScreen**: Complete IMEI management with dynamic layouts

**Code Quality**: Production-ready codebase with comprehensive error handling, proper validation, and optimized performance.

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
- **🛡️ GUARD CLAUSES MANDATORY**: Always use guard clauses instead of nested if statements for better readability and early returns
- **🎨 MODERN DESIGN MANDATORY**: All UI must follow modern design principles with clean, contemporary aesthetics
- **📝 SINGLE-STEP FORMS ONLY**: Multi-step forms are strictly prohibited - use single scrollable layouts with sections
- **🌐 INTERNATIONALIZATION MANDATORY**: All user-facing text must use i18n with AppLocalizations - no hardcoded strings allowed

### 🛡️ **GUARD CLAUSE PATTERNS** 🛡️

**MANDATORY**: All new code must use guard clauses instead of nested if statements for better readability and maintainability.

#### **Required Guard Clause Patterns:**

```dart
// ✅ CORRECT: Early return validation
Future<void> saveData() async {
  if (!isValid) return;
  if (!hasPermission) return;
  if (!mounted) return;
  
  // Main logic here
}

// ❌ WRONG: Nested if statements
Future<void> saveData() async {
  if (isValid) {
    if (hasPermission) {
      if (mounted) {
        // Main logic here
      }
    }
  }
}

// ✅ CORRECT: Conditional processing with guard clauses
void processItem(String? item) {
  if (item == null) return;
  if (item.isEmpty) return;
  
  // Process item logic
}

// ✅ CORRECT: Widget mounted checks
void updateUI() {
  if (!mounted) return;
  
  setState(() {
    // Update logic
  });
}

// ✅ CORRECT: Permission checks
void performAction() {
  if (!user.hasPermission) return;
  if (user.role != UserRole.admin) return;
  
  // Action logic
}
```

#### **Benefits of Guard Clauses:**
- **Reduced cognitive load**: Less nesting, easier to read
- **Early validation**: Fail fast pattern
- **Cleaner code**: Eliminate deeply nested if statements
- **Better error handling**: Clear validation boundaries
- **Improved maintainability**: Easier to modify and debug

### 📱 **RESPONSIVE UI PATTERNS** 📱

**MANDATORY**: All widgets, screens, and UI components must be responsive and handle text/content overflow gracefully.

#### **Required Responsive Patterns:**

```dart
// ✅ CORRECT: Use Flexible/Expanded for Row/Column children
Row(
  children: [
    Flexible(
      child: Text('Label', overflow: TextOverflow.ellipsis),
    ),
    Expanded(
      child: Text('Long content that might overflow', 
        overflow: TextOverflow.ellipsis),
    ),
  ],
)

// ✅ CORRECT: Wrap long content with overflow handling
Container(
  constraints: BoxConstraints(maxWidth: 200),
  child: Text(
    'Very long text that needs to be truncated',
    overflow: TextOverflow.ellipsis,
    maxLines: 1,
  ),
)

// ✅ CORRECT: Use SingleChildScrollView for potentially long content
SingleChildScrollView(
  child: Column(
    children: [...],
  ),
)

// ❌ WRONG: Fixed width containers without overflow handling
Container(
  width: 200,
  child: Text('This might overflow'), // Will cause RenderFlex errors
)

// ❌ WRONG: Row/Column without Flexible/Expanded
Row(
  children: [
    Text('Label'),
    Text('Very long content'), // Will overflow
  ],
)
```

#### **Responsive UI Requirements:**
- **Always use `Flexible` or `Expanded`** for Row/Column children that contain text
- **Always add `overflow: TextOverflow.ellipsis`** for text that might be long
- **Use `SingleChildScrollView`** for content that might exceed screen height
- **Test on different screen sizes** - mobile, tablet, and desktop
- **Handle edge cases** - very long product names, UUIDs, currency amounts
- **Wrap content appropriately** using `Wrap` widget when needed
- **Use `LayoutBuilder`** for complex responsive layouts
- **Add `maxLines`** parameter for multi-line text control

### 📱 **MOBILE DEVICE COMPATIBILITY** 📱

**MANDATORY**: All mobile UI must be optimized for standard smartphone dimensions and ensure perfect compatibility with common device sizes.

#### **Target Device Specifications:**
- **Reference Device**: 168.6 x 76.6 x 9 mm (6.64 x 3.02 x 0.35 in)
- **Screen Width**: ~76.6mm (~375-390px logical pixels)
- **Usable Height**: ~150mm (~700-800px logical pixels after system UI)

#### **Mobile Design Requirements:**
- **Text Breaking**: NO text overflow or word breaking - use `TextOverflow.ellipsis` and `maxLines`
- **Button Positioning**: Minimum 44x44 logical pixels touch targets, properly spaced
- **Content Spacing**: Minimum 16px margins, 8-24px between sections
- **Scrollable Content**: Always use `SingleChildScrollView` for forms and long lists
- **Responsive Widgets**: All components must adapt to narrow screen widths
- **Safe Area**: Respect device safe areas with `SafeArea` widget
- **Keyboard Handling**: Form fields must handle keyboard overlay properly
- **Portrait Orientation**: Primary design for portrait mode (76.6mm width)
- **Compact Layout**: Efficient use of vertical space, collapsible sections where appropriate

#### **Mobile Testing Checklist:**
- ✅ **No horizontal overflow** on narrow screens (375px width)
- ✅ **Text readability** with proper font sizes (14sp minimum)
- ✅ **Touch targets** meet accessibility guidelines (44dp minimum)
- ✅ **Form usability** with keyboard navigation and proper scrolling
- ✅ **Content priority** - most important information visible without scrolling
- ✅ **Loading states** properly centered and sized for mobile
- ✅ **Error messages** fit within screen bounds without overflow

### 🎨 **MODERN DESIGN STANDARDS** 🎨

**MANDATORY**: All user interface designs must follow modern design principles and provide an elegant, contemporary user experience.

#### **Modern Design Requirements:**
- **Material Design 3**: Use latest Material Design principles with proper color schemes, elevation, and typography
- **Clean Visual Hierarchy**: Clear typography scales, consistent spacing, purposeful use of whitespace
- **Contemporary Color Palette**: Modern color schemes with proper contrast ratios and accessibility compliance
- **Subtle Animations**: Smooth transitions, micro-interactions, and loading states that enhance user experience
- **Card-Based Layout**: Use cards and containers with rounded corners and subtle shadows for content grouping
- **Icon Integration**: Consistent icon usage with proper sizing, spacing, and semantic meaning
- **Progressive Enhancement**: Graceful degradation with accessibility-first approach

#### **Visual Design Patterns:**
- **Section Headers**: Always include icons with titles and descriptive subtitles
- **Form Styling**: Rounded input fields with clear labels and proper focus states
- **Button Design**: Elevated primary buttons, outlined secondary buttons, text buttons for tertiary actions
- **Color Usage**: Primary colors for actions, neutral grays for content, semantic colors for status
- **Typography**: Consistent font weights, proper line heights, optimal character spacing
- **Spacing System**: 8px grid system with 16px base margins and 8-24px between sections

#### **Modern UI Components:**
- **Gradient Backgrounds**: Subtle gradients for emphasis areas and call-to-action sections
- **Elevated Surfaces**: Proper use of shadows and elevation for depth and hierarchy
- **Rounded Corners**: Consistent border radius (8-12px) across all interactive elements
- **Status Indicators**: Visual status chips, progress indicators, and feedback systems
- **Interactive States**: Proper hover, focus, active, and disabled states for all interactive elements

### 📝 **SINGLE-STEP FORM POLICY** 📝

**MANDATORY**: All forms in the application must be single-step forms. Multi-step forms are strictly prohibited.

#### **Form Design Requirements:**
- **Single Scrollable Layout**: All form fields must be presented in one continuous, scrollable interface
- **Logical Grouping**: Group related fields using section headers and visual separators
- **Progressive Disclosure**: Use collapsible sections or conditional fields instead of multiple steps
- **Clear Validation**: Real-time field validation with immediate feedback
- **Streamlined Navigation**: Single Save/Submit button at the bottom, optional Cancel button

#### **Section Organization Patterns:**
- **Visual Sections**: Use section headers with icons, titles, and descriptions
- **Grouped Fields**: Related fields grouped with consistent spacing and visual hierarchy
- **Conditional Display**: Show/hide sections based on user selections (e.g., IMEI fields for IMEI products)
- **Smart Defaults**: Pre-populate fields where possible to reduce user input
- **Clear Labeling**: All required fields marked with asterisks, optional fields clearly indicated

#### **Benefits of Single-Step Forms:**
- **Reduced Friction**: Users see all requirements upfront, no surprises
- **Better Mobile Experience**: Optimal for touch interfaces and small screens
- **Faster Completion**: No navigation between steps, direct path to completion
- **Improved Validation**: Immediate feedback on all fields, better error handling
- **Enhanced Accessibility**: Screen readers and keyboard navigation work seamlessly

### 🌐 **INTERNATIONALIZATION REQUIREMENTS** 🌐

**MANDATORY**: All user-facing text must be internationalized using Flutter's i18n system. Hardcoded strings are strictly prohibited.

#### **i18n Implementation Requirements:**

```dart
// ✅ CORRECT: Using AppLocalizations for all user-facing text
Widget build(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  
  return Text(l10n.productName);
  return AppBar(title: Text(l10n.products));
  return ElevatedButton(
    onPressed: () {},
    child: Text(l10n.save),
  );
}

// ❌ WRONG: Hardcoded strings
Widget build(BuildContext context) {
  return Text('Product Name'); // Never hardcode text
  return AppBar(title: Text('Products')); // Always use i18n
  return ElevatedButton(
    onPressed: () {},
    child: Text('Save'), // Must use AppLocalizations
  );
}
```

#### **Text Localization Rules:**
- **All UI Text**: Buttons, labels, titles, descriptions, error messages
- **Dynamic Content**: Form validation messages, status text, notifications
- **Accessibility**: Screen reader content, tooltips, semantic labels
- **Placeholders**: Input hints, loading messages, empty states
- **Error Handling**: Exception messages, network errors, validation feedback

#### **Implementation Patterns:**

```dart
// Required import for all screens/widgets
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Standard pattern in build method
@override
Widget build(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  
  return Scaffold(
    appBar: AppBar(
      title: Text(l10n.screenTitle),
    ),
    body: Column(
      children: [
        Text(l10n.description),
        ElevatedButton(
          onPressed: () {},
          child: Text(l10n.actionButton),
        ),
      ],
    ),
  );
}

// For form validation
String? validateField(String? value) {
  final l10n = AppLocalizations.of(context)!;
  
  if (value?.isEmpty ?? true) {
    return l10n.fieldRequired;
  }
  return null;
}

// For error handling
void _showError(String message) {
  final l10n = AppLocalizations.of(context)!;
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(l10n.errorPrefix + message),
      backgroundColor: Colors.red,
    ),
  );
}
```

#### **i18n File Organization:**
- **English**: `lib/l10n/app_en.arb` (primary language)
- **Indonesian**: `lib/l10n/app_id.arb` (secondary language)
- **Generated**: `lib/generated/` (auto-generated classes)

#### **Localization Key Naming Convention:**
```json
{
  "screenName_elementType_description": "Localized Text",
  "products_title_main": "Products",
  "products_button_create": "Create Product",
  "products_label_name": "Product Name",
  "products_error_loadFailed": "Failed to load products",
  "common_button_save": "Save",
  "common_button_cancel": "Cancel",
  "validation_field_required": "This field is required"
}
```

#### **Benefits of Proper i18n:**
- **Global Accessibility**: Support for multiple languages and regions
- **Consistent User Experience**: Unified terminology across the application
- **Maintainable Code**: Centralized text management and easy updates
- **Professional Quality**: Industry-standard localization practices
- **Future-Proof**: Easy addition of new languages and markets

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
4. ✅ **Mobile Phase 13**: Product CRUD Forms *(COMPLETED - Multi-step forms with IMEI support and validation)*
5. ✅ **Mobile Phase 14**: Product Detail & IMEI Management *(COMPLETED - Comprehensive product detail with IMEI management)*
6. ✅ **Mobile Phase 15**: Transaction Creation & Item Management *(COMPLETED - Complete transaction workflows)*
7. ✅ **UI/UX Polish & Integration**: Currency system, barcode integration, layout fixes, theme consistency *(COMPLETED)*
8. **Mobile Phase 16**: Thermal Printer Foundation (2-3 days) *(Next Priority)*
9. **Mobile Phase 17**: Receipt & Label Printing (2-3 days)
10. **Mobile Phase 18**: Advanced Settings & User Management (2-3 days)
11. **Mobile Phase 19**: Analytics & Reporting (3-4 days)
12. **Mobile Phase 20**: Testing & Production Deployment (2-3 days)
13. **Web Frontend Development**: Build React UI using the complete API contract (optional)

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