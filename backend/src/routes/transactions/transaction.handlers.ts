import { Context } from "hono";
import { TransactionService } from "../../services/transaction.service";
import { ResponseUtils } from "../../utils/responses";
import { getValidated } from "../../utils/context";
import type { CreateTransactionRequest, UpdateTransactionRequest, ListTransactionsQuery, TransactionIdParam } from "../../schemas/transaction.schemas";

export const createTransactionHandler = async (c: Context) => {
  try {
    const validatedData = getValidated<CreateTransactionRequest>(c, "validatedBody");
    const user = c.get("user");
    const result = await TransactionService.createTransaction(validatedData, user);
    return ResponseUtils.sendCreated(c, result);
  } catch (error) {
    return ResponseUtils.sendError(c, error);
  }
};

export const getTransactionHandler = async (c: Context) => {
  try {
    const { id } = getValidated<TransactionIdParam>(c, "validatedParams");
    const result = await TransactionService.getTransactionById(id);
    return ResponseUtils.sendSuccess(c, result);
  } catch (error) {
    return ResponseUtils.sendError(c, error);
  }
};

export const listTransactionsHandler = async (c: Context) => {
  try {
    const query = getValidated<ListTransactionsQuery>(c, "validatedQuery");
    const user = c.get("user");
    const result = await TransactionService.listTransactions(query, user);
    return ResponseUtils.sendPaginated(c, result.transactions, result.pagination);
  } catch (error) {
    return ResponseUtils.sendError(c, error);
  }
};

export const updateTransactionHandler = async (c: Context) => {
  try {
    const { id } = getValidated<TransactionIdParam>(c, "validatedParams");
    const validatedData = getValidated<UpdateTransactionRequest>(c, "validatedBody");
    const user = c.get("user");
    const result = await TransactionService.updateTransaction(id, validatedData, user);
    return ResponseUtils.sendSuccess(c, result);
  } catch (error) {
    return ResponseUtils.sendError(c, error);
  }
};