import { Context } from "hono";
import { StoreService } from "../../services/store.service";
import { ResponseUtils } from "../../utils/responses";
import { getValidated } from "../../utils/context";
import type { CreateStoreRequest, UpdateStoreRequest, ListStoresQuery, StoreIdParam } from "../../schemas/store.schemas";

export const createStoreHandler = async (c: Context) => {
  try {
    const validatedData = getValidated<CreateStoreRequest>(c, "validatedBody");
    const user = c.get("user");
    const result = await StoreService.createStore(validatedData, user);
    return ResponseUtils.sendCreated(c, result);
  } catch (error) {
    return ResponseUtils.sendError(c, error);
  }
};

export const getStoreHandler = async (c: Context) => {
  try {
    const { id } = getValidated<StoreIdParam>(c, "validatedParams");
    const user = c.get("user");
    const result = await StoreService.getStoreById(id, user);
    return ResponseUtils.sendSuccess(c, result);
  } catch (error) {
    return ResponseUtils.sendError(c, error);
  }
};

export const listStoresHandler = async (c: Context) => {
  try {
    const query = getValidated<ListStoresQuery>(c, "validatedQuery");
    const user = c.get("user");
    const result = await StoreService.listStores(query, user);
    return ResponseUtils.sendPaginated(c, result.stores, result.pagination);
  } catch (error) {
    return ResponseUtils.sendError(c, error);
  }
};

export const updateStoreHandler = async (c: Context) => {
  try {
    const { id } = getValidated<StoreIdParam>(c, "validatedParams");
    const validatedData = getValidated<UpdateStoreRequest>(c, "validatedBody");
    const user = c.get("user");
    const result = await StoreService.updateStore(id, validatedData, user);
    return ResponseUtils.sendSuccess(c, result);
  } catch (error) {
    return ResponseUtils.sendError(c, error);
  }
};