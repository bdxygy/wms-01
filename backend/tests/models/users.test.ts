import { db } from '@/config/database';
import { users } from '@/models/users';
import { and, eq, isNull } from 'drizzle-orm';
import { describe, expect, it } from 'vitest';
import { createAdminFixture, createCashierFixture, createOwnerFixture, createStaffFixture, setupTestDatabase } from '../utils';

setupTestDatabase();

describe('User Model', () => {
  describe('Database Operations', () => {
    it('should create a new user with all required fields', async () => {
      const userData = createOwnerFixture();
      
      const [result] = await db.insert(users).values(userData).returning();
      
      expect(result).toMatchObject({
        id: userData.id,
        email: userData.email,
        name: userData.name,
        role: userData.role,
        isActive: true,
      });
      expect(result.createdAt).toBeInstanceOf(Date);
      expect(result.updatedAt).toBeInstanceOf(Date);
    });

    it('should enforce unique email constraint', async () => {
      const userData = createOwnerFixture();
      
      await db.insert(users).values(userData);
      
      await expect(
        db.insert(users).values(createOwnerFixture({ email: userData.email }))
      ).rejects.toThrow();
    });

    it('should create users with all role types', async () => {
      const owner = createOwnerFixture();
      const [ownerResult] = await db.insert(users).values(owner).returning();
      
      const admin = createAdminFixture(owner.id, 'store-1');
      const [adminResult] = await db.insert(users).values(admin).returning();
      
      const staff = createStaffFixture(owner.id);
      const [staffResult] = await db.insert(users).values(staff).returning();
      
      const cashier = createCashierFixture(owner.id);
      const [cashierResult] = await db.insert(users).values(cashier).returning();
      
      expect(ownerResult.role).toBe('OWNER');
      expect(adminResult.role).toBe('ADMIN');
      expect(staffResult.role).toBe('STAFF');
      expect(cashierResult.role).toBe('CASHIER');
    });

    it('should soft delete users', async () => {
      const userData = createOwnerFixture();
      const [user] = await db.insert(users).values(userData).returning();
      
      const deletedAt = new Date();
      await db.update(users)
        .set({ deletedAt })
        .where(eq(users.id, user.id));
      
      const [softDeletedUser] = await db
        .select()
        .from(users)
        .where(eq(users.id, user.id));
      
      expect(softDeletedUser.deletedAt).toBeInstanceOf(Date);
      expect(Math.abs(softDeletedUser.deletedAt.getTime() - deletedAt.getTime())).toBeLessThan(1000);
    });

    it('should query only active users', async () => {
      const activeUser = createOwnerFixture();
      const inactiveUser = createOwnerFixture({ isActive: false });
      
      await db.insert(users).values([activeUser, inactiveUser]);
      
      const activeUsers = await db
        .select()
        .from(users)
        .where(and(eq(users.isActive, true), isNull(users.deletedAt)));
      
      expect(activeUsers).toHaveLength(1);
      expect(activeUsers[0].id).toBe(activeUser.id);
    });

    it('should establish owner-user relationships', async () => {
      const owner = createOwnerFixture();
      const staff = createStaffFixture(owner.id);
      
      await db.insert(users).values([owner, staff]);
      
      const staffWithOwner = await db
        .select()
        .from(users)
        .where(eq(users.id, staff.id));
      
      expect(staffWithOwner[0].ownerId).toBe(owner.id);
    });

    it('should update user timestamps on modification', async () => {
      const userData = createOwnerFixture();
      const [user] = await db.insert(users).values(userData).returning();
      
      // Wait a bit to ensure timestamp difference
      await new Promise(resolve => setTimeout(resolve, 10));
      
      const updatedAt = new Date();
      await db.update(users)
        .set({ name: 'Updated Name', updatedAt })
        .where(eq(users.id, user.id));
      
      const [updatedUser] = await db
        .select()
        .from(users)
        .where(eq(users.id, user.id));
      
      expect(updatedUser.name).toBe('Updated Name');
      expect(updatedUser.updatedAt.getTime()).toBeGreaterThanOrEqual(user.updatedAt.getTime());
    });

    it('should handle null owner_id for OWNER role', async () => {
      const owner = createOwnerFixture({ ownerId: null });
      
      const [result] = await db.insert(users).values(owner).returning();
      
      expect(result.ownerId).toBeNull();
      expect(result.role).toBe('OWNER');
    });

    it('should handle null store_id for non-admin roles', async () => {
      const owner = createOwnerFixture();
      const staff = createStaffFixture(owner.id, { storeId: null });
      
      await db.insert(users).values([owner, staff]);
      
      const [staffResult] = await db
        .select()
        .from(users)
        .where(eq(users.id, staff.id));
      
      expect(staffResult.storeId).toBeNull();
    });

    it('should query users by role', async () => {
      const owner = createOwnerFixture();
      const staff1 = createStaffFixture(owner.id);
      const staff2 = createStaffFixture(owner.id);
      const admin = createAdminFixture(owner.id, 'store-1');
      
      await db.insert(users).values([owner, staff1, staff2, admin]);
      
      const staffUsers = await db
        .select()
        .from(users)
        .where(eq(users.role, 'STAFF'));
      
      expect(staffUsers).toHaveLength(2);
      expect(staffUsers.every(u => u.role === 'STAFF')).toBe(true);
    });
  });

  describe('Schema Validation', () => {
    it('should validate role enum values', async () => {
      const userData = createOwnerFixture();
      
      // Valid role should work
      await expect(
        db.insert(users).values(userData)
      ).resolves.not.toThrow();
      
      // Invalid role should be handled by TypeScript/Zod at runtime
      const invalidUserData = { ...userData, role: 'INVALID_ROLE' as any };
      
      await expect(
        db.insert(users).values(invalidUserData)
      ).rejects.toThrow();
    });

    it('should require email field', async () => {
      const userData = createOwnerFixture();
      delete (userData as any).email;
      
      await expect(
        db.insert(users).values(userData)
      ).rejects.toThrow();
    });

    it('should require password field', async () => {
      const userData = createOwnerFixture();
      delete (userData as any).password;
      
      await expect(
        db.insert(users).values(userData)
      ).rejects.toThrow();
    });

    it('should require name field', async () => {
      const userData = createOwnerFixture();
      delete (userData as any).name;
      
      await expect(
        db.insert(users).values(userData)
      ).rejects.toThrow();
    });

    it('should default isActive to true', async () => {
      const userData = createOwnerFixture();
      delete (userData as any).isActive;
      
      const [result] = await db.insert(users).values(userData).returning();
      
      expect(result.isActive).toBe(true);
    });

    it('should set createdAt and updatedAt automatically', async () => {
      const userData = createOwnerFixture();
      delete (userData as any).createdAt;
      delete (userData as any).updatedAt;
      
      const [result] = await db.insert(users).values(userData).returning();
      
      expect(result.createdAt).toBeInstanceOf(Date);
      expect(result.updatedAt).toBeInstanceOf(Date);
    });
  });

  describe('Business Logic', () => {
    it('should handle owner hierarchy correctly', async () => {
      const owner = createOwnerFixture();
      const admin = createAdminFixture(owner.id, 'store-1');
      const staff = createStaffFixture(owner.id);
      
      await db.insert(users).values([owner, admin, staff]);
      
      const ownedUsers = await db
        .select()
        .from(users)
        .where(eq(users.ownerId, owner.id));
      
      expect(ownedUsers).toHaveLength(2);
      expect(ownedUsers.map(u => u.role)).toEqual(
        expect.arrayContaining(['ADMIN', 'STAFF'])
      );
    });

    it('should query users by owner scope', async () => {
      const owner1 = createOwnerFixture();
      const owner2 = createOwnerFixture();
      const staff1 = createStaffFixture(owner1.id);
      const staff2 = createStaffFixture(owner2.id);
      
      await db.insert(users).values([owner1, owner2, staff1, staff2]);
      
      const owner1Users = await db
        .select()
        .from(users)
        .where(eq(users.ownerId, owner1.id));
      
      const owner2Users = await db
        .select()
        .from(users)
        .where(eq(users.ownerId, owner2.id));
      
      expect(owner1Users).toHaveLength(1);
      expect(owner1Users[0].id).toBe(staff1.id);
      
      expect(owner2Users).toHaveLength(1);
      expect(owner2Users[0].id).toBe(staff2.id);
    });

    it('should handle user deactivation', async () => {
      const userData = createOwnerFixture();
      const [user] = await db.insert(users).values(userData).returning();
      
      await db.update(users)
        .set({ isActive: false })
        .where(eq(users.id, user.id));
      
      const [deactivatedUser] = await db
        .select()
        .from(users)
        .where(eq(users.id, user.id));
      
      expect(deactivatedUser.isActive).toBe(false);
    });
  });
});