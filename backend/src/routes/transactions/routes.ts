import { Hono } from "hono";
import { ValidationMiddleware } from "../../utils/validation";
import { authMiddleware } from "../../middleware/auth.middleware";
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

// Create transaction endpoint (OWNER or ADMIN only)
transactions.post(
  "/",
  authMiddleware,
  ValidationMiddleware.body(createTransactionSchema),
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
  getTransactionHandler
);

// Update transaction endpoint (OWNER or ADMIN only)
transactions.put(
  "/:id",
  authMiddleware,
  ValidationMiddleware.params(transactionIdParamSchema),
  ValidationMiddleware.body(updateTransactionSchema),
  updateTransactionHandler
);

export { transactions as transactionRoutes };