## Brief overview
  - This rule file provides guidelines for working with the Warehouse Management System (WMS) project in alignment with the CLAUDE.md file.
  - It covers communication style, development workflow, coding standards, and project-specific architectural and testing preferences.

## Communication style
  - Be concise and technical in responses, avoiding unnecessary verbosity or conversational fillers.
  - Provide clear explanations of actions taken, especially when modifying or creating code.
  - Avoid asking for more information than necessary; use available tools to gather context before requesting user input.

## Development workflow
  - Follow the phased implementation priority: API controllers and routes first, then business logic and services, followed by testing and documentation, and finally frontend implementation.
  - Use existing Zod schemas for request/response validation.
  - Implement role-based access control strictly as per user roles defined.
  - Ensure all database tables use soft delete functionality.
  - Use the provided development commands for backend and frontend consistently.
  - Maintain modular code organization aligned with the project structure outlined in CLAUDE.md.

## Coding best practices
  - Adhere to DRY (Don't Repeat Yourself) and KISS (Keep It Simple, Stupid) principles.
  - Use clear, descriptive, and consistent naming conventions for variables, functions, and modules.
  - Keep code modular and organized logically by feature and layer (controllers, services, repositories, models).
  - Write comprehensive unit and integration tests covering service methods, API endpoints, role-based access, validation, and security.
  - Use ESLint and TypeScript type checking to maintain code quality.

## Project context
  - The project is a web-based inventory management system with multi-store support and role-based access control.
  - Backend uses Hono.js with Drizzle ORM on SQLite/Turso.
  - Frontend uses React with Shadcn UI, Tailwindcss, and React Query.
  - Key features include barcode scanning, photo proof for sales, product checking, cross-store transfers, and analytics.
  - Role hierarchy: OWNER > ADMIN > STAFF > CASHIER, each with specific permissions and restrictions.

## Other guidelines
  - Enforce business rules such as barcode uniqueness, photo proof requirements, and strict RBAC.
  - Follow the project structure strictly as documented.
  - Prioritize backend infrastructure completion before frontend implementation.
  - Use the OpenAPI/Swagger documentation at the /ui endpoint for API reference.
