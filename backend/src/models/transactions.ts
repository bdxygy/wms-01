import { sqliteTable, text, integer, real } from 'drizzle-orm/sqlite-core';
import { createInsertSchema, createSelectSchema } from 'drizzle-zod';
import { relations } from 'drizzle-orm';
import { users } from './users';
import { stores } from './stores';
import { products } from './products';
import { randomUUID } from "crypto";

export const transactionTypes = ['SALE', 'TRANSFER'] as const;
export type TransactionType = typeof transactionTypes[number];

export const transactions = sqliteTable('transactions', {
  id: text('id').primaryKey(),
  type: text('type', { enum: transactionTypes }).notNull(),
  createdBy: text('created_by').references(() => users.id),
  approvedBy: text('approved_by').references(() => users.id),
  fromStoreId: text('from_store_id').references(() => stores.id),
  toStoreId: text('to_store_id').references(() => stores.id),
  photoProofUrl: text('photo_proof_url'),
  transferProofUrl: text('transfer_proof_url'),
  to: text('to'),
  customerPhone: text('customer_phone'),
  amount: real('amount'),
  isFinished: integer('is_finished', { mode: 'boolean' }).default(false),
  createdAt: integer('created_at', { mode: 'timestamp' }).notNull().$defaultFn(() => new Date()),
});

export const transactionItems = sqliteTable('transaction_items', {
  id: text('id').primaryKey().$defaultFn(() => randomUUID()),
  transactionId: text('transaction_id').notNull().references(() => transactions.id),
  productId: text('product_id').notNull().references(() => products.id),
  name: text('name').notNull(),
  price: real('price').notNull(),
  quantity: integer('quantity').notNull(),
  amount: real('amount'),
  createdAt: integer('created_at', { mode: 'timestamp' }).notNull().$defaultFn(() => new Date()),
});

export const transactionsRelations = relations(transactions, ({ one, many }) => ({
  transactionItems: many(transactionItems),
  createdByUser: one(users, {
    fields: [transactions.createdBy],
    references: [users.id],
  }),
  approvedByUser: one(users, {
    fields: [transactions.approvedBy],
    references: [users.id],
  }),
  fromStore: one(stores, {
    fields: [transactions.fromStoreId],
    references: [stores.id],
  }),
  toStore: one(stores, {
    fields: [transactions.toStoreId],
    references: [stores.id],
  }),
}));

export const transactionItemsRelations = relations(transactionItems, ({ one }) => ({
  transaction: one(transactions, {
    fields: [transactionItems.transactionId],
    references: [transactions.id],
  }),
  product: one(products, {
    fields: [transactionItems.productId],
    references: [products.id],
  }),
}));

export const insertTransactionSchema = createInsertSchema(transactions);
export const selectTransactionSchema = createSelectSchema(transactions);
export type Transaction = typeof transactions.$inferSelect;
export type NewTransaction = typeof transactions.$inferInsert;

export const insertTransactionItemSchema = createInsertSchema(transactionItems);
export const selectTransactionItemSchema = createSelectSchema(transactionItems);
export type TransactionItem = typeof transactionItems.$inferSelect;
export type NewTransactionItem = typeof transactionItems.$inferInsert;