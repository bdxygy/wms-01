import { z } from "zod";

// Create product schema (without barcode - it's auto-generated)
export const createProductSchema = z.object({
  name: z.string().min(1, "Product name is required").max(200, "Product name must be less than 200 characters"),
  storeId: z.string().uuid("Invalid store ID format"),
  categoryId: z.string().uuid("Invalid category ID format").optional(),
  sku: z.string().min(1, "SKU is required").max(100, "SKU must be less than 100 characters"),
  isImei: z.boolean().default(false),
  quantity: z.number().int().min(0, "Quantity must be non-negative").default(1),
  purchasePrice: z.number().positive("Purchase price must be positive"),
  salePrice: z.number().positive("Sale price must be positive").optional(),
});

// Update product schema (without barcode - it's auto-generated)
export const updateProductSchema = z.object({
  name: z.string().min(1, "Product name is required").max(200, "Product name must be less than 200 characters").optional(),
  categoryId: z.string().uuid("Invalid category ID format").optional().nullable(),
  sku: z.string().min(1, "SKU is required").max(100, "SKU must be less than 100 characters").optional(),
  isImei: z.boolean().optional(),
  quantity: z.number().int().min(0, "Quantity must be non-negative").optional(),
  purchasePrice: z.number().positive("Purchase price must be positive").optional(),
  salePrice: z.number().positive("Sale price must be positive").optional().nullable(),
}).refine((data) => {
  // If quantity is provided and isImei is true, quantity must be 1
  if (data.isImei === true && data.quantity !== undefined && data.quantity !== 1) {
    return false;
  }
  return true;
}, {
  message: "IMEI products must have quantity of 1",
  path: ["quantity"],
});

// Query parameters for list products
export const listProductsQuerySchema = z.object({
  page: z.coerce.number().min(1).default(1),
  limit: z.coerce.number().min(1).max(100).default(10),
  search: z.string().optional(),
  storeId: z.string().uuid("Invalid store ID format").optional(),
  categoryId: z.string().uuid("Invalid category ID format").optional(),
  isImei: z.coerce.boolean().optional(),
  minPrice: z.coerce.number().min(0).optional(),
  maxPrice: z.coerce.number().min(0).optional(),
});

// Product ID parameter schema
export const productIdParamSchema = z.object({
  id: z.string().uuid("Invalid product ID format"),
});

// Barcode parameter schema
export const barcodeParamSchema = z.object({
  barcode: z.string().min(1, "Barcode is required").max(50, "Barcode must be less than 50 characters"),
});

// Product response schema
export const productResponseSchema = z.object({
  id: z.string(),
  name: z.string(),
  storeId: z.string(),
  categoryId: z.string().nullable(),
  sku: z.string(),
  isImei: z.boolean(),
  barcode: z.string(),
  quantity: z.number(),
  purchasePrice: z.number(),
  salePrice: z.number().nullable(),
  createdBy: z.string(),
  createdAt: z.date(),
  updatedAt: z.date(),
});

// Product response with relations
export const productWithRelationsSchema = z.object({
  id: z.string(),
  name: z.string(),
  storeId: z.string(),
  categoryId: z.string().nullable(),
  sku: z.string(),
  isImei: z.boolean(),
  barcode: z.string(),
  quantity: z.number(),
  purchasePrice: z.number(),
  salePrice: z.number().nullable(),
  createdBy: z.string(),
  createdAt: z.date(),
  updatedAt: z.date(),
  store: z.object({
    id: z.string(),
    name: z.string(),
  }).optional(),
  category: z.object({
    id: z.string(),
    name: z.string(),
  }).optional(),
  createdByUser: z.object({
    id: z.string(),
    name: z.string(),
  }).optional(),
});

// Product list response schema
export const productListResponseSchema = z.object({
  products: z.array(productResponseSchema),
  pagination: z.object({
    page: z.number(),
    limit: z.number(),
    total: z.number(),
    totalPages: z.number(),
    hasNext: z.boolean(),
    hasPrev: z.boolean(),
  }),
});

// Update product with IMEIs schema
export const updateProductWithImeisSchema = z.object({
  name: z.string().min(1, "Product name is required").max(200, "Product name must be less than 200 characters").optional(),
  categoryId: z.string().uuid("Invalid category ID format").optional().nullable(),
  sku: z.string().min(1, "SKU is required").max(100, "SKU must be less than 100 characters").optional(),
  purchasePrice: z.number().positive("Purchase price must be positive").optional(),
  salePrice: z.number().positive("Sale price must be positive").optional().nullable(),
  imeis: z.array(z.string().min(15, "IMEI must be at least 15 characters").max(15, "IMEI must be exactly 15 characters")).min(1, "At least one IMEI is required"),
}).refine((data) => {
  // Ensure IMEIs are unique
  const uniqueImeis = new Set(data.imeis);
  return uniqueImeis.size === data.imeis.length;
}, {
  message: "All IMEIs must be unique",
  path: ["imeis"],
});

// Type exports
export type CreateProductRequest = z.infer<typeof createProductSchema>;
export type UpdateProductRequest = z.infer<typeof updateProductSchema>;
export type UpdateProductWithImeisRequest = z.infer<typeof updateProductWithImeisSchema>;
export type ListProductsQuery = z.infer<typeof listProductsQuerySchema>;
export type ProductIdParam = z.infer<typeof productIdParamSchema>;
export type BarcodeParam = z.infer<typeof barcodeParamSchema>;
export type ProductResponse = z.infer<typeof productResponseSchema>;
export type ProductWithRelations = z.infer<typeof productWithRelationsSchema>;
export type ProductListResponse = z.infer<typeof productListResponseSchema>;