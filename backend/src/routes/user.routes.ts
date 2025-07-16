import { OpenAPIHono, createRoute, z } from '@hono/zod-openapi';
import { UserController } from '../controllers/user.controller';
import {
  CreateUserRequestSchema,
  UpdateUserRequestSchema,
  UpdateCurrentUserRequestSchema,
  UserQueryParamsSchema,
  UserIdParamSchema,
  OwnerIdParamSchema,
  RoleParamSchema,
  UserIdForStoresParamSchema,
  UserSuccessResponseSchema,
  PaginatedUserSuccessResponseSchema,
  StoresSuccessResponseSchema,
  DeleteSuccessResponseSchema,
  ErrorResponseSchema,
} from '../schemas/user.schemas';

const userRoutes = new OpenAPIHono();
const userController = new UserController();

// Create user route
const createUserRoute = createRoute({
  method: 'post',
  path: '/',
  tags: ['Users'],
  summary: 'Create a new user',
  description: 'Create a new user with role-based restrictions. ADMIN users can only create STAFF users.',
  request: {
    body: {
      content: {
        'application/json': {
          schema: CreateUserRequestSchema,
        },
      },
    },
  },
  responses: {
    201: {
      content: {
        'application/json': {
          schema: UserSuccessResponseSchema,
        },
      },
      description: 'User created successfully',
    },
    400: {
      content: {
        'application/json': {
          schema: ErrorResponseSchema,
        },
      },
      description: 'Bad request - validation error or business rule violation',
    },
    401: {
      content: {
        'application/json': {
          schema: ErrorResponseSchema,
        },
      },
      description: 'Authentication required',
    },
    403: {
      content: {
        'application/json': {
          schema: ErrorResponseSchema,
        },
      },
      description: 'Insufficient permissions',
    },
  },
});

// Get all users route
const getAllUsersRoute = createRoute({
  method: 'get',
  path: '/',
  tags: ['Users'],
  summary: 'Get all users',
  description: 'Retrieve all users with pagination and filtering. Results are scoped by user permissions.',
  request: {
    query: UserQueryParamsSchema,
  },
  responses: {
    200: {
      content: {
        'application/json': {
          schema: PaginatedUserSuccessResponseSchema,
        },
      },
      description: 'Users retrieved successfully',
    },
    401: {
      content: {
        'application/json': {
          schema: ErrorResponseSchema,
        },
      },
      description: 'Authentication required',
    },
  },
});

// Get active users route
const getActiveUsersRoute = createRoute({
  method: 'get',
  path: '/active',
  tags: ['Users'],
  summary: 'Get active users',
  description: 'Retrieve all active users. Results are scoped by user permissions.',
  responses: {
    200: {
      content: {
        'application/json': {
          schema: PaginatedUserSuccessResponseSchema,
        },
      },
      description: 'Active users retrieved successfully',
    },
    401: {
      content: {
        'application/json': {
          schema: ErrorResponseSchema,
        },
      },
      description: 'Authentication required',
    },
  },
});

// Get current user route
const getCurrentUserRoute = createRoute({
  method: 'get',
  path: '/me',
  tags: ['Users'],
  summary: 'Get current user',
  description: 'Retrieve the profile of the currently authenticated user.',
  responses: {
    200: {
      content: {
        'application/json': {
          schema: UserSuccessResponseSchema,
        },
      },
      description: 'Current user retrieved successfully',
    },
    401: {
      content: {
        'application/json': {
          schema: ErrorResponseSchema,
        },
      },
      description: 'Authentication required',
    },
  },
});

// Update current user route
const updateCurrentUserRoute = createRoute({
  method: 'put',
  path: '/me',
  tags: ['Users'],
  summary: 'Update current user',
  description: 'Update the profile of the currently authenticated user. Limited to name and email only.',
  request: {
    body: {
      content: {
        'application/json': {
          schema: UpdateCurrentUserRequestSchema,
        },
      },
    },
  },
  responses: {
    200: {
      content: {
        'application/json': {
          schema: UserSuccessResponseSchema,
        },
      },
      description: 'Profile updated successfully',
    },
    400: {
      content: {
        'application/json': {
          schema: ErrorResponseSchema,
        },
      },
      description: 'Bad request - validation error',
    },
    401: {
      content: {
        'application/json': {
          schema: ErrorResponseSchema,
        },
      },
      description: 'Authentication required',
    },
  },
});

// Get users by owner route
const getUsersByOwnerRoute = createRoute({
  method: 'get',
  path: '/owner/{ownerId}',
  tags: ['Users'],
  summary: 'Get users by owner',
  description: 'Retrieve all users belonging to a specific owner.',
  request: {
    params: OwnerIdParamSchema,
  },
  responses: {
    200: {
      content: {
        'application/json': {
          schema: PaginatedUserSuccessResponseSchema,
        },
      },
      description: 'Users retrieved successfully',
    },
    401: {
      content: {
        'application/json': {
          schema: ErrorResponseSchema,
        },
      },
      description: 'Authentication required',
    },
    403: {
      content: {
        'application/json': {
          schema: ErrorResponseSchema,
        },
      },
      description: 'Access denied',
    },
  },
});

// Get users by role route
const getUsersByRoleRoute = createRoute({
  method: 'get',
  path: '/role/{role}',
  tags: ['Users'],
  summary: 'Get users by role',
  description: 'Retrieve all users with a specific role. Results are scoped by user permissions.',
  request: {
    params: RoleParamSchema,
  },
  responses: {
    200: {
      content: {
        'application/json': {
          schema: PaginatedUserSuccessResponseSchema,
        },
      },
      description: 'Users retrieved successfully',
    },
    401: {
      content: {
        'application/json': {
          schema: ErrorResponseSchema,
        },
      },
      description: 'Authentication required',
    },
  },
});

// Get user by ID route
const getUserByIdRoute = createRoute({
  method: 'get',
  path: '/{id}',
  tags: ['Users'],
  summary: 'Get user by ID',
  description: 'Retrieve a specific user by their ID. Access is controlled by user permissions.',
  request: {
    params: UserIdParamSchema,
  },
  responses: {
    200: {
      content: {
        'application/json': {
          schema: UserSuccessResponseSchema,
        },
      },
      description: 'User retrieved successfully',
    },
    401: {
      content: {
        'application/json': {
          schema: ErrorResponseSchema,
        },
      },
      description: 'Authentication required',
    },
    403: {
      content: {
        'application/json': {
          schema: ErrorResponseSchema,
        },
      },
      description: 'Access denied',
    },
    404: {
      content: {
        'application/json': {
          schema: ErrorResponseSchema,
        },
      },
      description: 'User not found',
    },
  },
});

// Update user route
const updateUserRoute = createRoute({
  method: 'put',
  path: '/{id}',
  tags: ['Users'],
  summary: 'Update user',
  description: 'Update a specific user. Access and update permissions are controlled by user roles.',
  request: {
    params: UserIdParamSchema,
    body: {
      content: {
        'application/json': {
          schema: UpdateUserRequestSchema,
        },
      },
    },
  },
  responses: {
    200: {
      content: {
        'application/json': {
          schema: UserSuccessResponseSchema,
        },
      },
      description: 'User updated successfully',
    },
    400: {
      content: {
        'application/json': {
          schema: ErrorResponseSchema,
        },
      },
      description: 'Bad request - validation error or business rule violation',
    },
    401: {
      content: {
        'application/json': {
          schema: ErrorResponseSchema,
        },
      },
      description: 'Authentication required',
    },
    403: {
      content: {
        'application/json': {
          schema: ErrorResponseSchema,
        },
      },
      description: 'Access denied',
    },
    404: {
      content: {
        'application/json': {
          schema: ErrorResponseSchema,
        },
      },
      description: 'User not found',
    },
  },
});

// Delete user route
const deleteUserRoute = createRoute({
  method: 'delete',
  path: '/{id}',
  tags: ['Users'],
  summary: 'Delete user',
  description: 'Soft delete a user. Only OWNER users can delete users, and ADMIN users cannot delete.',
  request: {
    params: UserIdParamSchema,
  },
  responses: {
    200: {
      content: {
        'application/json': {
          schema: DeleteSuccessResponseSchema,
        },
      },
      description: 'User deleted successfully',
    },
    401: {
      content: {
        'application/json': {
          schema: ErrorResponseSchema,
        },
      },
      description: 'Authentication required',
    },
    403: {
      content: {
        'application/json': {
          schema: ErrorResponseSchema,
        },
      },
      description: 'Access denied - ADMIN users cannot delete',
    },
    404: {
      content: {
        'application/json': {
          schema: ErrorResponseSchema,
        },
      },
      description: 'User not found',
    },
  },
});

// Get user stores route
const getUserStoresRoute = createRoute({
  method: 'get',
  path: '/{userId}/stores',
  tags: ['Users'],
  summary: 'Get user stores',
  description: 'Get all stores accessible to a specific user for dashboard navigation.',
  request: {
    params: UserIdForStoresParamSchema,
  },
  responses: {
    200: {
      content: {
        'application/json': {
          schema: StoresSuccessResponseSchema,
        },
      },
      description: 'User stores retrieved successfully',
    },
    401: {
      content: {
        'application/json': {
          schema: ErrorResponseSchema,
        },
      },
      description: 'Authentication required',
    },
    403: {
      content: {
        'application/json': {
          schema: ErrorResponseSchema,
        },
      },
      description: 'Access denied',
    },
    404: {
      content: {
        'application/json': {
          schema: ErrorResponseSchema,
        },
      },
      description: 'User not found',
    },
  },
});

// Register routes
userRoutes.openapi(createUserRoute, async (c) => await userController.createUser(c));
userRoutes.openapi(getAllUsersRoute, async (c) => await userController.getAllUsers(c));
userRoutes.openapi(getActiveUsersRoute, async (c) => await userController.getActiveUsers(c));
userRoutes.openapi(getCurrentUserRoute, async (c) => await userController.getCurrentUser(c));
userRoutes.openapi(updateCurrentUserRoute, async (c) => await userController.updateCurrentUser(c));
userRoutes.openapi(getUsersByOwnerRoute, async (c) => await userController.getUsersByOwner(c));
userRoutes.openapi(getUsersByRoleRoute, async (c) => await userController.getUsersByRole(c));
userRoutes.openapi(getUserByIdRoute, async (c) => await userController.getUserById(c));
userRoutes.openapi(updateUserRoute, async (c) => await userController.updateUser(c));
userRoutes.openapi(deleteUserRoute, async (c) => await userController.deleteUser(c));
userRoutes.openapi(getUserStoresRoute, async (c) => await userController.getUserStores(c));

export { userRoutes };