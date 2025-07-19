import { randomUUID } from "crypto";
import { db } from "../config/database";
import { transactions, transactionItems } from "../models/transactions";
import { stores } from "../models/stores";
import { products } from "../models/products";
import { users } from "../models/users";
import { eq, and, or, isNull, count, gte, lte } from "drizzle-orm";
import { HTTPException } from "hono/http-exception";
import type { CreateTransactionRequest, UpdateTransactionRequest, ListTransactionsQuery } from "../schemas/transaction.schemas";
import type { User } from "../models/users";

export class TransactionService {
  static async createTransaction(data: CreateTransactionRequest, createdBy: User) {
    // Verify stores exist (authorization middleware has already checked role and access)
    const storeChecks = [];
    
    if (data.fromStoreId) {
      const fromStore = await db
        .select()
        .from(stores)
        .where(eq(stores.id, data.fromStoreId));

      if (!fromStore[0]) {
        throw new HTTPException(404, { message: "From store not found" });
      }
      storeChecks.push(fromStore[0]);
    }

    if (data.toStoreId) {
      const toStore = await db
        .select()
        .from(stores)
        .where(eq(stores.id, data.toStoreId));

      if (!toStore[0]) {
        throw new HTTPException(404, { message: "To store not found" });
      }
      storeChecks.push(toStore[0]);
    }

    // Store access checks have been handled by authorization middleware

    // Verify all products exist and calculate total amount
    let totalAmount = 0;
    const productChecks = [];

    for (const item of data.items) {
      const product = await db
        .select({
          id: products.id,
          name: products.name,
          storeId: products.storeId,
          quantity: products.quantity,
          salePrice: products.salePrice,
          purchasePrice: products.purchasePrice,
          storeOwnerId: stores.ownerId,
        })
        .from(products)
        .innerJoin(stores, eq(products.storeId, stores.id))
        .where(
          and(
            eq(products.id, item.productId),
            isNull(products.deletedAt)
          )
        );

      if (!product[0]) {
        throw new HTTPException(404, { message: `Product ${item.productId} not found` });
      }

      // Product access checks have been handled by authorization middleware

      // Check if sufficient quantity is available
      if (product[0].quantity < item.quantity) {
        throw new HTTPException(400, { message: `Insufficient quantity for product ${product[0].name}` });
      }

      // For SALE transactions, validate product belongs to fromStore or toStore
      if (data.type === "SALE") {
        const validStore = data.fromStoreId === product[0].storeId || data.toStoreId === product[0].storeId;
        if (!validStore) {
          throw new HTTPException(400, { message: `Product ${product[0].name} does not belong to the specified store` });
        }
      }

      productChecks.push(product[0]);
      totalAmount += item.amount;
    }

    // Create transaction
    const transactionId = randomUUID();
    const transaction = await db.insert(transactions).values({
      id: transactionId,
      type: data.type,
      createdBy: createdBy.id,
      approvedBy: null,
      fromStoreId: data.fromStoreId || null,
      toStoreId: data.toStoreId || null,
      photoProofUrl: data.photoProofUrl || null,
      transferProofUrl: data.transferProofUrl || null,
      to: data.to || null,
      customerPhone: data.customerPhone || null,
      amount: totalAmount,
      isFinished: false,
      createdAt: new Date(),
    }).returning();

    if (!transaction[0]) {
      throw new HTTPException(500, { message: "Failed to create transaction" });
    }

    // Create transaction items
    const itemsToInsert = data.items.map(item => ({
      id: randomUUID(),
      transactionId: transactionId,
      productId: item.productId,
      name: item.name,
      price: item.price,
      quantity: item.quantity,
      amount: item.amount,
      createdAt: new Date(),
    }));

    const insertedItems = await db.insert(transactionItems).values(itemsToInsert).returning();

    return {
      id: transaction[0].id,
      type: transaction[0].type,
      createdBy: transaction[0].createdBy,
      approvedBy: transaction[0].approvedBy,
      fromStoreId: transaction[0].fromStoreId,
      toStoreId: transaction[0].toStoreId,
      photoProofUrl: transaction[0].photoProofUrl,
      transferProofUrl: transaction[0].transferProofUrl,
      to: transaction[0].to,
      customerPhone: transaction[0].customerPhone,
      amount: transaction[0].amount,
      isFinished: transaction[0].isFinished,
      createdAt: transaction[0].createdAt,
      items: insertedItems.map(item => ({
        id: item.id,
        productId: item.productId,
        name: item.name,
        price: item.price,
        quantity: item.quantity,
        amount: item.amount,
        createdAt: item.createdAt,
      })),
    };
  }

  static async getTransactionById(id: string) {
    const transaction = await db
      .select({
        id: transactions.id,
        type: transactions.type,
        createdBy: transactions.createdBy,
        approvedBy: transactions.approvedBy,
        fromStoreId: transactions.fromStoreId,
        toStoreId: transactions.toStoreId,
        photoProofUrl: transactions.photoProofUrl,
        transferProofUrl: transactions.transferProofUrl,
        to: transactions.to,
        customerPhone: transactions.customerPhone,
        amount: transactions.amount,
        isFinished: transactions.isFinished,
        createdAt: transactions.createdAt,
        fromStoreOwnerId: stores.ownerId,
      })
      .from(transactions)
      .leftJoin(stores, eq(transactions.fromStoreId, stores.id))
      .where(eq(transactions.id, id));

    if (!transaction[0]) {
      throw new HTTPException(404, { message: "Transaction not found" });
    }

    // Authorization middleware has already checked transaction access

    // Get transaction items
    const items = await db
      .select()
      .from(transactionItems)
      .where(eq(transactionItems.transactionId, id));

    return {
      id: transaction[0].id,
      type: transaction[0].type,
      createdBy: transaction[0].createdBy,
      approvedBy: transaction[0].approvedBy,
      fromStoreId: transaction[0].fromStoreId,
      toStoreId: transaction[0].toStoreId,
      photoProofUrl: transaction[0].photoProofUrl,
      transferProofUrl: transaction[0].transferProofUrl,
      to: transaction[0].to,
      customerPhone: transaction[0].customerPhone,
      amount: transaction[0].amount,
      isFinished: transaction[0].isFinished,
      createdAt: transaction[0].createdAt,
      items: items.map(item => ({
        id: item.id,
        productId: item.productId,
        name: item.name,
        price: item.price,
        quantity: item.quantity,
        amount: item.amount,
        createdAt: item.createdAt,
      })),
    };
  }

  static async listTransactions(query: ListTransactionsQuery, requestingUser: User) {
    // Build where conditions
    const conditions = [];

    // Owner scoping - only show transactions from stores owned by the user's owner
    if (requestingUser.role === "OWNER") {
      // Get all stores owned by the user
      const userStores = await db
        .select({ id: stores.id })
        .from(stores)
        .where(eq(stores.ownerId, requestingUser.id));

      const storeIds = userStores.map(store => store.id);
      if (storeIds.length > 0) {
        conditions.push(
          or(
            ...storeIds.map(storeId => eq(transactions.fromStoreId, storeId)),
            ...storeIds.map(storeId => eq(transactions.toStoreId, storeId))
          )
        );
      } else {
        // No stores owned, return empty result
        return {
          transactions: [],
          pagination: {
            page: query.page,
            limit: query.limit,
            total: 0,
            totalPages: 0,
            hasNext: false,
            hasPrev: false,
          },
        };
      }
    } else {
      // Get all stores owned by the user's owner
      const userStores = await db
        .select({ id: stores.id })
        .from(stores)
        .where(eq(stores.ownerId, requestingUser.ownerId!));

      const storeIds = userStores.map(store => store.id);
      if (storeIds.length > 0) {
        conditions.push(
          or(
            ...storeIds.map(storeId => eq(transactions.fromStoreId, storeId)),
            ...storeIds.map(storeId => eq(transactions.toStoreId, storeId))
          )
        );
      } else {
        // No stores available, return empty result
        return {
          transactions: [],
          pagination: {
            page: query.page,
            limit: query.limit,
            total: 0,
            totalPages: 0,
            hasNext: false,
            hasPrev: false,
          },
        };
      }
    }

    // Type filter
    if (query.type) {
      conditions.push(eq(transactions.type, query.type));
    }

    // Store filter
    if (query.storeId) {
      conditions.push(
        or(
          eq(transactions.fromStoreId, query.storeId),
          eq(transactions.toStoreId, query.storeId)
        )
      );
    }

    // Finished filter
    if (query.isFinished !== undefined) {
      conditions.push(eq(transactions.isFinished, query.isFinished));
    }

    // Date filters
    if (query.startDate) {
      conditions.push(gte(transactions.createdAt, query.startDate));
    }

    if (query.endDate) {
      conditions.push(lte(transactions.createdAt, query.endDate));
    }

    // Amount filters
    if (query.minAmount !== undefined) {
      conditions.push(gte(transactions.amount, query.minAmount));
    }

    if (query.maxAmount !== undefined) {
      conditions.push(lte(transactions.amount, query.maxAmount));
    }

    const whereClause = and(...conditions);

    // Get total count
    const totalResult = await db
      .select({ count: count() })
      .from(transactions)
      .where(whereClause);

    const total = totalResult[0].count;
    const totalPages = Math.ceil(total / query.limit);
    const offset = (query.page - 1) * query.limit;

    // Get transactions with pagination
    const transactionList = await db
      .select()
      .from(transactions)
      .where(whereClause)
      .limit(query.limit)
      .offset(offset)
      .orderBy(transactions.createdAt);

    // Get items for each transaction
    const transactionWithItems = await Promise.all(
      transactionList.map(async (transaction) => {
        const items = await db
          .select()
          .from(transactionItems)
          .where(eq(transactionItems.transactionId, transaction.id));

        return {
          id: transaction.id,
          type: transaction.type,
          createdBy: transaction.createdBy,
          approvedBy: transaction.approvedBy,
          fromStoreId: transaction.fromStoreId,
          toStoreId: transaction.toStoreId,
          photoProofUrl: transaction.photoProofUrl,
          transferProofUrl: transaction.transferProofUrl,
          to: transaction.to,
          customerPhone: transaction.customerPhone,
          amount: transaction.amount,
          isFinished: transaction.isFinished,
          createdAt: transaction.createdAt,
          items: items.map(item => ({
            id: item.id,
            productId: item.productId,
            name: item.name,
            price: item.price,
            quantity: item.quantity,
            amount: item.amount,
            createdAt: item.createdAt,
          })),
        };
      })
    );

    return {
      transactions: transactionWithItems,
      pagination: {
        page: query.page,
        limit: query.limit,
        total,
        totalPages,
        hasNext: query.page < totalPages,
        hasPrev: query.page > 1,
      },
    };
  }

  static async updateTransaction(id: string, data: UpdateTransactionRequest, requestingUser: User) {

    // Find transaction to update
    const existingTransaction = await db
      .select()
      .from(transactions)
      .where(eq(transactions.id, id));

    if (!existingTransaction[0]) {
      throw new HTTPException(404, { message: "Transaction not found" });
    }

    // Authorization middleware has already checked transaction access

    // If updating items, validate them
    if (data.items) {
      let totalAmount = 0;

      for (const item of data.items) {
        const product = await db
          .select({
            id: products.id,
            name: products.name,
            storeId: products.storeId,
            quantity: products.quantity,
            storeOwnerId: stores.ownerId,
          })
          .from(products)
          .innerJoin(stores, eq(products.storeId, stores.id))
          .where(
            and(
              eq(products.id, item.productId),
              isNull(products.deletedAt)
            )
          );

        if (!product[0]) {
          throw new HTTPException(404, { message: `Product ${item.productId} not found` });
        }

        // Check if user can access this product
        if (requestingUser.role === "OWNER") {
          if (product[0].storeOwnerId !== requestingUser.id) {
            throw new HTTPException(403, { message: "Access denied to product" });
          }
        } else {
          if (product[0].storeOwnerId !== requestingUser.ownerId) {
            throw new HTTPException(403, { message: "Access denied to product" });
          }
        }

        totalAmount += item.amount;
      }

      // Delete existing items
      await db
        .delete(transactionItems)
        .where(eq(transactionItems.transactionId, id));

      // Insert new items
      const itemsToInsert = data.items.map(item => ({
        id: randomUUID(),
        transactionId: id,
        productId: item.productId,
        name: item.name,
        price: item.price,
        quantity: item.quantity,
        amount: item.amount,
        createdAt: new Date(),
      }));

      await db.insert(transactionItems).values(itemsToInsert);
    }

    // Prepare update data
    const updateData: any = {};

    if (data.photoProofUrl !== undefined) updateData.photoProofUrl = data.photoProofUrl;
    if (data.transferProofUrl !== undefined) updateData.transferProofUrl = data.transferProofUrl;
    if (data.to !== undefined) updateData.to = data.to;
    if (data.customerPhone !== undefined) updateData.customerPhone = data.customerPhone;
    if (data.isFinished !== undefined) updateData.isFinished = data.isFinished;

    // Update amount if items were updated
    if (data.items) {
      const totalAmount = data.items.reduce((sum, item) => sum + item.amount, 0);
      updateData.amount = totalAmount;
    }

    // Update transaction
    const updatedTransaction = await db
      .update(transactions)
      .set(updateData)
      .where(eq(transactions.id, id))
      .returning();

    if (!updatedTransaction[0]) {
      throw new HTTPException(500, { message: "Failed to update transaction" });
    }

    // Get updated items
    const items = await db
      .select()
      .from(transactionItems)
      .where(eq(transactionItems.transactionId, id));

    return {
      id: updatedTransaction[0].id,
      type: updatedTransaction[0].type,
      createdBy: updatedTransaction[0].createdBy,
      approvedBy: updatedTransaction[0].approvedBy,
      fromStoreId: updatedTransaction[0].fromStoreId,
      toStoreId: updatedTransaction[0].toStoreId,
      photoProofUrl: updatedTransaction[0].photoProofUrl,
      transferProofUrl: updatedTransaction[0].transferProofUrl,
      to: updatedTransaction[0].to,
      customerPhone: updatedTransaction[0].customerPhone,
      amount: updatedTransaction[0].amount,
      isFinished: updatedTransaction[0].isFinished,
      createdAt: updatedTransaction[0].createdAt,
      items: items.map(item => ({
        id: item.id,
        productId: item.productId,
        name: item.name,
        price: item.price,
        quantity: item.quantity,
        amount: item.amount,
        createdAt: item.createdAt,
      })),
    };
  }
}