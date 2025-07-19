import { sqliteTable, text, integer, real, unique } from 'drizzle-orm/sqlite-core';
import { createInsertSchema, createSelectSchema } from 'drizzle-zod';
import { relations } from 'drizzle-orm';
import { users } from './users';
import { stores } from './stores';
import { categories } from './categories';
import { transactionItems } from './transactions';
import { productChecks } from './product_checks';
import { productImeis } from './product_imeis';

export const productStatus = ['ACTIVE', 'INACTIVE', 'DISCONTINUED'] as const;
export type ProductStatus = typeof productStatus[number];

export const products = sqliteTable('products', {
  id: text('id').primaryKey(),
  createdBy: text('created_by').notNull().references(() => users.id),
  storeId: text('store_id').notNull().references(() => stores.id),
  name: text('name').notNull(),
  categoryId: text('category_id').references(() => categories.id),
  sku: text('sku').notNull(),
  isImei: integer('is_imei', { mode: 'boolean' }).default(false),
  barcode: text('barcode').notNull(),
  quantity: integer('quantity').default(1).notNull(),
  purchasePrice: real('purchase_price').notNull(),
  salePrice: real('sale_price'),
  createdAt: integer('created_at', { mode: 'timestamp' }).notNull().$defaultFn(() => new Date()),
  updatedAt: integer('updated_at', { mode: 'timestamp' }).notNull().$defaultFn(() => new Date()),
  deletedAt: integer('deleted_at', { mode: 'timestamp' }),
}, (table) => ({
  // Unique constraint: SKU must be unique within each store (excluding soft-deleted products)
  uniqueSkuPerStore: unique('unique_sku_per_store').on(table.sku, table.storeId),
  // Unique constraint: Barcode must be globally unique (excluding soft-deleted products)
  uniqueBarcode: unique('unique_barcode').on(table.barcode),
}));

export const productsRelations = relations(products, ({ one, many }) => ({
  store: one(stores, {
    fields: [products.storeId],
    references: [stores.id],
  }),
  category: one(categories, {
    fields: [products.categoryId],
    references: [categories.id],
  }),
  createdByUser: one(users, {
    fields: [products.createdBy],
    references: [users.id],
  }),
  transactionItems: many(transactionItems),
  productChecks: many(productChecks),
  productImeis: many(productImeis),
}));

export const insertProductSchema = createInsertSchema(products);
export const selectProductSchema = createSelectSchema(products);
export type Product = typeof products.$inferSelect;
export type NewProduct = typeof products.$inferInsert;