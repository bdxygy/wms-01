import { db } from '@/config/database';
import { users } from '@/models/users';
import { stores } from '@/models/stores';
import { User } from '@/models/users';
import { Store } from '@/models/stores';
import { createOwnerFixture, createAdminFixture, createStaffFixture, createCashierFixture, createStoreFixture } from './fixtures';
import { OpenAPIHono } from '@hono/zod-openapi';
import { userRoutes } from '@/routes/user.routes';
import { storeRoutes } from '@/routes/store.routes';

/**
 * Authentication test helpers for integration tests
 */

export interface TestUser {
  user: User;
  token: string; // Mock token for testing
}

export interface TestStore {
  store: Store;
}

/**
 * Create a test user in the database and return user with mock token
 */
export async function createTestUser(fixture: any): Promise<TestUser> {
  const [user] = await db.insert(users).values(fixture).returning();
  return {
    user,
    token: `mock-token-${user.id}`,
  };
}

/**
 * Create a test owner user
 */
export async function createTestOwner(overrides: any = {}): Promise<TestUser> {
  const fixture = createOwnerFixture(overrides);
  return await createTestUser(fixture);
}

/**
 * Create a test admin user
 */
export async function createTestAdmin(ownerId: string, overrides: any = {}): Promise<TestUser> {
  const fixture = createAdminFixture(ownerId, overrides);
  return await createTestUser(fixture);
}

/**
 * Create a test staff user
 */
export async function createTestStaff(ownerId: string, overrides: any = {}): Promise<TestUser> {
  const fixture = createStaffFixture(ownerId, overrides);
  return await createTestUser(fixture);
}

/**
 * Create a test cashier user
 */
export async function createTestCashier(ownerId: string, overrides: any = {}): Promise<TestUser> {
  const fixture = createCashierFixture(ownerId, overrides);
  return await createTestUser(fixture);
}

/**
 * Create a test store
 */
export async function createTestStore(ownerId: string, overrides: any = {}): Promise<TestStore> {
  const fixture = createStoreFixture(ownerId, overrides);
  const [store] = await db.insert(stores).values(fixture).returning();
  return {
    store,
  };
}

/**
 * Create request headers with mock authorization
 */
export function createAuthHeaders(testUser: TestUser) {
  return {
    Authorization: `Bearer ${testUser.token}`,
    'Content-Type': 'application/json',
  };
}

/**
 * Create a test app with mocked authentication middleware
 */
export async function createTestApp(authenticatedUser?: TestUser) {
  const app = new OpenAPIHono();
  
  // Mock authentication middleware
  app.use('*', async (c: any, next) => {
    if (authenticatedUser) {
      c.set('user', authenticatedUser.user);
    }
    await next();
  });
  
  // Mount user routes
  app.route('/api/v1/users', userRoutes);
  app.route('/api/v1/stores', storeRoutes);
  
  // Mount auth routes
  const { authRoutes } = await import('@/routes/auth.routes');
  app.route('/api/v1/auth', authRoutes);
  
  // Mount category routes
  const { categoryRoutes } = await import('@/routes/category.routes');
  app.route('/api/v1/categories', categoryRoutes);
  
  // Mount product routes
  const { productRoutes } = await import('@/routes/product.routes');
  app.route('/api/v1/products', productRoutes);
  
  return app;
}

/**
 * Helper to create multiple test users with hierarchy and stores
 */
export async function createUserHierarchy() {
  const owner = await createTestOwner();
  const testStore = await createTestStore(owner.user.id);
  const admin = await createTestAdmin(owner.user.id);
  const staff = await createTestStaff(owner.user.id);
  const cashier = await createTestCashier(owner.user.id);

  return {
    owner,
    admin,
    staff,
    cashier,
    store: testStore,
  };
}

/**
 * Helper to create users from different owners for testing access control
 */
export async function createMultiOwnerUsers() {
  const owner1 = await createTestOwner();
  const owner2 = await createTestOwner();
  
  const store1 = await createTestStore(owner1.user.id);
  const store2 = await createTestStore(owner2.user.id);
  
  const admin1 = await createTestAdmin(owner1.user.id);
  const admin2 = await createTestAdmin(owner2.user.id);
  
  const staff1 = await createTestStaff(owner1.user.id);
  const staff2 = await createTestStaff(owner2.user.id);

  return {
    owner1,
    owner2,
    admin1,
    admin2,
    staff1,
    staff2,
    store1,
    store2,
  };
}