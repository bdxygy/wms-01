import { sqliteTable, text, integer, real } from 'drizzle-orm/sqlite-core';
import { createInsertSchema, createSelectSchema } from 'drizzle-zod';
import { relations } from 'drizzle-orm';
import { users } from './users';
import { stores } from './stores';
import { categories } from './categories';
import { transactions } from './transactions';
import { productChecks } from './product_checks';

export const productStatus = ['ACTIVE', 'INACTIVE', 'DISCONTINUED'] as const;
export type ProductStatus = typeof productStatus[number];

export const products = sqliteTable('products', {
  id: text('id').primaryKey(),
  barcode: text('barcode').notNull(),
  name: text('name').notNull(),
  description: text('description'),
  price: real('price').notNull(),
  cost: real('cost'),
  quantity: integer('quantity').notNull().default(0),
  minStock: integer('min_stock').default(0),
  maxStock: integer('max_stock'),
  status: text('status', { enum: productStatus }).default('ACTIVE'),
  storeId: text('store_id').notNull().references(() => stores.id),
  categoryId: text('category_id').references(() => categories.id),
  ownerId: text('owner_id').notNull().references(() => users.id),
  imageUrl: text('image_url'),
  isActive: integer('is_active', { mode: 'boolean' }).default(true),
  createdAt: integer('created_at', { mode: 'timestamp' }).notNull().$defaultFn(() => new Date()),
  updatedAt: integer('updated_at', { mode: 'timestamp' }).notNull().$defaultFn(() => new Date()),
  deletedAt: integer('deleted_at', { mode: 'timestamp' }),
});

export const productsRelations = relations(products, ({ one, many }) => ({
  store: one(stores, {
    fields: [products.storeId],
    references: [stores.id],
  }),
  category: one(categories, {
    fields: [products.categoryId],
    references: [categories.id],
  }),
  owner: one(users, {
    fields: [products.ownerId],
    references: [users.id],
  }),
  transactions: many(transactions),
  productChecks: many(productChecks),
}));

export const insertProductSchema = createInsertSchema(products);
export const selectProductSchema = createSelectSchema(products);
export type Product = typeof products.$inferSelect;
export type NewProduct = typeof products.$inferInsert;