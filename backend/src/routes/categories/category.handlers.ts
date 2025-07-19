import { Context } from "hono";
import { CategoryService } from "../../services/category.service";
import { ResponseUtils } from "../../utils/responses";
import { getValidated } from "../../utils/context";
import type { CreateCategoryRequest, UpdateCategoryRequest, ListCategoriesQuery, CategoryIdParam } from "../../schemas/category.schemas";

export const createCategoryHandler = async (c: Context) => {
  try {
    const validatedData = getValidated<CreateCategoryRequest>(c, "validatedBody");
    const user = c.get("user");
    const result = await CategoryService.createCategory(validatedData, user);
    return ResponseUtils.sendCreated(c, result);
  } catch (error) {
    return ResponseUtils.sendError(c, error);
  }
};

export const getCategoryHandler = async (c: Context) => {
  try {
    const { id } = getValidated<CategoryIdParam>(c, "validatedParams");
    const result = await CategoryService.getCategoryById(id);
    return ResponseUtils.sendSuccess(c, result);
  } catch (error) {
    return ResponseUtils.sendError(c, error);
  }
};

export const listCategoriesHandler = async (c: Context) => {
  try {
    const query = getValidated<ListCategoriesQuery>(c, "validatedQuery");
    const user = c.get("user");
    const result = await CategoryService.listCategories(query, user);
    return ResponseUtils.sendPaginated(c, result.categories, result.pagination);
  } catch (error) {
    return ResponseUtils.sendError(c, error);
  }
};

export const updateCategoryHandler = async (c: Context) => {
  try {
    const { id } = getValidated<CategoryIdParam>(c, "validatedParams");
    const validatedData = getValidated<UpdateCategoryRequest>(c, "validatedBody");
    const user = c.get("user");
    const result = await CategoryService.updateCategory(id, validatedData, user);
    return ResponseUtils.sendSuccess(c, result);
  } catch (error) {
    return ResponseUtils.sendError(c, error);
  }
};