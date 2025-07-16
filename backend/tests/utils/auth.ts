import { db } from '@/config/database';
import { users } from '@/models/users';
import { User } from '@/models/users';
import { createOwnerFixture, createAdminFixture, createStaffFixture, createCashierFixture } from './fixtures';
import { OpenAPIHono } from '@hono/zod-openapi';
import { userRoutes } from '@/routes/user.routes';

/**
 * Authentication test helpers for integration tests
 */

export interface TestUser {
  user: User;
  token: string; // Mock token for testing
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
export async function createTestAdmin(ownerId: string, storeId: string, overrides: any = {}): Promise<TestUser> {
  const fixture = createAdminFixture(ownerId, storeId, overrides);
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
export function createTestApp(authenticatedUser?: TestUser) {
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
  
  return app;
}

/**
 * Helper to create multiple test users with hierarchy
 */
export async function createUserHierarchy() {
  const owner = await createTestOwner();
  const admin = await createTestAdmin(owner.user.id, 'store-1');
  const staff = await createTestStaff(owner.user.id);
  const cashier = await createTestCashier(owner.user.id);

  return {
    owner,
    admin,
    staff,
    cashier,
  };
}

/**
 * Helper to create users from different owners for testing access control
 */
export async function createMultiOwnerUsers() {
  const owner1 = await createTestOwner();
  const owner2 = await createTestOwner();
  
  const admin1 = await createTestAdmin(owner1.user.id, 'store-1');
  const admin2 = await createTestAdmin(owner2.user.id, 'store-2');
  
  const staff1 = await createTestStaff(owner1.user.id);
  const staff2 = await createTestStaff(owner2.user.id);

  return {
    owner1,
    owner2,
    admin1,
    admin2,
    staff1,
    staff2,
  };
}