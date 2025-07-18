import { User, NewUser, Role } from '@/models/users';
import { Store, NewStore } from '@/models/stores';
import { Category, NewCategory } from '@/models/categories';
import { Product, NewProduct } from '@/models/products';
import { Transaction, NewTransaction } from '@/models/transactions';
import { ProductCheck, NewProductCheck } from '@/models/product_checks';
import { randomUUID } from 'crypto';
import bcrypt from 'bcryptjs';

/**
 * Generate test user data
 */
export function createUserFixture(overrides: Partial<NewUser> = {}): NewUser {
  const id = randomUUID();
  // Hash the default password synchronously for tests
  const hashedPassword = bcrypt.hashSync('password123', 12);
  return {
    id,
    username: `test_user_${id}`,
    passwordHash: hashedPassword,
    name: `Test User ${id}`,
    role: 'STAFF' as Role,
    ownerId: null,
    createdAt: new Date(),
    updatedAt: new Date(),
    deletedAt: null,
    ...overrides,
  };
}

/**
 * Generate test owner user data
 */
export function createOwnerFixture(overrides: Partial<NewUser> = {}): NewUser {
  return createUserFixture({
    role: 'OWNER' as Role,
    ...overrides,
  });
}

/**
 * Generate test admin user data
 */
export function createAdminFixture(ownerId: string, overrides: Partial<NewUser> = {}): NewUser {
  return createUserFixture({
    role: 'ADMIN' as Role,
    ownerId,
    ...overrides,
  });
}

/**
 * Generate test staff user data
 */
export function createStaffFixture(ownerId: string, overrides: Partial<NewUser> = {}): NewUser {
  return createUserFixture({
    role: 'STAFF' as Role,
    ownerId,
    ...overrides,
  });
}

/**
 * Generate test cashier user data
 */
export function createCashierFixture(ownerId: string, overrides: Partial<NewUser> = {}): NewUser {
  return createUserFixture({
    role: 'CASHIER' as Role,
    ownerId,
    ...overrides,
  });
}

/**
 * Generate test store data
 */
export function createStoreFixture(ownerId: string, overrides: Partial<NewStore> = {}): NewStore {
  const id = randomUUID();
  return {
    id,
    ownerId,
    name: `Test Store ${id}`,
    code: `STORE-${id.slice(0, 8).toUpperCase()}`,
    type: 'RETAIL',
    addressLine1: `123 Test St, Suite ${id.slice(0, 3)}`,
    addressLine2: null,
    city: 'Test City',
    province: 'Test Province',
    postalCode: '12345',
    country: 'Test Country',
    phoneNumber: `+1234567890`,
    email: `store-${id}@example.com`,
    isActive: true,
    openTime: null,
    closeTime: null,
    timezone: 'Asia/Jakarta',
    mapLocation: null,
    createdBy: ownerId,
    createdAt: new Date(),
    updatedAt: new Date(),
    deletedAt: null,
    ...overrides,
  };
}

/**
 * Generate test category data
 */
export function createCategoryFixture(createdBy: string, overrides: Partial<NewCategory> = {}): NewCategory {
  const id = randomUUID();
  return {
    id,
    createdBy,
    name: `Test Category ${id}`,
    description: `Description for test category ${id}`,
    createdAt: new Date(),
    updatedAt: new Date(),
    deletedAt: null,
    ...overrides,
  };
}

/**
 * Generate test product data
 */
export function createProductFixture(createdBy: string, storeId: string, categoryId?: string, overrides: Partial<NewProduct> = {}): NewProduct {
  const id = randomUUID();
  return {
    id,
    createdBy,
    storeId,
    name: `Test Product ${id}`,
    categoryId: categoryId || null,
    sku: `SKU-${id.slice(0, 8).toUpperCase()}`,
    isImei: false,
    barcode: `TEST${id}`,
    quantity: 100,
    purchasePrice: 19.99,
    salePrice: 29.99,
    createdAt: new Date(),
    updatedAt: new Date(),
    deletedAt: null,
    ...overrides,
  };
}

/**
 * Generate test transaction data
 */
export function createTransactionFixture(
  createdBy: string,
  type: 'SALE' | 'TRANSFER' = 'SALE',
  overrides: Partial<NewTransaction> = {}
): NewTransaction {
  const id = randomUUID();
  return {
    id,
    type,
    createdBy,
    approvedBy: null,
    fromStoreId: null,
    toStoreId: null,
    photoProofUrl: 'https://example.com/photo.jpg',
    transferProofUrl: null,
    to: null,
    customerPhone: null,
    amount: 29.99,
    isFinished: false,
    createdAt: new Date(),
    ...overrides,
  };
}

/**
 * Generate test product check data
 */
export function createProductCheckFixture(
  productId: string,
  checkedBy: string,
  storeId: string,
  overrides: Partial<NewProductCheck> = {}
): NewProductCheck {
  const id = randomUUID();
  return {
    id,
    productId,
    checkedBy,
    storeId,
    status: 'PENDING',
    note: `Test product check ${id}`,
    checkedAt: new Date(),
    ...overrides,
  };
}
