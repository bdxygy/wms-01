import { randomUUID } from "crypto";
import { customAlphabet } from "nanoid";
import { db } from "../config/database";
import { products } from "../models/products";
import { stores } from "../models/stores";
import { categories } from "../models/categories";
import { productImeis } from "../models/product_imeis";
import { eq, and, like, isNull, count, gte, lte } from "drizzle-orm";
import { HTTPException } from "hono/http-exception";
import type {
  CreateProductRequest,
  UpdateProductRequest,
  ListProductsQuery,
} from "../schemas/product.schemas";
import type { User } from "../models/users";
import { generateBarcode } from "@/utils/barcode";

export class ProductService {
  static async createProduct(data: CreateProductRequest, createdBy: User) {
    // Verify store exists (authorization middleware has already checked role and access)
    const store = await db
      .select()
      .from(stores)
      .where(eq(stores.id, data.storeId));

    if (!store[0]) {
      throw new HTTPException(404, { message: "Store not found" });
    }

    // Verify category exists and belongs to the same store (if provided)
    if (data.categoryId) {
      const category = await db
        .select()
        .from(categories)
        .where(
          and(
            eq(categories.id, data.categoryId),
            eq(categories.storeId, data.storeId),
            isNull(categories.deletedAt)
          )
        );

      if (!category[0]) {
        throw new HTTPException(404, {
          message: "Category not found or does not belong to this store",
        });
      }
    }

    // Check if SKU already exists in the store
    const existingSku = await db
      .select()
      .from(products)
      .where(
        and(
          eq(products.sku, data.sku),
          eq(products.storeId, data.storeId),
          isNull(products.deletedAt)
        )
      );

    if (existingSku.length > 0) {
      throw new HTTPException(400, {
        message: "SKU already exists in this store",
      });
    }

    // Generate unique barcode
    let barcode: string;
    let barcodeExists = true;
    let attempts = 0;

    while (barcodeExists && attempts < 10) {
      barcode = generateBarcode();
      const existingBarcode = await db
        .select()
        .from(products)
        .where(and(eq(products.barcode, barcode), isNull(products.deletedAt)));

      barcodeExists = existingBarcode.length > 0;
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
        name: data.name,
        storeId: data.storeId,
        categoryId: data.categoryId || null,
        sku: data.sku,
        isImei: data.isImei,
        barcode: barcode!,
        quantity: data.quantity,
        purchasePrice: data.purchasePrice,
        salePrice: data.salePrice || null,
        createdBy: createdBy.id,
        createdAt: new Date(),
        updatedAt: new Date(),
      })
      .returning();

    if (!product[0]) {
      throw new HTTPException(500, { message: "Failed to create product" });
    }

    return {
      id: product[0].id,
      name: product[0].name,
      storeId: product[0].storeId,
      categoryId: product[0].categoryId,
      sku: product[0].sku,
      isImei: product[0].isImei,
      barcode: product[0].barcode,
      quantity: product[0].quantity,
      purchasePrice: product[0].purchasePrice,
      salePrice: product[0].salePrice,
      createdBy: product[0].createdBy,
      createdAt: product[0].createdAt,
      updatedAt: product[0].updatedAt,
    };
  }

  static async getProductById(id: string) {
    const product = await db
      .select({
        id: products.id,
        name: products.name,
        storeId: products.storeId,
        categoryId: products.categoryId,
        sku: products.sku,
        isImei: products.isImei,
        barcode: products.barcode,
        quantity: products.quantity,
        purchasePrice: products.purchasePrice,
        salePrice: products.salePrice,
        createdBy: products.createdBy,
        createdAt: products.createdAt,
        updatedAt: products.updatedAt,
      })
      .from(products)
      .where(and(eq(products.id, id), isNull(products.deletedAt)));

    if (!product[0]) {
      throw new HTTPException(404, { message: "Product not found" });
    }

    return {
      id: product[0].id,
      name: product[0].name,
      storeId: product[0].storeId,
      categoryId: product[0].categoryId,
      sku: product[0].sku,
      isImei: product[0].isImei,
      barcode: product[0].barcode,
      quantity: product[0].quantity,
      purchasePrice: product[0].purchasePrice,
      salePrice: product[0].salePrice,
      createdBy: product[0].createdBy,
      createdAt: product[0].createdAt,
      updatedAt: product[0].updatedAt,
    };
  }

  static async getProductByBarcode(barcode: string, requestingUser: User) {
    const product = await db
      .select({
        id: products.id,
        name: products.name,
        storeId: products.storeId,
        categoryId: products.categoryId,
        sku: products.sku,
        isImei: products.isImei,
        barcode: products.barcode,
        quantity: products.quantity,
        purchasePrice: products.purchasePrice,
        salePrice: products.salePrice,
        createdBy: products.createdBy,
        createdAt: products.createdAt,
        updatedAt: products.updatedAt,
        storeOwnerId: stores.ownerId,
      })
      .from(products)
      .innerJoin(stores, eq(products.storeId, stores.id))
      .where(and(eq(products.barcode, barcode), isNull(products.deletedAt)));

    if (!product[0]) {
      throw new HTTPException(404, { message: "Product not found" });
    }

    // Check if user can access this product (owner scoped)
    if (requestingUser.role === "OWNER") {
      if (product[0].storeOwnerId !== requestingUser.id) {
        throw new HTTPException(403, { message: "Access denied" });
      }
    } else {
      // For non-OWNER users, check if they belong to the same owner
      if (product[0].storeOwnerId !== requestingUser.ownerId) {
        throw new HTTPException(403, { message: "Access denied" });
      }
    }

    return {
      id: product[0].id,
      name: product[0].name,
      storeId: product[0].storeId,
      categoryId: product[0].categoryId,
      sku: product[0].sku,
      isImei: product[0].isImei,
      barcode: product[0].barcode,
      quantity: product[0].quantity,
      purchasePrice: product[0].purchasePrice,
      salePrice: product[0].salePrice,
      createdBy: product[0].createdBy,
      createdAt: product[0].createdAt,
      updatedAt: product[0].updatedAt,
    };
  }

  static async listProducts(query: ListProductsQuery, requestingUser: User) {
    // Build where conditions
    const conditions = [];

    // Owner scoping - only show products from stores owned by the user's owner
    if (requestingUser.role === "OWNER") {
      conditions.push(eq(stores.ownerId, requestingUser.id));
    } else {
      conditions.push(eq(stores.ownerId, requestingUser.ownerId!));
    }

    // Store filter
    if (query.storeId) {
      conditions.push(eq(products.storeId, query.storeId));
    }

    // Category filter
    if (query.categoryId) {
      conditions.push(eq(products.categoryId, query.categoryId));
    }

    // IMEI filter
    if (query.isImei !== undefined) {
      conditions.push(eq(products.isImei, query.isImei));
    }

    // Search filter
    if (query.search) {
      conditions.push(like(products.name, `%${query.search}%`));
    }

    // Price filters
    if (query.minPrice !== undefined) {
      conditions.push(gte(products.purchasePrice, query.minPrice));
    }

    if (query.maxPrice !== undefined) {
      conditions.push(lte(products.purchasePrice, query.maxPrice));
    }

    // Exclude deleted products
    conditions.push(isNull(products.deletedAt));

    const whereClause = and(...conditions);

    // Get total count
    const totalResult = await db
      .select({ count: count() })
      .from(products)
      .innerJoin(stores, eq(products.storeId, stores.id))
      .where(whereClause);

    const total = totalResult[0].count;
    const totalPages = Math.ceil(total / query.limit);
    const offset = (query.page - 1) * query.limit;

    // Get products with pagination
    const productList = await db
      .select({
        id: products.id,
        name: products.name,
        storeId: products.storeId,
        categoryId: products.categoryId,
        sku: products.sku,
        isImei: products.isImei,
        barcode: products.barcode,
        quantity: products.quantity,
        purchasePrice: products.purchasePrice,
        salePrice: products.salePrice,
        createdBy: products.createdBy,
        createdAt: products.createdAt,
        updatedAt: products.updatedAt,
      })
      .from(products)
      .innerJoin(stores, eq(products.storeId, stores.id))
      .where(whereClause)
      .limit(query.limit)
      .offset(offset)
      .orderBy(products.createdAt);

    return {
      products: productList,
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

  static async updateProduct(
    id: string,
    data: UpdateProductRequest,
    requestingUser: User
  ) {
    // Find product to update (authorization middleware has already checked access)
    const existingProduct = await db
      .select({
        id: products.id,
        name: products.name,
        storeId: products.storeId,
        categoryId: products.categoryId,
        sku: products.sku,
        createdBy: products.createdBy,
        storeOwnerId: stores.ownerId,
      })
      .from(products)
      .where(and(eq(products.id, id), isNull(products.deletedAt)));

    if (!existingProduct[0]) {
      throw new HTTPException(404, { message: "Product not found" });
    }

    // Verify category exists and belongs to the same store (if provided)
    if (data.categoryId) {
      const category = await db
        .select()
        .from(categories)
        .where(
          and(
            eq(categories.id, data.categoryId),
            eq(categories.storeId, existingProduct[0].storeId),
            isNull(categories.deletedAt)
          )
        );

      if (!category[0]) {
        throw new HTTPException(404, {
          message: "Category not found or does not belong to this store",
        });
      }
    }

    // Check if SKU already exists in the store (if SKU is being updated)
    if (data.sku && data.sku !== existingProduct[0].sku) {
      const duplicateSku = await db
        .select()
        .from(products)
        .where(
          and(
            eq(products.sku, data.sku),
            eq(products.storeId, existingProduct[0].storeId),
            isNull(products.deletedAt)
          )
        );

      if (duplicateSku.length > 0) {
        throw new HTTPException(400, {
          message: "SKU already exists in this store",
        });
      }
    }

    // Prepare update data
    const updateData: any = {
      updatedAt: new Date(),
    };

    if (data.name) updateData.name = data.name;
    if (data.categoryId !== undefined) updateData.categoryId = data.categoryId;
    if (data.sku) updateData.sku = data.sku;
    if (data.isImei !== undefined) updateData.isImei = data.isImei;
    if (data.quantity !== undefined) updateData.quantity = data.quantity;
    if (data.purchasePrice !== undefined)
      updateData.purchasePrice = data.purchasePrice;
    if (data.salePrice !== undefined) updateData.salePrice = data.salePrice;

    // Update product
    const updatedProduct = await db
      .update(products)
      .set(updateData)
      .where(eq(products.id, id))
      .returning();

    if (!updatedProduct[0]) {
      throw new HTTPException(500, { message: "Failed to update product" });
    }

    return {
      id: updatedProduct[0].id,
      name: updatedProduct[0].name,
      storeId: updatedProduct[0].storeId,
      categoryId: updatedProduct[0].categoryId,
      sku: updatedProduct[0].sku,
      isImei: updatedProduct[0].isImei,
      barcode: updatedProduct[0].barcode,
      quantity: updatedProduct[0].quantity,
      purchasePrice: updatedProduct[0].purchasePrice,
      salePrice: updatedProduct[0].salePrice,
      createdBy: updatedProduct[0].createdBy,
      createdAt: updatedProduct[0].createdAt,
      updatedAt: updatedProduct[0].updatedAt,
    };
  }

  static async getProductByImei(imei: string, requestingUser: User) {
    // First find the product by IMEI
    const productWithImei = await db
      .select({
        id: products.id,
        name: products.name,
        storeId: products.storeId,
        categoryId: products.categoryId,
        sku: products.sku,
        isImei: products.isImei,
        barcode: products.barcode,
        quantity: products.quantity,
        purchasePrice: products.purchasePrice,
        salePrice: products.salePrice,
        createdBy: products.createdBy,
        createdAt: products.createdAt,
        updatedAt: products.updatedAt,
        storeOwnerId: stores.ownerId,
      })
      .from(productImeis)
      .innerJoin(products, eq(productImeis.productId, products.id))
      .innerJoin(stores, eq(products.storeId, stores.id))
      .where(
        and(
          eq(productImeis.imei, imei),
          isNull(products.deletedAt)
        )
      );

    if (!productWithImei[0]) {
      throw new HTTPException(404, { message: "Product with IMEI not found" });
    }

    const product = productWithImei[0];

    // Check if user can access this product (owner scoped)
    if (requestingUser.role === "OWNER") {
      if (product.storeOwnerId !== requestingUser.id) {
        throw new HTTPException(403, { message: "Access denied" });
      }
    } else {
      // For non-OWNER users, check if they belong to the same owner
      if (product.storeOwnerId !== requestingUser.ownerId) {
        throw new HTTPException(403, { message: "Access denied" });
      }
    }

    // Get all IMEIs for this product
    const allImeis = await db
      .select({
        imei: productImeis.imei,
      })
      .from(productImeis)
      .where(eq(productImeis.productId, product.id));

    return {
      id: product.id,
      name: product.name,
      storeId: product.storeId,
      categoryId: product.categoryId,
      sku: product.sku,
      isImei: product.isImei,
      barcode: product.barcode,
      quantity: product.quantity,
      purchasePrice: product.purchasePrice,
      salePrice: product.salePrice,
      createdBy: product.createdBy,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
      imeis: allImeis.map(item => item.imei),
    };
  }
}
