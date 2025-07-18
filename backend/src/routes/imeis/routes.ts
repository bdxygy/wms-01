import { Hono } from "hono";
import { ValidationMiddleware } from "../../utils/validation";
import { authMiddleware } from "../../middleware/auth.middleware";
import { 
  addImeiSchema, 
  productIdParamSchema, 
  imeiIdParamSchema, 
  listProductImeisQuerySchema 
} from "../../schemas/imei.schemas";
import { 
  addImeiHandler, 
  listProductImeisHandler, 
  removeImeiHandler 
} from "./imei.handlers";

const imeis = new Hono();

// Add IMEI endpoint (OWNER/ADMIN only)
imeis.post(
  "/products/:id/imeis",
  authMiddleware,
  ValidationMiddleware.params(productIdParamSchema),
  ValidationMiddleware.body(addImeiSchema),
  addImeiHandler
);

// List product IMEIs endpoint
imeis.get(
  "/products/:id/imeis",
  authMiddleware,
  ValidationMiddleware.params(productIdParamSchema),
  ValidationMiddleware.query(listProductImeisQuerySchema),
  listProductImeisHandler
);

// Remove IMEI endpoint (OWNER/ADMIN only)
imeis.delete(
  "/imeis/:id",
  authMiddleware,
  ValidationMiddleware.params(imeiIdParamSchema),
  removeImeiHandler
);

export { imeis as imeiRoutes };