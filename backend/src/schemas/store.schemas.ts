import { z } from "zod";

// Create store request schema
export const createStoreSchema = z.object({
  name: z.string().min(1, "Store name is required"),
  type: z.string().min(1, "Store type is required"),
  addressLine1: z.string().min(1, "Address line 1 is required"),
  addressLine2: z.string().optional(),
  city: z.string().min(1, "City is required"),
  province: z.string().min(1, "Province is required"),
  postalCode: z.string().min(1, "Postal code is required"),
  country: z.string().min(1, "Country is required"),
  phoneNumber: z.string().min(1, "Phone number is required"),
  email: z.string().email("Invalid email format").optional(),
  openTime: z.string().datetime().optional(),
  closeTime: z.string().datetime().optional(),
  timezone: z.string().optional(),
  mapLocation: z.string().optional(),
});

// Update store request schema
export const updateStoreSchema = z.object({
  name: z.string().min(1, "Store name is required").optional(),
  type: z.string().min(1, "Store type is required").optional(),
  addressLine1: z.string().min(1, "Address line 1 is required").optional(),
  addressLine2: z.string().optional(),
  city: z.string().min(1, "City is required").optional(),
  province: z.string().min(1, "Province is required").optional(),
  postalCode: z.string().min(1, "Postal code is required").optional(),
  country: z.string().min(1, "Country is required").optional(),
  phoneNumber: z.string().min(1, "Phone number is required").optional(),
  email: z.string().email("Invalid email format").optional(),
  isActive: z.boolean().optional(),
  openTime: z.string().datetime().optional(),
  closeTime: z.string().datetime().optional(),
  timezone: z.string().optional(),
  mapLocation: z.string().optional(),
});

// List stores query schema
export const listStoresQuerySchema = z.object({
  page: z.coerce.number().min(1).default(1),
  limit: z.coerce.number().min(1).max(100).default(10),
  search: z.string().optional(),
  type: z.string().optional(),
  isActive: z.coerce.boolean().optional(),
  city: z.string().optional(),
  province: z.string().optional(),
});

// Store ID parameter schema
export const storeIdParamSchema = z.object({
  id: z.string().uuid("Invalid store ID format"),
});

// Store response schema
export const storeResponseSchema = z.object({
  id: z.string(),
  ownerId: z.string(),
  name: z.string(),
  type: z.string(),
  addressLine1: z.string(),
  addressLine2: z.string().nullable(),
  city: z.string(),
  province: z.string(),
  postalCode: z.string(),
  country: z.string(),
  phoneNumber: z.string(),
  email: z.string().nullable(),
  isActive: z.boolean(),
  openTime: z.string().nullable(),
  closeTime: z.string().nullable(),
  timezone: z.string().nullable(),
  mapLocation: z.string().nullable(),
  createdBy: z.string(),
  createdAt: z.string(),
  updatedAt: z.string(),
});

// Store list response schema
export const storeListResponseSchema = z.object({
  success: z.boolean(),
  data: z.array(storeResponseSchema),
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

// Type definitions
export type CreateStoreRequest = z.infer<typeof createStoreSchema>;
export type UpdateStoreRequest = z.infer<typeof updateStoreSchema>;
export type ListStoresQuery = z.infer<typeof listStoresQuerySchema>;
export type StoreIdParam = z.infer<typeof storeIdParamSchema>;
export type StoreResponse = z.infer<typeof storeResponseSchema>;