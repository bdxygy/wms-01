import { z } from "zod";

// Add IMEI request schema
export const addImeiSchema = z.object({
  imei: z
    .string()
    .min(15, "IMEI must be at least 15 characters")
    .max(17, "IMEI must be at most 17 characters"),
});

// Product ID parameter schema
export const productIdParamSchema = z.object({
  id: z.string().uuid("Invalid product ID format"),
});

// IMEI ID parameter schema
export const imeiIdParamSchema = z.object({
  id: z.string().uuid("Invalid IMEI ID format"),
});

// IMEI search parameter schema
export const imeiSearchParamSchema = z.object({
  imei: z
    .string()
    .min(15, "IMEI must be at least 15 characters")
    .max(17, "IMEI must be at most 17 characters"),
});

// List product IMEIs query schema
export const listProductImeisQuerySchema = z.object({
  page: z.coerce.number().min(1).default(1),
  limit: z.coerce.number().min(1).max(100).default(10),
});

// IMEI response schema
export const imeiResponseSchema = z.object({
  id: z.string(),
  productId: z.string(),
  imei: z.string(),
  createdBy: z.string(),
  createdAt: z.string(),
  updatedAt: z.string(),
});

// IMEI list response schema
export const imeiListResponseSchema = z.object({
  success: z.boolean(),
  data: z.array(imeiResponseSchema),
  pagination: z.object({
    page: z.number(),
    limit: z.number(),
    total: z.number(),
    totalPages: z.number(),
    hasNext: z.boolean(),
    hasPrev: z.boolean(),
  }),
  timestamp: z.string(),
});

// Create product with IMEIs schema
export const createProductWithImeisSchema = z.object({
  name: z.string().min(1, "Product name is required"),
  categoryId: z.string().uuid().optional(),
  sku: z.string().min(1, "SKU is required"),
  storeId: z.string().uuid("Store ID is required"),
  quantity: z.number().positive("Quantity must be positive"),
  purchasePrice: z.number().positive("Purchase price must be positive"),
  salePrice: z.number().positive("Sale price must be positive").optional(),
  isImei: z.boolean().default(true), // Default to true for this endpoint
  imeis: z
    .array(
      z
        .string()
        .min(15, "IMEI must be at least 15 characters")
        .max(17, "IMEI must be at most 17 characters")
    )
    .min(1, "At least one IMEI is required"),
});

// Type definitions
export type AddImeiRequest = z.infer<typeof addImeiSchema>;
export type ProductIdParam = z.infer<typeof productIdParamSchema>;
export type ImeiIdParam = z.infer<typeof imeiIdParamSchema>;
export type ImeiSearchParam = z.infer<typeof imeiSearchParamSchema>;
export type ListProductImeisQuery = z.infer<typeof listProductImeisQuerySchema>;
export type ImeiResponse = z.infer<typeof imeiResponseSchema>;

export type CreateProductWithImeisRequest = z.infer<
  typeof createProductWithImeisSchema
>;
