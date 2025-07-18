import { sqliteTable, text, integer } from 'drizzle-orm/sqlite-core';
import { createInsertSchema, createSelectSchema } from 'drizzle-zod';
import { relations } from 'drizzle-orm';
import { products } from './products';
import { users } from './users';

export const productImeis = sqliteTable('product_imeis', {
  id: text('id').primaryKey(),
  productId: text('product_id').notNull().references(() => products.id),
  imei: text('imei').notNull(),
  createdBy: text('created_by').notNull().references(() => users.id),
  createdAt: integer('created_at', { mode: 'timestamp' }).notNull().$defaultFn(() => new Date()),
  updatedAt: integer('updated_at', { mode: 'timestamp' }).notNull().$defaultFn(() => new Date()),
});

export const productImeisRelations = relations(productImeis, ({ one }) => ({
  product: one(products, {
    fields: [productImeis.productId],
    references: [products.id],
  }),
  createdBy: one(users, {
    fields: [productImeis.createdBy],
    references: [users.id],
  }),
}));

export const insertProductImeiSchema = createInsertSchema(productImeis);
export const selectProductImeiSchema = createSelectSchema(productImeis);
export type ProductImei = typeof productImeis.$inferSelect;
export type NewProductImei = typeof productImeis.$inferInsert;