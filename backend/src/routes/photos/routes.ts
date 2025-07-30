import { Hono } from "hono";
import { ValidationMiddleware } from "../../utils/validation";
import { authMiddleware } from "../../middleware/auth.middleware";
import {
  photoIdParamSchema,
  transactionIdParamSchema,
  productIdParamSchema,
  photoTypeQuerySchema,
  updateTransactionPhotoParamSchema,
  updateProductPhotoParamSchema,
  uploadPhotoSchema,
} from "../../schemas/photo.schemas";
import {
  uploadPhotoHandler,
  getPhotosByTransactionHandler,
  getPhotosByProductHandler,
  deletePhotoHandler,
  updatePhotoByTransactionHandler,
  updatePhotoByProductHandler,
} from "./photo.handlers";

const photos = new Hono();

// Upload photo endpoint - multipart form data with image file
// Form fields: image (File), type (photoProof|transferProof|product), transactionId (optional), productId (optional)
// - type='product' requires productId
// - type='photoProof' or type='transferProof' requires transactionId
photos.post(
  "/",
  authMiddleware,
  uploadPhotoHandler
);

// Get photos by transaction ID endpoint
// Query parameter: ?type=photoProof|transferProof (optional)
photos.get(
  "/transaction/:id",
  authMiddleware,
  ValidationMiddleware.params(transactionIdParamSchema),
  ValidationMiddleware.query(photoTypeQuerySchema),
  getPhotosByTransactionHandler
);

// Get photos by product ID endpoint  
// Query parameter: ?type=product (optional, but only 'product' is valid)
photos.get(
  "/product/:id",
  authMiddleware,
  ValidationMiddleware.params(productIdParamSchema),
  ValidationMiddleware.query(photoTypeQuerySchema),
  getPhotosByProductHandler
);

// Delete photo endpoint - soft delete with Cloudinary cleanup
photos.delete(
  "/:id",
  authMiddleware,
  ValidationMiddleware.params(photoIdParamSchema),
  deletePhotoHandler
);

// Update photo by transaction ID endpoint - replaces existing photo or creates new one
// Query parameter: ?type=photoProof|transferProof (required)
// Form data: image (File, required)
photos.put(
  "/transaction/:transactionId",
  authMiddleware,
  ValidationMiddleware.params(updateTransactionPhotoParamSchema),
  updatePhotoByTransactionHandler
);

// Update photo by product ID endpoint - replaces existing photo or creates new one
// Form data: image (File, required)
photos.put(
  "/product/:productId",
  authMiddleware,
  ValidationMiddleware.params(updateProductPhotoParamSchema),
  updatePhotoByProductHandler
);

export { photos as photoRoutes };