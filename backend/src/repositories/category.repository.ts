import { and, eq, isNull, like, or, sql, SQL } from 'drizzle-orm';
import { BaseRepositoryImpl } from './base.repository';
import { categories, type Category, type NewCategory } from '../models/categories';

export class CategoryRepository extends BaseRepositoryImpl<Category, NewCategory, Partial<Category>> {
  constructor() {
    super(categories);
  }

  async findByOwnerId(ownerId: string, options: any = {}) {
    return this.findAll({
      ...options,
      filters: { ...(options.filters || {}), ownerId }
    });
  }

  async findActiveCategories() {
    return this.findAll({
      filters: { isActive: true }
    });
  }

  async findActiveCategoriesByOwner(ownerId: string) {
    return this.findAll({
      filters: { ownerId, isActive: true }
    });
  }

  async searchCategoriesByName(searchTerm: string, options: any = {}) {
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
      data: results as Category[],
      total,
      page,
      limit,
      totalPages: Math.max(1, Math.ceil(total / limit)),
    };
  }

  async countCategoriesByOwner(ownerId: string): Promise<number> {
    return this.count({
      filters: { ownerId }
    });
  }

  async findCategoriesByOwnerAndStatus(ownerId: string, isActive: boolean) {
    return this.findAll({
      filters: { ownerId, isActive }
    });
  }
}