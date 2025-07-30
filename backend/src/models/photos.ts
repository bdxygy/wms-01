import { sqliteTable, text, integer } from 'drizzle-orm/sqlite-core';
import { createInsertSchema, createSelectSchema } from 'drizzle-zod';
import { relations } from 'drizzle-orm';
import { transactions } from './transactions';
import { products } from './products';
import { users } from './users';

export const photoTypes = ['photoProof', 'transferProof', 'product'] as const;
export type PhotoType = typeof photoTypes[number];

export const photos = sqliteTable('photos', {
  id: text('id').primaryKey(),
  publicId: text('public_id').notNull(), // Cloudinary public_id
  secureUrl: text('secure_url').notNull(), // Cloudinary secure_url
  type: text('type', { enum: photoTypes }).notNull(), // Photo type
  transactionId: text('transaction_id').references(() => transactions.id),
  productId: text('product_id').references(() => products.id),
  createdBy: text('created_by').notNull().references(() => users.id),
  createdAt: integer('created_at', { mode: 'timestamp' }).notNull().$defaultFn(() => new Date()),
  updatedAt: integer('updated_at', { mode: 'timestamp' }).notNull().$defaultFn(() => new Date()),
  deletedAt: integer('deleted_at', { mode: 'timestamp' }),
});

export const photosRelations = relations(photos, ({ one }) => ({
  transaction: one(transactions, {
    fields: [photos.transactionId],
    references: [transactions.id],
  }),
  product: one(products, {
    fields: [photos.productId],
    references: [products.id],
  }),
  createdByUser: one(users, {
    fields: [photos.createdBy],
    references: [users.id],
  }),
}));

export const insertPhotoSchema = createInsertSchema(photos);
export const selectPhotoSchema = createSelectSchema(photos);
export type Photo = typeof photos.$inferSelect;
export type NewPhoto = typeof photos.$inferInsert;