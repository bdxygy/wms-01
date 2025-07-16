import { drizzle as drizzleBetterSqlite } from 'drizzle-orm/better-sqlite3';
import { drizzle as drizzleLibsql } from 'drizzle-orm/libsql';
import Database from 'better-sqlite3';
import { createClient } from '@libsql/client';
import { env } from './env';
import * as schema from '../models';

// Database type based on environment
export type DatabaseType = 'better-sqlite3' | 'libsql';

let dbInstance: ReturnType<typeof drizzleBetterSqlite> | ReturnType<typeof drizzleLibsql>;
let dbType: DatabaseType;

function createDatabase() {
  if (env.NODE_ENV === 'test') {
    // Use better-sqlite3 for testing only (file-based)
    const sqlite = new Database(env.DATABASE_URL.replace('file:', ''));
    dbInstance = drizzleBetterSqlite(sqlite, { schema });
    dbType = 'better-sqlite3';
  } else {
    // Use Turso (libsql) for both development and production
    const client = createClient({
      url: env.DATABASE_URL,
      authToken: env.DATABASE_AUTH_TOKEN,
    });
    
    dbInstance = drizzleLibsql(client, { schema });
    dbType = 'libsql';
  }

  return { db: dbInstance, type: dbType };
}

const { db, type } = createDatabase();

export { db, type as dbType };

// Export the underlying database instance for advanced usage
export function getDatabaseInstance() {
  return db;
}

// Export for testing purposes
export function getDatabaseType(): DatabaseType {
  return type;
}