import { Context } from "hono";
import { AuthService } from "../../services/auth.service";
import { ResponseUtils } from "../../utils/responses";
import { getValidated } from "../../utils/context";
import type { DevRegisterRequest, RegisterRequest, LoginRequest, RefreshTokenRequest } from "../../schemas/auth.schemas";

export const devRegisterHandler = async (c: Context) => {
  try {
    const validatedData = getValidated<DevRegisterRequest>(c, "validatedBody");
    const result = await AuthService.devRegister(validatedData, c);
    return ResponseUtils.sendCreated(c, result);
  } catch (error) {
    return ResponseUtils.sendError(c, error);
  }
};

export const registerHandler = async (c: Context) => {
  try {
    const validatedData = getValidated<RegisterRequest>(c, "validatedBody");
    const user = c.get("user");
    const result = await AuthService.register(validatedData, user.id, c);
    return ResponseUtils.sendCreated(c, result);
  } catch (error) {
    return ResponseUtils.sendError(c, error);
  }
};

export const loginHandler = async (c: Context) => {
  try {
    const validatedData = getValidated<LoginRequest>(c, "validatedBody");
    const result = await AuthService.login(validatedData, c);
    return ResponseUtils.sendSuccess(c, result);
  } catch (error) {
    return ResponseUtils.sendError(c, error);
  }
};

export const refreshHandler = async (c: Context) => {
  try {
    const validatedData = getValidated<RefreshTokenRequest>(c, "validatedBody");
    const result = await AuthService.refresh(validatedData, c);
    return ResponseUtils.sendSuccess(c, result);
  } catch (error) {
    return ResponseUtils.sendError(c, error);
  }
};

export const logoutHandler = async (c: Context) => {
  try {
    const result = await AuthService.logout(c);
    return ResponseUtils.sendSuccess(c, result);
  } catch (error) {
    return ResponseUtils.sendError(c, error);
  }
};