import { Context } from 'hono';
import { HTTPException } from 'hono/http-exception';
import { UserService, CreateUserRequest, UpdateUserRequest } from '../services/user.service';
import { createSuccessResponse, createPaginatedResponse, createErrorResponse, parsePaginationOptions } from '../utils/response';
import { User } from '../models/users';

export class UserController {
  private userService: UserService;

  constructor() {
    this.userService = new UserService();
  }

  private throwHttpError(status: number, message: string, code?: string, details?: any): never {
    const errorResponse = createErrorResponse(message, code, details);
    throw new HTTPException(status as any, { 
      message: errorResponse.message,
      cause: errorResponse 
    });
  }

  async createUser(c: Context) {
    try {
      const requestingUser = c.get('user') as User;
      
      if (!requestingUser) {
        this.throwHttpError(401, 'Authentication required', 'AUTH_REQUIRED');
      }

      const data = await c.req.json() as CreateUserRequest;
      
      // Basic validation
      if (!data.email || !data.password || !data.name || !data.role) {
        this.throwHttpError(400, 'Email, password, name, and role are required', 'VALIDATION_ERROR');
      }

      const user = await this.userService.createUser(data, requestingUser);
      
      // Remove password from response
      const { password, ...userResponse } = user;
      
      return c.json(createSuccessResponse(userResponse, 'User created successfully'), 201);
    } catch (error) {
      if (error instanceof HTTPException) {
        throw error;
      }
      
      const message = error instanceof Error ? error.message : 'Failed to create user';
      const details = error instanceof Error ? error.stack : undefined;
      this.throwHttpError(400, message, 'USER_CREATE_ERROR', details);
    }
  }

  async getUserById(c: Context) {
    try {
      const requestingUser = c.get('user') as User;
      const id = c.req.param('id');
      
      if (!requestingUser) {
        this.throwHttpError(401, 'Authentication required', 'AUTH_REQUIRED');
      }

      const user = await this.userService.getUserById(id, requestingUser);
      
      if (!user) {
        this.throwHttpError(404, 'User not found', 'USER_NOT_FOUND');
      }

      // Remove password from response
      const { password, ...userResponse } = user;
      
      return c.json(createSuccessResponse(userResponse));
    } catch (error) {
      if (error instanceof HTTPException) {
        throw error;
      }
      
      const message = error instanceof Error ? error.message : 'Failed to fetch user';
      const details = error instanceof Error ? error.stack : undefined;
      this.throwHttpError(400, message, 'USER_FETCH_ERROR', details);
    }
  }

  async getAllUsers(c: Context) {
    try {
      const requestingUser = c.get('user') as User;
      
      if (!requestingUser) {
        this.throwHttpError(401, 'Authentication required', 'AUTH_REQUIRED');
      }

      // Parse and validate pagination options
      const paginationOptions = parsePaginationOptions(c.req.query());
      
      // Parse additional filters
      const role = c.req.query('role');
      const isActive = c.req.query('isActive');
      
      const filters: any = {};
      if (role) filters.role = role;
      if (isActive !== undefined) filters.isActive = isActive === 'true';

      const options = {
        ...paginationOptions,
        filters
      };

      const result = await this.userService.getAllUsers(options, requestingUser);
      
      // Remove passwords from all user responses
      const sanitizedData = result.data.map(user => {
        const { password, ...userResponse } = user;
        return userResponse;
      });

      return c.json(createPaginatedResponse(
        sanitizedData,
        result.page,
        result.limit,
        result.total,
        'Users retrieved successfully'
      ));
    } catch (error) {
      if (error instanceof HTTPException) {
        throw error;
      }
      
      const message = error instanceof Error ? error.message : 'Failed to fetch users';
      const details = error instanceof Error ? error.stack : undefined;
      this.throwHttpError(400, message, 'USERS_FETCH_ERROR', details);
    }
  }

  async updateUser(c: Context) {
    try {
      const requestingUser = c.get('user') as User;
      const id = c.req.param('id');
      
      if (!requestingUser) {
        this.throwHttpError(401, 'Authentication required', 'AUTH_REQUIRED');
      }

      const data = await c.req.json() as UpdateUserRequest;
      
      const user = await this.userService.updateUser(id, data, requestingUser);
      
      if (!user) {
        this.throwHttpError(404, 'User not found', 'USER_NOT_FOUND');
      }

      // Remove password from response
      const { password, ...userResponse } = user;
      
      return c.json(createSuccessResponse(userResponse, 'User updated successfully'));
    } catch (error) {
      if (error instanceof HTTPException) {
        throw error;
      }
      
      const message = error instanceof Error ? error.message : 'Failed to update user';
      const details = error instanceof Error ? error.stack : undefined;
      this.throwHttpError(400, message, 'USER_UPDATE_ERROR', details);
    }
  }

  async deleteUser(c: Context) {
    try {
      const requestingUser = c.get('user') as User;
      const id = c.req.param('id');
      
      if (!requestingUser) {
        this.throwHttpError(401, 'Authentication required', 'AUTH_REQUIRED');
      }

      const success = await this.userService.softDeleteUser(id, requestingUser);
      
      if (!success) {
        this.throwHttpError(404, 'User not found', 'USER_NOT_FOUND');
      }

      return c.json(createSuccessResponse(null, 'User deleted successfully'));
    } catch (error) {
      if (error instanceof HTTPException) {
        throw error;
      }
      
      const message = error instanceof Error ? error.message : 'Failed to delete user';
      const details = error instanceof Error ? error.stack : undefined;
      this.throwHttpError(403, message, 'USER_DELETE_ERROR', details);
    }
  }

  async getUsersByOwner(c: Context) {
    try {
      const requestingUser = c.get('user') as User;
      const ownerId = c.req.param('ownerId');
      
      if (!requestingUser) {
        this.throwHttpError(401, 'Authentication required', 'AUTH_REQUIRED');
      }

      // Parse and validate pagination options
      const paginationOptions = parsePaginationOptions(c.req.query());

      const result = await this.userService.getUsersByOwner(ownerId, requestingUser, paginationOptions);
      
      // Remove passwords from all user responses
      const sanitizedData = result.data.map(user => {
        const { password, ...userResponse } = user;
        return userResponse;
      });

      return c.json(createPaginatedResponse(
        sanitizedData,
        result.page,
        result.limit,
        result.total,
        'Users retrieved successfully'
      ));
    } catch (error) {
      if (error instanceof HTTPException) {
        throw error;
      }
      
      const message = error instanceof Error ? error.message : 'Failed to fetch users by owner';
      const details = error instanceof Error ? error.stack : undefined;
      this.throwHttpError(400, message, 'USERS_BY_OWNER_ERROR', details);
    }
  }

  async getUsersByRole(c: Context) {
    try {
      const requestingUser = c.get('user') as User;
      const role = c.req.param('role');
      
      if (!requestingUser) {
        this.throwHttpError(401, 'Authentication required', 'AUTH_REQUIRED');
      }

      // Parse and validate pagination options
      const paginationOptions = parsePaginationOptions(c.req.query());

      const result = await this.userService.getUsersByRole(role as any, requestingUser, paginationOptions);
      
      // Remove passwords from all user responses
      const sanitizedData = result.data.map(user => {
        const { password, ...userResponse } = user;
        return userResponse;
      });

      return c.json(createPaginatedResponse(
        sanitizedData,
        result.page,
        result.limit,
        result.total,
        'Users retrieved successfully'
      ));
    } catch (error) {
      if (error instanceof HTTPException) {
        throw error;
      }
      
      const message = error instanceof Error ? error.message : 'Failed to fetch users by role';
      const details = error instanceof Error ? error.stack : undefined;
      this.throwHttpError(400, message, 'USERS_BY_ROLE_ERROR', details);
    }
  }

  async getActiveUsers(c: Context) {
    try {
      const requestingUser = c.get('user') as User;
      
      if (!requestingUser) {
        this.throwHttpError(401, 'Authentication required', 'AUTH_REQUIRED');
      }

      // Parse and validate pagination options
      const paginationOptions = parsePaginationOptions(c.req.query());

      const result = await this.userService.getActiveUsers(requestingUser, paginationOptions);
      
      // Remove passwords from all user responses
      const sanitizedData = result.data.map(user => {
        const { password, ...userResponse } = user;
        return userResponse;
      });

      return c.json(createPaginatedResponse(
        sanitizedData,
        result.page,
        result.limit,
        result.total,
        'Active users retrieved successfully'
      ));
    } catch (error) {
      if (error instanceof HTTPException) {
        throw error;
      }
      
      const message = error instanceof Error ? error.message : 'Failed to fetch active users';
      const details = error instanceof Error ? error.stack : undefined;
      this.throwHttpError(400, message, 'ACTIVE_USERS_ERROR', details);
    }
  }

  async getUserStores(c: Context) {
    try {
      const requestingUser = c.get('user') as User;
      const userId = c.req.param('userId');
      
      if (!requestingUser) {
        this.throwHttpError(401, 'Authentication required', 'AUTH_REQUIRED');
      }

      const stores = await this.userService.getUserStores(userId, requestingUser);
      
      return c.json(createSuccessResponse(stores, 'User stores retrieved successfully'));
    } catch (error) {
      if (error instanceof HTTPException) {
        throw error;
      }
      
      const message = error instanceof Error ? error.message : 'Failed to fetch user stores';
      const details = error instanceof Error ? error.stack : undefined;
      this.throwHttpError(400, message, 'USER_STORES_ERROR', details);
    }
  }

  async getCurrentUser(c: Context) {
    try {
      const requestingUser = c.get('user') as User;
      
      if (!requestingUser) {
        this.throwHttpError(401, 'Authentication required', 'AUTH_REQUIRED');
      }

      // Remove password from response
      const { password, ...userResponse } = requestingUser;
      
      return c.json(createSuccessResponse(userResponse));
    } catch (error) {
      if (error instanceof HTTPException) {
        throw error;
      }
      
      const message = error instanceof Error ? error.message : 'Failed to fetch current user';
      const details = error instanceof Error ? error.stack : undefined;
      this.throwHttpError(400, message, 'CURRENT_USER_ERROR', details);
    }
  }

  async updateCurrentUser(c: Context) {
    try {
      const requestingUser = c.get('user') as User;
      
      if (!requestingUser) {
        this.throwHttpError(401, 'Authentication required', 'AUTH_REQUIRED');
      }

      const data = await c.req.json() as UpdateUserRequest;
      
      // Users can only update their own profile with limited fields
      const allowedFields: UpdateUserRequest = {
        name: data.name,
        email: data.email
      };

      const user = await this.userService.updateUser(requestingUser.id, allowedFields, requestingUser);
      
      if (!user) {
        this.throwHttpError(404, 'User not found', 'USER_NOT_FOUND');
      }

      // Remove password from response
      const { password, ...userResponse } = user;
      
      return c.json(createSuccessResponse(userResponse, 'Profile updated successfully'));
    } catch (error) {
      if (error instanceof HTTPException) {
        throw error;
      }
      
      const message = error instanceof Error ? error.message : 'Failed to update profile';
      const details = error instanceof Error ? error.stack : undefined;
      this.throwHttpError(400, message, 'PROFILE_UPDATE_ERROR', details);
    }
  }
}