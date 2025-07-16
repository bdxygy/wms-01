import { and, eq, isNull, lte, gte, like, or, sql, SQL } from 'drizzle-orm';
import { BaseRepositoryImpl } from './base.repository';
import { products, type Product, type NewProduct } from '../models/products';

export class ProductRepository extends BaseRepositoryImpl<Product, NewProduct, Partial<Product>> {
  constructor() {
    super(products);
  }

  async findByBarcode(barcode: string): Promise<Product | null> {
    const [result] = await this.getDb()
      .select()
      .from(this.table)
      .where(
        and(
          eq(this.getColumn('barcode'), barcode),
          isNull(this.getColumn('deletedAt'))
        )
      )
      .limit(1);
    
    return result as Product || null;
  }

  async findByStoreId(storeId: string, options: any = {}) {
    return this.findAll({
      ...options,
      filters: { ...(options.filters || {}), storeId }
    });
  }

  async findByCategoryId(categoryId: string, options: any = {}) {
    return this.findAll({
      ...options,
      filters: { ...(options.filters || {}), categoryId }
    });
  }

  async findByOwnerId(ownerId: string, options: any = {}) {
    return this.findAll({
      ...options,
      filters: { ...(options.filters || {}), ownerId }
    });
  }

  async findLowStock(options: any = {}) {
    const [result] = await this.getDb()
      .select()
      .from(this.table)
      .where(
        and(
          lte(this.getColumn('quantity'), this.getColumn('minStock')),
          eq(this.getColumn('isActive'), true),
          isNull(this.getColumn('deletedAt'))
        )
      );
    
    return result as Product[];
  }

  async searchByName(searchTerm: string, options: any = {}) {
    const {
      page = 1,
      limit = 10,
      sortBy = "createdAt",
      sortOrder = "desc",
      includeDeleted = false,
      filters = {},
    } = options;

    const offset = Math.max(0, (page - 1) * limit);
    
    const whereConditions: SQL[] = [];

    if (!includeDeleted) {
      whereConditions.push(isNull(this.getColumn('deletedAt')));
    }

    // Apply filters
    Object.entries(filters).forEach(([key, value]) => {
      if (value !== undefined && value !== null) {
        const column = (this.columns as any)[key];
        if (column) {
          whereConditions.push(eq(column, value));
        }
      }
    });

    // Add search conditions for name and description
    if (searchTerm) {
      const searchConditions: SQL[] = [
        like(this.getColumn('name'), `%${searchTerm}%`)
      ];
      
      // Only add description search if the description column exists
      const descriptionColumn = this.getColumn('description');
      if (descriptionColumn) {
        searchConditions.push(like(descriptionColumn, `%${searchTerm}%`));
      }
      
      if (searchConditions.length > 0) {
        whereConditions.push(or(...searchConditions));
      }
    }

    const finalWhere = whereConditions.length > 0 ? and(...whereConditions) : sql`1=1`;

    // Get total count
    const countResult = await this.getDb()
      .select({ count: sql`count(*)` })
      .from(this.table)
      .where(finalWhere);
    const [result] = countResult;
    const total = Number(result?.count) || 0;

    // Get paginated results
    const sortColumn = (this.columns as any)[sortBy];
    const orderByClause = sortColumn
      ? sortOrder === "asc"
        ? sql`${sortColumn} ASC`
        : sql`${sortColumn} DESC`
      : sql`${this.getColumn('createdAt')} DESC`;

    const resultsQuery = this.getDb()
      .select()
      .from(this.table)
      .where(finalWhere)
      .orderBy(orderByClause)
      .limit(limit)
      .offset(offset);

    const results = await resultsQuery;

    return {
      data: results as Product[],
      total,
      page,
      limit,
      totalPages: Math.max(1, Math.ceil(total / limit)),
    };
  }

  async findActiveProducts() {
    return this.findAll({
      filters: { isActive: true }
    });
  }

  async findProductsByStatus(status: string, options: any = {}) {
    return this.findAll({
      ...options,
      filters: { ...(options.filters || {}), status }
    });
  }

  async countProductsByStore(storeId: string): Promise<number> {
    return this.count({
      filters: { storeId }
    });
  }

  async findProductsInPriceRange(minPrice: number, maxPrice: number) {
    const query = this.getDb()
      .select()
      .from(this.table)
      .where(
        and(
          gte(this.getColumn('price'), minPrice),
          lte(this.getColumn('price'), maxPrice),
          isNull(this.getColumn('deletedAt'))
        )
      );
    
    const results = await query;
    return results as Product[];
  }
}