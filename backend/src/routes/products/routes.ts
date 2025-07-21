import { Hono } from "hono";
import { ValidationMiddleware } from "../../utils/validation";
import { authMiddleware } from "../../middleware/auth.middleware";
import {
  requireOwnerOrAdmin,
  requireProductAccess,
  extractParamId,
} from "../../middleware/authorization.middleware";
import { 
  createProductSchema, 
  updateProductSchema, 
  updateProductWithImeisSchema,
  listProductsQuerySchema, 
  productIdParamSchema,
  barcodeParamSchema 
} from "../../schemas/product.schemas";
import { 
  createProductHandler, 
  getProductHandler, 
  getProductByBarcodeHandler,
  listProductsHandler, 
  updateProductHandler,
  updateProductWithImeisHandler,
  softDeleteProductHandler
} from "./product.handlers";

const products = new Hono();

// Create product endpoint (OWNER or ADMIN only)
products.post(
  "/",
  authMiddleware,
  requireOwnerOrAdmin(),
  ValidationMiddleware.body(createProductSchema),
  createProductHandler
);

// List products endpoint (filtered by owner/store)
products.get(
  "/",
  authMiddleware,
  ValidationMiddleware.query(listProductsQuerySchema),
  listProductsHandler
);

// Get product by barcode endpoint (must be before /:id to avoid conflicts)
// Note: No product access middleware here since we're searching by barcode
// Owner scoping will be handled in the service layer
products.get(
  "/barcode/:barcode",
  authMiddleware,
  ValidationMiddleware.params(barcodeParamSchema),
  getProductByBarcodeHandler
);

// Get product by ID endpoint
products.get(
  "/:id",
  authMiddleware,
  ValidationMiddleware.params(productIdParamSchema),
  requireProductAccess(extractParamId("id")),
  getProductHandler
);

// Update product endpoint (OWNER or ADMIN only)
products.put(
  "/:id",
  authMiddleware,
  requireOwnerOrAdmin(),
  ValidationMiddleware.params(productIdParamSchema),
  requireProductAccess(extractParamId("id")),
  ValidationMiddleware.body(updateProductSchema),
  updateProductHandler
);

// Update product with IMEIs endpoint (OWNER or ADMIN only)
products.put(
  "/:id/imeis",
  authMiddleware,
  requireOwnerOrAdmin(),
  ValidationMiddleware.params(productIdParamSchema),
  requireProductAccess(extractParamId("id")),
  ValidationMiddleware.body(updateProductWithImeisSchema),
  updateProductWithImeisHandler
);

// Soft delete product endpoint (OWNER only)
products.delete(
  "/:id",
  authMiddleware,
  requireOwnerOrAdmin(),
  ValidationMiddleware.params(productIdParamSchema),
  requireProductAccess(extractParamId("id")),
  softDeleteProductHandler
);

export { products as productRoutes };