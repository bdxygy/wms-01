import { nanoid } from 'nanoid';
import { StoreRepository } from '../repositories/store.repository';
import { type Store, type NewStore } from '../models/stores';
import { type User } from '../models/users';
import { PaginatedResult, QueryOptions, PaginationOptions } from '../repositories/base.repository';
import { PaginatedBaseRequest } from '../utils/response';
import { 
  CreateStoreRequest, 
  UpdateStoreRequest 
} from '../schemas/store.schemas';
import { ValidationError, AuthorizationError, NotFoundError, ConflictError } from '../utils/errors';

export class StoreService {
  private storeRepository: StoreRepository;

  constructor() {
    this.storeRepository = new StoreRepository();
  }

  async createStore(data: CreateStoreRequest, requestingUser: User): Promise<Store> {
    // Validate store creation permissions
    this.validateStoreCreation(data, requestingUser);

    // Determine owner assignment
    const ownerId = this.determineOwnerId(requestingUser);

    // Check for duplicate store name under same owner
    await this.validateUniqueStoreName(data.name, ownerId);

    const newStore: NewStore = {
      id: nanoid(),
      name: data.name,
      address: data.address,
      phone: data.phone,
      email: data.email,
      ownerId,
      isActive: true,
    };

    return await this.storeRepository.create(newStore);
  }

  async getStoreById(id: string, requestingUser: User): Promise<Store | null> {
    const store = await this.storeRepository.findById(id);
    
    if (!store) {
      return null;
    }

    // Check access permissions
    this.validateStoreAccess(store, requestingUser);
    
    return store;
  }

  async getAllStores(
    options: Partial<QueryOptions & PaginationOptions>,
    requestingUser: User
  ): Promise<PaginatedResult<Store>> {
    const queryOptions = this.buildStoreQueryOptions(options, requestingUser);
    return await this.storeRepository.findAll(queryOptions);
  }

  async updateStore(id: string, data: UpdateStoreRequest, requestingUser: User): Promise<Store | null> {
    const existingStore = await this.storeRepository.findById(id);
    
    if (!existingStore) {
      throw new NotFoundError('Store not found');
    }

    // Check permissions
    this.validateStoreUpdateAccess(existingStore, requestingUser);

    // Validate unique store name if name is being changed
    if (data.name && data.name !== existingStore.name) {
      await this.validateUniqueStoreName(data.name, existingStore.ownerId, id);
    }

    const updateData: Partial<Store> = { ...data };

    return await this.storeRepository.update(id, updateData);
  }

  async softDeleteStore(id: string, requestingUser: User): Promise<boolean> {
    const storeToDelete = await this.storeRepository.findById(id);
    
    if (!storeToDelete) {
      throw new NotFoundError('Store not found');
    }

    // Check permissions - ADMIN cannot delete stores
    this.validateStoreDeleteAccess(storeToDelete, requestingUser);

    return await this.storeRepository.softDelete(id);
  }

  async getStoresByOwner(ownerId: string, requestingUser: User, paginationOptions?: PaginatedBaseRequest): Promise<PaginatedResult<Store>> {
    // Validate access to owner's stores
    this.validateOwnerAccess(ownerId, requestingUser);

    const paginationOpts = this.convertToPaginationOptions(paginationOptions);
    return await this.storeRepository.findByOwnerId(ownerId, paginationOpts);
  }

  async getActiveStores(requestingUser: User, paginationOptions?: PaginatedBaseRequest): Promise<PaginatedResult<Store>> {
    const paginationOpts = this.convertToPaginationOptions(paginationOptions);
    const queryOptions = this.buildStoreQueryOptions({ filters: { isActive: true } }, requestingUser);
    const mergedOptions = { ...queryOptions, ...paginationOpts };
    return await this.storeRepository.findAll(mergedOptions);
  }

  async searchStores(searchTerm: string, requestingUser: User, paginationOptions?: PaginatedBaseRequest): Promise<PaginatedResult<Store>> {
    const paginationOpts = this.convertToPaginationOptions(paginationOptions);
    const queryOptions = this.buildStoreQueryOptions({}, requestingUser);
    const mergedOptions = { ...queryOptions, ...paginationOpts };
    
    return await this.storeRepository.searchStoresByName(searchTerm, mergedOptions);
  }

  async getUserAccessibleStores(userId: string, requestingUser: User): Promise<Store[]> {
    // Validate access to user's accessible stores
    this.validateUserStoreAccess(userId, requestingUser);

    // For all roles except OWNER, return all stores under the same owner
    if (requestingUser.role !== 'OWNER') {
      const ownerId = requestingUser.ownerId || requestingUser.id;
      const result = await this.storeRepository.findActiveStoresByOwner(ownerId);
      return result.data;
    }

    // For OWNER users, return all their stores
    if (requestingUser.role === 'OWNER') {
      const result = await this.storeRepository.findActiveStoresByOwner(requestingUser.id);
      return result.data;
    }

    return [];
  }

  // Private helper methods

  private convertToPaginationOptions(paginationOptions?: PaginatedBaseRequest): PaginationOptions {
    return {
      page: paginationOptions?.page || 1,
      limit: paginationOptions?.limit || 10,
      sortBy: paginationOptions?.sortBy || 'createdAt',
      sortOrder: paginationOptions?.sortOrder || 'desc',
    };
  }

  private validateStoreCreation(data: CreateStoreRequest, requestingUser: User): void {
    // STAFF and CASHIER cannot create stores
    if (requestingUser.role === 'STAFF' || requestingUser.role === 'CASHIER') {
      throw new AuthorizationError('Insufficient permissions to create stores');
    }

    // Validate required fields
    if (!data.name || data.name.trim().length === 0) {
      throw new ValidationError('Store name is required');
    }
  }

  private determineOwnerId(requestingUser: User): string {
    // If creating user is OWNER, they become the owner
    if (requestingUser.role === 'OWNER') {
      return requestingUser.id;
    }

    // For ADMIN creating stores, use the ADMIN's owner
    if (requestingUser.role === 'ADMIN' && requestingUser.ownerId) {
      return requestingUser.ownerId;
    }

    throw new ValidationError('Unable to determine owner for new store');
  }

  private async validateUniqueStoreName(name: string, ownerId: string, excludeStoreId?: string): Promise<void> {
    const existingStores = await this.storeRepository.findByOwnerId(ownerId);
    
    const duplicateStore = existingStores.data.find(store => 
      store.name.toLowerCase() === name.toLowerCase() && 
      store.id !== excludeStoreId
    );

    if (duplicateStore) {
      throw new ConflictError('A store with this name already exists for this owner');
    }
  }

  private validateStoreAccess(store: Store, requestingUser: User): void {
    // OWNER can access all stores under their ownership
    if (requestingUser.role === 'OWNER') {
      if (store.ownerId !== requestingUser.id) {
        throw new AuthorizationError('Access denied: Store not under your ownership');
      }
      return;
    }

    // ADMIN, STAFF, and CASHIER can access stores under the same owner
    if (requestingUser.ownerId && store.ownerId === requestingUser.ownerId) {
      return;
    }

    throw new AuthorizationError('Access denied: Store not accessible to your role');
  }

  private validateStoreUpdateAccess(storeToUpdate: Store, requestingUser: User): void {
    // Use same logic as read access
    this.validateStoreAccess(storeToUpdate, requestingUser);

    // Additional restrictions: STAFF and CASHIER cannot update stores
    if (requestingUser.role === 'STAFF' || requestingUser.role === 'CASHIER') {
      throw new AuthorizationError('Insufficient permissions to update stores');
    }
  }

  private validateStoreDeleteAccess(storeToDelete: Store, requestingUser: User): void {
    // ADMIN cannot delete stores at all
    if (requestingUser.role === 'ADMIN') {
      throw new AuthorizationError('Admin users cannot delete stores');
    }

    // Only OWNER can delete stores
    if (requestingUser.role !== 'OWNER') {
      throw new AuthorizationError('Only Owner can delete stores');
    }

    // OWNER can only delete stores under their ownership
    if (storeToDelete.ownerId !== requestingUser.id) {
      throw new AuthorizationError('Cannot delete store not under your ownership');
    }
  }

  private validateOwnerAccess(ownerId: string, requestingUser: User): void {
    if (requestingUser.role === 'OWNER' && requestingUser.id !== ownerId) {
      throw new AuthorizationError('Access denied: Cannot access other owner\'s stores');
    }

    if (requestingUser.role !== 'OWNER' && requestingUser.ownerId !== ownerId) {
      throw new AuthorizationError('Access denied: Cannot access stores outside your owner scope');
    }
  }

  private validateUserStoreAccess(userId: string, requestingUser: User): void {
    // Users can only access stores for themselves or users under their management
    if (requestingUser.role === 'OWNER') {
      // OWNER can access stores for any user under their ownership
      return;
    }

    if (requestingUser.role === 'ADMIN') {
      // ADMIN can access stores for users under the same owner
      return;
    }

    // STAFF and CASHIER can only access their own stores
    if (userId !== requestingUser.id) {
      throw new AuthorizationError('Access denied: Can only access own accessible stores');
    }
  }

  private buildStoreQueryOptions(
    options: Partial<QueryOptions & PaginationOptions>,
    requestingUser: User
  ): Partial<QueryOptions & PaginationOptions> {
    const queryOptions = { ...options };

    // Apply owner-based filtering
    if (requestingUser.role === 'OWNER') {
      // OWNER sees all stores under their ownership
      queryOptions.filters = {
        ...queryOptions.filters,
        ownerId: requestingUser.id
      };
    } else if (requestingUser.ownerId) {
      // Non-OWNER users see only stores under the same owner
      queryOptions.filters = {
        ...queryOptions.filters,
        ownerId: requestingUser.ownerId
      };
    } else {
      // Fallback: no stores visible
      queryOptions.filters = {
        ...queryOptions.filters,
        ownerId: 'no-access'
      };
    }

    return queryOptions;
  }
}