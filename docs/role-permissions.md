# Role Hierarchy & Permissions

## Role Hierarchy

1. **OWNER**: Full system access, can manage multiple stores and all user roles
2. **ADMIN**: Store-scoped CRU access (no delete), can manage STAFF users only
3. **STAFF**: Read-only + product checking across owner's stores
4. **CASHIER**: SALE transactions only, read access to owner's stores

## Printing Permissions (Mobile)

| Role | Barcode Printing | Receipt Printing | Printer Management |
|------|------------------|------------------|--------------------|
| **OWNER** | ✅ Yes | ✅ Yes | ✅ Yes |
| **ADMIN** | ✅ Yes | ✅ Yes | ✅ Yes |
| **STAFF** | ❌ No | ❌ No | ❌ No |
| **CASHIER** | ❌ No | ✅ Yes | ✅ Yes |

### Business Logic

- **Barcode printing** restricted to administrative roles (Owner/Admin) for inventory control
- **Receipt printing** available to transactional roles (Owner/Admin/Cashier) for sales operations
- **Staff** cannot print as they have read-only access with product checking only

## Permission Implementation

### Backend Permissions
- All data is owner-scoped (non-OWNER roles see data from same owner only)
- ADMIN role has store-scoped CRU access (no delete operations)
- Soft delete implemented for audit trail
- Authorization middleware enforces role-based access control

### Mobile Permissions
- Role-based dashboard UI (Owner: 8 sections, Admin: 6 sections, Staff: 4 sections, Cashier: 4 sections)
- Print buttons automatically hidden/shown based on user roles
- WMSAppBar system enforces role-based visibility for actions
- Navigation guards prevent unauthorized access to restricted features

## Security Implementation

- JWT-based authentication with role information embedded
- Authorization service validates permissions on every API request
- Client-side role checks for UI optimization (security enforced server-side)
- IMEI tracking and device verification for additional security