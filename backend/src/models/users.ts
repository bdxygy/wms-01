import {
  sqliteTable,
  text,
  integer,
  foreignKey,
} from "drizzle-orm/sqlite-core";
import { createInsertSchema, createSelectSchema } from "drizzle-zod";
import { relations } from "drizzle-orm";

export const roles = ["OWNER", "ADMIN", "STAFF", "CASHIER"] as const;
export type Role = (typeof roles)[number];

export const users = sqliteTable(
  "users",
  {
    id: text("id").primaryKey(),
    ownerId: text("owner_id"),
    name: text("name").notNull(),
    username: text("username").notNull().unique(),
    passwordHash: text("password").notNull(),
    role: text("role", { enum: roles }).notNull(),
    isActive: integer("is_active", { mode: "boolean" }).default(true),
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
      columns: [table.ownerId],
      foreignColumns: [table.id],
      name: "owned_users",
    }),
  ]
);

export const usersRelations = relations(users, ({ one, many }) => ({
  owner: one(users, {
    fields: [users.ownerId],
    references: [users.id],
    relationName: "owner_users",
  }),
  ownedUsers: many(users, {
    relationName: "owner_users",
  }),
}));

export const insertUserSchema = createInsertSchema(users);
export const selectUserSchema = createSelectSchema(users);
export type User = typeof users.$inferSelect;
export type NewUser = typeof users.$inferInsert;
