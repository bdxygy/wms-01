import "dotenv/config";
import { migrate } from "drizzle-orm/better-sqlite3/migrator";
import { db } from "./database";

async function main() {
  try {
    console.log("Starting database migration...");
    // For libsql/Turso
    await migrate(db, {
      migrationsFolder: "./drizzle",
    });

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
