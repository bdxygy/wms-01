import { db } from "@/config/database";
import {
  users,
  stores,
  categories,
  products,
  transactions,
  productChecks,
} from "@/models";
import { sql } from "drizzle-orm";
import { beforeEach, afterEach } from "vitest";

/**
 * Clean all test data from the database
 */
export async function cleanDatabase() {
  await db.delete(productChecks);
  await db.delete(transactions);
  await db.delete(products);
  await db.delete(categories);
  await db.delete(stores);
  await db.delete(users);
}

/**
 * Set up clean database state before each test
 */
export function setupTestDatabase() {
  beforeEach(async () => {
    await cleanDatabase();
  });

  afterEach(async () => {
    await cleanDatabase();
  });
}
