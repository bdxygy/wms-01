import { randomUUID } from "crypto";
import { and, count, eq, inArray, isNull } from "drizzle-orm";
import { HTTPException } from "hono/http-exception";
import { customAlphabet } from "nanoid";
import { db } from "../config/database";
import { categories } from "../models/categories";
import { productImeis } from "../models/product_imeis";
import { products } from "../models/products";
import { stores } from "../models/stores";
import type { User } from "../models/users";
import type {
  AddImeiRequest,
  CreateProductWithImeisRequest,
  ListProductImeisQuery,
} from "../schemas/imei.schemas";

export class ImeiService {
  // Generate barcode using nanoid with numeric-alphabetical chars
  private static generateBarcode = customAlphabet(
    "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ",
    12
  );
  static async addImei(
    productId: string,
    data: AddImeiRequest,
    createdBy: User
  ) {
    // Check if user has permission to add IMEIs
    if (createdBy.role !== "OWNER" && createdBy.role !== "ADMIN") {
      throw new HTTPException(403, {
        message: "Only OWNER and ADMIN can add IMEIs",
      });
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
      throw new HTTPException(400, {
        message: "Product does not support IMEI tracking",
      });
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
    const imei = await db
      .insert(productImeis)
      .values({
        id: imeiId,
        productId: productId,
        imei: data.imei,
        createdBy: createdBy.id,
        createdAt: new Date(),
        updatedAt: new Date(),
      })
      .returning();

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

  static async listProductImeis(
    productId: string,
    query: ListProductImeisQuery,
    requestingUser: User
  ) {
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
      throw new HTTPException(400, {
        message: "Product does not support IMEI tracking",
      });
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
      imeis: imeiList.map((imei) => ({
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
      throw new HTTPException(403, {
        message: "Only OWNER and ADMIN can remove IMEIs",
      });
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

  static async createProductWithImeis(
    data: CreateProductWithImeisRequest,
    createdBy: User
  ) {
    // Check if user has permission to create products
    if (createdBy.role !== "OWNER" && createdBy.role !== "ADMIN") {
      throw new HTTPException(403, {
        message: "Only OWNER and ADMIN can create products",
      });
    }

    // Verify store exists and user has access to it
    const store = await db
      .select()
      .from(stores)
      .where(eq(stores.id, data.storeId));

    if (!store[0]) {
      throw new HTTPException(404, { message: "Store not found" });
    }

    // Check if user can access this store (owner scoped)
    if (createdBy.role === "OWNER") {
      if (store[0].ownerId !== createdBy.id) {
        throw new HTTPException(403, { message: "Access denied to store" });
      }
    } else {
      if (store[0].ownerId !== createdBy.ownerId) {
        throw new HTTPException(403, { message: "Access denied to store" });
      }
    }

    // Verify category exists if provided
    if (data.categoryId) {
      const category = await db
        .select()
        .from(categories)
        .where(eq(categories.id, data.categoryId));

      if (!category[0]) {
        throw new HTTPException(404, { message: "Category not found" });
      }
    }

    // Validate IMEI uniqueness
    const existingImeis = await db
      .select()
      .from(productImeis)
      .where(inArray(productImeis.imei, data.imeis));

    if (existingImeis.length > 0) {
      const duplicateImeis = existingImeis.map((imei) => imei.imei);
      throw new HTTPException(400, {
        message: `IMEIs already exist: ${duplicateImeis.join(", ")}`,
      });
    }

    // Validate quantity matches IMEI count
    if (data.quantity !== data.imeis.length) {
      throw new HTTPException(400, {
        message: `Quantity (${data.quantity}) must match number of IMEIs (${data.imeis.length})`,
      });
    }

    // Generate unique barcode
    let barcode: string;
    let barcodeExists = true;
    let attempts = 0;
    const maxAttempts = 10;

    while (barcodeExists && attempts < maxAttempts) {
      barcode = this.generateBarcode();

      // Check if barcode exists in owner's scope
      const existingProduct = await db
        .select()
        .from(products)
        .innerJoin(stores, eq(products.storeId, stores.id))
        .where(
          and(
            eq(products.barcode, barcode),
            createdBy.role === "OWNER"
              ? eq(stores.ownerId, createdBy.id)
              : eq(stores.ownerId, createdBy.ownerId!),
            isNull(products.deletedAt)
          )
        );

      barcodeExists = existingProduct.length > 0;
      attempts++;
    }

    if (barcodeExists) {
      throw new HTTPException(500, {
        message: "Failed to generate unique barcode",
      });
    }

    // Create product
    const productId = randomUUID();
    const product = await db
      .insert(products)
      .values({
        id: productId,
        createdBy: createdBy.id,
        storeId: data.storeId,
        name: data.name,
        categoryId: data.categoryId || null,
        sku: data.sku,
        isImei: true, // Always true for this endpoint
        barcode: barcode!,
        quantity: data.quantity,
        purchasePrice: data.purchasePrice,
        salePrice: data.salePrice || null,
        createdAt: new Date(),
        updatedAt: new Date(),
      })
      .returning();

    if (!product[0]) {
      throw new HTTPException(500, { message: "Failed to create product" });
    }

    // Create IMEIs for the product
    const imeiRecords = data.imeis.map((imei) => ({
      id: randomUUID(),
      productId: productId,
      imei: imei,
      createdBy: createdBy.id,
      createdAt: new Date(),
      updatedAt: new Date(),
    }));

    const insertedImeis = await db
      .insert(productImeis)
      .values(imeiRecords)
      .returning();

    return {
      id: product[0].id,
      createdBy: product[0].createdBy,
      storeId: product[0].storeId,
      name: product[0].name,
      categoryId: product[0].categoryId,
      sku: product[0].sku,
      isImei: product[0].isImei,
      barcode: product[0].barcode,
      quantity: product[0].quantity,
      purchasePrice: product[0].purchasePrice,
      salePrice: product[0].salePrice,
      createdAt: product[0].createdAt.toISOString(),
      updatedAt: product[0].updatedAt.toISOString(),
      imeis: insertedImeis.map((imei) => ({
        id: imei.id,
        imei: imei.imei,
        createdBy: imei.createdBy,
        createdAt: imei.createdAt.toISOString(),
        updatedAt: imei.updatedAt.toISOString(),
      })),
    };
  }
}
