import { z } from "zod";
import { transactionTypes } from "../models/transactions";

// Transaction item schema
export const transactionItemSchema = z.object({
  productId: z.string().uuid("Invalid product ID format"),
  name: z.string().min(1, "Product name is required"),
  price: z.number().positive("Price must be positive"),
  quantity: z.number().int().min(1, "Quantity must be at least 1"),
  amount: z.number().positive("Amount must be positive"),
});

// Create transaction schema
export const createTransactionSchema = z.object({
  type: z.enum(transactionTypes).default("SALE"),
  fromStoreId: z.string().uuid("Invalid store ID format").optional(),
  toStoreId: z.string().uuid("Invalid store ID format").optional(),
  photoProofUrl: z.string().url("Invalid photo proof URL").optional(),
  transferProofUrl: z.string().url("Invalid transfer proof URL").optional(),
  to: z.string().optional(),
  customerPhone: z.string().optional(),
  items: z.array(transactionItemSchema).min(1, "At least one item is required"),
}).refine((data) => {
  // For SALE transactions, at least one of fromStoreId or toStoreId should be provided
  if (data.type === "SALE") {
    return data.fromStoreId || data.toStoreId;
  }
  // For TRANSFER transactions, both fromStoreId and toStoreId are required
  if (data.type === "TRANSFER") {
    return data.fromStoreId && data.toStoreId;
  }
  return true;
}, {
  message: "Invalid store configuration for transaction type",
  path: ["fromStoreId", "toStoreId"],
});

// Update transaction schema
export const updateTransactionSchema = z.object({
  photoProofUrl: z.string().url("Invalid photo proof URL").optional(),
  transferProofUrl: z.string().url("Invalid transfer proof URL").optional(),
  to: z.string().optional(),
  customerPhone: z.string().optional(),
  isFinished: z.boolean().optional(),
  items: z.array(transactionItemSchema).min(1, "At least one item is required").optional(),
});

// Query parameters for list transactions
export const listTransactionsQuerySchema = z.object({
  page: z.coerce.number().min(1).default(1),
  limit: z.coerce.number().min(1).max(100).default(10),
  type: z.enum(transactionTypes).optional(),
  storeId: z.string().uuid("Invalid store ID format").optional(),
  isFinished: z.coerce.boolean().optional(),
  startDate: z.coerce.date().optional(),
  endDate: z.coerce.date().optional(),
  minAmount: z.coerce.number().min(0).optional(),
  maxAmount: z.coerce.number().min(0).optional(),
});

// Transaction ID parameter schema
export const transactionIdParamSchema = z.object({
  id: z.string().uuid("Invalid transaction ID format"),
});

// Transaction item response schema
export const transactionItemResponseSchema = z.object({
  id: z.string(),
  productId: z.string(),
  name: z.string(),
  price: z.number(),
  quantity: z.number(),
  amount: z.number(),
  createdAt: z.date(),
});

// Transaction response schema
export const transactionResponseSchema = z.object({
  id: z.string(),
  type: z.enum(transactionTypes),
  createdBy: z.string().nullable(),
  approvedBy: z.string().nullable(),
  fromStoreId: z.string().nullable(),
  toStoreId: z.string().nullable(),
  photoProofUrl: z.string().nullable(),
  transferProofUrl: z.string().nullable(),
  to: z.string().nullable(),
  customerPhone: z.string().nullable(),
  amount: z.number().nullable(),
  isFinished: z.boolean(),
  createdAt: z.date(),
  items: z.array(transactionItemResponseSchema),
});

// Transaction response with relations
export const transactionWithRelationsSchema = z.object({
  id: z.string(),
  type: z.enum(transactionTypes),
  createdBy: z.string().nullable(),
  approvedBy: z.string().nullable(),
  fromStoreId: z.string().nullable(),
  toStoreId: z.string().nullable(),
  photoProofUrl: z.string().nullable(),
  transferProofUrl: z.string().nullable(),
  to: z.string().nullable(),
  customerPhone: z.string().nullable(),
  amount: z.number().nullable(),
  isFinished: z.boolean(),
  createdAt: z.date(),
  items: z.array(transactionItemResponseSchema),
  createdByUser: z.object({
    id: z.string(),
    name: z.string(),
  }).optional(),
  approvedByUser: z.object({
    id: z.string(),
    name: z.string(),
  }).optional(),
  fromStore: z.object({
    id: z.string(),
    name: z.string(),
  }).optional(),
  toStore: z.object({
    id: z.string(),
    name: z.string(),
  }).optional(),
});

// Transaction list response schema
export const transactionListResponseSchema = z.object({
  transactions: z.array(transactionResponseSchema),
  pagination: z.object({
    page: z.number(),
    limit: z.number(),
    total: z.number(),
    totalPages: z.number(),
    hasNext: z.boolean(),
    hasPrev: z.boolean(),
  }),
});

// Type exports
export type TransactionItemRequest = z.infer<typeof transactionItemSchema>;
export type CreateTransactionRequest = z.infer<typeof createTransactionSchema>;
export type UpdateTransactionRequest = z.infer<typeof updateTransactionSchema>;
export type ListTransactionsQuery = z.infer<typeof listTransactionsQuerySchema>;
export type TransactionIdParam = z.infer<typeof transactionIdParamSchema>;
export type TransactionItemResponse = z.infer<typeof transactionItemResponseSchema>;
export type TransactionResponse = z.infer<typeof transactionResponseSchema>;
export type TransactionWithRelations = z.infer<typeof transactionWithRelationsSchema>;
export type TransactionListResponse = z.infer<typeof transactionListResponseSchema>;