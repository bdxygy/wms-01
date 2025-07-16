import { db } from '@/config/database';
import { stores } from '@/models/stores';
import { users } from '@/models/users';
import { and, eq, isNull } from 'drizzle-orm';
import { describe, expect, it } from 'vitest';
import { createOwnerFixture, createStoreFixture, setupTestDatabase } from '../utils';

setupTestDatabase();

describe('Store Model', () => {
  describe('Database Operations', () => {
    it('should create a new store with all required fields', async () => {
      const owner = createOwnerFixture();
      await db.insert(users).values(owner);
      
      const storeData = createStoreFixture(owner.id);
      const [result] = await db.insert(stores).values(storeData).returning();
      
      expect(result).toMatchObject({
        id: storeData.id,
        name: storeData.name,
        address: storeData.address,
        phone: storeData.phone,
        email: storeData.email,
        ownerId: owner.id,
        isActive: true,
      });
      expect(result.createdAt).toBeInstanceOf(Date);
      expect(result.updatedAt).toBeInstanceOf(Date);
    });

    it('should enforce foreign key constraint with users table', async () => {
      const storeData = createStoreFixture('non-existent-owner');
      
      await expect(
        db.insert(stores).values(storeData)
      ).rejects.toThrow();
    });

    it('should soft delete stores', async () => {
      const owner = createOwnerFixture();
      await db.insert(users).values(owner);
      
      const storeData = createStoreFixture(owner.id);
      const [store] = await db.insert(stores).values(storeData).returning();
      
      const deletedAt = new Date();
      await db.update(stores)
        .set({ deletedAt })
        .where(eq(stores.id, store.id));
      
      const [softDeletedStore] = await db
        .select()
        .from(stores)
        .where(eq(stores.id, store.id));
      
      expect(softDeletedStore.deletedAt).toBeInstanceOf(Date);
      expect(Math.abs(softDeletedStore.deletedAt.getTime() - deletedAt.getTime())).toBeLessThan(1000);
    });

    it('should query only active stores', async () => {
      const owner = createOwnerFixture();
      await db.insert(users).values(owner);
      
      const activeStore = createStoreFixture(owner.id);
      const inactiveStore = createStoreFixture(owner.id, { isActive: false });
      
      await db.insert(stores).values([activeStore, inactiveStore]);
      
      const activeStores = await db
        .select()
        .from(stores)
        .where(and(eq(stores.isActive, true), isNull(stores.deletedAt)));
      
      expect(activeStores).toHaveLength(1);
      expect(activeStores[0].id).toBe(activeStore.id);
    });

    it('should update store timestamps on modification', async () => {
      const owner = createOwnerFixture();
      await db.insert(users).values(owner);
      
      const storeData = createStoreFixture(owner.id);
      const [store] = await db.insert(stores).values(storeData).returning();
      
      // Wait a bit to ensure timestamp difference
      await new Promise(resolve => setTimeout(resolve, 10));
      
      const updatedAt = new Date();
      await db.update(stores)
        .set({ name: 'Updated Store Name', updatedAt })
        .where(eq(stores.id, store.id));
      
      const [updatedStore] = await db
        .select()
        .from(stores)
        .where(eq(stores.id, store.id));
      
      expect(updatedStore.name).toBe('Updated Store Name');
      expect(updatedStore.updatedAt.getTime()).toBeGreaterThanOrEqual(store.updatedAt.getTime());
    });

    it('should handle optional fields correctly', async () => {
      const owner = createOwnerFixture();
      await db.insert(users).values(owner);
      
      const storeData = createStoreFixture(owner.id, {
        address: null,
        phone: null,
        email: null,
      });
      
      const [result] = await db.insert(stores).values(storeData).returning();
      
      expect(result.address).toBeNull();
      expect(result.phone).toBeNull();
      expect(result.email).toBeNull();
    });

    it('should query stores by owner', async () => {
      const owner1 = createOwnerFixture();
      const owner2 = createOwnerFixture();
      await db.insert(users).values([owner1, owner2]);
      
      const store1 = createStoreFixture(owner1.id);
      const store2 = createStoreFixture(owner1.id);
      const store3 = createStoreFixture(owner2.id);
      
      await db.insert(stores).values([store1, store2, store3]);
      
      const owner1Stores = await db
        .select()
        .from(stores)
        .where(eq(stores.ownerId, owner1.id));
      
      expect(owner1Stores).toHaveLength(2);
      expect(owner1Stores.map(s => s.id)).toEqual(
        expect.arrayContaining([store1.id, store2.id])
      );
    });

    it('should handle store deactivation', async () => {
      const owner = createOwnerFixture();
      await db.insert(users).values(owner);
      
      const storeData = createStoreFixture(owner.id);
      const [store] = await db.insert(stores).values(storeData).returning();
      
      await db.update(stores)
        .set({ isActive: false })
        .where(eq(stores.id, store.id));
      
      const [deactivatedStore] = await db
        .select()
        .from(stores)
        .where(eq(stores.id, store.id));
      
      expect(deactivatedStore.isActive).toBe(false);
    });
  });

  describe('Schema Validation', () => {
    it('should require name field', async () => {
      const owner = createOwnerFixture();
      await db.insert(users).values(owner);
      
      const storeData = createStoreFixture(owner.id);
      delete (storeData as any).name;
      
      await expect(
        db.insert(stores).values(storeData)
      ).rejects.toThrow();
    });

    it('should require ownerId field', async () => {
      const storeData = createStoreFixture('owner-id');
      delete (storeData as any).ownerId;
      
      await expect(
        db.insert(stores).values(storeData)
      ).rejects.toThrow();
    });

    it('should default isActive to true', async () => {
      const owner = createOwnerFixture();
      await db.insert(users).values(owner);
      
      const storeData = createStoreFixture(owner.id);
      delete (storeData as any).isActive;
      
      const [result] = await db.insert(stores).values(storeData).returning();
      
      expect(result.isActive).toBe(true);
    });

    it('should set createdAt and updatedAt automatically', async () => {
      const owner = createOwnerFixture();
      await db.insert(users).values(owner);
      
      const storeData = createStoreFixture(owner.id);
      delete (storeData as any).createdAt;
      delete (storeData as any).updatedAt;
      
      const [result] = await db.insert(stores).values(storeData).returning();
      
      expect(result.createdAt).toBeInstanceOf(Date);
      expect(result.updatedAt).toBeInstanceOf(Date);
    });
  });

  describe('Business Logic', () => {
    it('should support multiple stores per owner', async () => {
      const owner = createOwnerFixture();
      await db.insert(users).values(owner);
      
      const store1 = createStoreFixture(owner.id, { name: 'Store 1' });
      const store2 = createStoreFixture(owner.id, { name: 'Store 2' });
      const store3 = createStoreFixture(owner.id, { name: 'Store 3' });
      
      await db.insert(stores).values([store1, store2, store3]);
      
      const ownerStores = await db
        .select()
        .from(stores)
        .where(eq(stores.ownerId, owner.id));
      
      expect(ownerStores).toHaveLength(3);
      expect(ownerStores.map(s => s.name)).toEqual(
        expect.arrayContaining(['Store 1', 'Store 2', 'Store 3'])
      );
    });

    it('should handle store contact information updates', async () => {
      const owner = createOwnerFixture();
      await db.insert(users).values(owner);
      
      const storeData = createStoreFixture(owner.id);
      const [store] = await db.insert(stores).values(storeData).returning();
      
      const newContactInfo = {
        address: '456 New Address St',
        phone: '+9876543210',
        email: 'new-email@example.com',
        updatedAt: new Date(),
      };
      
      await db.update(stores)
        .set(newContactInfo)
        .where(eq(stores.id, store.id));
      
      const [updatedStore] = await db
        .select()
        .from(stores)
        .where(eq(stores.id, store.id));
      
      expect(updatedStore.address).toBe(newContactInfo.address);
      expect(updatedStore.phone).toBe(newContactInfo.phone);
      expect(updatedStore.email).toBe(newContactInfo.email);
    });

    it('should query stores excluding soft deleted ones', async () => {
      const owner = createOwnerFixture();
      await db.insert(users).values(owner);
      
      const activeStore = createStoreFixture(owner.id, { name: 'Active Store' });
      const deletedStore = createStoreFixture(owner.id, { name: 'Deleted Store' });
      
      await db.insert(stores).values([activeStore, deletedStore]);
      
      // Soft delete one store
      await db.update(stores)
        .set({ deletedAt: new Date() })
        .where(eq(stores.id, deletedStore.id));
      
      const activeStores = await db
        .select()
        .from(stores)
        .where(and(eq(stores.ownerId, owner.id), isNull(stores.deletedAt)));
      
      expect(activeStores).toHaveLength(1);
      expect(activeStores[0].name).toBe('Active Store');
    });

    it('should handle store ownership transfer', async () => {
      const owner1 = createOwnerFixture();
      const owner2 = createOwnerFixture();
      await db.insert(users).values([owner1, owner2]);
      
      const storeData = createStoreFixture(owner1.id);
      const [store] = await db.insert(stores).values(storeData).returning();
      
      // Transfer ownership
      await db.update(stores)
        .set({ ownerId: owner2.id, updatedAt: new Date() })
        .where(eq(stores.id, store.id));
      
      const [transferredStore] = await db
        .select()
        .from(stores)
        .where(eq(stores.id, store.id));
      
      expect(transferredStore.ownerId).toBe(owner2.id);
    });
  });
});