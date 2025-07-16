// @ts-nocheck
import { and, eq, isNull, like, or, sql, SQL } from "drizzle-orm";
import { SQLiteTable } from "drizzle-orm/sqlite-core";
import { getTableColumns } from "drizzle-orm";
import { db } from "../config/database";

export interface PaginationOptions {
  page: number;
  limit: number;
  sortBy?: string;
  sortOrder?: "asc" | "desc";
}

export interface PaginatedResult<T> {
  data: T[];
  total: number;
  page: number;
  limit: number;
  totalPages: number;
}

export interface QueryOptions {
  includeDeleted?: boolean;
  filters?: Record<string, any>;
}

export interface BaseRepository<
  T extends Record<string, any>,
  C = Partial<T>,
  U = Partial<T>
> {
  create(data: C): Promise<T>;
  findById(id: string, options?: QueryOptions): Promise<T | null>;
  findAll(
    options?: Partial<QueryOptions & PaginationOptions>
  ): Promise<PaginatedResult<T>>;
  update(id: string, data: U): Promise<T | null>;
  delete(id: string): Promise<boolean>;
  softDelete(id: string): Promise<boolean>;
  restore(id: string): Promise<boolean>;
  count(options?: QueryOptions): Promise<number>;
  exists(id: string): Promise<boolean>;
}

export abstract class BaseRepositoryImpl<
  T extends Record<string, any>,
  C = Partial<T>,
  U = Partial<T>
> implements BaseRepository<T, C, U>
{
  protected readonly table: SQLiteTable;
  protected readonly db = db;
  protected readonly columns: ReturnType<typeof getTableColumns>;

  constructor(table: SQLiteTable) {
    this.table = table;
    this.columns = getTableColumns(table);
  }

  async create(data: C): Promise<T> {
    const [result] = await this.db
      .insert(this.table)
      .values(data as any)
      .returning();
    return result as T;
  }

  async findById(id: string, options: QueryOptions = {}): Promise<T | null> {
    const { includeDeleted = false } = options;

    const whereConditions: SQL[] = [eq(this.columns.id, id)];

    if (!includeDeleted) {
      whereConditions.push(isNull(this.columns.deletedAt));
    }

    const [result] = await this.db
      .select()
      .from(this.table)
      .where(and(...whereConditions))
      .limit(1);

    return (result as T) || null;
  }

  async findAll(
    options: Partial<QueryOptions & PaginationOptions> = {}
  ): Promise<PaginatedResult<T>> {
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
      whereConditions.push(isNull(this.columns.deletedAt));
    }

    // Apply filters - only allow exact matches for security
    Object.entries(filters).forEach(([key, value]) => {
      if (value !== undefined && value !== null) {
        const column = (this.columns as any)[key];
        if (column) {
          whereConditions.push(eq(column, value));
        }
      }
    });

    const finalWhere =
      whereConditions.length > 0 ? and(...whereConditions) : sql`1=1`;

    // Get total count
    const countResult = await this.db
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
      : sql`${this.columns.createdAt} DESC`;

    const resultsQuery = this.db
      .select()
      .from(this.table)
      .where(finalWhere)
      .orderBy(orderByClause)
      .limit(limit)
      .offset(offset);

    const results = await resultsQuery;

    return {
      data: results as T[],
      total,
      page,
      limit,
      totalPages: Math.max(1, Math.ceil(total / limit)),
    };
  }

  async update(id: string, data: U): Promise<T | null> {
    const [result] = await this.db
      .update(this.table)
      .set({ ...data, updatedAt: new Date() } as any)
      .where(and(eq(this.columns.id, id), isNull(this.columns.deletedAt)))
      .returning();

    return (result as T) || null;
  }

  async delete(id: string): Promise<boolean> {
    const result = await this.db
      .delete(this.table)
      .where(eq(this.columns.id, id))
      .returning({ id: this.columns.id });

    return result.length > 0;
  }

  async softDelete(id: string): Promise<boolean> {
    const [result] = await this.db
      .update(this.table)
      .set({ deletedAt: new Date(), updatedAt: new Date() } as any)
      .where(and(eq(this.columns.id, id), isNull(this.columns.deletedAt)))
      .returning({ id: this.columns.id });

    return !!result;
  }

  async restore(id: string): Promise<boolean> {
    const [result] = await this.db
      .update(this.table)
      .set({ deletedAt: null, updatedAt: new Date() } as any)
      .where(eq(this.columns.id, id))
      .returning({ id: this.columns.id });

    return !!result;
  }

  async count(options: QueryOptions = {}): Promise<number> {
    const { includeDeleted = false, filters = {} } = options;

    const whereConditions: SQL[] = [];

    if (!includeDeleted) {
      whereConditions.push(isNull(this.columns.deletedAt));
    }

    // Apply filters - only allow exact matches for security
    Object.entries(filters).forEach(([key, value]) => {
      if (value !== undefined && value !== null) {
        const column = (this.columns as any)[key];
        if (column) {
          whereConditions.push(eq(column, value));
        }
      }
    });

    const finalWhere =
      whereConditions.length > 0 ? and(...whereConditions) : sql`1=1`;

    const [result] = await this.db
      .select({ count: sql`count(*)`.as("count") })
      .from(this.table)
      .where(finalWhere);

    return Number(result?.count) || 0;
  }

  async exists(id: string): Promise<boolean> {
    const [result] = await this.db
      .select({ id: this.columns.id })
      .from(this.table)
      .where(and(eq(this.columns.id, id), isNull(this.columns.deletedAt)))
      .limit(1);

    return !!result;
  }

  // Utility method for custom queries
  protected getQueryBuilder() {
    return this.db.select().from(this.table);
  }

  // Utility method for transaction support
  protected getDb() {
    return this.db;
  }

  // Helper method to get column by name
  protected getColumn<K extends keyof typeof this.columns>(name: K) {
    return this.columns[name];
  }
}
