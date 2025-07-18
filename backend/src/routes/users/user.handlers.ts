import { Context } from "hono";
import { UserService } from "../../services/user.service";
import { ResponseUtils } from "../../utils/responses";
import { getValidated } from "../../utils/context";
import type { CreateUserRequest, UpdateUserRequest, ListUsersQuery, UserIdParam } from "../../schemas/user.schemas";

export const createUserHandler = async (c: Context) => {
  try {
    const validatedData = getValidated<CreateUserRequest>(c, "validatedBody");
    const user = c.get("user");
    const result = await UserService.createUser(validatedData, user);
    return ResponseUtils.sendCreated(c, result);
  } catch (error) {
    return ResponseUtils.sendError(c, error);
  }
};

export const getUserHandler = async (c: Context) => {
  try {
    const { id } = getValidated<UserIdParam>(c, "validatedParams");
    const user = c.get("user");
    const result = await UserService.getUserById(id, user);
    return ResponseUtils.sendSuccess(c, result);
  } catch (error) {
    return ResponseUtils.sendError(c, error);
  }
};

export const listUsersHandler = async (c: Context) => {
  try {
    const query = getValidated<ListUsersQuery>(c, "validatedQuery");
    const user = c.get("user");
    const result = await UserService.listUsers(query, user);
    return ResponseUtils.sendPaginated(c, result.users, result.pagination);
  } catch (error) {
    return ResponseUtils.sendError(c, error);
  }
};

export const updateUserHandler = async (c: Context) => {
  try {
    const { id } = getValidated<UserIdParam>(c, "validatedParams");
    const validatedData = getValidated<UpdateUserRequest>(c, "validatedBody");
    const user = c.get("user");
    const result = await UserService.updateUser(id, validatedData, user);
    return ResponseUtils.sendSuccess(c, result);
  } catch (error) {
    return ResponseUtils.sendError(c, error);
  }
};

export const deleteUserHandler = async (c: Context) => {
  try {
    const { id } = getValidated<UserIdParam>(c, "validatedParams");
    const user = c.get("user");
    const result = await UserService.deleteUser(id, user);
    return ResponseUtils.sendSuccess(c, result);
  } catch (error) {
    return ResponseUtils.sendError(c, error);
  }
};