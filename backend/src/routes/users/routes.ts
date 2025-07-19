import { Hono } from "hono";
import { ValidationMiddleware } from "../../utils/validation";
import { authMiddleware } from "../../middleware/auth.middleware";
import { 
  requireOwnerRole,
  requireStaffCannotCreateUsers,
  requireAdminCanOnlyCreateStaff,
  requireAdminCanOnlySetStaffRole,
  requireUserAccess,
  extractParamId
} from "../../middleware/authorization.middleware";
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
  requireStaffCannotCreateUsers(),
  requireAdminCanOnlyCreateStaff(),
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
  requireUserAccess(extractParamId("id")),
  getUserHandler
);

// Update user endpoint
users.put(
  "/:id",
  authMiddleware,
  ValidationMiddleware.params(userIdParamSchema),
  ValidationMiddleware.body(updateUserSchema),
  requireUserAccess(extractParamId("id")),
  requireAdminCanOnlySetStaffRole(),
  updateUserHandler
);

// Delete user endpoint (OWNER only)
users.delete(
  "/:id",
  authMiddleware,
  ValidationMiddleware.params(userIdParamSchema),
  requireOwnerRole(),
  deleteUserHandler
);

export { users as userRoutes };