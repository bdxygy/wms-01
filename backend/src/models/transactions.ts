import { sqliteTable, text, integer, real } from 'drizzle-orm/sqlite-core';
import { createInsertSchema, createSelectSchema } from 'drizzle-zod';
import { relations } from 'drizzle-orm';
import { users } from './users';
import { stores } from './stores';
import { products } from './products';

export const transactionTypes = ['SALE', 'TRANSFER', 'ADJUSTMENT', 'RESTOCK'] as const;
export type TransactionType = typeof transactionTypes[number];

export const transactionStatus = ['PENDING', 'COMPLETED', 'CANCELLED'] as const;
export type TransactionStatus = typeof transactionStatus[number];

export const transactions = sqliteTable('transactions', {
  id: text('id').primaryKey(),
  type: text('type', { enum: transactionTypes }).notNull(),
  status: text('status', { enum: transactionStatus }).default('PENDING'),
  quantity: integer('quantity').notNull(),
  price: real('price'),
  total: real('total'),
  notes: text('notes'),
  photoProof: text('photo_proof'),
  productId: text('product_id').notNull().references(() => products.id),
  fromStoreId: text('from_store_id').references(() => stores.id),
  toStoreId: text('to_store_id').references(() => stores.id),
  userId: text('user_id').notNull().references(() => users.id),
  ownerId: text('owner_id').notNull().references(() => users.id),
  createdAt: integer('created_at', { mode: 'timestamp' }).notNull().$defaultFn(() => new Date()),
  updatedAt: integer('updated_at', { mode: 'timestamp' }).notNull().$defaultFn(() => new Date()),
  deletedAt: integer('deleted_at', { mode: 'timestamp' }),
});

export const transactionsRelations = relations(transactions, ({ one }) => ({
  product: one(products, {
    fields: [transactions.productId],
    references: [products.id],
  }),
  fromStore: one(stores, {
    fields: [transactions.fromStoreId],
    references: [stores.id],
  }),
  toStore: one(stores, {
    fields: [transactions.toStoreId],
    references: [stores.id],
  }),
  user: one(users, {
    fields: [transactions.userId],
    references: [users.id],
  }),
  owner: one(users, {
    fields: [transactions.ownerId],
    references: [users.id],
  }),
}));

export const insertTransactionSchema = createInsertSchema(transactions);
export const selectTransactionSchema = createSelectSchema(transactions);
export type Transaction = typeof transactions.$inferSelect;
export type NewTransaction = typeof transactions.$inferInsert;