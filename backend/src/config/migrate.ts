import 'dotenv/config';
import { migrate as migrateLibsql } from 'drizzle-orm/libsql/migrator';
import { migrate as migrateBetterSqlite } from 'drizzle-orm/better-sqlite3/migrator';
import { db, dbType } from './database';
import Database from 'better-sqlite3';
import { drizzle } from 'drizzle-orm/better-sqlite3';
import * as schema from '../models';

async function main() {
  try {
    console.log('Starting database migration...');
    
    if (dbType === 'better-sqlite3') {
      // For testing environment with better-sqlite3
      const sqlite = new Database(process.env.DATABASE_URL!.replace('file:', ''));
      const testDb = drizzle(sqlite, { schema });
      migrateBetterSqlite(testDb, { migrationsFolder: './drizzle' });
    } else {
      // For libsql/Turso
      await migrateLibsql(db, { migrationsFolder: './drizzle' });
    }
    
    console.log('Database migration completed successfully');
  } catch (error) {
    console.error('Migration failed:', error);
    process.exit(1);
  }
}

main().catch((error) => {
  console.error('Migration error:', error);
  process.exit(1);
});