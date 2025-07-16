import { sqliteTable, text, integer } from 'drizzle-orm/sqlite-core';
import { createInsertSchema, createSelectSchema } from 'drizzle-zod';
import { relations } from 'drizzle-orm';
import { users } from './users';
import { stores } from './stores';
import { products } from './products';

export const checkStatus = ['PENDING', 'OK', 'MISSING', 'BROKEN'] as const;
export type CheckStatus = typeof checkStatus[number];

export const productChecks = sqliteTable('product_checks', {
  id: text('id').primaryKey(),
  status: text('status', { enum: checkStatus }).notNull(),
  expectedQuantity: integer('expected_quantity').notNull(),
  actualQuantity: integer('actual_quantity'),
  notes: text('notes'),
  productId: text('product_id').notNull().references(() => products.id),
  storeId: text('store_id').notNull().references(() => stores.id),
  userId: text('user_id').notNull().references(() => users.id),
  ownerId: text('owner_id').notNull().references(() => users.id),
  createdAt: integer('created_at', { mode: 'timestamp' }).notNull().$defaultFn(() => new Date()),
  updatedAt: integer('updated_at', { mode: 'timestamp' }).notNull().$defaultFn(() => new Date()),
  deletedAt: integer('deleted_at', { mode: 'timestamp' }),
});

export const productChecksRelations = relations(productChecks, ({ one }) => ({
  product: one(products, {
    fields: [productChecks.productId],
    references: [products.id],
  }),
  store: one(stores, {
    fields: [productChecks.storeId],
    references: [stores.id],
  }),
  user: one(users, {
    fields: [productChecks.userId],
    references: [users.id],
  }),
  owner: one(users, {
    fields: [productChecks.ownerId],
    references: [users.id],
  }),
}));

export const insertProductCheckSchema = createInsertSchema(productChecks);
export const selectProductCheckSchema = createSelectSchema(productChecks);
export type ProductCheck = typeof productChecks.$inferSelect;
export type NewProductCheck = typeof productChecks.$inferInsert;