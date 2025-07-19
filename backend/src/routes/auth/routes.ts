import { Hono } from "hono";
import { ValidationMiddleware } from "../../utils/validation";
import { basicAuthMiddleware } from "../../middleware/basic-auth.middleware";
import { authMiddleware } from "../../middleware/auth.middleware";
import {
  requireStaffCannotCreateUsers,
  requireAdminCanOnlyCreateStaff,
} from "../../middleware/authorization.middleware";
import { devRegisterSchema, registerSchema, loginSchema, refreshTokenSchema } from "../../schemas/auth.schemas";
import { devRegisterHandler, registerHandler, loginHandler, refreshHandler, logoutHandler } from "./auth.handlers";

const auth = new Hono();

// Developer registration endpoint (protected with basic auth)
auth.post(
  "/dev/register",
  basicAuthMiddleware,
  ValidationMiddleware.body(devRegisterSchema),
  devRegisterHandler
);

// Regular user registration endpoint (requires authentication)
auth.post(
  "/register",
  authMiddleware,
  requireStaffCannotCreateUsers(),
  requireAdminCanOnlyCreateStaff(),
  ValidationMiddleware.body(registerSchema),
  registerHandler
);

// Login endpoint
auth.post(
  "/login",
  ValidationMiddleware.body(loginSchema),
  loginHandler
);

// Token refresh endpoint
auth.post(
  "/refresh",
  ValidationMiddleware.body(refreshTokenSchema),
  refreshHandler
);

// Logout endpoint
auth.post(
  "/logout",
  authMiddleware,
  logoutHandler
);

export { auth as authRoutes };