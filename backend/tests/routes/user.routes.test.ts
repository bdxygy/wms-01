//@ts-nocheck
import { describe, expect, it } from 'vitest';
import {
  createAuthHeaders,
  createMultiOwnerUsers,
  createTestApp,
  createUserHierarchy,
  setupTestDatabase
} from '../utils';

setupTestDatabase();

describe('User Routes Integration Tests', () => {
  describe('POST /api/v1/users - Create User', () => {
    it('should create a new user as OWNER', async () => {
      const { owner } = await createUserHierarchy();
      const app = createTestApp(owner);
      
      const newUserData = {
        email: 'newuser@example.com',
        password: 'password123',
        name: 'New User',
        role: 'STAFF',
      };

      const response = await app.request('/api/v1/users', {
        method: 'POST',
        headers: createAuthHeaders(owner),
        body: JSON.stringify(newUserData),
      });

      expect(response.status).toBe(201);
      
      const body = await response.json();
      expect(body.success).toBe(true);
      expect(body.message).toBe('User created successfully');
      expect(body.data).toMatchObject({
        email: newUserData.email,
        name: newUserData.name,
        role: newUserData.role,
        ownerId: owner.user.id,
      });
      expect(body.data.password).toBeUndefined();
    });

    it('should create a new user as ADMIN (only STAFF)', async () => {
      const { admin } = await createUserHierarchy();
      const app = createTestApp(admin);
      
      const newUserData = {
        email: 'newstaff@example.com',
        password: 'password123',
        name: 'New Staff',
        role: 'STAFF',
      };

      const response = await app.request('/api/v1/users', {
        method: 'POST',
        headers: createAuthHeaders(admin),
        body: JSON.stringify(newUserData),
      });

      expect(response.status).toBe(201);
      
      const body = await response.json();
      expect(body.success).toBe(true);
      expect(body.data.role).toBe('STAFF');
    });

    it('should prevent ADMIN from creating ADMIN users', async () => {
      const { admin } = await createUserHierarchy();
      const app = createTestApp(admin);
      
      const newUserData = {
        email: 'newadmin@example.com',
        password: 'password123',
        name: 'New Admin',
        role: 'ADMIN',
      };

      const response = await app.request('/api/v1/users', {
        method: 'POST',
        headers: createAuthHeaders(admin),
        body: JSON.stringify(newUserData),
      });

      expect(response.status).toBe(400);
      
      const text = await response.text();
      expect(text).toContain('Admin users can only create STAFF users');
    });

    it('should prevent STAFF from creating users', async () => {
      const { staff } = await createUserHierarchy();
      const app = createTestApp(staff);
      
      const newUserData = {
        email: 'newuser@example.com',
        password: 'password123',
        name: 'New User',
        role: 'STAFF',
      };

      const response = await app.request('/api/v1/users', {
        method: 'POST',
        headers: createAuthHeaders(staff),
        body: JSON.stringify(newUserData),
      });

      expect(response.status).toBe(403);
      
      const text = await response.text();
      expect(text).toContain('Insufficient permissions to create users');
    });

    it('should prevent CASHIER from creating users', async () => {
      const { cashier } = await createUserHierarchy();
      const app = createTestApp(cashier);
      
      const newUserData = {
        email: 'newuser@example.com',
        password: 'password123',
        name: 'New User',
        role: 'STAFF',
      };

      const response = await app.request('/api/v1/users', {
        method: 'POST',
        headers: createAuthHeaders(cashier),
        body: JSON.stringify(newUserData),
      });

      expect(response.status).toBe(403);
      
      const text = await response.text();
      expect(text).toContain('Insufficient permissions to create users');
    });

    it('should validate required fields', async () => {
      const { owner } = await createUserHierarchy();
      const app = createTestApp(owner);
      
      const invalidUserData = {
        email: 'invalid-email',
        // missing password, name, role
      };

      const response = await app.request('/api/v1/users', {
        method: 'POST',
        headers: createAuthHeaders(owner),
        body: JSON.stringify(invalidUserData),
      });

      expect(response.status).toBe(400);
      
      const text = await response.text();
      expect(text).toContain('Invalid email');
    });

    it('should prevent duplicate emails', async () => {
      const { owner } = await createUserHierarchy();
      const app = createTestApp(owner);
      
      const userData = {
        email: 'duplicate@example.com',
        password: 'password123',
        name: 'First User',
        role: 'STAFF',
      };

      // Create first user
      const firstResponse = await app.request('/api/v1/users', {
        method: 'POST',
        headers: createAuthHeaders(owner),
        body: JSON.stringify(userData),
      });
      expect(firstResponse.status).toBe(201);

      // Try to create user with same email
      const duplicateResponse = await app.request('/api/v1/users', {
        method: 'POST',
        headers: createAuthHeaders(owner),
        body: JSON.stringify({
          ...userData,
          name: 'Second User',
        }),
      });

      expect(duplicateResponse.status).toBe(409);
      
      const text = await duplicateResponse.text();
      expect(text).toContain('Duplicate email');
    });
  });

  describe('GET /api/v1/users - Get All Users', () => {
    it('should get all users for OWNER', async () => {
      const { owner, admin, staff, cashier } = await createUserHierarchy();
      const app = createTestApp(owner);

      const response = await app.request('/api/v1/users', {
        method: 'GET',
        headers: createAuthHeaders(owner),
      });

      expect(response.status).toBe(200);
      
      const body = await response.json();
      expect(body.success).toBe(true);
      expect(body.data).toHaveLength(4);
      expect(body.pagination).toMatchObject({
        page: 1,
        limit: 10,
        total: 4,
      });
    });

    it('should filter users by role', async () => {
      const { owner, admin, staff, cashier } = await createUserHierarchy();
      const app = createTestApp(owner);

      const response = await app.request('/api/v1/users?role=STAFF', {
        method: 'GET',
        headers: createAuthHeaders(owner),
      });

      expect(response.status).toBe(200);
      
      const body = await response.json();
      expect(body.success).toBe(true);
      expect(body.data).toHaveLength(1);
      expect(body.data[0].role).toBe('STAFF');
    });

    it('should filter users by active status', async () => {
      const { owner } = await createUserHierarchy();
      const app = createTestApp(owner);

      const response = await app.request('/api/v1/users?isActive=true', {
        method: 'GET',
        headers: createAuthHeaders(owner),
      });

      expect(response.status).toBe(200);
      
      const body = await response.json();
      expect(body.success).toBe(true);
      expect(body.data.every((user: any) => user.isActive)).toBe(true);
    });

    it('should paginate results', async () => {
      const { owner } = await createUserHierarchy();
      const app = createTestApp(owner);

      const response = await app.request('/api/v1/users?page=1&limit=2', {
        method: 'GET',
        headers: createAuthHeaders(owner),
      });

      expect(response.status).toBe(200);
      
      const body = await response.json();
      expect(body.success).toBe(true);
      expect(body.data).toHaveLength(2);
      expect(body.pagination.page).toBe(1);
      expect(body.pagination.limit).toBe(2);
      expect(body.pagination.total).toBe(4);
    });

    it('should return only owner-scoped users for ADMIN', async () => {
      const { owner1, owner2, admin1, admin2 } = await createMultiOwnerUsers();
      const app = createTestApp(admin1);

      const response = await app.request('/api/v1/users', {
        method: 'GET',
        headers: createAuthHeaders(admin1),
      });

      expect(response.status).toBe(200);
      
      const body = await response.json();
      expect(body.success).toBe(true);
      // Should only see users from owner1 (admin1 + staff1)
      expect(body.data).toHaveLength(2);
      expect(body.data.every((user: any) => 
        user.ownerId === owner1.user.id
      )).toBe(true);
    });

    it('should return only owner-scoped users for STAFF', async () => {
      const { owner1, owner2, staff1, staff2 } = await createMultiOwnerUsers();
      const app = createTestApp(staff1);

      const response = await app.request('/api/v1/users', {
        method: 'GET',
        headers: createAuthHeaders(staff1),
      });

      expect(response.status).toBe(200);
      
      const body = await response.json();
      expect(body.success).toBe(true);
      // Should only see users from owner1
      expect(body.data.every((user: any) => 
        user.ownerId === owner1.user.id || user.id === owner1.user.id
      )).toBe(true);
    });
  });

  describe('GET /api/v1/users/{id} - Get User By ID', () => {
    it('should get user by ID for OWNER', async () => {
      const { owner, staff } = await createUserHierarchy();
      const app = createTestApp(owner);

      const response = await app.request(`/api/v1/users/${staff.user.id}`, {
        method: 'GET',
        headers: createAuthHeaders(owner),
      });

      expect(response.status).toBe(200);
      
      const body = await response.json();
      expect(body.success).toBe(true);
      expect(body.data.id).toBe(staff.user.id);
      expect(body.data.password).toBeUndefined();
    });

    it('should get own user profile for any role', async () => {
      const { staff } = await createUserHierarchy();
      const app = createTestApp(staff);

      const response = await app.request(`/api/v1/users/${staff.user.id}`, {
        method: 'GET',
        headers: createAuthHeaders(staff),
      });

      expect(response.status).toBe(200);
      
      const body = await response.json();
      expect(body.success).toBe(true);
      expect(body.data.id).toBe(staff.user.id);
    });

    it('should prevent access to users from different owners', async () => {
      const { admin1, staff2 } = await createMultiOwnerUsers();
      const app = createTestApp(admin1);

      const response = await app.request(`/api/v1/users/${staff2.user.id}`, {
        method: 'GET',
        headers: createAuthHeaders(admin1),
      });

      expect(response.status).toBe(403);
      
      const text = await response.text();
      expect(text).toContain('Access denied');
    });

    it('should return 404 for non-existent user', async () => {
      const { owner } = await createUserHierarchy();
      const app = createTestApp(owner);

      const response = await app.request('/api/v1/users/nonexistent-id', {
        method: 'GET',
        headers: createAuthHeaders(owner),
      });

      expect(response.status).toBe(404);
      
      const text = await response.text();
      expect(text).toContain('User not found');
    });
  });

  describe('PUT /api/v1/users/{id} - Update User', () => {
    it('should update user as OWNER', async () => {
      const { owner, staff } = await createUserHierarchy();
      const app = createTestApp(owner);
      
      const updateData = {
        name: 'Updated Staff Name',
        email: 'updated@example.com',
      };

      const response = await app.request(`/api/v1/users/${staff.user.id}`, {
        method: 'PUT',
        headers: createAuthHeaders(owner),
        body: JSON.stringify(updateData),
      });

      expect(response.status).toBe(200);
      
      const body = await response.json();
      expect(body.success).toBe(true);
      expect(body.message).toBe('User updated successfully');
      expect(body.data.name).toBe(updateData.name);
      expect(body.data.email).toBe(updateData.email);
    });

    it('should update user as ADMIN (limited permissions)', async () => {
      const { admin, staff } = await createUserHierarchy();
      const app = createTestApp(admin);
      
      const updateData = {
        name: 'Updated by Admin',
      };

      const response = await app.request(`/api/v1/users/${staff.user.id}`, {
        method: 'PUT',
        headers: createAuthHeaders(admin),
        body: JSON.stringify(updateData),
      });

      expect(response.status).toBe(200);
      
      const body = await response.json();
      expect(body.success).toBe(true);
      expect(body.data.name).toBe(updateData.name);
    });

    it('should prevent ADMIN from updating user roles', async () => {
      const { admin, staff } = await createUserHierarchy();
      const app = createTestApp(admin);
      
      const updateData = {
        role: 'ADMIN',
      };

      const response = await app.request(`/api/v1/users/${staff.user.id}`, {
        method: 'PUT',
        headers: createAuthHeaders(admin),
        body: JSON.stringify(updateData),
      });

      expect(response.status).toBe(403);
      
      const text = await response.text();
      expect(text).toContain('Admin users cannot change user roles');
    });

    it('should prevent STAFF from updating other users', async () => {
      const { staff, cashier } = await createUserHierarchy();
      const app = createTestApp(staff);
      
      const updateData = {
        name: 'Trying to update',
      };

      const response = await app.request(`/api/v1/users/${cashier.user.id}`, {
        method: 'PUT',
        headers: createAuthHeaders(staff),
        body: JSON.stringify(updateData),
      });

      expect(response.status).toBe(403);
      
      const text = await response.text();
      expect(text).toContain('Access denied');
    });

    it('should prevent updating users from different owners', async () => {
      const { admin1, staff2 } = await createMultiOwnerUsers();
      const app = createTestApp(admin1);
      
      const updateData = {
        name: 'Cross-owner update',
      };

      const response = await app.request(`/api/v1/users/${staff2.user.id}`, {
        method: 'PUT',
        headers: createAuthHeaders(admin1),
        body: JSON.stringify(updateData),
      });

      expect(response.status).toBe(403);
      
      const text = await response.text();
      expect(text).toContain('Access denied');
    });
  });

  describe('DELETE /api/v1/users/{id} - Delete User', () => {
    it('should delete user as OWNER', async () => {
      const { owner, staff } = await createUserHierarchy();
      const app = createTestApp(owner);

      const response = await app.request(`/api/v1/users/${staff.user.id}`, {
        method: 'DELETE',
        headers: createAuthHeaders(owner),
      });

      expect(response.status).toBe(200);
      
      const body = await response.json();
      expect(body.success).toBe(true);
      expect(body.message).toBe('User deleted successfully');
    });

    it('should prevent ADMIN from deleting users', async () => {
      const { admin, staff } = await createUserHierarchy();
      const app = createTestApp(admin);

      const response = await app.request(`/api/v1/users/${staff.user.id}`, {
        method: 'DELETE',
        headers: createAuthHeaders(admin),
      });

      expect(response.status).toBe(403);
      
      const text = await response.text();
      expect(text).toContain('Admin users cannot delete users');
    });

    it('should prevent STAFF from deleting users', async () => {
      const { staff, cashier } = await createUserHierarchy();
      const app = createTestApp(staff);

      const response = await app.request(`/api/v1/users/${cashier.user.id}`, {
        method: 'DELETE',
        headers: createAuthHeaders(staff),
      });

      expect(response.status).toBe(403);
      
      const text = await response.text();
      expect(text).toContain('Only Owner can delete users');
    });

    it('should prevent CASHIER from deleting users', async () => {
      const { cashier, staff } = await createUserHierarchy();
      const app = createTestApp(cashier);

      const response = await app.request(`/api/v1/users/${staff.user.id}`, {
        method: 'DELETE',
        headers: createAuthHeaders(cashier),
      });

      expect(response.status).toBe(403);
      
      const text = await response.text();
      expect(text).toContain('Only Owner can delete users');
    });
  });

  describe('GET /api/v1/users/me - Get Current User', () => {
    it('should get current user profile for any role', async () => {
      const { staff } = await createUserHierarchy();
      const app = createTestApp(staff);

      const response = await app.request('/api/v1/users/me', {
        method: 'GET',
        headers: createAuthHeaders(staff),
      });

      expect(response.status).toBe(200);
      
      const body = await response.json();
      expect(body.success).toBe(true);
      expect(body.data.id).toBe(staff.user.id);
      expect(body.data.password).toBeUndefined();
    });

    it('should require authentication', async () => {
      const app = createTestApp();
      const response = await app.request('/api/v1/users/me', {
        method: 'GET',
      });

      expect(response.status).toBe(401);
      
      const text = await response.text();
      expect(text).toContain('Authentication required');
    });
  });

  describe('PUT /api/v1/users/me - Update Current User', () => {
    it('should update current user profile', async () => {
      const { staff } = await createUserHierarchy();
      const app = createTestApp(staff);
      
      const updateData = {
        name: 'Updated Name',
        email: 'newemail@example.com',
      };

      const response = await app.request('/api/v1/users/me', {
        method: 'PUT',
        headers: createAuthHeaders(staff),
        body: JSON.stringify(updateData),
      });

      expect(response.status).toBe(200);
      
      const body = await response.json();
      expect(body.success).toBe(true);
      expect(body.message).toBe('Profile updated successfully');
      expect(body.data.name).toBe(updateData.name);
      expect(body.data.email).toBe(updateData.email);
    });

    it('should only allow updating name and email', async () => {
      const { staff } = await createUserHierarchy();
      const app = createTestApp(staff);
      
      const updateData = {
        name: 'Updated Name',
        email: 'newemail@example.com',
        role: 'ADMIN', // This should be ignored
        isActive: false, // This should be ignored
      };

      const response = await app.request('/api/v1/users/me', {
        method: 'PUT',
        headers: createAuthHeaders(staff),
        body: JSON.stringify(updateData),
      });

      expect(response.status).toBe(200);
      
      const body = await response.json();
      expect(body.success).toBe(true);
      expect(body.data.name).toBe(updateData.name);
      expect(body.data.email).toBe(updateData.email);
      expect(body.data.role).toBe('STAFF'); // Should remain unchanged
      expect(body.data.isActive).toBe(true); // Should remain unchanged
    });
  });

  describe('GET /api/v1/users/{userId}/stores - Get User Stores', () => {
    it('should get stores for user as OWNER', async () => {
      const { owner, staff } = await createUserHierarchy();
      const app = createTestApp(owner);

      const response = await app.request(`/api/v1/users/${staff.user.id}/stores`, {
        method: 'GET',
        headers: createAuthHeaders(owner),
      });

      expect(response.status).toBe(200);
      
      const body = await response.json();
      expect(body.success).toBe(true);
      expect(body.message).toBe('User stores retrieved successfully');
      expect(Array.isArray(body.data)).toBe(true);
    });

    it('should get own stores for any role', async () => {
      const { staff } = await createUserHierarchy();
      const app = createTestApp(staff);

      const response = await app.request(`/api/v1/users/${staff.user.id}/stores`, {
        method: 'GET',
        headers: createAuthHeaders(staff),
      });

      expect(response.status).toBe(200);
      
      const body = await response.json();
      expect(body.success).toBe(true);
      expect(Array.isArray(body.data)).toBe(true);
    });

    it('should prevent access to stores for users from different owners', async () => {
      const { admin1, staff2 } = await createMultiOwnerUsers();
      const app = createTestApp(admin1);

      const response = await app.request(`/api/v1/users/${staff2.user.id}/stores`, {
        method: 'GET',
        headers: createAuthHeaders(admin1),
      });

      expect(response.status).toBe(403);
      
      const text = await response.text();
      expect(text).toContain('Access denied');
    });
  });

  describe('GET /api/v1/users/active - Get Active Users', () => {
    it('should get active users for OWNER', async () => {
      const { owner } = await createUserHierarchy();
      const app = createTestApp(owner);

      const response = await app.request('/api/v1/users/active', {
        method: 'GET',
        headers: createAuthHeaders(owner),
      });

      expect(response.status).toBe(200);
      
      const body = await response.json();
      expect(body.success).toBe(true);
      expect(body.message).toBe('Active users retrieved successfully');
      expect(body.data.every((user: any) => user.isActive)).toBe(true);
    });

    it('should return only owner-scoped active users for ADMIN', async () => {
      const { admin1, owner1 } = await createMultiOwnerUsers();
      const app = createTestApp(admin1);

      const response = await app.request('/api/v1/users/active', {
        method: 'GET',
        headers: createAuthHeaders(admin1),
      });

      expect(response.status).toBe(200);
      
      const body = await response.json();
      expect(body.success).toBe(true);
      expect(body.data.every((user: any) => 
        user.isActive && (user.ownerId === owner1.user.id || user.id === owner1.user.id)
      )).toBe(true);
    });
  });

  describe('GET /api/v1/users/role/{role} - Get Users By Role', () => {
    it('should get users by role for OWNER', async () => {
      const { owner } = await createUserHierarchy();
      const app = createTestApp(owner);

      const response = await app.request('/api/v1/users/role/STAFF', {
        method: 'GET',
        headers: createAuthHeaders(owner),
      });

      expect(response.status).toBe(200);
      
      const body = await response.json();
      expect(body.success).toBe(true);
      expect(body.message).toBe('Users retrieved successfully');
      expect(body.data.every((user: any) => user.role === 'STAFF')).toBe(true);
    });

    it('should return only owner-scoped users by role for ADMIN', async () => {
      const { admin1, owner1 } = await createMultiOwnerUsers();
      const app = createTestApp(admin1);

      const response = await app.request('/api/v1/users/role/STAFF', {
        method: 'GET',
        headers: createAuthHeaders(admin1),
      });

      expect(response.status).toBe(200);
      
      const body = await response.json();
      expect(body.success).toBe(true);
      expect(body.data.every((user: any) => 
        user.role === 'STAFF' && user.ownerId === owner1.user.id
      )).toBe(true);
    });
  });

  describe('GET /api/v1/users/owner/{ownerId} - Get Users By Owner', () => {
    it('should get users by owner for OWNER', async () => {
      const { owner } = await createUserHierarchy();
      const app = createTestApp(owner);

      const response = await app.request(`/api/v1/users/owner/${owner.user.id}`, {
        method: 'GET',
        headers: createAuthHeaders(owner),
      });

      expect(response.status).toBe(200);
      
      const body = await response.json();
      expect(body.success).toBe(true);
      expect(body.message).toBe('Users retrieved successfully');
      expect(body.data.every((user: any) => user.ownerId === owner.user.id)).toBe(true);
    });

    it('should prevent access to users from different owners', async () => {
      const { admin1, staff2 } = await createMultiOwnerUsers();
      const app = createTestApp(admin1);

      const response = await app.request(`/api/v1/users/${staff2.user.id}`, {
        method: 'GET',
        headers: createAuthHeaders(admin1),
      });

      expect(response.status).toBe(403);
      
      const text = await response.text();
      expect(text).toContain('Access denied');
    });
  });
});
