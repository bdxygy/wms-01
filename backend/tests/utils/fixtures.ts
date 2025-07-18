import { User, NewUser, Role } from '@/models/users';
import { Store, NewStore } from '@/models/stores';
import { Category, NewCategory } from '@/models/categories';
import { Product, NewProduct } from '@/models/products';
import { Transaction, NewTransaction } from '@/models/transactions';
import { ProductCheck, NewProductCheck } from '@/models/product_checks';
import { nanoid } from 'nanoid';
import bcrypt from 'bcryptjs';

/**
 * Generate test user data
 */
export function createUserFixture(overrides: Partial<NewUser> = {}): NewUser {
  const id = nanoid();
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
  const id = nanoid();
  return {
    id,
    name: `Test Store ${id}`,
    address: `123 Test St, Suite ${id.slice(0, 3)}`,
    phone: `+1234567890`,
    email: `store-${id}@example.com`,
    ownerId,
    isActive: true,
    createdAt: new Date(),
    updatedAt: new Date(),
    deletedAt: null,
    ...overrides,
  };
}

/**
 * Generate test category data
 */
export function createCategoryFixture(ownerId: string, overrides: Partial<NewCategory> = {}): NewCategory {
  const id = nanoid();
  return {
    id,
    name: `Test Category ${id}`,
    description: `Description for test category ${id}`,
    ownerId,
    createdAt: new Date(),
    updatedAt: new Date(),
    deletedAt: null,
    ...overrides,
  };
}

/**
 * Generate test product data
 */
export function createProductFixture(ownerId: string, storeId: string, categoryId: string, overrides: Partial<NewProduct> = {}): NewProduct {
  const id = nanoid();
  return {
    id,
    barcode: `TEST${id}`,
    name: `Test Product ${id}`,
    description: `Description for test product ${id}`,
    price: 29.99,
    cost: 19.99,
    quantity: 100,
    minStock: 0,
    maxStock: null,
    status: 'ACTIVE',
    storeId,
    categoryId,
    ownerId,
    imageUrl: null,
    isActive: true,
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
  userId: string,
  productId: string,
  ownerId: string,
  overrides: Partial<NewTransaction> = {}
): NewTransaction {
  const id = nanoid();
  return {
    id,
    type: 'SALE',
    status: 'PENDING',
    quantity: 1,
    price: 29.99,
    total: 29.99,
    notes: `Test transaction ${id}`,
    photoProof: 'https://example.com/photo.jpg',
    productId,
    fromStoreId: null,
    toStoreId: null,
    userId,
    ownerId,
    createdAt: new Date(),
    updatedAt: new Date(),
    deletedAt: null,
    ...overrides,
  };
}

/**
 * Generate test product check data
 */
export function createProductCheckFixture(
  productId: string,
  userId: string,
  storeId: string,
  ownerId: string,
  overrides: Partial<NewProductCheck> = {}
): NewProductCheck {
  const id = nanoid();
  return {
    id,
    status: 'PENDING',
    expectedQuantity: 100,
    actualQuantity: null,
    notes: `Test product check ${id}`,
    productId,
    storeId,
    userId,
    ownerId,
    createdAt: new Date(),
    updatedAt: new Date(),
    deletedAt: null,
    ...overrides,
  };
}
