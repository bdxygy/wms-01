## Brief overview
  - This rule file ensures consistent adherence to the CLAUDE.md project documentation and established code patterns when working on the Warehouse Management System (WMS) project.
  - It enforces reference to CLAUDE.md before any development work and maintains consistency with existing codebase patterns.

## Development workflow
  - Always read and reference CLAUDE.md file before starting any development work to understand current project status, architecture, and guidelines
  - Follow the phased implementation priority: Backend API controllers/routes first, then business logic/services, followed by testing/documentation, and finally frontend implementation
  - Use existing code patterns and architectural decisions documented in CLAUDE.md rather than introducing new patterns
  - Maintain the service layer architecture with no controller layer - routes use service layer directly following Hono best practices
  - Implement owner-scoped data access for all non-owner roles and soft delete functionality for audit trail

## Coding best practices
  - Mandatory use of guard clauses instead of nested if statements for better readability and early returns
  - Follow DRY (Don't Repeat Yourself) and KISS (Keep It Simple, Stupid) principles consistently
  - Use Zod schemas for all validation and maintain type safety throughout the codebase
  - Always use ResponseUtils from `src/utils/responses.ts` for API responses in BaseResponse<T> or PaginatedResponse<T> format
  - Use randomUUID() for database primary keys and nanoid() exclusively for barcode generation
  - Never expose secrets/keys and validate all inputs using established validation patterns

## Project context
  - Backend is production-ready with 40+ API endpoints using Hono, Drizzle ORM, SQLite/Turso with JWT authentication and RBAC
  - Mobile app is 85% complete (Phase 15+/20) with Flutter, ready for production with full business workflows implemented
  - Role hierarchy: OWNER (full access) > ADMIN (store-scoped CRU) > STAFF (read-only + product checking) > CASHIER (SALE transactions only)
  - Business rules: unique barcodes within owner scope, SALE transactions require photo proof, all data is owner-scoped for non-OWNER roles

## Critical protections
  - Never modify database model files without explicit user request: users.ts, stores.ts, categories.ts, products.ts, transactions.ts, product_checks.ts, product_imeis.ts
  - Maintain existing API endpoint patterns and response formats established in the 40+ implemented endpoints
  - Preserve the established authentication flow, role-based access control, and security middleware patterns
  - Follow the documented tech stack without introducing alternative technologies unless explicitly requested

## Other guidelines
  - Use the documented development commands for backend (pnpm run dev/test/db:migrate/lint) and mobile (flutter run/analyze/test)
  - Reference the current mobile architecture with 75+ core files and 30+ feature screens when adding new functionality
  - Maintain the established internationalization system with English/Indonesian translations
  - Follow the guard clause patterns documented in CLAUDE.md for all new code implementations
