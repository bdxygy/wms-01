import { Context, Next } from "hono";
import { HTTPException } from "hono/http-exception";
import { env } from "../config/env";

export const basicAuthMiddleware = async (c: Context, next: Next) => {
  const authHeader = c.req.header("Authorization");
  
  if (!authHeader || !authHeader.startsWith("Basic ")) {
    throw new HTTPException(401, { message: "Basic authentication required" });
  }

  const base64Credentials = authHeader.slice(6); // Remove "Basic " prefix
  const credentials = Buffer.from(base64Credentials, "base64").toString("utf-8");
  const [username, password] = credentials.split(":");

  if (username !== env.BASIC_AUTH_USERNAME || password !== env.BASIC_AUTH_PASSWORD) {
    throw new HTTPException(401, { message: "Invalid credentials" });
  }

  await next();
};