import { OpenAPIHono, createRoute, z } from '@hono/zod-openapi';
import { StoreController } from '../controllers/store.controller';
import {
  CreateStoreRequestSchema,
  UpdateStoreRequestSchema,
  StoreQueryParamsSchema,
  StoreIdParamSchema,
  OwnerIdParamSchema,
  StoreSuccessResponseSchema,
  PaginatedStoreSuccessResponseSchema,
  DeleteSuccessResponseSchema,
  ErrorResponseSchema,
} from '../schemas/store.schemas';

const storeRoutes = new OpenAPIHono();
const storeController = new StoreController();

// Create store route
const createStoreRoute = createRoute({
  method: 'post',
  path: '/',
  tags: ['Stores'],
  summary: 'Create a new store',
  description: 'Create a new store. Only OWNER and ADMIN users can create stores.',
  request: {
    body: {
      content: {
        'application/json': {
          schema: CreateStoreRequestSchema,
        },
      },
    },
  },
  responses: {
    201: {
      content: {
        'application/json': {
          schema: StoreSuccessResponseSchema,
        },
      },
      description: 'Store created successfully',
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
    409: {
      content: {
        'application/json': {
          schema: ErrorResponseSchema,
        },
      },
      description: 'Store name already exists for this owner',
    },
  },
});

// Get all stores route
const getAllStoresRoute = createRoute({
  method: 'get',
  path: '/',
  tags: ['Stores'],
  summary: 'Get all stores',
  description: 'Retrieve all stores with pagination and filtering. Results are scoped by user permissions.',
  request: {
    query: StoreQueryParamsSchema,
  },
  responses: {
    200: {
      content: {
        'application/json': {
          schema: PaginatedStoreSuccessResponseSchema,
        },
      },
      description: 'Stores retrieved successfully',
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

// Get active stores route
const getActiveStoresRoute = createRoute({
  method: 'get',
  path: '/active',
  tags: ['Stores'],
  summary: 'Get active stores',
  description: 'Retrieve all active stores. Results are scoped by user permissions.',
  responses: {
    200: {
      content: {
        'application/json': {
          schema: PaginatedStoreSuccessResponseSchema,
        },
      },
      description: 'Active stores retrieved successfully',
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

// Get stores by owner route
const getStoresByOwnerRoute = createRoute({
  method: 'get',
  path: '/owner/{ownerId}',
  tags: ['Stores'],
  summary: 'Get stores by owner',
  description: 'Retrieve all stores belonging to a specific owner.',
  request: {
    params: OwnerIdParamSchema,
  },
  responses: {
    200: {
      content: {
        'application/json': {
          schema: PaginatedStoreSuccessResponseSchema,
        },
      },
      description: 'Stores retrieved successfully',
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

// Get store by ID route
const getStoreByIdRoute = createRoute({
  method: 'get',
  path: '/{id}',
  tags: ['Stores'],
  summary: 'Get store by ID',
  description: 'Retrieve a specific store by its ID. Access is controlled by user permissions.',
  request: {
    params: StoreIdParamSchema,
  },
  responses: {
    200: {
      content: {
        'application/json': {
          schema: StoreSuccessResponseSchema,
        },
      },
      description: 'Store retrieved successfully',
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
      description: 'Store not found',
    },
  },
});

// Update store route
const updateStoreRoute = createRoute({
  method: 'put',
  path: '/{id}',
  tags: ['Stores'],
  summary: 'Update store',
  description: 'Update a specific store. Only OWNER and ADMIN users can update stores.',
  request: {
    params: StoreIdParamSchema,
    body: {
      content: {
        'application/json': {
          schema: UpdateStoreRequestSchema,
        },
      },
    },
  },
  responses: {
    200: {
      content: {
        'application/json': {
          schema: StoreSuccessResponseSchema,
        },
      },
      description: 'Store updated successfully',
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
      description: 'Store not found',
    },
    409: {
      content: {
        'application/json': {
          schema: ErrorResponseSchema,
        },
      },
      description: 'Store name already exists for this owner',
    },
  },
});

// Delete store route
const deleteStoreRoute = createRoute({
  method: 'delete',
  path: '/{id}',
  tags: ['Stores'],
  summary: 'Delete store',
  description: 'Soft delete a store. Only OWNER users can delete stores.',
  request: {
    params: StoreIdParamSchema,
  },
  responses: {
    200: {
      content: {
        'application/json': {
          schema: DeleteSuccessResponseSchema,
        },
      },
      description: 'Store deleted successfully',
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
      description: 'Access denied - only OWNER can delete stores',
    },
    404: {
      content: {
        'application/json': {
          schema: ErrorResponseSchema,
        },
      },
      description: 'Store not found',
    },
  },
});

// Get user accessible stores route
const getUserStoresRoute = createRoute({
  method: 'get',
  path: '/user/{userId}/accessible',
  tags: ['Stores'],
  summary: 'Get user accessible stores',
  description: 'Get all stores accessible to a specific user for dashboard navigation.',
  request: {
    params: z.object({
      userId: z.string().openapi({ 
        description: 'User ID to get accessible stores for',
        example: 'user_123'
      }),
    }),
  },
  responses: {
    200: {
      content: {
        'application/json': {
          schema: StoreSuccessResponseSchema,
        },
      },
      description: 'User accessible stores retrieved successfully',
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
storeRoutes.openapi(createStoreRoute, async (c) => await storeController.createStore(c));
storeRoutes.openapi(getAllStoresRoute, async (c) => await storeController.getAllStores(c));
storeRoutes.openapi(getActiveStoresRoute, async (c) => await storeController.getActiveStores(c));
storeRoutes.openapi(getStoresByOwnerRoute, async (c) => await storeController.getStoresByOwner(c));
storeRoutes.openapi(getStoreByIdRoute, async (c) => await storeController.getStoreById(c));
storeRoutes.openapi(updateStoreRoute, async (c) => await storeController.updateStore(c));
storeRoutes.openapi(deleteStoreRoute, async (c) => await storeController.deleteStore(c));
storeRoutes.openapi(getUserStoresRoute, async (c) => await storeController.getUserStores(c));

export { storeRoutes };