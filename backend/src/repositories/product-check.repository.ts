import { and, eq, isNull, gte, lte, ne, desc, sql } from 'drizzle-orm';
import { BaseRepositoryImpl } from './base.repository';
import { productChecks, type ProductCheck, type NewProductCheck } from '../models/product_checks';

export class ProductCheckRepository extends BaseRepositoryImpl<ProductCheck, NewProductCheck, Partial<ProductCheck>> {
  constructor() {
    super(productChecks);
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

  async findByStoreId(storeId: string, options: any = {}) {
    return this.findAll({
      ...options,
      filters: { ...(options.filters || {}), storeId }
    });
  }

  async findByStatus(status: string, options: any = {}) {
    return this.findAll({
      ...options,
      filters: { ...(options.filters || {}), status }
    });
  }

  async findPendingChecks(options: any = {}) {
    return this.findAll({
      ...options,
      filters: { ...(options.filters || {}), status: 'PENDING' }
    });
  }

  async findCompletedChecks(options: any = {}) {
    return this.findAll({
      ...options,
      filters: { 
        ...(options.filters || {}), 
        status: ['OK', 'MISSING', 'BROKEN'] 
      }
    });
  }

  async findProblematicChecks(options: any = {}) {
    return this.findAll({
      ...options,
      filters: { 
        ...(options.filters || {}), 
        status: ['MISSING', 'BROKEN'] 
      }
    });
  }

  async findChecksByDateRange(startDate: Date, endDate: Date, options: any = {}) {
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
    return results as ProductCheck[];
  }

  async findChecksByOwnerAndStatus(ownerId: string, status: string, options: any = {}) {
    return this.findAll({
      ...options,
      filters: { ...(options.filters || {}), ownerId, status }
    });
  }

  async findChecksByStoreAndStatus(storeId: string, status: string, options: any = {}) {
    return this.findAll({
      ...options,
      filters: { ...(options.filters || {}), storeId, status }
    });
  }

  async countChecksByStatus(status: string): Promise<number> {
    return this.count({
      filters: { status }
    });
  }

  async countChecksByOwner(ownerId: string): Promise<number> {
    return this.count({
      filters: { ownerId }
    });
  }

  async findLatestCheckByProduct(productId: string): Promise<ProductCheck | null> {
    const [result] = await this.getDb()
      .select()
      .from(this.table)
      .where(
        and(
          eq(this.getColumn('productId'), productId),
          isNull(this.getColumn('deletedAt'))
        )
      )
      .orderBy(desc(this.getColumn('createdAt')))
      .limit(1);
    
    return result as ProductCheck || null;
  }

  async findCheckHistory(productId: string, options: any = {}) {
    return this.findAll({
      ...options,
      filters: { ...(options.filters || {}), productId },
      sortBy: 'createdAt',
      sortOrder: 'desc'
    });
  }

  async findDiscrepancies() {
    const query = this.getDb()
      .select()
      .from(this.table)
      .where(
        and(
          ne(this.getColumn('expectedQuantity'), this.getColumn('actualQuantity')),
          isNull(this.getColumn('deletedAt'))
        )
      );
    
    const results = await query;
    return results as ProductCheck[];
  }

  async getCheckStatistics(ownerId: string) {
    const query = this.getDb()
      .select({
        status: this.getColumn('status'),
        count: sql`count(${this.getColumn('id')})`
      })
      .from(this.table)
      .where(
        and(
          eq(this.getColumn('ownerId'), ownerId),
          isNull(this.getColumn('deletedAt'))
        )
      )
      .groupBy(this.getColumn('status'));
    
    const results = await query;
    return results;
  }
}