import { and, eq, isNull, gte, lte, desc, sql } from 'drizzle-orm';
import { BaseRepositoryImpl } from './base.repository';
import { transactions, type Transaction, type NewTransaction } from '../models/transactions';

export class TransactionRepository extends BaseRepositoryImpl<Transaction, NewTransaction, Partial<Transaction>> {
  constructor() {
    super(transactions);
  }

  async findByOwnerId(ownerId: string, options: any = {}) {
    return this.findAll({
      ...options,
      filters: { ...(options.filters || {}), ownerId }
    });
  }

  async findByUserId(userId: string, options: any = {}) {
    return this.findAll({
      ...options,
      filters: { ...(options.filters || {}), userId }
    });
  }

  async findByProductId(productId: string, options: any = {}) {
    return this.findAll({
      ...options,
      filters: { ...(options.filters || {}), productId }
    });
  }

  async findByType(type: string, options: any = {}) {
    return this.findAll({
      ...options,
      filters: { ...(options.filters || {}), type }
    });
  }

  async findByStatus(status: string, options: any = {}) {
    return this.findAll({
      ...options,
      filters: { ...(options.filters || {}), status }
    });
  }

  async findByStoreId(storeId: string, options: any = {}) {
    return this.findAll({
      ...options,
      filters: { 
        ...(options.filters || {}), 
        $or: [
          { fromStoreId: storeId },
          { toStoreId: storeId }
        ]
      }
    });
  }

  async findSaleTransactions(options: any = {}) {
    return this.findAll({
      ...options,
      filters: { ...(options.filters || {}), type: 'SALE' }
    });
  }

  async findTransferTransactions(options: any = {}) {
    return this.findAll({
      ...options,
      filters: { 
        ...(options.filters || {}), 
        type: 'TRANSFER' 
      }
    });
  }

  async findCompletedTransactions(options: any = {}) {
    return this.findAll({
      ...options,
      filters: { ...(options.filters || {}), status: 'COMPLETED' }
    });
  }

  async findPendingTransactions(options: any = {}) {
    return this.findAll({
      ...options,
      filters: { ...(options.filters || {}), status: 'PENDING' }
    });
  }

  async findTransactionsByDateRange(startDate: Date, endDate: Date, options: any = {}) {
    const query = this.getDb()
      .select()
      .from(this.table)
      .where(
        and(
          gte(this.getColumn('createdAt'), startDate),
          lte(this.getColumn('createdAt'), endDate),
          isNull(this.getColumn('deletedAt'))
        )
      );
    
    const results = await query;
    return results as Transaction[];
  }

  async findTransactionsByOwnerAndType(ownerId: string, type: string, options: any = {}) {
    return this.findAll({
      ...options,
      filters: { ...(options.filters || {}), ownerId, type }
    });
  }

  async countTransactionsByType(type: string): Promise<number> {
    return this.count({
      filters: { type }
    });
  }

  async countTransactionsByOwner(ownerId: string): Promise<number> {
    return this.count({
      filters: { ownerId }
    });
  }

  async findRevenueByOwner(ownerId: string) {
    const query = this.getDb()
      .select({
        total: sql`sum(${this.getColumn('total')})`
      })
      .from(this.table)
      .where(
        and(
          eq(this.getColumn('ownerId'), ownerId),
          eq(this.getColumn('type'), 'SALE'),
          eq(this.getColumn('status'), 'COMPLETED'),
          isNull(this.getColumn('deletedAt'))
        )
      );
    
    const [result] = await query;
    return Number(result?.total) || 0;
  }

  async findTopSellingProducts(ownerId: string, limit: number = 10) {
    const query = this.getDb()
      .select({
        productId: this.getColumn('productId'),
        totalQuantity: sql`sum(${this.getColumn('quantity')})`,
        totalRevenue: sql`sum(${this.getColumn('total')})`
      })
      .from(this.table)
      .where(
        and(
          eq(this.getColumn('ownerId'), ownerId),
          eq(this.getColumn('type'), 'SALE'),
          eq(this.getColumn('status'), 'COMPLETED'),
          isNull(this.getColumn('deletedAt'))
        )
      )
      .groupBy(this.getColumn('productId'))
      .orderBy(desc(sql`sum(${this.getColumn('quantity')})`))
      .limit(limit);
    
    const results = await query;
    return results;
  }
}