import { nanoid } from 'nanoid';
import bcrypt from 'bcryptjs';
import { UserRepository } from '../repositories/user.repository';
import { StoreRepository } from '../repositories/store.repository';
import { type User, type NewUser, type Role } from '../models/users';
import { PaginatedResult, QueryOptions, PaginationOptions } from '../repositories/base.repository';
import { PaginatedBaseRequest } from '../utils/response';
import { 
  CreateUserRequest, 
  UpdateUserRequest 
} from '../schemas/user.schemas';
import { ValidationError, AuthorizationError, NotFoundError, ConflictError } from '../utils/errors';

export class UserService {
  private userRepository: UserRepository;
  private storeRepository: StoreRepository;

  constructor() {
    this.userRepository = new UserRepository();
    this.storeRepository = new StoreRepository();
  }

  async createUser(data: CreateUserRequest, requestingUser: User): Promise<User> {
    // Validate role-based creation restrictions
    this.validateUserCreation(data, requestingUser);

    // Hash password
    const hashedPassword = await bcrypt.hash(data.password, 12);

    // Determine owner assignment
    const ownerId = this.determineOwnerId(data, requestingUser);

    // Validate store assignment if provided
    if (data.storeId) {
      await this.validateStoreAssignment(data.storeId, ownerId);
    }

    const newUser: NewUser = {
      id: nanoid(),
      email: data.email,
      password: hashedPassword,
      name: data.name,
      role: data.role,
      ownerId,
      storeId: data.storeId,
      isActive: true,
    };

    return await this.userRepository.create(newUser);
  }

  async getUserById(id: string, requestingUser: User): Promise<User | null> {
    const user = await this.userRepository.findById(id);
    
    if (!user) {
      return null;
    }

    // Check access permissions
    this.validateUserAccess(user, requestingUser);
    
    return user;
  }

  async getAllUsers(
    options: Partial<QueryOptions & PaginationOptions>,
    requestingUser: User
  ): Promise<PaginatedResult<User>> {
    const queryOptions = this.buildUserQueryOptions(options, requestingUser);
    return await this.userRepository.findAll(queryOptions);
  }

  async updateUser(id: string, data: UpdateUserRequest, requestingUser: User): Promise<User | null> {
    const existingUser = await this.userRepository.findById(id);
    
    if (!existingUser) {
      throw new NotFoundError('User not found');
    }

    // Check permissions
    this.validateUserUpdateAccess(existingUser, requestingUser);

    // Validate role changes
    if (data.role && data.role !== existingUser.role) {
      this.validateRoleChange(data.role, requestingUser);
    }

    // Validate store assignment if provided
    if (data.storeId) {
      const ownerId = existingUser.ownerId || requestingUser.id;
      await this.validateStoreAssignment(data.storeId, ownerId);
    }

    const updateData: Partial<User> = { ...data };
    
    // Hash password if provided
    if (data.password) {
      updateData.password = await bcrypt.hash(data.password, 12);
    }

    return await this.userRepository.update(id, updateData);
  }

  async softDeleteUser(id: string, requestingUser: User): Promise<boolean> {
    const userToDelete = await this.userRepository.findById(id);
    
    if (!userToDelete) {
      throw new NotFoundError('User not found');
    }

    // Check permissions - ADMIN cannot delete users
    this.validateUserDeleteAccess(userToDelete, requestingUser);

    return await this.userRepository.softDelete(id);
  }

  async getUsersByOwner(ownerId: string, requestingUser: User, paginationOptions?: PaginatedBaseRequest): Promise<PaginatedResult<User>> {
    // Validate access to owner's users
    this.validateOwnerAccess(ownerId, requestingUser);

    const paginationOpts = this.convertToPaginationOptions(paginationOptions);
    return await this.userRepository.findByOwnerId(ownerId, paginationOpts);
  }

  async getUsersByRole(role: Role, requestingUser: User, paginationOptions?: PaginatedBaseRequest): Promise<PaginatedResult<User>> {
    const paginationOpts = this.convertToPaginationOptions(paginationOptions);
    const queryOptions = this.buildUserQueryOptions({ filters: { role } }, requestingUser);
    const mergedOptions = { ...queryOptions, ...paginationOpts };
    return await this.userRepository.findAll(mergedOptions);
  }

  async getActiveUsers(requestingUser: User, paginationOptions?: PaginatedBaseRequest): Promise<PaginatedResult<User>> {
    const paginationOpts = this.convertToPaginationOptions(paginationOptions);
    const queryOptions = this.buildUserQueryOptions({ filters: { isActive: true } }, requestingUser);
    const mergedOptions = { ...queryOptions, ...paginationOpts };
    return await this.userRepository.findAll(mergedOptions);
  }

  async getUserStores(userId: string, requestingUser: User): Promise<any[]> {
    const user = await this.getUserById(userId, requestingUser);
    
    if (!user) {
      throw new NotFoundError('User not found');
    }

    // For staff and cashier users, return all stores under the same owner
    if (user.role === 'STAFF' || user.role === 'CASHIER') {
      const ownerId = user.ownerId || user.id;
      return (await this.storeRepository.findActiveStoresByOwner(ownerId)).data;
    }

    // For ADMIN users, return stores they have access to under their owner
    if (user.role === 'ADMIN' && user.ownerId) {
      return (await this.storeRepository.findActiveStoresByOwner(user.ownerId)).data;
    }

    // For OWNER users, return all their stores
    if (user.role === 'OWNER') {
      return (await this.storeRepository.findActiveStoresByOwner(user.id)).data;
    }

    return [];
  }

  async verifyPassword(user: User, password: string): Promise<boolean> {
    return await bcrypt.compare(password, user.password);
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

  private validateUserCreation(data: CreateUserRequest, requestingUser: User): void {
    // ADMIN can only create STAFF users
    if (requestingUser.role === 'ADMIN' && data.role !== 'STAFF') {
      throw new ValidationError('Admin users can only create STAFF users');
    }

    // STAFF and CASHIER cannot create users
    if (requestingUser.role === 'STAFF' || requestingUser.role === 'CASHIER') {
      throw new AuthorizationError('Insufficient permissions to create users');
    }

    // OWNER can create any role except other OWNERS
    if (requestingUser.role === 'OWNER' && data.role === 'OWNER') {
      throw new ValidationError('Cannot create another OWNER user');
    }
  }

  private determineOwnerId(data: CreateUserRequest, requestingUser: User): string {
    // If creating user is OWNER, they become the owner
    if (requestingUser.role === 'OWNER') {
      return requestingUser.id;
    }

    // For ADMIN creating STAFF, use the ADMIN's owner
    if (requestingUser.role === 'ADMIN' && requestingUser.ownerId) {
      return requestingUser.ownerId;
    }

    throw new ValidationError('Unable to determine owner for new user');
  }

  private async validateStoreAssignment(storeId: string, ownerId: string): Promise<void> {
    const store = await this.storeRepository.findById(storeId);
    
    if (!store) {
      throw new NotFoundError('Store not found');
    }

    if (store.ownerId !== ownerId) {
      throw new AuthorizationError('Store does not belong to the specified owner');
    }

    if (!store.isActive) {
      throw new ValidationError('Cannot assign user to inactive store');
    }
  }

  private validateUserAccess(user: User, requestingUser: User): void {
    // OWNER can access all users under their ownership
    if (requestingUser.role === 'OWNER') {
      if (user.ownerId !== requestingUser.id && user.id !== requestingUser.id) {
        throw new AuthorizationError('Access denied: User not under your ownership');
      }
      return;
    }

    // ADMIN can access users under the same owner (including other ADMINs and STAFFs)
    if (requestingUser.role === 'ADMIN') {
      if (user.ownerId !== requestingUser.ownerId && user.id !== requestingUser.id) {
        throw new AuthorizationError('Access denied: User not under same owner');
      }
      return;
    }

    // STAFF and CASHIER can only access their own profile
    if (requestingUser.role === 'STAFF' || requestingUser.role === 'CASHIER') {
      if (user.id !== requestingUser.id) {
        throw new AuthorizationError('Access denied: Can only access own profile');
      }
      return;
    }

    throw new AuthorizationError('Access denied');
  }

  private validateUserUpdateAccess(userToUpdate: User, requestingUser: User): void {
    // Use same logic as read access
    this.validateUserAccess(userToUpdate, requestingUser);

    // Additional restriction: ADMIN cannot modify other ADMIN or OWNER users
    if (requestingUser.role === 'ADMIN') {
      if (userToUpdate.role === 'ADMIN' || userToUpdate.role === 'OWNER') {
        if (userToUpdate.id !== requestingUser.id) {
          throw new AuthorizationError('Admin cannot modify other Admin or Owner users');
        }
      }
    }
  }

  private validateUserDeleteAccess(userToDelete: User, requestingUser: User): void {
    // ADMIN cannot delete users at all
    if (requestingUser.role === 'ADMIN') {
      throw new AuthorizationError('Admin users cannot delete users');
    }

    // Only OWNER can delete users
    if (requestingUser.role !== 'OWNER') {
      throw new AuthorizationError('Only Owner can delete users');
    }

    // OWNER can only delete users under their ownership
    if (userToDelete.ownerId !== requestingUser.id && userToDelete.id !== requestingUser.id) {
      throw new AuthorizationError('Cannot delete user not under your ownership');
    }

    // Cannot delete other OWNER users
    if (userToDelete.role === 'OWNER' && userToDelete.id !== requestingUser.id) {
      throw new AuthorizationError('Cannot delete other Owner users');
    }
  }

  private validateRoleChange(newRole: Role, requestingUser: User): void {
    // ADMIN cannot change roles
    if (requestingUser.role === 'ADMIN') {
      throw new AuthorizationError('Admin users cannot change user roles');
    }

    // Only OWNER can change roles
    if (requestingUser.role !== 'OWNER') {
      throw new AuthorizationError('Only Owner can change user roles');
    }

    // Cannot change role to OWNER
    if (newRole === 'OWNER') {
      throw new ValidationError('Cannot change role to OWNER');
    }
  }

  private validateOwnerAccess(ownerId: string, requestingUser: User): void {
    if (requestingUser.role === 'OWNER' && requestingUser.id !== ownerId) {
      throw new AuthorizationError('Access denied: Cannot access other owner\'s users');
    }

    if (requestingUser.role !== 'OWNER' && requestingUser.ownerId !== ownerId) {
      throw new AuthorizationError('Access denied: Cannot access users outside your owner scope');
    }
  }

  private buildUserQueryOptions(
    options: Partial<QueryOptions & PaginationOptions>,
    requestingUser: User
  ): Partial<QueryOptions & PaginationOptions> {
    const queryOptions = { ...options };

    // Apply owner-based filtering
    if (requestingUser.role === 'OWNER') {
      // OWNER sees all users under their ownership + themselves
      queryOptions.filters = {
        ...queryOptions.filters,
        $or: [
          { ownerId: requestingUser.id },
          { id: requestingUser.id }
        ]
      };
    } else if (requestingUser.ownerId) {
      // Non-OWNER users see only users under the same owner
      queryOptions.filters = {
        ...queryOptions.filters,
        ownerId: requestingUser.ownerId
      };
    } else {
      // Fallback: only show own profile
      queryOptions.filters = {
        ...queryOptions.filters,
        id: requestingUser.id
      };
    }

    return queryOptions;
  }
}