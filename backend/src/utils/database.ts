/**
 * Database utilities for the WMS application
 * Provides connection management and query helpers for Drizzle ORM
 */

import { and, eq, isNull, sql, type SQL } from "drizzle-orm";
import type { SQLiteTable } from "drizzle-orm/sqlite-core";
import { db, getDatabaseInstance, getDatabaseType } from "../config/database";
import { InternalServerError, NotFoundError } from "./errors";

/**
 * Database connection and query utilities
 */
export class DatabaseUtils {
  /**
   * Gets the database instance
   */
  static getDb() {
    return getDatabaseInstance();
  }

  /**
   * Gets the database type
   */
  static getDbType() {
    return getDatabaseType();
  }

  /**
   * Checks if a record exists by ID
   */
  static async exists(table: SQLiteTable, id: string): Promise<boolean> {
    try {
      const result = await db
        // @ts-ignore
        .select({ id: (table as any).id })
        .from(table)
        .where(and(eq((table as any).id, id), isNull((table as any).deletedAt)))
        .limit(1);

      return result.length > 0;
    } catch (error) {
      throw new InternalServerError(
        "Database existence check failed",
        error instanceof Error ? error : undefined
      );
    }
  }

  /**
   * Finds a record by ID or throws NotFoundError
   */
  static async findByIdOrThrow(
    table: SQLiteTable,
    id: string,
    resourceName: string = "Record"
  ): Promise<any> {
    try {
      const result = await db
        .select()
        .from(table)
        .where(and(eq((table as any).id, id), isNull((table as any).deletedAt)))
        .limit(1);

      if (result.length === 0) {
        throw new NotFoundError(resourceName);
      }

      return result[0];
    } catch (error) {
      if (error instanceof NotFoundError) {
        throw error;
      }
      throw new InternalServerError(
        "Database query failed",
        error instanceof Error ? error : undefined
      );
    }
  }

  /**
   * Soft deletes a record by setting deletedAt timestamp
   */
  static async softDelete(
    table: SQLiteTable,
    id: string,
    resourceName: string = "Record"
  ): Promise<void> {
    try {
      const now = new Date();
      await db
        .update(table)
        .set({ deletedAt: now } as any)
        .where(
          and(eq((table as any).id, id), isNull((table as any).deletedAt))
        );

      // Verify the record was actually soft deleted
      const stillExists = await this.exists(table, id);
      if (stillExists) {
        throw new NotFoundError(resourceName);
      }
    } catch (error) {
      if (error instanceof NotFoundError) {
        throw error;
      }
      throw new InternalServerError(
        "Database soft delete failed",
        error instanceof Error ? error : undefined
      );
    }
  }

  /**
   * Creates a condition for owner-scoped queries
   */
  static ownerScope(table: SQLiteTable, ownerId: string): SQL {
    // Try ownerId first, fall back to createdBy for tables without ownerId
    const tableAny = table as any;
    if (tableAny.ownerId) {
      return eq(tableAny.ownerId, ownerId);
    } else if (tableAny.createdBy) {
      return eq(tableAny.createdBy, ownerId);
    }
    throw new Error("Table does not support owner scoping");
  }

  /**
   * Creates a condition for active (non-deleted) records
   */
  static activeScope(table: SQLiteTable): SQL {
    return isNull((table as any).deletedAt);
  }

  /**
   * Creates a combined condition for owner-scoped active records
   */
  static ownerActiveScope(table: SQLiteTable, ownerId: string): SQL {
    return and(this.ownerScope(table, ownerId), this.activeScope(table))!;
  }

  /**
   * Builds pagination query with offset and limit
   */
  static paginate<T>(query: T, offset: number, limit: number) {
    return (query as any).offset(offset).limit(limit);
  }

  /**
   * Counts total records for pagination
   */
  static async count(table: SQLiteTable, where?: SQL): Promise<number> {
    try {
      const baseCondition = this.activeScope(table);
      const condition = where ? and(baseCondition, where) : baseCondition;

      const result = await db
        // @ts-ignore
        .select({ count: sql<number>`count(*)` })
        .from(table)
        .where(condition);

      return result[0]?.count || 0;
    } catch (error) {
      throw new InternalServerError(
        "Database count query failed",
        error instanceof Error ? error : undefined
      );
    }
  }

  /**
   * Generates a new UUID using database function or fallback
   */
  static generateId(): string {
    // Using crypto.randomUUID() as a fallback since it's available in Node.js 14.17+
    return crypto.randomUUID();
  }

  /**
   * Creates timestamp for current time
   */
  static now(): Date {
    return new Date();
  }

  /**
   * Validates that required foreign key references exist
   */
  static async validateForeignKeys(
    references: Array<{
      table: any;
      id: string;
      name: string;
    }>
  ): Promise<void> {
    for (const ref of references) {
      const exists = await this.exists(ref.table, ref.id);
      if (!exists) {
        throw new NotFoundError(ref.name);
      }
    }
  }
}

/**
 * Database transaction utilities for the WMS application
 * Provides advanced transaction management and rollback capabilities
 */
export class DatabaseTransactionUtils {
  /**
   * Executes a database transaction with proper error handling
   */
  static async executeTransaction<T>(
    callback: (tx: any) => Promise<T>,
    options?: {
      maxRetries?: number;
      retryDelay?: number;
      isolationLevel?: 'read uncommitted' | 'read committed' | 'repeatable read' | 'serializable';
    }
  ): Promise<T> {
    const { maxRetries = 3, retryDelay = 100 } = options || {};
    
    let lastError: Error | undefined;
    
    for (let attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        // @ts-ignore - Drizzle transaction typing issues
        return await db.transaction(async (tx) => {
          return await callback(tx);
        });
      } catch (error) {
        lastError = error instanceof Error ? error : new Error('Unknown transaction error');
        
        // Check if error is retryable (deadlock, lock timeout, etc.)
        if (this.isRetryableError(lastError) && attempt < maxRetries) {
          await this.delay(retryDelay * attempt); // Exponential backoff
          continue;
        }
        
        // If not retryable or max retries reached, throw the error
        throw new InternalServerError(
          `Transaction failed after ${attempt} attempts: ${lastError.message}`,
          lastError
        );
      }
    }
    
    // Should never reach here, but TypeScript requires it
    throw new InternalServerError(
      'Transaction failed unexpectedly',
      lastError
    );
  }

  /**
   * Executes multiple operations in a single transaction
   */
  static async executeBatch<T>(
    operations: Array<(tx: any) => Promise<T>>
  ): Promise<T[]> {
    return this.executeTransaction(async (tx) => {
      const results: T[] = [];
      
      for (const operation of operations) {
        const result = await operation(tx);
        results.push(result);
      }
      
      return results;
    });
  }

  /**
   * Executes a transaction with savepoints for partial rollback
   */
  static async executeWithSavepoint<T>(
    callback: (tx: any, createSavepoint: (name: string) => Promise<void>, rollbackToSavepoint: (name: string) => Promise<void>) => Promise<T>
  ): Promise<T> {
    return this.executeTransaction(async (tx) => {
      const savepoints = new Set<string>();
      
      const createSavepoint = async (name: string) => {
        await tx.execute(sql.raw(`SAVEPOINT ${name}`));
        savepoints.add(name);
      };
      
      const rollbackToSavepoint = async (name: string) => {
        if (!savepoints.has(name)) {
          throw new Error(`Savepoint '${name}' does not exist`);
        }
        await tx.execute(sql.raw(`ROLLBACK TO SAVEPOINT ${name}`));
      };
      
      try {
        return await callback(tx, createSavepoint, rollbackToSavepoint);
      } finally {
        // Clean up savepoints
        for (const savepoint of savepoints) {
          try {
            await tx.execute(sql.raw(`RELEASE SAVEPOINT ${savepoint}`));
          } catch {
            // Ignore cleanup errors
          }
        }
      }
    });
  }

  /**
   * Executes a read-only transaction for complex queries
   */
  static async executeReadOnlyTransaction<T>(
    callback: (tx: any) => Promise<T>
  ): Promise<T> {
    return this.executeTransaction(async (tx) => {
      // Start read-only transaction (SQLite specific)
      await tx.execute(sql.raw('BEGIN DEFERRED'));
      
      try {
        const result = await callback(tx);
        
        // For read-only, we can just rollback to avoid any potential writes
        await tx.execute(sql.raw('ROLLBACK'));
        
        return result;
      } catch (error) {
        await tx.execute(sql.raw('ROLLBACK'));
        throw error;
      }
    });
  }

  /**
   * Validates that all operations in a transaction complete successfully
   * before committing, with optional validation callbacks
   */
  static async executeValidatedTransaction<T>(
    operations: Array<(tx: any) => Promise<T>>,
    validators?: Array<(results: T[], tx: any) => Promise<void>>
  ): Promise<T[]> {
    return this.executeTransaction(async (tx) => {
      // Execute all operations
      const results: T[] = [];
      
      for (const operation of operations) {
        const result = await operation(tx);
        results.push(result);
      }
      
      // Run validation callbacks if provided
      if (validators) {
        for (const validator of validators) {
          await validator(results, tx);
        }
      }
      
      return results;
    });
  }

  /**
   * Creates a transaction context that can be passed around
   */
  static async createTransactionContext<T>(
    callback: (context: TransactionContext) => Promise<T>
  ): Promise<T> {
    return this.executeTransaction(async (tx) => {
      const context: TransactionContext = {
        tx,
        operations: [],
        rollbackCallbacks: [],
        
        async addOperation<U>(operation: (tx: any) => Promise<U>): Promise<U> {
          const result = await operation(tx);
          this.operations.push(result);
          return result;
        },
        
        addRollbackCallback(callback: () => Promise<void> | void) {
          this.rollbackCallbacks.push(callback);
        },
        
        async executeRollbackCallbacks() {
          for (const callback of this.rollbackCallbacks.reverse()) {
            try {
              await callback();
            } catch (error) {
              console.error('Rollback callback failed:', error);
            }
          }
        }
      };
      
      try {
        return await callback(context);
      } catch (error) {
        await context.executeRollbackCallbacks();
        throw error;
      }
    });
  }

  /**
   * Checks if an error is retryable (deadlock, busy database, etc.)
   */
  private static isRetryableError(error: Error): boolean {
    const retryableMessages = [
      'database is busy',
      'database is locked',
      'deadlock',
      'SQLITE_BUSY',
      'SQLITE_LOCKED'
    ];
    
    return retryableMessages.some(message => 
      error.message.toLowerCase().includes(message.toLowerCase())
    );
  }

  /**
   * Creates a delay for retry logic
   */
  private static delay(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}

/**
 * Transaction context interface for advanced transaction management
 */
export interface TransactionContext {
  tx: any;
  operations: any[];
  rollbackCallbacks: Array<() => Promise<void> | void>;
  
  addOperation<T>(operation: (tx: any) => Promise<T>): Promise<T>;
  addRollbackCallback(callback: () => Promise<void> | void): void;
  executeRollbackCallbacks(): Promise<void>;
}

/**
 * Query builder utilities for common database patterns
 */
export class QueryUtils {
  /**
   * Creates a base query for listing records with owner scope
   */
  static createOwnerScopedListQuery(table: SQLiteTable, ownerId: string) {
    return db
      .select()
      .from(table)
      .where(DatabaseUtils.ownerActiveScope(table, ownerId));
  }

  /**
   * Creates a query for finding a single record by ID with owner scope
   */
  static createOwnerScopedFindQuery(
    table: SQLiteTable,
    id: string,
    ownerId: string
  ) {
    return db
      .select()
      .from(table)
      .where(
        and(
          eq((table as any).id, id),
          DatabaseUtils.ownerActiveScope(table, ownerId)
        )
      )
      .limit(1);
  }
}

/**
 * Connection health check utilities
 */
export class HealthCheckUtils {
  /**
   * Performs a basic database health check
   */
  static async checkDatabaseHealth(): Promise<{
    healthy: boolean;
    type: string;
    timestamp: string;
  }> {
    try {
      // Simple query to test database connectivity
      // @ts-ignore
      await db.execute(sql`SELECT 1`);

      return {
        healthy: true,
        type: getDatabaseType(),
        timestamp: new Date().toISOString(),
      };
    } catch (error) {
      return {
        healthy: false,
        type: getDatabaseType(),
        timestamp: new Date().toISOString(),
      };
    }
  }
}
