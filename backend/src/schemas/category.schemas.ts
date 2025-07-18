import { z } from "zod";

// Create category schema
export const createCategorySchema = z.object({
  name: z.string().min(1, "Category name is required").max(100, "Category name must be less than 100 characters"),
  storeId: z.string().uuid("Invalid store ID format"),
});

// Update category schema
export const updateCategorySchema = z.object({
  name: z.string().min(1, "Category name is required").max(100, "Category name must be less than 100 characters").optional(),
});

// Query parameters for list categories
export const listCategoriesQuerySchema = z.object({
  page: z.coerce.number().min(1).default(1),
  limit: z.coerce.number().min(1).max(100).default(10),
  search: z.string().optional(),
  storeId: z.string().uuid("Invalid store ID format").optional(),
});

// Category ID parameter schema
export const categoryIdParamSchema = z.object({
  id: z.string().uuid("Invalid category ID format"),
});

// Category response schema
export const categoryResponseSchema = z.object({
  id: z.string(),
  name: z.string(),
  storeId: z.string(),
  createdBy: z.string(),
  createdAt: z.date(),
  updatedAt: z.date(),
});

// Category list response schema
export const categoryListResponseSchema = z.object({
  categories: z.array(categoryResponseSchema),
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
export type CreateCategoryRequest = z.infer<typeof createCategorySchema>;
export type UpdateCategoryRequest = z.infer<typeof updateCategorySchema>;
export type ListCategoriesQuery = z.infer<typeof listCategoriesQuerySchema>;
export type CategoryIdParam = z.infer<typeof categoryIdParamSchema>;
export type CategoryResponse = z.infer<typeof categoryResponseSchema>;
export type CategoryListResponse = z.infer<typeof categoryListResponseSchema>;