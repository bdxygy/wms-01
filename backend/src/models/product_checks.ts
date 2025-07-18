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
  productId: text('product_id').notNull().references(() => products.id),
  checkedBy: text('checked_by').notNull().references(() => users.id),
  storeId: text('store_id').notNull().references(() => stores.id),
  status: text('status', { enum: checkStatus }).notNull(),
  note: text('note'),
  checkedAt: integer('checked_at', { mode: 'timestamp' }).notNull().$defaultFn(() => new Date()),
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
  checkedByUser: one(users, {
    fields: [productChecks.checkedBy],
    references: [users.id],
  }),
}));

export const insertProductCheckSchema = createInsertSchema(productChecks);
export const selectProductCheckSchema = createSelectSchema(productChecks);
export type ProductCheck = typeof productChecks.$inferSelect;
export type NewProductCheck = typeof productChecks.$inferInsert;