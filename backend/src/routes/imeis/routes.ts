import { Hono } from "hono";
import { ValidationMiddleware } from "../../utils/validation";
import { authMiddleware } from "../../middleware/auth.middleware";
import {
  requireOwnerOrAdmin,
  requireProductAccess,
  extractParamId,
} from "../../middleware/authorization.middleware";
import {
  addImeiSchema,
  productIdParamSchema,
  imeiIdParamSchema,
  imeiSearchParamSchema,
  listProductImeisQuerySchema,
  createProductWithImeisSchema,
} from "../../schemas/imei.schemas";
import {
  addImeiHandler,
  listProductImeisHandler,
  removeImeiHandler,
  createProductWithImeisHandler,
  getProductByImeiHandler,
} from "./imei.handlers";

const imeis = new Hono();

// Add IMEI endpoint (OWNER/ADMIN only)
imeis.post(
  "/products/:id/imeis",
  authMiddleware,
  requireOwnerOrAdmin(),
  ValidationMiddleware.params(productIdParamSchema),
  requireProductAccess(extractParamId("id")),
  ValidationMiddleware.body(addImeiSchema),
  addImeiHandler
);

// List product IMEIs endpoint
imeis.get(
  "/products/:id/imeis",
  authMiddleware,
  ValidationMiddleware.params(productIdParamSchema),
  requireProductAccess(extractParamId("id")),
  ValidationMiddleware.query(listProductImeisQuerySchema),
  listProductImeisHandler
);

// Remove IMEI endpoint (OWNER/ADMIN only)
imeis.delete(
  "/imeis/:id",
  authMiddleware,
  requireOwnerOrAdmin(),
  ValidationMiddleware.params(imeiIdParamSchema),
  removeImeiHandler
);

// Create product with IMEIs endpoint (OWNER/ADMIN only)
imeis.post(
  "/products/imeis",
  authMiddleware,
  requireOwnerOrAdmin(),
  ValidationMiddleware.body(createProductWithImeisSchema),
  createProductWithImeisHandler
);

// Get product by IMEI endpoint
imeis.get(
  "/products/imeis/:imei",
  authMiddleware,
  ValidationMiddleware.params(imeiSearchParamSchema),
  getProductByImeiHandler
);

export { imeis as imeiRoutes };
