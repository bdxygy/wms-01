import {
  sqliteTable,
  text,
  integer,
  foreignKey,
} from "drizzle-orm/sqlite-core";
import { createInsertSchema, createSelectSchema } from "drizzle-zod";
import { relations } from "drizzle-orm";
import { users } from "./users";
import { stores } from "./stores";

export const categories = sqliteTable(
  "categories",
  {
    id: text("id").primaryKey(),
    storeId: text("store_id").notNull(),
    name: text("name").notNull(),
    createdBy: text("created_by").notNull(),
    createdAt: integer("created_at", { mode: "timestamp" })
      .notNull()
      .$defaultFn(() => new Date()),
    updatedAt: integer("updated_at", { mode: "timestamp" })
      .notNull()
      .$defaultFn(() => new Date()),
    deletedAt: integer("deleted_at", { mode: "timestamp" }),
  },
  (table) => [
    foreignKey({
      columns: [table.storeId],
      foreignColumns: [stores.id],
      name: "category_store_fk",
    }),
    foreignKey({
      columns: [table.createdBy],
      foreignColumns: [users.id],
      name: "category_created_by_fk",
    }),
  ]
);

export const categoriesRelations = relations(categories, ({ one }) => ({
  store: one(stores, {
    fields: [categories.storeId],
    references: [stores.id],
    relationName: "category_store",
  }),
  createdByUser: one(users, {
    fields: [categories.createdBy],
    references: [users.id],
    relationName: "category_created_by",
  }),
}));

export const insertCategorySchema = createInsertSchema(categories);
export const selectCategorySchema = createSelectSchema(categories);
export type Category = typeof categories.$inferSelect;
export type NewCategory = typeof categories.$inferInsert;