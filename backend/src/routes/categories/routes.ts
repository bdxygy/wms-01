import { Hono } from "hono";
import { ValidationMiddleware } from "../../utils/validation";
import { authMiddleware } from "../../middleware/auth.middleware";
import {
  requireOwnerOrAdmin,
  requireCategoryAccess,
  extractParamId,
} from "../../middleware/authorization.middleware";
import { 
  createCategorySchema, 
  updateCategorySchema, 
  listCategoriesQuerySchema, 
  categoryIdParamSchema 
} from "../../schemas/category.schemas";
import { 
  createCategoryHandler, 
  getCategoryHandler, 
  listCategoriesHandler, 
  updateCategoryHandler 
} from "./category.handlers";

const categories = new Hono();

// Create category endpoint (OWNER or ADMIN only)
categories.post(
  "/",
  authMiddleware,
  requireOwnerOrAdmin(),
  ValidationMiddleware.body(createCategorySchema),
  createCategoryHandler
);

// List categories endpoint (filtered by owner)
categories.get(
  "/",
  authMiddleware,
  ValidationMiddleware.query(listCategoriesQuerySchema),
  listCategoriesHandler
);

// Get category by ID endpoint
categories.get(
  "/:id",
  authMiddleware,
  ValidationMiddleware.params(categoryIdParamSchema),
  requireCategoryAccess(extractParamId("id")),
  getCategoryHandler
);

// Update category endpoint (OWNER or ADMIN only)
categories.put(
  "/:id",
  authMiddleware,
  requireOwnerOrAdmin(),
  ValidationMiddleware.params(categoryIdParamSchema),
  requireCategoryAccess(extractParamId("id")),
  ValidationMiddleware.body(updateCategorySchema),
  updateCategoryHandler
);

export { categories as categoryRoutes };