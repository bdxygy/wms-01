import { Context } from "hono";
import { UserService } from "../services/user.service";
import {
  CreateUserRequest,
  UpdateUserRequest,
  UpdateCurrentUserRequest,
} from "../schemas/user.schemas";
import {
  createBaseResponse,
  createPaginatedResponse,
  parsePaginationOptions,
} from "../utils/response";
import { handleServiceError } from "../utils/errors";
import { User } from "../models/users";

export class UserController {
  private userService: UserService;

  constructor() {
    this.userService = new UserService();
  }

  async createUser(c: Context) {
    try {
      const requestingUser = c.get("user") as User;

      if (!requestingUser) {
        return c.json(
          createBaseResponse(false, "Unauthorized", null, {
            code: "UNAUTHORIZED",
            details: "Unauthorized",
          }),
          401
        );
      }

      const data = (await c.req.json()) as CreateUserRequest;

      const user = await this.userService.createUser(data, requestingUser);

      // Remove password from response
      const { password, ...userResponse } = user;

      return c.json(
        createBaseResponse(true, "User created successfully", userResponse),
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

  async getUserById(c: Context) {
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

      const user = await this.userService.getUserById(id, requestingUser);

      if (!user) {
        return c.json(
          createBaseResponse(false, "User not found", null, {
            code: "USER_NOT_FOUND",
            details: `User with id ${id} not found`,
          }),
          404
        );
      }

      // Remove password from response
      const { password, ...userResponse } = user;

      return c.json(
        createBaseResponse(true, "User retrieved successfully", userResponse)
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

  async getAllUsers(c: Context) {
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
      const role = c.req.query("role");
      const isActive = c.req.query("isActive");

      const filters: any = {};
      if (role) filters.role = role;
      if (isActive !== undefined) filters.isActive = isActive === "true";

      const options = {
        ...paginationOptions,
        filters,
      };

      const result = await this.userService.getAllUsers(
        options,
        requestingUser
      );

      // Remove passwords from all user responses
      const sanitizedData = result.data.map((user) => {
        const { password, ...userResponse } = user;
        return userResponse;
      });

      return c.json(
        createPaginatedResponse(
          sanitizedData,
          result.page,
          result.limit,
          result.total,
          "Users retrieved successfully"
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

  async updateUser(c: Context) {
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

      const data = (await c.req.json()) as UpdateUserRequest;

      const user = await this.userService.updateUser(id, data, requestingUser);

      if (!user) {
        return c.json(
          createBaseResponse(false, "User not found", null, {
            code: "USER_NOT_FOUND",
            details: `User with id ${id} not found`,
          }),
          404
        );
      }

      // Remove password from response
      const { password, ...userResponse } = user;

      return c.json(
        createBaseResponse(true, "User updated successfully", userResponse)
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

  async deleteUser(c: Context) {
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

      const success = await this.userService.softDeleteUser(id, requestingUser);

      if (!success) {
        return c.json(
          createBaseResponse(false, "User not found", null, {
            code: "USER_NOT_FOUND",
            details: `User with id ${id} not found or cannot be deleted`,
          }),
          404
        );
      }

      return c.json(
        createBaseResponse(true, "User deleted successfully", null)
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

  async getUsersByOwner(c: Context) {
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

      const result = await this.userService.getUsersByOwner(
        ownerId,
        requestingUser,
        paginationOptions
      );

      // Remove passwords from all user responses
      const sanitizedData = result.data.map((user) => {
        const { password, ...userResponse } = user;
        return userResponse;
      });

      return c.json(
        createPaginatedResponse(
          sanitizedData,
          result.page,
          result.limit,
          result.total,
          "Users retrieved successfully"
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

  async getUsersByRole(c: Context) {
    try {
      const requestingUser = c.get("user") as User;
      const role = c.req.param("role");

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

      const result = await this.userService.getUsersByRole(
        role as any,
        requestingUser,
        paginationOptions
      );

      // Remove passwords from all user responses
      const sanitizedData = result.data.map((user) => {
        const { password, ...userResponse } = user;
        return userResponse;
      });

      return c.json(
        createPaginatedResponse(
          sanitizedData,
          result.page,
          result.limit,
          result.total,
          "Users retrieved successfully"
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

  async getActiveUsers(c: Context) {
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

      const result = await this.userService.getActiveUsers(
        requestingUser,
        paginationOptions
      );

      // Remove passwords from all user responses
      const sanitizedData = result.data.map((user) => {
        const { password, ...userResponse } = user;
        return userResponse;
      });

      return c.json(
        createPaginatedResponse(
          sanitizedData,
          result.page,
          result.limit,
          result.total,
          "Active users retrieved successfully"
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

      const stores = await this.userService.getUserStores(
        userId,
        requestingUser
      );

      return c.json(
        createBaseResponse(true, "User stores retrieved successfully", stores)
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

  async getCurrentUser(c: Context) {
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

      // Remove password from response
      const { password, ...userResponse } = requestingUser;

      return c.json(
        createBaseResponse(true, "Current user retrieved successfully", userResponse)
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

  async updateCurrentUser(c: Context) {
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

      let data = (await c.req.json()) as UpdateCurrentUserRequest;

      // Filter out role and isActive fields to prevent unauthorized updates
      const { role, isActive, ...allowedData } = data;
      // Cast allowedData to UpdateUserRequest to match service method signature
      const filteredData = allowedData as Partial<UpdateUserRequest>;

      const user = await this.userService.updateUser(
        requestingUser.id,
        filteredData,
        requestingUser
      );

      if (!user) {
        return c.json(
          createBaseResponse(false, "User not found", null, {
            code: "USER_NOT_FOUND",
            details: "Current user not found",
          }),
          404
        );
      }

      // Remove password from response
      const { password, ...userResponse } = user;

      return c.json(
        createBaseResponse(true, "Profile updated successfully", userResponse)
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
