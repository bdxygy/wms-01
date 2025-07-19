import { Context } from "hono";
import { ProductService } from "../../services/product.service";
import { ResponseUtils } from "../../utils/responses";
import { getValidated } from "../../utils/context";
import type { CreateProductRequest, UpdateProductRequest, ListProductsQuery, ProductIdParam, BarcodeParam } from "../../schemas/product.schemas";

export const createProductHandler = async (c: Context) => {
  try {
    const validatedData = getValidated<CreateProductRequest>(c, "validatedBody");
    const user = c.get("user");
    const result = await ProductService.createProduct(validatedData, user);
    return ResponseUtils.sendCreated(c, result);
  } catch (error) {
    return ResponseUtils.sendError(c, error);
  }
};

export const getProductHandler = async (c: Context) => {
  try {
    const { id } = getValidated<ProductIdParam>(c, "validatedParams");
    const result = await ProductService.getProductById(id);
    return ResponseUtils.sendSuccess(c, result);
  } catch (error) {
    return ResponseUtils.sendError(c, error);
  }
};

export const getProductByBarcodeHandler = async (c: Context) => {
  try {
    const { barcode } = getValidated<BarcodeParam>(c, "validatedParams");
    const user = c.get("user");
    const result = await ProductService.getProductByBarcode(barcode, user);
    return ResponseUtils.sendSuccess(c, result);
  } catch (error) {
    return ResponseUtils.sendError(c, error);
  }
};

export const listProductsHandler = async (c: Context) => {
  try {
    const query = getValidated<ListProductsQuery>(c, "validatedQuery");
    const user = c.get("user");
    const result = await ProductService.listProducts(query, user);
    return ResponseUtils.sendPaginated(c, result.products, result.pagination);
  } catch (error) {
    return ResponseUtils.sendError(c, error);
  }
};

export const updateProductHandler = async (c: Context) => {
  try {
    const { id } = getValidated<ProductIdParam>(c, "validatedParams");
    const validatedData = getValidated<UpdateProductRequest>(c, "validatedBody");
    const user = c.get("user");
    const result = await ProductService.updateProduct(id, validatedData, user);
    return ResponseUtils.sendSuccess(c, result);
  } catch (error) {
    return ResponseUtils.sendError(c, error);
  }
};