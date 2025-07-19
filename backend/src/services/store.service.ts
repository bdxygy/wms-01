import { randomUUID } from "crypto";
import { db } from "../config/database";
import { stores } from "../models/stores";
import { eq, and, count, isNull, or, ilike, SQL } from "drizzle-orm";
import { HTTPException } from "hono/http-exception";
import type {
  CreateStoreRequest,
  UpdateStoreRequest,
  ListStoresQuery,
} from "../schemas/store.schemas";
import type { User } from "../models/users";

export class StoreService {
  static async createStore(data: CreateStoreRequest, createdBy: User) {

    // Create store
    const storeId = randomUUID();
    const store = await db
      .insert(stores)
      .values({
        id: storeId,
        ownerId: createdBy.id,
        name: data.name,
        type: data.type,
        addressLine1: data.addressLine1,
        addressLine2: data.addressLine2 || null,
        city: data.city,
        province: data.province,
        postalCode: data.postalCode,
        country: data.country,
        phoneNumber: data.phoneNumber,
        email: data.email || null,
        isActive: true,
        openTime: data.openTime ? new Date(data.openTime) : null,
        closeTime: data.closeTime ? new Date(data.closeTime) : null,
        timezone: data.timezone || "Asia/Jakarta",
        mapLocation: data.mapLocation || null,
        createdBy: createdBy.id,
        createdAt: new Date(),
        updatedAt: new Date(),
      })
      .returning();

    if (!store[0]) {
      throw new HTTPException(500, { message: "Failed to create store" });
    }

    return {
      id: store[0].id,
      ownerId: store[0].ownerId,
      name: store[0].name,
      type: store[0].type,
      addressLine1: store[0].addressLine1,
      addressLine2: store[0].addressLine2,
      city: store[0].city,
      province: store[0].province,
      postalCode: store[0].postalCode,
      country: store[0].country,
      phoneNumber: store[0].phoneNumber,
      email: store[0].email,
      isActive: store[0].isActive,
      openTime: store[0].openTime?.toISOString() || null,
      closeTime: store[0].closeTime?.toISOString() || null,
      timezone: store[0].timezone,
      mapLocation: store[0].mapLocation,
      createdBy: store[0].createdBy,
      createdAt: store[0].createdAt.toISOString(),
      updatedAt: store[0].updatedAt.toISOString(),
    };
  }

  static async getStoreById(id: string, requestingUser: User) {
    const store = await db
      .select()
      .from(stores)
      .where(and(eq(stores.id, id), isNull(stores.deletedAt)));

    if (!store[0]) {
      throw new HTTPException(404, { message: "Store not found" });
    }


    return {
      id: store[0].id,
      ownerId: store[0].ownerId,
      name: store[0].name,
      type: store[0].type,
      addressLine1: store[0].addressLine1,
      addressLine2: store[0].addressLine2,
      city: store[0].city,
      province: store[0].province,
      postalCode: store[0].postalCode,
      country: store[0].country,
      phoneNumber: store[0].phoneNumber,
      email: store[0].email,
      isActive: store[0].isActive,
      openTime: store[0].openTime?.toISOString() || null,
      closeTime: store[0].closeTime?.toISOString() || null,
      timezone: store[0].timezone,
      mapLocation: store[0].mapLocation,
      createdBy: store[0].createdBy,
      createdAt: store[0].createdAt.toISOString(),
      updatedAt: store[0].updatedAt.toISOString(),
    };
  }

  static async listStores(query: ListStoresQuery, requestingUser: User) {
    // Build where conditions
    const conditions = [isNull(stores.deletedAt)];

    // Owner scoping - only show stores owned by the user's owner
    if (requestingUser.role === "OWNER") {
      conditions.push(eq(stores.ownerId, requestingUser.id));
    } else {
      conditions.push(eq(stores.ownerId, requestingUser.ownerId!));
    }

    // Search filter
    if (query.search) {
      conditions.push(
        or(
          ilike(stores.name, `%${query.search}%`),
          ilike(stores.city, `%${query.search}%`),
          ilike(stores.province, `%${query.search}%`)
        ) as SQL
      );
    }

    // Type filter
    if (query.type) {
      conditions.push(eq(stores.type, query.type));
    }

    // Active filter
    if (query.isActive !== undefined) {
      conditions.push(eq(stores.isActive, query.isActive));
    }

    // City filter
    if (query.city) {
      conditions.push(ilike(stores.city, `%${query.city}%`));
    }

    // Province filter
    if (query.province) {
      conditions.push(ilike(stores.province, `%${query.province}%`));
    }

    const whereClause = conditions.length > 0 ? and(...conditions) : undefined;

    // Get total count
    const totalResult = await db
      .select({ count: count() })
      .from(stores)
      .where(whereClause);

    const total = totalResult[0].count;
    const totalPages = Math.ceil(total / query.limit);
    const offset = (query.page - 1) * query.limit;

    // Get stores with pagination
    const storeList = await db
      .select()
      .from(stores)
      .where(whereClause)
      .limit(query.limit)
      .offset(offset)
      .orderBy(stores.createdAt);

    return {
      stores: storeList.map((store) => ({
        id: store.id,
        ownerId: store.ownerId,
        name: store.name,
        type: store.type,
        addressLine1: store.addressLine1,
        addressLine2: store.addressLine2,
        city: store.city,
        province: store.province,
        postalCode: store.postalCode,
        country: store.country,
        phoneNumber: store.phoneNumber,
        email: store.email,
        isActive: store.isActive,
        openTime: store.openTime?.toISOString() || null,
        closeTime: store.closeTime?.toISOString() || null,
        timezone: store.timezone,
        mapLocation: store.mapLocation,
        createdBy: store.createdBy,
        createdAt: store.createdAt.toISOString(),
        updatedAt: store.updatedAt.toISOString(),
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

  static async updateStore(
    id: string,
    data: UpdateStoreRequest,
    requestingUser: User
  ) {

    // Find store to update
    const existingStore = await db
      .select()
      .from(stores)
      .where(and(eq(stores.id, id), isNull(stores.deletedAt)));

    if (!existingStore[0]) {
      throw new HTTPException(404, { message: "Store not found" });
    }


    // Prepare update data
    const updateData: any = {
      updatedAt: new Date(),
    };

    if (data.name !== undefined) updateData.name = data.name;
    if (data.type !== undefined) updateData.type = data.type;
    if (data.addressLine1 !== undefined)
      updateData.addressLine1 = data.addressLine1;
    if (data.addressLine2 !== undefined)
      updateData.addressLine2 = data.addressLine2;
    if (data.city !== undefined) updateData.city = data.city;
    if (data.province !== undefined) updateData.province = data.province;
    if (data.postalCode !== undefined) updateData.postalCode = data.postalCode;
    if (data.country !== undefined) updateData.country = data.country;
    if (data.phoneNumber !== undefined)
      updateData.phoneNumber = data.phoneNumber;
    if (data.email !== undefined) updateData.email = data.email;
    if (data.isActive !== undefined) updateData.isActive = data.isActive;
    if (data.openTime !== undefined)
      updateData.openTime = data.openTime ? new Date(data.openTime) : null;
    if (data.closeTime !== undefined)
      updateData.closeTime = data.closeTime ? new Date(data.closeTime) : null;
    if (data.timezone !== undefined) updateData.timezone = data.timezone;
    if (data.mapLocation !== undefined)
      updateData.mapLocation = data.mapLocation;

    // Update store
    const updatedStore = await db
      .update(stores)
      .set(updateData)
      .where(eq(stores.id, id))
      .returning();

    if (!updatedStore[0]) {
      throw new HTTPException(500, { message: "Failed to update store" });
    }

    return {
      id: updatedStore[0].id,
      ownerId: updatedStore[0].ownerId,
      name: updatedStore[0].name,
      type: updatedStore[0].type,
      addressLine1: updatedStore[0].addressLine1,
      addressLine2: updatedStore[0].addressLine2,
      city: updatedStore[0].city,
      province: updatedStore[0].province,
      postalCode: updatedStore[0].postalCode,
      country: updatedStore[0].country,
      phoneNumber: updatedStore[0].phoneNumber,
      email: updatedStore[0].email,
      isActive: updatedStore[0].isActive,
      openTime: updatedStore[0].openTime?.toISOString() || null,
      closeTime: updatedStore[0].closeTime?.toISOString() || null,
      timezone: updatedStore[0].timezone,
      mapLocation: updatedStore[0].mapLocation,
      createdBy: updatedStore[0].createdBy,
      createdAt: updatedStore[0].createdAt.toISOString(),
      updatedAt: updatedStore[0].updatedAt.toISOString(),
    };
  }
}
