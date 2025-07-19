import { Hono } from "hono";
import { ValidationMiddleware } from "../../utils/validation";
import { authMiddleware } from "../../middleware/auth.middleware";
import { 
  requireOwnerRole,
  requireStoreAccess,
  extractParamId
} from "../../middleware/authorization.middleware";
import { 
  createStoreSchema, 
  updateStoreSchema, 
  listStoresQuerySchema, 
  storeIdParamSchema 
} from "../../schemas/store.schemas";
import { 
  createStoreHandler, 
  getStoreHandler, 
  listStoresHandler, 
  updateStoreHandler 
} from "./store.handlers";

const stores = new Hono();

// Create store endpoint (OWNER only)
stores.post(
  "/",
  authMiddleware,
  ValidationMiddleware.body(createStoreSchema),
  requireOwnerRole(),
  createStoreHandler
);

// List stores endpoint (filtered by owner)
stores.get(
  "/",
  authMiddleware,
  ValidationMiddleware.query(listStoresQuerySchema),
  listStoresHandler
);

// Get store by ID endpoint
stores.get(
  "/:id",
  authMiddleware,
  ValidationMiddleware.params(storeIdParamSchema),
  requireStoreAccess(extractParamId("id")),
  getStoreHandler
);

// Update store endpoint (OWNER only)
stores.put(
  "/:id",
  authMiddleware,
  ValidationMiddleware.params(storeIdParamSchema),
  ValidationMiddleware.body(updateStoreSchema),
  requireOwnerRole(),
  updateStoreHandler
);

export { stores as storeRoutes };