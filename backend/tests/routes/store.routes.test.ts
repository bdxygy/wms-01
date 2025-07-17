//@ts-nocheck
import { describe, expect, it } from 'vitest';
import {
  createAuthHeaders,
  createMultiOwnerUsers,
  createTestApp,
  createUserHierarchy,
  createTestStore,
  setupTestDatabase
} from '../utils';

setupTestDatabase();

describe('Store Routes Integration Tests', () => {
  describe('POST /api/v1/stores - Create Store', () => {
    it('should create a new store as OWNER', async () => {
      const { owner } = await createUserHierarchy();
      const app = createTestApp(owner);
      
      const newStoreData = {
        name: 'New Store',
        address: '123 New Street',
        phone: '+1-555-0123',
        email: 'new@store.com',
      };

      const response = await app.request('/api/v1/stores', {
        method: 'POST',
        headers: createAuthHeaders(owner),
        body: JSON.stringify(newStoreData),
      });

      expect(response.status).toBe(201);
      
      const body = await response.json();
      expect(body.success).toBe(true);
      expect(body.message).toBe('Store created successfully');
      expect(body.data).toMatchObject({
        name: newStoreData.name,
        address: newStoreData.address,
        phone: newStoreData.phone,
        email: newStoreData.email,
        ownerId: owner.user.id,
      });
    });

    it('should create a new store as ADMIN', async () => {
      const { admin, owner } = await createUserHierarchy();
      const app = createTestApp(admin);
      
      const newStoreData = {
        name: 'Admin Store',
        address: '321 Admin Street',
      };

      const response = await app.request('/api/v1/stores', {
        method: 'POST',
        headers: createAuthHeaders(admin),
        body: JSON.stringify(newStoreData),
      });

      expect(response.status).toBe(201);
      
      const body = await response.json();
      expect(body.success).toBe(true);
      expect(body.data.ownerId).toBe(owner.user.id); // Should use ADMIN's owner
    });

    it('should prevent STAFF from creating stores', async () => {
      const { staff } = await createUserHierarchy();
      const app = createTestApp(staff);
      
      const newStoreData = {
        name: 'Staff Store',
      };

      const response = await app.request('/api/v1/stores', {
        method: 'POST',
        headers: createAuthHeaders(staff),
        body: JSON.stringify(newStoreData),
      });

      expect(response.status).toBe(403);
      
      const text = await response.text();
      expect(text).toContain('AUTHORIZATION_ERROR');
    });

    it('should prevent CASHIER from creating stores', async () => {
      const { cashier } = await createUserHierarchy();
      const app = createTestApp(cashier);
      
      const newStoreData = {
        name: 'Cashier Store',
      };

      const response = await app.request('/api/v1/stores', {
        method: 'POST',
        headers: createAuthHeaders(cashier),
        body: JSON.stringify(newStoreData),
      });

      expect(response.status).toBe(403);
      
      const text = await response.text();
      expect(text).toContain('AUTHORIZATION_ERROR');
    });

    it('should prevent duplicate store names for same owner', async () => {
      const { owner, testStore } = await createUserHierarchy();
      const app = createTestApp(owner);
      
      const newStoreData = {
        name: testStore.store.name, // Same name as existing store
      };

      const response = await app.request('/api/v1/stores', {
        method: 'POST',
        headers: createAuthHeaders(owner),
        body: JSON.stringify(newStoreData),
      });

      expect(response.status).toBe(409);
      
      const text = await response.text();
      expect(text).toContain('CONFLICT_ERROR');
    });

    it('should validate required fields', async () => {
      const { owner } = await createUserHierarchy();
      const app = createTestApp(owner);
      
      const invalidStoreData = {
        // Missing required 'name' field
        address: '123 Test Street',
      };

      const response = await app.request('/api/v1/stores', {
        method: 'POST',
        headers: createAuthHeaders(owner),
        body: JSON.stringify(invalidStoreData),
      });

      expect(response.status).toBe(400);
    });

    it('should require authentication', async () => {
      const app = createTestApp();
      
      const storeData = {
        name: 'Test Store',
      };

      const response = await app.request('/api/v1/stores', {
        method: 'POST',
        body: JSON.stringify(storeData),
      });

      expect(response.status).toBe(401);
      
      const text = await response.text();
      expect(text).toContain('UNAUTHORIZED');
    });
  });

  describe('GET /api/v1/stores/{id} - Get Store By ID', () => {
    it('should get store by ID as OWNER', async () => {
      const { owner, testStore } = await createUserHierarchy();
      const app = createTestApp(owner);

      const response = await app.request(`/api/v1/stores/${testStore.store.id}`, {
        method: 'GET',
        headers: createAuthHeaders(owner),
      });

      expect(response.status).toBe(200);
      
      const body = await response.json();
      expect(body.success).toBe(true);
      expect(body.data.id).toBe(testStore.store.id);
    });

    it('should get store by ID as ADMIN (same owner)', async () => {
      const { admin, testStore } = await createUserHierarchy();
      const app = createTestApp(admin);

      const response = await app.request(`/api/v1/stores/${testStore.store.id}`, {
        method: 'GET',
        headers: createAuthHeaders(admin),
      });

      expect(response.status).toBe(200);
      
      const body = await response.json();
      expect(body.success).toBe(true);
    });

    it('should prevent access to stores from different owners', async () => {
      const { owner1, store2 } = await createMultiOwnerUsers();
      const app = createTestApp(owner1);

      const response = await app.request(`/api/v1/stores/${store2.store.id}`, {
        method: 'GET',
        headers: createAuthHeaders(owner1),
      });

      expect(response.status).toBe(403);
      
      const text = await response.text();
      expect(text).toContain('AUTHORIZATION_ERROR');
    });

    it('should return 404 for non-existent store', async () => {
      const { owner } = await createUserHierarchy();
      const app = createTestApp(owner);

      const response = await app.request('/api/v1/stores/nonexistent-id', {
        method: 'GET',
        headers: createAuthHeaders(owner),
      });

      expect(response.status).toBe(404);
      
      const text = await response.text();
      expect(text).toContain('Store not found');
    });
  });

  describe('GET /api/v1/stores - Get All Stores', () => {
    it('should get all stores for OWNER (owner-scoped)', async () => {
      const { owner } = await createUserHierarchy();
      const app = createTestApp(owner);

      const response = await app.request('/api/v1/stores', {
        method: 'GET',
        headers: createAuthHeaders(owner),
      });

      expect(response.status).toBe(200);
      
      const body = await response.json();
      expect(body.success).toBe(true);
      expect(body.data).toHaveLength(1); // Only stores under this owner
      expect(body.data[0].ownerId).toBe(owner.user.id);
    });

    it('should get owner-scoped stores for ADMIN', async () => {
      const { admin, owner } = await createUserHierarchy();
      const app = createTestApp(admin);

      const response = await app.request('/api/v1/stores', {
        method: 'GET',
        headers: createAuthHeaders(admin),
      });

      expect(response.status).toBe(200);
      
      const body = await response.json();
      expect(body.success).toBe(true);
      expect(body.data).toHaveLength(1); // Only stores under admin's owner
      expect(body.data[0].ownerId).toBe(owner.user.id);
    });

    it('should filter stores by active status', async () => {
      const { owner } = await createUserHierarchy();
      const app = createTestApp(owner);

      const response = await app.request('/api/v1/stores?isActive=true', {
        method: 'GET',
        headers: createAuthHeaders(owner),
      });

      expect(response.status).toBe(200);
      
      const body = await response.json();
      expect(body.success).toBe(true);
      expect(body.data.every((store: any) => store.isActive)).toBe(true);
    });

    it('should paginate results', async () => {
      const { owner } = await createUserHierarchy();
      const app = createTestApp(owner);

      const response = await app.request('/api/v1/stores?page=1&limit=1', {
        method: 'GET',
        headers: createAuthHeaders(owner),
      });

      expect(response.status).toBe(200);
      
      const body = await response.json();
      expect(body.success).toBe(true);
      expect(body.pagination).toMatchObject({
        page: 1,
        limit: 1,
      });
    });
  });

  describe('PUT /api/v1/stores/{id} - Update Store', () => {
    it('should update store as OWNER', async () => {
      const { owner, testStore } = await createUserHierarchy();
      const app = createTestApp(owner);
      
      const updateData = {
        name: 'Updated Store Name',
        address: 'Updated Address',
      };

      const response = await app.request(`/api/v1/stores/${testStore.store.id}`, {
        method: 'PUT',
        headers: createAuthHeaders(owner),
        body: JSON.stringify(updateData),
      });

      expect(response.status).toBe(200);
      
      const body = await response.json();
      expect(body.success).toBe(true);
      expect(body.message).toBe('Store updated successfully');
      expect(body.data.name).toBe(updateData.name);
    });

    it('should update store as ADMIN (same owner)', async () => {
      const { admin, testStore } = await createUserHierarchy();
      const app = createTestApp(admin);
      
      const updateData = {
        phone: '+1-999-888-7777',
      };

      const response = await app.request(`/api/v1/stores/${testStore.store.id}`, {
        method: 'PUT',
        headers: createAuthHeaders(admin),
        body: JSON.stringify(updateData),
      });

      expect(response.status).toBe(200);
      
      const body = await response.json();
      expect(body.success).toBe(true);
    });

    it('should prevent STAFF from updating stores', async () => {
      const { staff, testStore } = await createUserHierarchy();
      const app = createTestApp(staff);
      
      const updateData = {
        name: 'Staff Updated Store',
      };

      const response = await app.request(`/api/v1/stores/${testStore.store.id}`, {
        method: 'PUT',
        headers: createAuthHeaders(staff),
        body: JSON.stringify(updateData),
      });

      expect(response.status).toBe(403);
      
      const text = await response.text();
      expect(text).toContain('AUTHORIZATION_ERROR');
    });

    it('should prevent updating stores from different owners', async () => {
      const { owner1, store2 } = await createMultiOwnerUsers();
      const app = createTestApp(owner1);
      
      const updateData = {
        name: 'Hacked Store',
      };

      const response = await app.request(`/api/v1/stores/${store2.store.id}`, {
        method: 'PUT',
        headers: createAuthHeaders(owner1),
        body: JSON.stringify(updateData),
      });

      expect(response.status).toBe(403);
      
      const text = await response.text();
      expect(text).toContain('AUTHORIZATION_ERROR');
    });
  });

  describe('DELETE /api/v1/stores/{id} - Delete Store', () => {
    it('should delete store as OWNER', async () => {
      const { owner, testStore } = await createUserHierarchy();
      const app = createTestApp(owner);

      const response = await app.request(`/api/v1/stores/${testStore.store.id}`, {
        method: 'DELETE',
        headers: createAuthHeaders(owner),
      });

      expect(response.status).toBe(200);
      
      const body = await response.json();
      expect(body.success).toBe(true);
      expect(body.message).toBe('Store deleted successfully');
    });

    it('should prevent ADMIN from deleting stores', async () => {
      const { admin, testStore } = await createUserHierarchy();
      const app = createTestApp(admin);

      const response = await app.request(`/api/v1/stores/${testStore.store.id}`, {
        method: 'DELETE',
        headers: createAuthHeaders(admin),
      });

      expect(response.status).toBe(403);
      
      const text = await response.text();
      expect(text).toContain('AUTHORIZATION_ERROR');
    });

    it('should prevent STAFF from deleting stores', async () => {
      const { staff, testStore } = await createUserHierarchy();
      const app = createTestApp(staff);

      const response = await app.request(`/api/v1/stores/${testStore.store.id}`, {
        method: 'DELETE',
        headers: createAuthHeaders(staff),
      });

      expect(response.status).toBe(403);
      
      const text = await response.text();
      expect(text).toContain('AUTHORIZATION_ERROR');
    });
  });

  describe('GET /api/v1/stores/active - Get Active Stores', () => {
    it('should get active stores for OWNER', async () => {
      const { owner } = await createUserHierarchy();
      const app = createTestApp(owner);

      const response = await app.request('/api/v1/stores/active', {
        method: 'GET',
        headers: createAuthHeaders(owner),
      });

      expect(response.status).toBe(200);
      
      const body = await response.json();
      expect(body.success).toBe(true);
      expect(body.message).toBe('Active stores retrieved successfully');
      expect(body.data.every((store: any) => store.isActive)).toBe(true);
    });
  });

  describe('GET /api/v1/stores/user/{userId}/accessible - Get User Accessible Stores', () => {
    it('should get accessible stores for STAFF user', async () => {
      const { staff } = await createUserHierarchy();
      const app = createTestApp(staff);

      const response = await app.request(`/api/v1/stores/user/${staff.user.id}/accessible`, {
        method: 'GET',
        headers: createAuthHeaders(staff),
      });

      expect(response.status).toBe(200);
      
      const body = await response.json();
      expect(body.success).toBe(true);
      expect(body.message).toBe('User accessible stores retrieved successfully');
      expect(Array.isArray(body.data)).toBe(true);
    });

    it('should prevent access to other user accessible stores', async () => {
      const { staff1, staff2 } = await createMultiOwnerUsers();
      const app = createTestApp(staff1);

      const response = await app.request(`/api/v1/stores/user/${staff2.user.id}/accessible`, {
        method: 'GET',
        headers: createAuthHeaders(staff1),
      });

      expect(response.status).toBe(403);
      
      const text = await response.text();
      expect(text).toContain('AUTHORIZATION_ERROR');
    });
  });

  describe('GET /api/v1/stores/owner/{ownerId} - Get Stores By Owner', () => {
    it('should get stores by owner for OWNER', async () => {
      const { owner } = await createUserHierarchy();
      const app = createTestApp(owner);

      const response = await app.request(`/api/v1/stores/owner/${owner.user.id}`, {
        method: 'GET',
        headers: createAuthHeaders(owner),
      });

      expect(response.status).toBe(200);
      
      const body = await response.json();
      expect(body.success).toBe(true);
      expect(body.message).toBe('Stores retrieved successfully');
      expect(body.data.every((store: any) => store.ownerId === owner.user.id)).toBe(true);
    });

    it('should prevent access to stores from different owners', async () => {
      const { admin1, owner2 } = await createMultiOwnerUsers();
      const app = createTestApp(admin1);

      const response = await app.request(`/api/v1/stores/owner/${owner2.user.id}`, {
        method: 'GET',
        headers: createAuthHeaders(admin1),
      });

      expect(response.status).toBe(403);
      
      const text = await response.text();
      expect(text).toContain('AUTHORIZATION_ERROR');
    });
  });
});