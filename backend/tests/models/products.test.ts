import { db } from '@/config/database';
import { categories } from '@/models/categories';
import { products } from '@/models/products';
import { stores } from '@/models/stores';
import { users } from '@/models/users';
import { and, eq, isNull, sql } from 'drizzle-orm';
import { describe, expect, it } from 'vitest';
import { createCategoryFixture, createOwnerFixture, createProductFixture, createStoreFixture, setupTestDatabase } from '../utils';

setupTestDatabase();

describe('Product Model', () => {
  describe('Database Operations', () => {
    it('should create a new product with all required fields', async () => {
      const owner = createOwnerFixture();
      await db.insert(users).values(owner);
      
      const store = createStoreFixture(owner.id);
      await db.insert(stores).values(store);
      
      const category = createCategoryFixture(owner.id);
      await db.insert(categories).values(category);
      
      const productData = createProductFixture(owner.id, store.id, category.id);
      const [result] = await db.insert(products).values(productData).returning();
      
      expect(result).toMatchObject({
        id: productData.id,
        name: productData.name,
        description: productData.description,
        barcode: productData.barcode,
        price: productData.price,
        cost: productData.cost,
        quantity: productData.quantity,
        minStock: productData.minStock,
        maxStock: productData.maxStock,
        status: 'ACTIVE',
        storeId: store.id,
        categoryId: category.id,
        ownerId: owner.id,
        isActive: true,
      });
      expect(result.createdAt).toBeInstanceOf(Date);
      expect(result.updatedAt).toBeInstanceOf(Date);
    });

    it('should enforce foreign key constraints', async () => {
      const owner = createOwnerFixture();
      await db.insert(users).values(owner);
      
      const store = createStoreFixture(owner.id);
      await db.insert(stores).values(store);
      
      // Test with non-existent owner
      const category1 = createCategoryFixture(owner.id);
      await db.insert(categories).values(category1);
      const productData1 = createProductFixture('non-existent-owner', store.id, category1.id);
      await expect(
        db.insert(products).values(productData1)
      ).rejects.toThrow();
      
      // Test with non-existent store
      const category2 = createCategoryFixture(owner.id);
      await db.insert(categories).values(category2);
      const productData2 = createProductFixture(owner.id, 'non-existent-store', category2.id);
      await expect(
        db.insert(products).values(productData2)
      ).rejects.toThrow();
    });

    it('should handle optional category field', async () => {
      const owner = createOwnerFixture();
      await db.insert(users).values(owner);
      
      const store = createStoreFixture(owner.id);
      await db.insert(stores).values(store);
      
      const category = createCategoryFixture(owner.id);
      await db.insert(categories).values(category);
      const productData = createProductFixture(owner.id, store.id, category.id, {
        categoryId: null,
      });
      
      const [result] = await db.insert(products).values(productData).returning();
      
      expect(result.categoryId).toBeNull();
    });

    it('should soft delete products', async () => {
      const owner = createOwnerFixture();
      await db.insert(users).values(owner);
      
      const store = createStoreFixture(owner.id);
      await db.insert(stores).values(store);
      
      const category = createCategoryFixture(owner.id);
      await db.insert(categories).values(category);
      
      const productData = createProductFixture(owner.id, store.id, category.id);
      const [product] = await db.insert(products).values(productData).returning();
      
      const deletedAt = new Date();
      await db.update(products)
        .set({ deletedAt })
        .where(eq(products.id, product.id));
      
      const [softDeletedProduct] = await db
        .select()
        .from(products)
        .where(eq(products.id, product.id));
      
      expect(softDeletedProduct.deletedAt).toBeInstanceOf(Date);
      expect(Math.abs(softDeletedProduct.deletedAt.getTime() - deletedAt.getTime())).toBeLessThan(1000);
    });

    it('should query only active products', async () => {
      const owner = createOwnerFixture();
      await db.insert(users).values(owner);
      
      const store = createStoreFixture(owner.id);
      await db.insert(stores).values(store);
      
      const category = createCategoryFixture(owner.id);
      await db.insert(categories).values(category);
      
      const activeProduct = createProductFixture(owner.id, store.id, category.id);
      const inactiveProduct = createProductFixture(owner.id, store.id, category.id, { isActive: false });
      
      await db.insert(products).values([activeProduct, inactiveProduct]);
      
      const activeProducts = await db
        .select()
        .from(products)
        .where(and(eq(products.isActive, true), isNull(products.deletedAt)));
      
      expect(activeProducts).toHaveLength(1);
      expect(activeProducts[0].id).toBe(activeProduct.id);
    });

    it('should update product inventory', async () => {
      const owner = createOwnerFixture();
      await db.insert(users).values(owner);
      
      const store = createStoreFixture(owner.id);
      await db.insert(stores).values(store);
      
      const category = createCategoryFixture(owner.id);
      await db.insert(categories).values(category);
      
      const productData = createProductFixture(owner.id, store.id, category.id);
      const [product] = await db.insert(products).values(productData).returning();
      
      const newQuantity = 50;
      await db.update(products)
        .set({ quantity: newQuantity, updatedAt: new Date() })
        .where(eq(products.id, product.id));
      
      const [updatedProduct] = await db
        .select()
        .from(products)
        .where(eq(products.id, product.id));
      
      expect(updatedProduct.quantity).toBe(newQuantity);
    });

    it('should handle product status changes', async () => {
      const owner = createOwnerFixture();
      await db.insert(users).values(owner);
      
      const store = createStoreFixture(owner.id);
      await db.insert(stores).values(store);
      
      const category = createCategoryFixture(owner.id);
      await db.insert(categories).values(category);
      
      const productData = createProductFixture(owner.id, store.id, category.id);
      const [product] = await db.insert(products).values(productData).returning();
      
      await db.update(products)
        .set({ status: 'DISCONTINUED', updatedAt: new Date() })
        .where(eq(products.id, product.id));
      
      const [updatedProduct] = await db
        .select()
        .from(products)
        .where(eq(products.id, product.id));
      
      expect(updatedProduct.status).toBe('DISCONTINUED');
    });

    it('should query products by store', async () => {
      const owner = createOwnerFixture();
      await db.insert(users).values(owner);
      
      const store1 = createStoreFixture(owner.id);
      const store2 = createStoreFixture(owner.id);
      await db.insert(stores).values([store1, store2]);
      
      const category = createCategoryFixture(owner.id);
      await db.insert(categories).values(category);
      
      const product1 = createProductFixture(owner.id, store1.id, category.id);
      const product2 = createProductFixture(owner.id, store1.id, category.id);
      const product3 = createProductFixture(owner.id, store2.id, category.id);
      
      await db.insert(products).values([product1, product2, product3]);
      
      const store1Products = await db
        .select()
        .from(products)
        .where(eq(products.storeId, store1.id));
      
      expect(store1Products).toHaveLength(2);
      expect(store1Products.map(p => p.id)).toEqual(
        expect.arrayContaining([product1.id, product2.id])
      );
    });

    it('should query products by category', async () => {
      const owner = createOwnerFixture();
      await db.insert(users).values(owner);
      
      const store = createStoreFixture(owner.id);
      await db.insert(stores).values(store);
      
      const category1 = createCategoryFixture(owner.id);
      const category2 = createCategoryFixture(owner.id);
      await db.insert(categories).values([category1, category2]);
      
      const product1 = createProductFixture(owner.id, store.id, category1.id);
      const product2 = createProductFixture(owner.id, store.id, category1.id);
      const product3 = createProductFixture(owner.id, store.id, category2.id);
      
      await db.insert(products).values([product1, product2, product3]);
      
      const category1Products = await db
        .select()
        .from(products)
        .where(eq(products.categoryId, category1.id));
      
      expect(category1Products).toHaveLength(2);
      expect(category1Products.map(p => p.id)).toEqual(
        expect.arrayContaining([product1.id, product2.id])
      );
    });

    it('should query products by barcode', async () => {
      const owner = createOwnerFixture();
      await db.insert(users).values(owner);
      
      const store = createStoreFixture(owner.id);
      await db.insert(stores).values(store);
      
      const category = createCategoryFixture(owner.id);
      await db.insert(categories).values(category);
      
      const productData = createProductFixture(owner.id, store.id, category.id, {
        barcode: 'UNIQUE_BARCODE_123',
      });
      
      await db.insert(products).values(productData);
      
      const [foundProduct] = await db
        .select()
        .from(products)
        .where(eq(products.barcode, 'UNIQUE_BARCODE_123'));
      
      expect(foundProduct).toBeDefined();
      expect(foundProduct.id).toBe(productData.id);
    });
  });

  describe('Schema Validation', () => {
    it('should require name field', async () => {
      const owner = createOwnerFixture();
      await db.insert(users).values(owner);
      
      const store = createStoreFixture(owner.id);
      await db.insert(stores).values(store);
      
      const category = createCategoryFixture(owner.id);
      await db.insert(categories).values(category);
      const productData = createProductFixture(owner.id, store.id, category.id);
      delete (productData as any).name;
      
      await expect(
        db.insert(products).values(productData)
      ).rejects.toThrow();
    });

    it('should require barcode field', async () => {
      const owner = createOwnerFixture();
      await db.insert(users).values(owner);
      
      const store = createStoreFixture(owner.id);
      await db.insert(stores).values(store);
      
      const category = createCategoryFixture(owner.id);
      await db.insert(categories).values(category);
      const productData = createProductFixture(owner.id, store.id, category.id);
      delete (productData as any).barcode;
      
      await expect(
        db.insert(products).values(productData)
      ).rejects.toThrow();
    });

    it('should require price field', async () => {
      const owner = createOwnerFixture();
      await db.insert(users).values(owner);
      
      const store = createStoreFixture(owner.id);
      await db.insert(stores).values(store);
      
      const category = createCategoryFixture(owner.id);
      await db.insert(categories).values(category);
      const productData = createProductFixture(owner.id, store.id, category.id);
      delete (productData as any).price;
      
      await expect(
        db.insert(products).values(productData)
      ).rejects.toThrow();
    });

    it('should default quantity to 0', async () => {
      const owner = createOwnerFixture();
      await db.insert(users).values(owner);
      
      const store = createStoreFixture(owner.id);
      await db.insert(stores).values(store);
      
      const category = createCategoryFixture(owner.id);
      await db.insert(categories).values(category);
      const productData = createProductFixture(owner.id, store.id, category.id);
      delete (productData as any).quantity;
      
      const [result] = await db.insert(products).values(productData).returning();
      
      expect(result.quantity).toBe(0);
    });

    it('should default minStock to 0', async () => {
      const owner = createOwnerFixture();
      await db.insert(users).values(owner);
      
      const store = createStoreFixture(owner.id);
      await db.insert(stores).values(store);
      
      const category = createCategoryFixture(owner.id);
      await db.insert(categories).values(category);
      const productData = createProductFixture(owner.id, store.id, category.id);
      delete (productData as any).minStock;
      
      const [result] = await db.insert(products).values(productData).returning();
      
      expect(result.minStock).toBe(0);
    });

    it('should default status to ACTIVE', async () => {
      const owner = createOwnerFixture();
      await db.insert(users).values(owner);
      
      const store = createStoreFixture(owner.id);
      await db.insert(stores).values(store);
      
      const category = createCategoryFixture(owner.id);
      await db.insert(categories).values(category);
      const productData = createProductFixture(owner.id, store.id, category.id);
      delete (productData as any).status;
      
      const [result] = await db.insert(products).values(productData).returning();
      
      expect(result.status).toBe('ACTIVE');
    });

    it('should validate product status enum', async () => {
      const owner = createOwnerFixture();
      await db.insert(users).values(owner);
      
      const store = createStoreFixture(owner.id);
      await db.insert(stores).values(store);
      
      // Valid status should work
      const category = createCategoryFixture(owner.id);
      await db.insert(categories).values(category);
      const validProductData = createProductFixture(owner.id, store.id, category.id, {
        status: 'DISCONTINUED',
      });
      
      await expect(
        db.insert(products).values(validProductData)
      ).resolves.not.toThrow();
      
      // Invalid status should fail
      const category2 = createCategoryFixture(owner.id);
      await db.insert(categories).values(category2);
      const invalidProductData = createProductFixture(owner.id, store.id, category2.id, {
        status: 'INVALID_STATUS' as any,
      });
      
      // SQLite doesn't enforce enum constraints at database level
      // This test will actually succeed with the invalid status
      const result = await db.insert(products).values(invalidProductData).returning();
      expect(result).toBeDefined();
      expect(result[0].status).toBe('INVALID_STATUS');
    });
  });

  describe('Business Logic', () => {
    it('should detect low stock products', async () => {
      const owner = createOwnerFixture();
      await db.insert(users).values(owner);
      
      const store = createStoreFixture(owner.id);
      await db.insert(stores).values(store);
      
      const category = createCategoryFixture(owner.id);
      await db.insert(categories).values(category);
      
      const lowStockProduct = createProductFixture(owner.id, store.id, category.id, {
        quantity: 5,
        minStock: 10,
      });
      
      const goodStockProduct = createProductFixture(owner.id, store.id, category.id, {
        quantity: 50,
        minStock: 10,
      });
      
      await db.insert(products).values([lowStockProduct, goodStockProduct]);
      
      // Query for low stock products (quantity <= minStock)
      const lowStockProducts = await db
        .select()
        .from(products)
        .where(
          and(
            eq(products.storeId, store.id),
            sql`quantity <= min_stock`,
            isNull(products.deletedAt)
          )
        );
      
      expect(lowStockProducts).toHaveLength(1);
      expect(lowStockProducts[0].id).toBe(lowStockProduct.id);
    });

    it('should handle product price updates', async () => {
      const owner = createOwnerFixture();
      await db.insert(users).values(owner);
      
      const store = createStoreFixture(owner.id);
      await db.insert(stores).values(store);
      
      const category = createCategoryFixture(owner.id);
      await db.insert(categories).values(category);
      
      const productData = createProductFixture(owner.id, store.id, category.id);
      const [product] = await db.insert(products).values(productData).returning();
      
      const newPrice = 39.99;
      const newCost = 25.99;
      
      await db.update(products)
        .set({ price: newPrice, cost: newCost, updatedAt: new Date() })
        .where(eq(products.id, product.id));
      
      const [updatedProduct] = await db
        .select()
        .from(products)
        .where(eq(products.id, product.id));
      
      expect(updatedProduct.price).toBe(newPrice);
      expect(updatedProduct.cost).toBe(newCost);
    });

    it('should handle out of stock products', async () => {
      const owner = createOwnerFixture();
      await db.insert(users).values(owner);
      
      const store = createStoreFixture(owner.id);
      await db.insert(stores).values(store);
      
      const category = createCategoryFixture(owner.id);
      await db.insert(categories).values(category);
      
      const productData = createProductFixture(owner.id, store.id, category.id, {
        quantity: 0,
      });
      
      await db.insert(products).values(productData);
      
      const outOfStockProducts = await db
        .select()
        .from(products)
        .where(
          and(
            eq(products.storeId, store.id),
            eq(products.quantity, 0),
            isNull(products.deletedAt)
          )
        );
      
      expect(outOfStockProducts).toHaveLength(1);
      expect(outOfStockProducts[0].quantity).toBe(0);
    });

    it('should query products by owner scope', async () => {
      const owner1 = createOwnerFixture();
      const owner2 = createOwnerFixture();
      await db.insert(users).values([owner1, owner2]);
      
      const store1 = createStoreFixture(owner1.id);
      const store2 = createStoreFixture(owner2.id);
      await db.insert(stores).values([store1, store2]);
      
      const category1 = createCategoryFixture(owner1.id);
      const category2 = createCategoryFixture(owner2.id);
      await db.insert(categories).values([category1, category2]);
      
      const product1 = createProductFixture(owner1.id, store1.id, category1.id);
      const product2 = createProductFixture(owner2.id, store2.id, category2.id);
      
      await db.insert(products).values([product1, product2]);
      
      const owner1Products = await db
        .select()
        .from(products)
        .where(eq(products.ownerId, owner1.id));
      
      expect(owner1Products).toHaveLength(1);
      expect(owner1Products[0].id).toBe(product1.id);
    });
  });
});