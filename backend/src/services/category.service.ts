import { randomUUID } from "crypto";
import { db } from "../config/database";
import { categories } from "../models/categories";
import { stores } from "../models/stores";
import { eq, and, like, isNull, count } from "drizzle-orm";
import { HTTPException } from "hono/http-exception";
import type { CreateCategoryRequest, UpdateCategoryRequest, ListCategoriesQuery } from "../schemas/category.schemas";
import type { User } from "../models/users";

export class CategoryService {
  static async createCategory(data: CreateCategoryRequest, createdBy: User) {
    // Check if user has permission to create categories
    if (createdBy.role !== "OWNER" && createdBy.role !== "ADMIN") {
      throw new HTTPException(403, { message: "Only OWNER and ADMIN can create categories" });
    }

    // Verify store exists and user has access to it
    const store = await db
      .select()
      .from(stores)
      .where(eq(stores.id, data.storeId));

    if (!store[0]) {
      throw new HTTPException(404, { message: "Store not found" });
    }

    // Check store access based on user role
    if (createdBy.role === "OWNER") {
      if (store[0].ownerId !== createdBy.id) {
        throw new HTTPException(403, { message: "Access denied to this store" });
      }
    } else {
      // For ADMIN users, check if store belongs to same owner
      if (store[0].ownerId !== createdBy.ownerId) {
        throw new HTTPException(403, { message: "Access denied to this store" });
      }
    }

    // Check if category name already exists in the store
    const existingCategory = await db
      .select()
      .from(categories)
      .where(
        and(
          eq(categories.name, data.name),
          eq(categories.storeId, data.storeId),
          isNull(categories.deletedAt)
        )
      );

    if (existingCategory.length > 0) {
      throw new HTTPException(400, { message: "Category name already exists in this store" });
    }

    // Create category
    const categoryId = randomUUID();
    const category = await db.insert(categories).values({
      id: categoryId,
      name: data.name,
      storeId: data.storeId,
      createdBy: createdBy.id,
      createdAt: new Date(),
      updatedAt: new Date(),
    }).returning();

    if (!category[0]) {
      throw new HTTPException(500, { message: "Failed to create category" });
    }

    return {
      id: category[0].id,
      name: category[0].name,
      storeId: category[0].storeId,
      createdBy: category[0].createdBy,
      createdAt: category[0].createdAt,
      updatedAt: category[0].updatedAt,
    };
  }

  static async getCategoryById(id: string, requestingUser: User) {
    const category = await db
      .select({
        id: categories.id,
        name: categories.name,
        storeId: categories.storeId,
        createdBy: categories.createdBy,
        createdAt: categories.createdAt,
        updatedAt: categories.updatedAt,
        storeOwnerId: stores.ownerId,
      })
      .from(categories)
      .innerJoin(stores, eq(categories.storeId, stores.id))
      .where(
        and(
          eq(categories.id, id),
          isNull(categories.deletedAt)
        )
      );

    if (!category[0]) {
      throw new HTTPException(404, { message: "Category not found" });
    }

    // Check if user can access this category (owner scoped)
    if (requestingUser.role === "OWNER") {
      if (category[0].storeOwnerId !== requestingUser.id) {
        throw new HTTPException(403, { message: "Access denied" });
      }
    } else {
      // For non-OWNER users, check if they belong to the same owner
      if (category[0].storeOwnerId !== requestingUser.ownerId) {
        throw new HTTPException(403, { message: "Access denied" });
      }
    }

    return {
      id: category[0].id,
      name: category[0].name,
      storeId: category[0].storeId,
      createdBy: category[0].createdBy,
      createdAt: category[0].createdAt,
      updatedAt: category[0].updatedAt,
    };
  }

  static async listCategories(query: ListCategoriesQuery, requestingUser: User) {
    // Build where conditions
    const conditions = [];

    // Owner scoping - only show categories from stores owned by the user's owner
    if (requestingUser.role === "OWNER") {
      conditions.push(eq(stores.ownerId, requestingUser.id));
    } else {
      conditions.push(eq(stores.ownerId, requestingUser.ownerId!));
    }

    // Store filter
    if (query.storeId) {
      conditions.push(eq(categories.storeId, query.storeId));
    }

    // Search filter
    if (query.search) {
      conditions.push(like(categories.name, `%${query.search}%`));
    }

    // Exclude deleted categories
    conditions.push(isNull(categories.deletedAt));

    const whereClause = and(...conditions);

    // Get total count
    const totalResult = await db
      .select({ count: count() })
      .from(categories)
      .innerJoin(stores, eq(categories.storeId, stores.id))
      .where(whereClause);

    const total = totalResult[0].count;
    const totalPages = Math.ceil(total / query.limit);
    const offset = (query.page - 1) * query.limit;

    // Get categories with pagination
    const categoryList = await db
      .select({
        id: categories.id,
        name: categories.name,
        storeId: categories.storeId,
        createdBy: categories.createdBy,
        createdAt: categories.createdAt,
        updatedAt: categories.updatedAt,
      })
      .from(categories)
      .innerJoin(stores, eq(categories.storeId, stores.id))
      .where(whereClause)
      .limit(query.limit)
      .offset(offset)
      .orderBy(categories.createdAt);

    return {
      categories: categoryList,
      pagination: {
        page: query.page,
        limit: query.limit,
        total,
        totalPages,
        hasNext: query.page < totalPages,
        hasPrev: query.page > 1,
      },
    };
  }

  static async updateCategory(id: string, data: UpdateCategoryRequest, requestingUser: User) {
    // Check if user has permission to update categories
    if (requestingUser.role !== "OWNER" && requestingUser.role !== "ADMIN") {
      throw new HTTPException(403, { message: "Only OWNER and ADMIN can update categories" });
    }

    // Find category to update
    const existingCategory = await db
      .select({
        id: categories.id,
        name: categories.name,
        storeId: categories.storeId,
        createdBy: categories.createdBy,
        storeOwnerId: stores.ownerId,
      })
      .from(categories)
      .innerJoin(stores, eq(categories.storeId, stores.id))
      .where(
        and(
          eq(categories.id, id),
          isNull(categories.deletedAt)
        )
      );

    if (!existingCategory[0]) {
      throw new HTTPException(404, { message: "Category not found" });
    }

    // Check if user can update this category (owner scoped)
    if (requestingUser.role === "OWNER") {
      if (existingCategory[0].storeOwnerId !== requestingUser.id) {
        throw new HTTPException(403, { message: "Access denied" });
      }
    } else {
      // For ADMIN users, check if they belong to the same owner
      if (existingCategory[0].storeOwnerId !== requestingUser.ownerId) {
        throw new HTTPException(403, { message: "Access denied" });
      }
    }

    // Check if category name already exists in the store (if name is being updated)
    if (data.name && data.name !== existingCategory[0].name) {
      const duplicateCategory = await db
        .select()
        .from(categories)
        .where(
          and(
            eq(categories.name, data.name),
            eq(categories.storeId, existingCategory[0].storeId),
            isNull(categories.deletedAt)
          )
        );

      if (duplicateCategory.length > 0) {
        throw new HTTPException(400, { message: "Category name already exists in this store" });
      }
    }

    // Prepare update data
    const updateData: any = {
      updatedAt: new Date(),
    };

    if (data.name) updateData.name = data.name;

    // Update category
    const updatedCategory = await db
      .update(categories)
      .set(updateData)
      .where(eq(categories.id, id))
      .returning();

    if (!updatedCategory[0]) {
      throw new HTTPException(500, { message: "Failed to update category" });
    }

    return {
      id: updatedCategory[0].id,
      name: updatedCategory[0].name,
      storeId: updatedCategory[0].storeId,
      createdBy: updatedCategory[0].createdBy,
      createdAt: updatedCategory[0].createdAt,
      updatedAt: updatedCategory[0].updatedAt,
    };
  }
}