import { randomUUID } from "crypto";
import { db } from "../config/database";
import { productImeis } from "../models/product_imeis";
import { products } from "../models/products";
import { stores } from "../models/stores";
import { eq, and, count } from "drizzle-orm";
import { HTTPException } from "hono/http-exception";
import type { AddImeiRequest, ListProductImeisQuery } from "../schemas/imei.schemas";
import type { User } from "../models/users";

export class ImeiService {
  static async addImei(productId: string, data: AddImeiRequest, createdBy: User) {
    // Check if user has permission to add IMEIs
    if (createdBy.role !== "OWNER" && createdBy.role !== "ADMIN") {
      throw new HTTPException(403, { message: "Only OWNER and ADMIN can add IMEIs" });
    }

    // Verify product exists and user has access to it
    const product = await db
      .select({
        id: products.id,
        name: products.name,
        storeId: products.storeId,
        isImei: products.isImei,
        storeOwnerId: stores.ownerId,
      })
      .from(products)
      .innerJoin(stores, eq(products.storeId, stores.id))
      .where(eq(products.id, productId));

    if (!product[0]) {
      throw new HTTPException(404, { message: "Product not found" });
    }

    // Check if product supports IMEI tracking
    if (!product[0].isImei) {
      throw new HTTPException(400, { message: "Product does not support IMEI tracking" });
    }

    // Check if user can access this product (owner scoped)
    if (createdBy.role === "OWNER") {
      if (product[0].storeOwnerId !== createdBy.id) {
        throw new HTTPException(403, { message: "Access denied to product" });
      }
    } else {
      if (product[0].storeOwnerId !== createdBy.ownerId) {
        throw new HTTPException(403, { message: "Access denied to product" });
      }
    }

    // Check if IMEI already exists
    const existingImei = await db
      .select()
      .from(productImeis)
      .where(eq(productImeis.imei, data.imei));

    if (existingImei.length > 0) {
      throw new HTTPException(400, { message: "IMEI already exists" });
    }

    // Create IMEI record
    const imeiId = randomUUID();
    const imei = await db.insert(productImeis).values({
      id: imeiId,
      productId: productId,
      imei: data.imei,
      createdBy: createdBy.id,
      createdAt: new Date(),
      updatedAt: new Date(),
    }).returning();

    if (!imei[0]) {
      throw new HTTPException(500, { message: "Failed to add IMEI" });
    }

    return {
      id: imei[0].id,
      productId: imei[0].productId,
      imei: imei[0].imei,
      createdBy: imei[0].createdBy,
      createdAt: imei[0].createdAt.toISOString(),
      updatedAt: imei[0].updatedAt.toISOString(),
    };
  }

  static async listProductImeis(productId: string, query: ListProductImeisQuery, requestingUser: User) {
    // Verify product exists and user has access to it
    const product = await db
      .select({
        id: products.id,
        name: products.name,
        storeId: products.storeId,
        isImei: products.isImei,
        storeOwnerId: stores.ownerId,
      })
      .from(products)
      .innerJoin(stores, eq(products.storeId, stores.id))
      .where(eq(products.id, productId));

    if (!product[0]) {
      throw new HTTPException(404, { message: "Product not found" });
    }

    // Check if product supports IMEI tracking
    if (!product[0].isImei) {
      throw new HTTPException(400, { message: "Product does not support IMEI tracking" });
    }

    // Check if user can access this product (owner scoped)
    if (requestingUser.role === "OWNER") {
      if (product[0].storeOwnerId !== requestingUser.id) {
        throw new HTTPException(403, { message: "Access denied to product" });
      }
    } else {
      if (product[0].storeOwnerId !== requestingUser.ownerId) {
        throw new HTTPException(403, { message: "Access denied to product" });
      }
    }

    // Get total count
    const totalResult = await db
      .select({ count: count() })
      .from(productImeis)
      .where(eq(productImeis.productId, productId));

    const total = totalResult[0].count;
    const totalPages = Math.ceil(total / query.limit);
    const offset = (query.page - 1) * query.limit;

    // Get IMEIs with pagination
    const imeiList = await db
      .select()
      .from(productImeis)
      .where(eq(productImeis.productId, productId))
      .limit(query.limit)
      .offset(offset)
      .orderBy(productImeis.createdAt);

    return {
      imeis: imeiList.map(imei => ({
        id: imei.id,
        productId: imei.productId,
        imei: imei.imei,
        createdBy: imei.createdBy,
        createdAt: imei.createdAt.toISOString(),
        updatedAt: imei.updatedAt.toISOString(),
      })),
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

  static async removeImei(imeiId: string, requestingUser: User) {
    // Check if user has permission to remove IMEIs
    if (requestingUser.role !== "OWNER" && requestingUser.role !== "ADMIN") {
      throw new HTTPException(403, { message: "Only OWNER and ADMIN can remove IMEIs" });
    }

    // Find IMEI to remove
    const imei = await db
      .select({
        id: productImeis.id,
        productId: productImeis.productId,
        imei: productImeis.imei,
        createdBy: productImeis.createdBy,
        storeOwnerId: stores.ownerId,
      })
      .from(productImeis)
      .innerJoin(products, eq(productImeis.productId, products.id))
      .innerJoin(stores, eq(products.storeId, stores.id))
      .where(eq(productImeis.id, imeiId));

    if (!imei[0]) {
      throw new HTTPException(404, { message: "IMEI not found" });
    }

    // Check if user can access this IMEI (owner scoped)
    if (requestingUser.role === "OWNER") {
      if (imei[0].storeOwnerId !== requestingUser.id) {
        throw new HTTPException(403, { message: "Access denied to IMEI" });
      }
    } else {
      if (imei[0].storeOwnerId !== requestingUser.ownerId) {
        throw new HTTPException(403, { message: "Access denied to IMEI" });
      }
    }

    // Remove IMEI
    await db.delete(productImeis).where(eq(productImeis.id, imeiId));

    return {
      message: "IMEI removed successfully",
      imei: {
        id: imei[0].id,
        productId: imei[0].productId,
        imei: imei[0].imei,
        createdBy: imei[0].createdBy,
      },
    };
  }

  static async getImeiById(imeiId: string, requestingUser: User) {
    // Find IMEI
    const imei = await db
      .select({
        id: productImeis.id,
        productId: productImeis.productId,
        imei: productImeis.imei,
        createdBy: productImeis.createdBy,
        createdAt: productImeis.createdAt,
        updatedAt: productImeis.updatedAt,
        storeOwnerId: stores.ownerId,
      })
      .from(productImeis)
      .innerJoin(products, eq(productImeis.productId, products.id))
      .innerJoin(stores, eq(products.storeId, stores.id))
      .where(eq(productImeis.id, imeiId));

    if (!imei[0]) {
      throw new HTTPException(404, { message: "IMEI not found" });
    }

    // Check if user can access this IMEI (owner scoped)
    if (requestingUser.role === "OWNER") {
      if (imei[0].storeOwnerId !== requestingUser.id) {
        throw new HTTPException(403, { message: "Access denied to IMEI" });
      }
    } else {
      if (imei[0].storeOwnerId !== requestingUser.ownerId) {
        throw new HTTPException(403, { message: "Access denied to IMEI" });
      }
    }

    return {
      id: imei[0].id,
      productId: imei[0].productId,
      imei: imei[0].imei,
      createdBy: imei[0].createdBy,
      createdAt: imei[0].createdAt.toISOString(),
      updatedAt: imei[0].updatedAt.toISOString(),
    };
  }
}