import { drizzle as drizzleBetterSqlite } from "drizzle-orm/better-sqlite3";

import * as schema from "../models";
import { env } from "./env";
import Database from "better-sqlite3";

// Database type based on environment
export type DatabaseType = "sqlite";

let dbInstance: ReturnType<typeof drizzleBetterSqlite>;

let dbType: DatabaseType;

function createDatabase() {
  const sqlite = new Database(env.DATABASE_URL);
  dbInstance = drizzleBetterSqlite(sqlite, { schema });
  dbType = "sqlite";

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
