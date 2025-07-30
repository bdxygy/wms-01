import { z } from "zod";
import { insertPhotoSchema, selectPhotoSchema, photoTypes } from "../models/photos";

// File upload schema for multipart form data
export const uploadPhotoSchema = z.object({
  type: z.enum(photoTypes, { 
    errorMap: () => ({ message: "Type must be one of: photoProof, transferProof, product" }) 
  }),
  transactionId: z.string().uuid("Transaction ID must be a valid UUID").optional(),
  productId: z.string().uuid("Product ID must be a valid UUID").optional(),
}).refine(
  (data) => (data.transactionId && !data.productId) || (!data.transactionId && data.productId),
  {
    message: "Either transactionId or productId must be provided, but not both",
    path: ["transactionId", "productId"],
  }
).refine(
  (data) => {
    // If productId is provided, type must be 'product'
    if (data.productId && data.type !== 'product') {
      return false;
    }
    // If transactionId is provided, type must be 'photoProof' or 'transferProof'
    if (data.transactionId && data.type === 'product') {
      return false;
    }
    return true;
  },
  {
    message: "Type 'product' can only be used with productId, and 'photoProof'/'transferProof' can only be used with transactionId",
    path: ["type"],
  }
);

// Direct photo creation schema (for internal use)
export const createPhotoSchema = z.object({
  publicId: z.string().min(1, "Public ID is required"),
  secureUrl: z.string().url("Secure URL must be a valid URL"),
  type: z.enum(photoTypes, { 
    errorMap: () => ({ message: "Type must be one of: photoProof, transferProof, product" }) 
  }),
  transactionId: z.string().uuid("Transaction ID must be a valid UUID").optional(),
  productId: z.string().uuid("Product ID must be a valid UUID").optional(),
}).refine(
  (data) => (data.transactionId && !data.productId) || (!data.transactionId && data.productId),
  {
    message: "Either transactionId or productId must be provided, but not both",
    path: ["transactionId", "productId"],
  }
).refine(
  (data) => {
    // If productId is provided, type must be 'product'
    if (data.productId && data.type !== 'product') {
      return false;
    }
    // If transactionId is provided, type must be 'photoProof' or 'transferProof'
    if (data.transactionId && data.type === 'product') {
      return false;
    }
    return true;
  },
  {
    message: "Type 'product' can only be used with productId, and 'photoProof'/'transferProof' can only be used with transactionId",
    path: ["type"],
  }
);

// Update photo request schema
export const updatePhotoSchema = z.object({
  publicId: z.string().min(1, "Public ID is required").optional(),
  secureUrl: z.string().url("Secure URL must be a valid URL").optional(),
});

// Param schemas
export const photoIdParamSchema = z.object({
  id: z.string().uuid("Photo ID must be a valid UUID"),
});

export const transactionIdParamSchema = z.object({
  id: z.string().uuid("Transaction ID must be a valid UUID"),
});

export const productIdParamSchema = z.object({
  id: z.string().uuid("Product ID must be a valid UUID"),
});

// Query schema for filtering photos by type
export const photoTypeQuerySchema = z.object({
  type: z.enum(photoTypes, { 
    errorMap: () => ({ message: "Type must be one of: photoProof, transferProof, product" }) 
  }).optional(),
});

// Update photo by transaction schema
export const updatePhotoByTransactionSchema = z.object({
  type: z.enum(['photoProof', 'transferProof'], { 
    errorMap: () => ({ message: "Type must be 'photoProof' or 'transferProof' for transaction photos" }) 
  }),
});

// Param schema for transaction ID in update route
export const updateTransactionPhotoParamSchema = z.object({
  transactionId: z.string().uuid("Transaction ID must be a valid UUID"),
});

// Param schema for product ID in update route  
export const updateProductPhotoParamSchema = z.object({
  productId: z.string().uuid("Product ID must be a valid UUID"),
});

// Export types
export type UploadPhotoRequest = z.infer<typeof uploadPhotoSchema>;
export type CreatePhotoRequest = z.infer<typeof createPhotoSchema>;
export type UpdatePhotoRequest = z.infer<typeof updatePhotoSchema>;
export type UpdatePhotoByTransactionRequest = z.infer<typeof updatePhotoByTransactionSchema>;
export type PhotoIdParam = z.infer<typeof photoIdParamSchema>;
export type TransactionIdParam = z.infer<typeof transactionIdParamSchema>;
export type ProductIdParam = z.infer<typeof productIdParamSchema>;
export type UpdateTransactionPhotoParam = z.infer<typeof updateTransactionPhotoParamSchema>;
export type UpdateProductPhotoParam = z.infer<typeof updateProductPhotoParamSchema>;
export type PhotoTypeQuery = z.infer<typeof photoTypeQuerySchema>;

// Re-export model schemas
export { insertPhotoSchema, selectPhotoSchema };
export type { Photo, NewPhoto, PhotoType } from "../models/photos";