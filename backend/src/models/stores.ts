import { sqliteTable, text, integer } from "drizzle-orm/sqlite-core";
import { createInsertSchema, createSelectSchema } from "drizzle-zod";
import { relations } from "drizzle-orm";
import { users } from "./users";

export const stores = sqliteTable("stores", {
  id: text("id").primaryKey(),
  ownerId: text("owner_id")
    .notNull()
    .references(() => users.id),
  name: text("name").notNull(),
  type: text("type").notNull(),
  addressLine1: text("address_line1").notNull(),
  addressLine2: text("address_line2"),
  city: text("city").notNull(),
  province: text("province").notNull(),
  postalCode: text("postal_code").notNull(),
  country: text("country").notNull(),
  phoneNumber: text("phone_number").notNull(),
  email: text("email"),
  isActive: integer("is_active", { mode: "boolean" }).default(true),
  openTime: integer("open_time", { mode: "timestamp" }),
  closeTime: integer("close_time", { mode: "timestamp" }),
  timezone: text("timezone").default("Asia/Jakarta"),
  mapLocation: text("map_location"),
  createdBy: text("created_by")
    .notNull()
    .references(() => users.id),
  createdAt: integer("created_at", { mode: "timestamp" })
    .notNull()
    .$defaultFn(() => new Date()),
  updatedAt: integer("updated_at", { mode: "timestamp" })
    .notNull()
    .$defaultFn(() => new Date()),
  deletedAt: integer("deleted_at", { mode: "timestamp" }),
});

export const storesRelations = relations(stores, ({ one, many }) => ({
  owner: one(users, {
    fields: [stores.ownerId],
    references: [users.id],
  }),
  createdByUser: one(users, {
    fields: [stores.createdBy],
    references: [users.id],
  }),
}));

export const insertStoreSchema = createInsertSchema(stores);
export const selectStoreSchema = createSelectSchema(stores);
export type Store = typeof stores.$inferSelect;
export type NewStore = typeof stores.$inferInsert;
