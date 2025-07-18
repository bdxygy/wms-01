import { createClient } from "@libsql/client";
import { drizzle as drizzleBetterSqlite } from "drizzle-orm/better-sqlite3";
import { drizzle as drizzleLibsql } from "drizzle-orm/libsql";
import * as schema from "../models";
import { env } from "./env";

// Database type based on environment
export type DatabaseType = "better-sqlite3" | "libsql";

let dbInstance:
  | ReturnType<typeof drizzleBetterSqlite>
  | ReturnType<typeof drizzleLibsql>;
let dbType: DatabaseType;

function createDatabase() {
  const client = createClient({
    url: env.DATABASE_URL,
    authToken: env.DATABASE_AUTH_TOKEN,
  });

  dbInstance = drizzleLibsql(client, { schema });
  dbType = "libsql";

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
