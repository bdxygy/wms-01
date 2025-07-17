import { Context } from "hono";
import { StoreService } from "../services/store.service";
import {
  CreateStoreRequest,
  UpdateStoreRequest,
} from "../schemas/store.schemas";
import {
  createBaseResponse,
  createPaginatedResponse,
  parsePaginationOptions,
} from "../utils/response";
import { handleServiceError } from "../utils/errors";
import { User } from "../models/users";

export class StoreController {
  private storeService: StoreService;

  constructor() {
    this.storeService = new StoreService();
  }

  async createStore(c: Context) {
    try {
      const requestingUser = c.get("user") as User;

      if (!requestingUser) {
        return c.json(
          createBaseResponse(false, "Unauthorized", null, {
            code: "UNAUTHORIZED",
            details: "Authentication required",
          }),
          401
        );
      }

      const data = (await c.req.json()) as CreateStoreRequest;

      const store = await this.storeService.createStore(data, requestingUser);

      return c.json(
        createBaseResponse(true, "Store created successfully", store),
        201
      );
    } catch (error) {
      const { message, statusCode, code, details } = handleServiceError(error);
      return c.json(
        createBaseResponse(false, message, null, {
          code,
          details,
        }),
        statusCode as any
      );
    }
  }

  async getStoreById(c: Context) {
    try {
      const requestingUser = c.get("user") as User;
      const id = c.req.param("id");

      if (!requestingUser) {
        return c.json(
          createBaseResponse(false, "Unauthorized", null, {
            code: "UNAUTHORIZED",
            details: "Authentication required",
          }),
          401
        );
      }

      const store = await this.storeService.getStoreById(id, requestingUser);

      if (!store) {
        return c.json(
          createBaseResponse(false, "Store not found", null, {
            code: "STORE_NOT_FOUND",
            details: `Store with id ${id} not found`,
          }),
          404
        );
      }

      return c.json(
        createBaseResponse(true, "Store retrieved successfully", store)
      );
    } catch (error) {
      const { message, statusCode, code, details } = handleServiceError(error);
      return c.json(
        createBaseResponse(false, message, null, {
          code,
          details,
        }),
        statusCode as any
      );
    }
  }

  async getAllStores(c: Context) {
    try {
      const requestingUser = c.get("user") as User;

      if (!requestingUser) {
        return c.json(
          createBaseResponse(false, "Unauthorized", null, {
            code: "UNAUTHORIZED",
            details: "Authentication required",
          }),
          401
        );
      }

      // Parse and validate pagination options
      const paginationOptions = parsePaginationOptions(c.req.query());

      // Parse additional filters
      const isActive = c.req.query("isActive");
      const search = c.req.query("search");

      const filters: any = {};
      if (isActive !== undefined) filters.isActive = isActive === "true";

      const options = {
        ...paginationOptions,
        filters,
      };

      let result;
      if (search) {
        // Use search functionality
        result = await this.storeService.searchStores(
          search,
          requestingUser,
          paginationOptions
        );
      } else {
        result = await this.storeService.getAllStores(
          options,
          requestingUser
        );
      }

      return c.json(
        createPaginatedResponse(
          result.data,
          result.page,
          result.limit,
          result.total,
          "Stores retrieved successfully"
        )
      );
    } catch (error) {
      const { message, statusCode, code, details } = handleServiceError(error);
      return c.json(
        createBaseResponse(false, message, null, {
          code,
          details,
        }),
        statusCode as any
      );
    }
  }

  async updateStore(c: Context) {
    try {
      const requestingUser = c.get("user") as User;
      const id = c.req.param("id");

      if (!requestingUser) {
        return c.json(
          createBaseResponse(false, "Unauthorized", null, {
            code: "UNAUTHORIZED",
            details: "Authentication required",
          }),
          401
        );
      }

      const data = (await c.req.json()) as UpdateStoreRequest;

      const store = await this.storeService.updateStore(id, data, requestingUser);

      if (!store) {
        return c.json(
          createBaseResponse(false, "Store not found", null, {
            code: "STORE_NOT_FOUND",
            details: `Store with id ${id} not found`,
          }),
          404
        );
      }

      return c.json(
        createBaseResponse(true, "Store updated successfully", store)
      );
    } catch (error) {
      const { message, statusCode, code, details } = handleServiceError(error);
      return c.json(
        createBaseResponse(false, message, null, {
          code,
          details,
        }),
        statusCode as any
      );
    }
  }

  async deleteStore(c: Context) {
    try {
      const requestingUser = c.get("user") as User;
      const id = c.req.param("id");

      if (!requestingUser) {
        return c.json(
          createBaseResponse(false, "Unauthorized", null, {
            code: "UNAUTHORIZED",
            details: "Authentication required",
          }),
          401
        );
      }

      const success = await this.storeService.softDeleteStore(id, requestingUser);

      if (!success) {
        return c.json(
          createBaseResponse(false, "Store not found", null, {
            code: "STORE_NOT_FOUND",
            details: `Store with id ${id} not found or cannot be deleted`,
          }),
          404
        );
      }

      return c.json(
        createBaseResponse(true, "Store deleted successfully", null)
      );
    } catch (error) {
      const { message, statusCode, code, details } = handleServiceError(error);
      return c.json(
        createBaseResponse(false, message, null, {
          code,
          details,
        }),
        statusCode as any
      );
    }
  }

  async getStoresByOwner(c: Context) {
    try {
      const requestingUser = c.get("user") as User;
      const ownerId = c.req.param("ownerId");

      if (!requestingUser) {
        return c.json(
          createBaseResponse(false, "Unauthorized", null, {
            code: "UNAUTHORIZED",
            details: "Authentication required",
          }),
          401
        );
      }

      // Parse and validate pagination options
      const paginationOptions = parsePaginationOptions(c.req.query());

      const result = await this.storeService.getStoresByOwner(
        ownerId,
        requestingUser,
        paginationOptions
      );

      return c.json(
        createPaginatedResponse(
          result.data,
          result.page,
          result.limit,
          result.total,
          "Stores retrieved successfully"
        )
      );
    } catch (error) {
      const { message, statusCode, code, details } = handleServiceError(error);
      return c.json(
        createBaseResponse(false, message, null, {
          code,
          details,
        }),
        statusCode as any
      );
    }
  }

  async getActiveStores(c: Context) {
    try {
      const requestingUser = c.get("user") as User;

      if (!requestingUser) {
        return c.json(
          createBaseResponse(false, "Unauthorized", null, {
            code: "UNAUTHORIZED",
            details: "Authentication required",
          }),
          401
        );
      }

      // Parse and validate pagination options
      const paginationOptions = parsePaginationOptions(c.req.query());

      const result = await this.storeService.getActiveStores(
        requestingUser,
        paginationOptions
      );

      return c.json(
        createPaginatedResponse(
          result.data,
          result.page,
          result.limit,
          result.total,
          "Active stores retrieved successfully"
        )
      );
    } catch (error) {
      const { message, statusCode, code, details } = handleServiceError(error);
      return c.json(
        createBaseResponse(false, message, null, {
          code,
          details,
        }),
        statusCode as any
      );
    }
  }

  async getUserStores(c: Context) {
    try {
      const requestingUser = c.get("user") as User;
      const userId = c.req.param("userId");

      if (!requestingUser) {
        return c.json(
          createBaseResponse(false, "Unauthorized", null, {
            code: "UNAUTHORIZED",
            details: "Authentication required",
          }),
          401
        );
      }

      const stores = await this.storeService.getUserAccessibleStores(
        userId,
        requestingUser
      );

      return c.json(
        createBaseResponse(true, "User accessible stores retrieved successfully", stores)
      );
    } catch (error) {
      const { message, statusCode, code, details } = handleServiceError(error);
      return c.json(
        createBaseResponse(false, message, null, {
          code,
          details,
        }),
        statusCode as any
      );
    }
  }
}