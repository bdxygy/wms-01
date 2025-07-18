import { Hono } from "hono";
import { ValidationMiddleware } from "../../utils/validation";
import { authMiddleware } from "../../middleware/auth.middleware";
import { 
  createUserSchema, 
  updateUserSchema, 
  listUsersQuerySchema, 
  userIdParamSchema 
} from "../../schemas/user.schemas";
import { 
  createUserHandler, 
  getUserHandler, 
  listUsersHandler, 
  updateUserHandler, 
  deleteUserHandler 
} from "./user.handlers";

const users = new Hono();

// Create user endpoint (OWNER or ADMIN only)
users.post(
  "/",
  authMiddleware,
  ValidationMiddleware.body(createUserSchema),
  createUserHandler
);

// List users endpoint (filtered by owner)
users.get(
  "/",
  authMiddleware,
  ValidationMiddleware.query(listUsersQuerySchema),
  listUsersHandler
);

// Get user by ID endpoint
users.get(
  "/:id",
  authMiddleware,
  ValidationMiddleware.params(userIdParamSchema),
  getUserHandler
);

// Update user endpoint
users.put(
  "/:id",
  authMiddleware,
  ValidationMiddleware.params(userIdParamSchema),
  ValidationMiddleware.body(updateUserSchema),
  updateUserHandler
);

// Delete user endpoint (OWNER only)
users.delete(
  "/:id",
  authMiddleware,
  ValidationMiddleware.params(userIdParamSchema),
  deleteUserHandler
);

export { users as userRoutes };