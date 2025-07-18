import { Hono } from "hono";
import { ValidationMiddleware } from "../../utils/validation";
import { authMiddleware } from "../../middleware/auth.middleware";
import { 
  createProductSchema, 
  updateProductSchema, 
  listProductsQuerySchema, 
  productIdParamSchema,
  barcodeParamSchema 
} from "../../schemas/product.schemas";
import { 
  createProductHandler, 
  getProductHandler, 
  getProductByBarcodeHandler,
  listProductsHandler, 
  updateProductHandler 
} from "./product.handlers";

const products = new Hono();

// Create product endpoint (OWNER or ADMIN only)
products.post(
  "/",
  authMiddleware,
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
  getProductHandler
);

// Update product endpoint (OWNER or ADMIN only)
products.put(
  "/:id",
  authMiddleware,
  ValidationMiddleware.params(productIdParamSchema),
  ValidationMiddleware.body(updateProductSchema),
  updateProductHandler
);

export { products as productRoutes };