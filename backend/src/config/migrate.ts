import Database from "better-sqlite3";
import "dotenv/config";
import { drizzle } from "drizzle-orm/better-sqlite3";
import { migrate as migrateBetterSqlite } from "drizzle-orm/better-sqlite3/migrator";
import { migrate as migrateLibsql } from "drizzle-orm/libsql/migrator";
import * as schema from "../models";
import { db, dbType } from "./database";
import { drizzle as drizzleLibsql } from "drizzle-orm/libsql";

async function main() {
  try {
    console.log("Starting database migration...");

    if (dbType === "better-sqlite3") {
      // For testing environment with better-sqlite3
      const sqlite = new Database(
        process.env.DATABASE_URL!.replace("file:", "")
      );
      const testDb = drizzle(sqlite, { schema });
      migrateBetterSqlite(testDb, { migrationsFolder: "./drizzle" });
    } else {
      // For libsql/Turso
      await migrateLibsql(db as ReturnType<typeof drizzleLibsql>, {
        migrationsFolder: "./drizzle",
      });
    }

    console.log("Database migration completed successfully");
  } catch (error) {
    console.error("Migration failed:", error);
    process.exit(1);
  }
}

main().catch((error) => {
  console.error("Migration error:", error);
  process.exit(1);
});
