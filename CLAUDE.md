# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Warehouse Management System (WMS)** - A complete inventory management system for tracking goods across multiple stores with role-based access control, featuring web and mobile applications.

### Tech Stack

- **Backend**: Hono, Node.js, Zod, Drizzle, SQLite Turso ✅ **PRODUCTION READY**
- **Database**: SQLite with Drizzle ORM ✅ **PRODUCTION READY**  
- **Authentication**: JWT-based with role-based access control ✅ **PRODUCTION READY**
- **Frontend Web**: React, Shadcn, Zod, React Query, Tailwindcss, Rsbuild 📋 **PLANNED**
- **Mobile**: Flutter (cross-platform mobile development) ✅ **PHASE 18++ COMPLETE - PRODUCTION READY**

### Architecture

- **Service layer** for business logic
- **Soft delete** for audit trail
- **Owner-scoped data access** for non-owner roles
- **Hono best practice pattern** - no controller layer, routes use service layer directly

## 📱 **Mobile Application Status**

**Current Status**: Production Ready (Phase 18++ Complete) | **Next**: Phase 19 - Thermal Printer Integration

*See [Mobile Development Phases](docs/mobile-development-phases.md) for complete phase details and architecture information.*

### Latest Achievements ✅
- **Scanner UX Enhancement**: Replaced all error dialogs and exceptions with seamless SnackBar notifications, ensuring smooth user experience without app hangs
- **Scanner System Overhaul**: Migrated all scanner functionality to use ScannerLauncher, fixed ADMIN user scanner hangs, and resolved 404 error handling issues
- **Product Schema Integration**: Updated mobile Product model to handle nullable purchasePrice for role-based access control (STAFF/CASHIER see null purchasePrice)
- **Error Handling Standards**: Established critical error handling rules to prevent app hangs caused by unnecessary exception throwing after callbacks
- **IMEI Per-Store Uniqueness**: Enhanced business logic to allow same IMEI across different stores while preventing duplicates within same store
- **Integration Test Infrastructure**: Created comprehensive product creation route tests with proper authentication and database setup
- **Flutter Code Quality Optimization**: Massive code quality improvement - Flutter analyze issues reduced from 149 to 12 (92% improvement)
- **Critical Error Resolution**: Fixed all undefined_getter errors for localization keys, resolved null safety warnings
- **Localization Enhancement**: Added 41+ missing translation keys for photo management and common UI elements
- **Code Cleanup**: Removed unused methods, fields, and dead code across multiple screens and widgets
- **Role-Based Transaction Tabs**: Implemented transaction type filtering (CASHIER: SALE only, OWNER/ADMIN: all types)
- **Product isMustCheck Field**: Added boolean field across backend/mobile for product verification requirements
- **CASHIER Role Transaction Authorization**: Fixed role-based transaction permissions (CASHIER: SALE only, ADMIN/OWNER: all types)
- **Product Access Control**: Implemented owner-scoped product access for all roles including CASHIER
- **Schema Compatibility**: 100% backend-mobile schema alignment for all product operations
- **Complete i18n System**: 285+ translation keys, all hardcoded strings eliminated
- **Global AppBar System**: Unified WMSAppBar with role-based print permissions
- **Production Ready**: All business workflows functional, exceptionally clean codebase

### Key Mobile Features ✅
- **18+ Development Phases Complete** - comprehensive mobile application
- **25+ Screens** - full business application coverage
- **Role-Based Dashboards** - Owner/Admin/Staff/Cashier specific interfaces  
- **Print System Integration** - barcode/receipt printing with role permissions
- **Complete CRUD Operations** - products, transactions, stores, users with full authorization
- **Advanced Scanning** - barcode and IMEI scanning with product search
- **Product Verification System** - isMustCheck field for quality control workflows
- **Modern UI/UX** - Material Design 3, responsive layouts, smooth animations

## 🤖 **Available Agents**

The following specialized agents are available for different aspects of the WMS project:

### **Backend Development (kang_BE)**
**Use for**: Expert-level backend development guidance, architecture decisions, or technical problem-solving for server-side systems.

**Examples**:
- "I'm seeing performance issues with our Hono API endpoints under load, how should I optimize them?"
- "Should we implement caching for our product inventory endpoints, and if so, what's the best approach with our current SQLite/Drizzle setup?"
- "Review this JWT authentication middleware - is the role-based access control properly implemented for owner-scoped data?"
- "We're planning to scale beyond single-store operations, how should we refactor our service layer for multi-tenant architecture?"
- "Debug this transaction service - the soft delete audit trail isn't capturing all the required fields"

### **Frontend Web Development (kang_FE_WEB)**
**Use for**: Expert guidance on frontend web development topics including modern frameworks (React, Angular, Vue, Svelte, Next.js, Remix, Astro), state management, component architecture, performance optimization, debugging strategies, or framework comparisons.

**Examples**:
- "Should I use React Query or Zustand for state management in my Next.js app?"
- "I'm seeing performance issues with my React component re-rendering"
- "Help me choose between Vue and React for my new project"

### **Flutter Mobile Development (kang_FE_Flutter)**
**Use for**: Expert-level Flutter development and UX design guidance including production-ready Flutter/Dart code, debugging complex Flutter issues, optimizing app architecture, implementing UI/UX best practices, aligning with Material/Cupertino design standards, or evaluating app flows for usability and consistency.

**Examples**:
- "After writing a new Flutter widget, review the code and suggest UX improvements"
- "When facing performance issues in a Flutter app, analyze and optimize the implementation"
- "When designing a new user flow, validate the UX patterns and provide Flutter-specific implementation guidance"

### **Product & Project Management (kang_PM2PD)**
**Use for**: Expert-level guidance across product management, product design, and project management disciplines. Strategic direction, tactical advice, and practical frameworks for building and delivering successful products.

**Examples**:
- "After defining a new product feature, validate the product strategy, design the user experience, and plan the development sprints"
- "When facing stakeholder misalignment, facilitate alignment through proven frameworks and communication strategies"
- "When planning a major product redesign, establish the product vision, create the design system, and structure the project timeline"

### **System Analysis (kang_System_Analyst)**
**Use for**: Expert-level system analysis for technical or business systems including analyzing existing systems, designing new architectures, improving system efficiency, or validating requirements.

**Examples**:
- "After writing a new service, analyze its architecture and identify potential bottlenecks"
- "When planning a new feature, break it down into system components and workflows"
- "When stakeholders provide vague requirements, gather and validate technical specifications"

### **General Purpose (general-purpose)**
**Use for**: General-purpose agent for researching complex questions, searching for code, and executing multi-step tasks. Use when you need extensive research or aren't confident you'll find the right match quickly.

## 📚 **Documentation References**

For detailed information, see the following documentation files:

- **[Role Hierarchy & Permissions](docs/role-permissions.md)** - Complete role-based access control system
- **[Backend API Reference](docs/backend-api-reference.md)** - 40+ production-ready API endpoints
- **[Mobile Development Phases](docs/mobile-development-phases.md)** - 18+ completed phases, production ready
- **[Development Guidelines](docs/development-guidelines.md)** - Coding standards, patterns, and requirements

## 🎯 **Agent Usage Guidelines**

### **When to Use Each Agent**

**Always use specialized agents** - never use generic prompts. Use the specific agent that matches your task:

1. **Backend code/architecture** → `kang_BE`
2. **Flutter mobile development** → `kang_FE_Flutter`
3. **Frontend web development** → `kang_FE_WEB`
4. **Product strategy/design** → `kang_PM2PD`
5. **System analysis/requirements** → `kang_System_Analyst`
6. **Complex research/search tasks** → `general-purpose`

### **Agent Invocation Format**
```
Use Task tool with subagent_type parameter:
- subagent_type='kang_BE' for backend
- subagent_type='kang_FE_Flutter' for Flutter
- subagent_type='kang_FE_WEB' for web frontend
- subagent_type='kang_PM2PD' for product management
- subagent_type='kang_System_Analyst' for system analysis
- subagent_type='general-purpose' for research
```

### **Example Usage**
```
Task(description="Optimize transaction service", prompt="Analyze transaction service performance...", subagent_type='kang_BE')
```

## 🔐 **Critical Protections**

- **🚫 NEVER MODIFY** database model files without explicit user request
- **✅ ALWAYS use ResponseUtils** from `src/utils/responses.ts`
- **✅ ALWAYS use Zod schemas** for validation
- **🔐 ROLE-BASED AUTHORIZATION**: All endpoints enforce proper role permissions and owner scoping

## ⚠️ **Critical Error Handling Rules**

### **Exception/Error Throwing Guidelines**

**🚫 NEVER throw exceptions after calling callback functions** - This can cause app hangs and poor UX:

```dart
// ❌ WRONG - Don't do this
} catch (e) {
  onProductNotFound(barcode);
  throw Exception('Product not found'); // This causes app hang!
}

// ✅ CORRECT - Do this instead
} catch (e) {
  onProductNotFound(barcode);
  // Let callback handle UI response, don't throw
}
```

**✅ ONLY throw exceptions in these scenarios:**
1. **Input validation failures** (invalid format, missing required data)
2. **System/Infrastructure errors** (network, database connection issues)
3. **Within try-catch blocks** where the exception will be properly handled
4. **When no callback exists** to handle the error scenario

**📋 Exception Best Practices:**
- **Always use meaningful error messages** that help debugging
- **Never throw after UI callbacks** (onSuccess, onError, onNotFound, etc.)
- **Let callback functions handle user-facing error messages**
- **Use proper error propagation** in service layers
- **Test error scenarios** to ensure they don't cause hangs or crashes

## 🚀 **Next Development Priorities**

### Recent Completions ✅
- **IMEI Per-Store Uniqueness Implementation**: Multi-store IMEI business logic allowing same IMEI across different stores
- **Backend Service Layer Enhancement**: Updated `ImeiService.addImei`, `ImeiService.createProductWithImeis`, and `ProductService.updateProductWithImeis`
- **Integration Testing Framework**: Comprehensive test suite for product creation routes with authentication flow
- **Flutter Code Quality Optimization**: Resolved 149→12 Flutter analyze issues (92% improvement, all critical errors fixed)
- **Photo Management Localization**: Added complete i18n support for photo upload, management, and viewer features
- **Code Quality Enhancement**: Eliminated unused code, fixed null safety warnings, optimized performance
- **Role-Based Transaction Tabs**: UI now filters transaction types by user role with proper security validation
- **Product isMustCheck Enhancement**: Added verification field across full stack with UI toggle
- **Transaction Authorization Fix**: Implemented proper CASHIER role restrictions (SALE only)
- **Product Access Resolution**: Fixed CASHIER product viewing with owner scoping
- **Transaction Type Receipts**: Enhanced receipts for TRANSFER, TRADE, and SALE types

### Immediate Priorities
12. **Mobile Phase 19**: Thermal Printer Integration (2-3 days) *(Next Priority)*
13. **Mobile Phase 20**: Analytics, Reporting & Production Deployment (3-4 days)
14. **Web Frontend Development**: Build React UI using the complete API contract (optional)

## 📊 **Agent Memory Integration**

All agents are now configured to understand:
- **Project architecture** and tech stack
- **Current development status** (Phase 18++ mobile complete)
- **Role-based access control** system
- **Transaction type handling** (TRANSFER, TRADE, SALE)
- **QR code integration** in receipts
- **IMEI per-store uniqueness** business logic (same IMEI allowed across different stores, unique within same store)
- **Integration testing infrastructure** with comprehensive product creation test coverage
- **Production-ready status** of mobile application

This memory ensures all agents provide contextually relevant guidance aligned with the WMS project goals and current state.