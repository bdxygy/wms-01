import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { BaseRepositoryImpl } from '../base.repository';
import { users } from '../../models/users';
import { db } from '../../config/database';
import { eq } from 'drizzle-orm';

// Test repository for users table
class TestUserRepository extends BaseRepositoryImpl<typeof users.$inferSelect, typeof users.$inferInsert> {
  constructor() {
    super(users);
  }
}

describe('BaseRepository', () => {
  let repository: TestUserRepository;

  beforeEach(async () => {
    repository = new TestUserRepository();
    // Clean up test data
    await db.delete(users).where(eq(users.email, 'test@example.com'));
  });

  afterEach(async () => {
    // Clean up after tests
    await db.delete(users).where(eq(users.email, 'test@example.com'));
  });

  describe('create', () => {
    it('should create a new user', async () => {
      const newUser = {
        id: 'test-user-1',
        email: 'test@example.com',
        password: 'hashed-password',
        name: 'Test User',
        role: 'STAFF' as const,
        isActive: true,
      };

      const result = await repository.create(newUser);
      
      expect(result).toBeDefined();
      expect(result.email).toBe(newUser.email);
      expect(result.name).toBe(newUser.name);
      expect(result.id).toBe(newUser.id);
    });
  });

  describe('findById', () => {
    it('should find a user by id', async () => {
      const newUser = {
        id: 'test-user-2',
        email: 'test@example.com',
        password: 'hashed-password',
        name: 'Test User',
        role: 'STAFF' as const,
        isActive: true,
      };

      await repository.create(newUser);
      const foundUser = await repository.findById(newUser.id);

      expect(foundUser).toBeDefined();
      expect(foundUser?.id).toBe(newUser.id);
      expect(foundUser?.email).toBe(newUser.email);
    });

    it('should return null for non-existent user', async () => {
      const foundUser = await repository.findById('non-existent-id');
      expect(foundUser).toBeNull();
    });

    it('should not return soft-deleted users by default', async () => {
      const newUser = {
        id: 'test-user-3',
        email: 'test@example.com',
        password: 'hashed-password',
        name: 'Test User',
        role: 'STAFF' as const,
        isActive: true,
      };

      await repository.create(newUser);
      await repository.softDelete(newUser.id);

      const foundUser = await repository.findById(newUser.id);
      expect(foundUser).toBeNull();
    });

    it('should return soft-deleted users when includeDeleted is true', async () => {
      const newUser = {
        id: 'test-user-4',
        email: 'test@example.com',
        password: 'hashed-password',
        name: 'Test User',
        role: 'STAFF' as const,
        isActive: true,
      };

      await repository.create(newUser);
      await repository.softDelete(newUser.id);

      const foundUser = await repository.findById(newUser.id, { includeDeleted: true });
      expect(foundUser).toBeDefined();
      expect(foundUser?.deletedAt).toBeDefined();
    });
  });

  describe('findAll', () => {
    it('should return paginated results', async () => {
      const result = await repository.findAll({ page: 1, limit: 10 });
      
      expect(result).toHaveProperty('data');
      expect(result).toHaveProperty('total');
      expect(result).toHaveProperty('page');
      expect(result).toHaveProperty('limit');
      expect(result).toHaveProperty('totalPages');
    });

    it('should apply pagination correctly', async () => {
      const result = await repository.findAll({ page: 2, limit: 5 });
      
      expect(result.page).toBe(2);
      expect(result.limit).toBe(5);
    });
  });

  describe('update', () => {
    it('should update an existing user', async () => {
      const newUser = {
        id: 'test-user-5',
        email: 'test@example.com',
        password: 'hashed-password',
        name: 'Test User',
        role: 'STAFF' as const,
        isActive: true,
      };

      await repository.create(newUser);
      
      const updatedUser = await repository.update(newUser.id, { name: 'Updated Name' });
      
      expect(updatedUser).toBeDefined();
      expect(updatedUser?.name).toBe('Updated Name');
      expect(updatedUser?.email).toBe(newUser.email);
    });

    it('should return null for non-existent user', async () => {
      const updatedUser = await repository.update('non-existent-id', { name: 'Updated' });
      expect(updatedUser).toBeNull();
    });
  });

  describe('softDelete and restore', () => {
    it('should soft delete a user', async () => {
      const newUser = {
        id: 'test-user-6',
        email: 'test@example.com',
        password: 'hashed-password',
        name: 'Test User',
        role: 'STAFF' as const,
        isActive: true,
      };

      await repository.create(newUser);
      
      const deleted = await repository.softDelete(newUser.id);
      expect(deleted).toBe(true);

      const foundUser = await repository.findById(newUser.id);
      expect(foundUser).toBeNull();
    });

    it('should restore a soft-deleted user', async () => {
      const newUser = {
        id: 'test-user-7',
        email: 'test@example.com',
        password: 'hashed-password',
        name: 'Test User',
        role: 'STAFF' as const,
        isActive: true,
      };

      await repository.create(newUser);
      await repository.softDelete(newUser.id);
      
      const restored = await repository.restore(newUser.id);
      expect(restored).toBe(true);

      const foundUser = await repository.findById(newUser.id);
      expect(foundUser).toBeDefined();
      expect(foundUser?.deletedAt).toBeNull();
    });
  });

  describe('count and exists', () => {
    it('should count total records', async () => {
      const count = await repository.count();
      expect(typeof count).toBe('number');
      expect(count).toBeGreaterThanOrEqual(0);
    });

    it('should check if user exists', async () => {
      const newUser = {
        id: 'test-user-8',
        email: 'test@example.com',
        password: 'hashed-password',
        name: 'Test User',
        role: 'STAFF' as const,
        isActive: true,
      };

      await repository.create(newUser);
      
      const exists = await repository.exists(newUser.id);
      expect(exists).toBe(true);

      const notExists = await repository.exists('non-existent-id');
      expect(notExists).toBe(false);
    });
  });
});