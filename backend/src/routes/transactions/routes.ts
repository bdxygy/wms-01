import { Hono } from "hono";
import { ValidationMiddleware } from "../../utils/validation";
import { authMiddleware } from "../../middleware/auth.middleware";
import {
  requireOwnerOrAdmin,
  requireTransactionAccess,
  requireTransactionPermission,
  requireTransactionUpdatePermission,
  extractParamId,
  extractBodyField,
} from "../../middleware/authorization.middleware";
import { 
  createTransactionSchema, 
  updateTransactionSchema, 
  listTransactionsQuerySchema, 
  transactionIdParamSchema 
} from "../../schemas/transaction.schemas";
import { 
  createTransactionHandler, 
  getTransactionHandler, 
  listTransactionsHandler, 
  updateTransactionHandler 
} from "./transaction.handlers";

const transactions = new Hono();

// Create transaction endpoint (role-based transaction type validation)
transactions.post(
  "/",
  authMiddleware,
  ValidationMiddleware.body(createTransactionSchema),
  requireTransactionPermission(extractBodyField("type")),
  createTransactionHandler
);

// List transactions endpoint (filtered by owner)
transactions.get(
  "/",
  authMiddleware,
  ValidationMiddleware.query(listTransactionsQuerySchema),
  listTransactionsHandler
);

// Get transaction by ID endpoint
transactions.get(
  "/:id",
  authMiddleware,
  ValidationMiddleware.params(transactionIdParamSchema),
  requireTransactionAccess(extractParamId("id")),
  getTransactionHandler
);

// Update transaction endpoint (role-based with transaction access validation)
transactions.put(
  "/:id",
  authMiddleware,
  ValidationMiddleware.params(transactionIdParamSchema),
  requireTransactionUpdatePermission(extractParamId("id")),
  requireTransactionAccess(extractParamId("id")),
  ValidationMiddleware.body(updateTransactionSchema),
  updateTransactionHandler
);

export { transactions as transactionRoutes };