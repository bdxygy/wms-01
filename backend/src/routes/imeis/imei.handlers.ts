import { Context } from "hono";
import { ImeiService } from "../../services/imei.service";
import { ResponseUtils } from "../../utils/responses";
import { getValidated } from "../../utils/context";
import type { AddImeiRequest, ProductIdParam, ImeiIdParam, ListProductImeisQuery } from "../../schemas/imei.schemas";

export const addImeiHandler = async (c: Context) => {
  try {
    const { id: productId } = getValidated<ProductIdParam>(c, "validatedParams");
    const validatedData = getValidated<AddImeiRequest>(c, "validatedBody");
    const user = c.get("user");
    const result = await ImeiService.addImei(productId, validatedData, user);
    return ResponseUtils.sendCreated(c, result);
  } catch (error) {
    return ResponseUtils.sendError(c, error);
  }
};

export const listProductImeisHandler = async (c: Context) => {
  try {
    const { id: productId } = getValidated<ProductIdParam>(c, "validatedParams");
    const query = getValidated<ListProductImeisQuery>(c, "validatedQuery");
    const user = c.get("user");
    const result = await ImeiService.listProductImeis(productId, query, user);
    return ResponseUtils.sendPaginated(c, result.imeis, result.pagination);
  } catch (error) {
    return ResponseUtils.sendError(c, error);
  }
};

export const removeImeiHandler = async (c: Context) => {
  try {
    const { id: imeiId } = getValidated<ImeiIdParam>(c, "validatedParams");
    const user = c.get("user");
    const result = await ImeiService.removeImei(imeiId, user);
    return ResponseUtils.sendSuccess(c, result);
  } catch (error) {
    return ResponseUtils.sendError(c, error);
  }
};