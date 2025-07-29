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

## Documentation References

For detailed information, see the following documentation files:

- **[Role Hierarchy & Permissions](docs/role-permissions.md)** - Complete role-based access control system
- **[Backend API Reference](docs/backend-api-reference.md)** - 40+ production-ready API endpoints
- **[Mobile Development Phases](docs/mobile-development-phases.md)** - 18+ completed phases, production ready
- **[Development Guidelines](docs/development-guidelines.md)** - Coding standards, patterns, and requirements

## 📱 **Mobile Application Status**

**Current Status**: Production Ready (Phase 18++ Complete) | **Next**: Phase 19 - Thermal Printer Integration

*See [Mobile Development Phases](docs/mobile-development-phases.md) for complete phase details and architecture information.*

### Latest Achievements ✅
- **Role-Based Transaction Tabs**: Implemented transaction type filtering (CASHIER: SALE only, OWNER/ADMIN: all types)
- **Product isMustCheck Field**: Added boolean field across backend/mobile for product verification requirements
- **CASHIER Role Transaction Authorization**: Fixed role-based transaction permissions (CASHIER: SALE only, ADMIN/OWNER: all types)
- **Product Access Control**: Implemented owner-scoped product access for all roles including CASHIER
- **Schema Compatibility**: 100% backend-mobile schema alignment for all product operations
- **Zero Blocking Errors**: Flutter analyze score improved 43% (158→90 issues)
- **Complete i18n System**: 285+ translation keys, all hardcoded strings eliminated
- **Global AppBar System**: Unified WMSAppBar with role-based print permissions
- **Production Ready**: All business workflows functional, clean codebase

### Key Mobile Features ✅
- **18+ Development Phases Complete** - comprehensive mobile application
- **25+ Screens** - full business application coverage
- **Role-Based Dashboards** - Owner/Admin/Staff/Cashier specific interfaces  
- **Print System Integration** - barcode/receipt printing with role permissions
- **Complete CRUD Operations** - products, transactions, stores, users with full authorization
- **Advanced Scanning** - barcode and IMEI scanning with product search
- **Product Verification System** - isMustCheck field for quality control workflows
- **Modern UI/UX** - Material Design 3, responsive layouts, smooth animations

*See [Development Guidelines](docs/development-guidelines.md) for complete coding standards, patterns, and requirements.*

## Quick Reference

### Essential Standards
- **🤖 AGENTS MANDATORY**: Always use specialized agents for ALL tasks - use Task tool with appropriate subagent_type
- **🛡️ GUARD CLAUSES MANDATORY**: Always use guard clauses instead of nested if statements
- **🎨 MODERN DESIGN MANDATORY**: All UI must follow modern design principles  
- **📝 SINGLE-STEP FORMS ONLY**: Multi-step forms are strictly prohibited
- **🌐 INTERNATIONALIZATION MANDATORY**: All user-facing text must use i18n
- **📱 WMSAppBar MANDATORY**: All screens must use WMSAppBar component

### Critical Protections
- **🚫 NEVER MODIFY** database model files without explicit user request
- **✅ ALWAYS use ResponseUtils** from `src/utils/responses.ts`
- **✅ ALWAYS use Zod schemas** for validation
- **🔐 ROLE-BASED AUTHORIZATION**: All endpoints enforce proper role permissions and owner scoping

## 📊 **Next Steps**

*See [Mobile Development Phases](docs/mobile-development-phases.md) for complete development roadmap.*

### Recent Completions ✅
- **Role-Based Transaction Tabs**: UI now filters transaction types by user role with proper security validation
- **Product isMustCheck Enhancement**: Added verification field across full stack with UI toggle
- **Transaction Authorization Fix**: Implemented proper CASHIER role restrictions (SALE only)
- **Product Access Resolution**: Fixed CASHIER product viewing with owner scoping

### Immediate Priorities
11. **Mobile Phase 19**: Thermal Printer Integration (2-3 days) *(Next Priority)*
12. **Mobile Phase 20**: Analytics, Reporting & Production Deployment (3-4 days)
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