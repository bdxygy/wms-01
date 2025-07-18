import { beforeAll, afterAll } from 'vitest';
import { db } from '../src/config/database'; // Adjust path as needed
import { migrate } from 'drizzle-orm/libsql/migrator';

beforeAll(async () => {
  // Run migrations before all tests
  // await migrate(db, { migrationsFolder: './drizzle' }); // Adjust path as needed
});

afterAll(async () => {
  // Clean up after all tests (e.g., close database connection)
  // For libsql, you might not need to explicitly close, but it's good practice
  // if db has a close method.
});