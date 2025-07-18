import { createMiddleware } from "hono/factory";
import { HTTPException } from "hono/http-exception";
import { JwtUtils } from "../utils/jwt";
import { db } from "../config/database";
import { users } from "../models/users";
import { eq } from "drizzle-orm";
import type { Applications } from "../http/hono";

export const authMiddleware = createMiddleware<Applications>(async (c, next) => {
  try {
    // Get token from Authorization header
    const authHeader = c.req.header("Authorization");
    
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      throw new HTTPException(401, { message: "Missing or invalid authorization header" });
    }

    const token = authHeader.slice(7); // Remove "Bearer " prefix

    // Verify JWT token
    const decoded = await JwtUtils.verifyAccessToken(token);

    // Find user in database
    const user = await db
      .select()
      .from(users)
      .where(eq(users.id, decoded.userId));

    if (!user[0]) {
      throw new HTTPException(401, { message: "User not found" });
    }

    // Check if user is active
    if (!user[0].isActive) {
      throw new HTTPException(401, { message: "Account is deactivated" });
    }

    // Inject user into context
    c.set("user", user[0]);

    await next();
  } catch (error) {
    if (error instanceof HTTPException) {
      throw error;
    }
    // Handle JWT verification errors
    throw new HTTPException(401, { message: "Invalid or expired token" });
  }
});

// Optional middleware - doesn't throw error if no token
export const optionalAuthMiddleware = createMiddleware<Applications>(async (c, next) => {
  try {
    const authHeader = c.req.header("Authorization");
    
    if (authHeader && authHeader.startsWith("Bearer ")) {
      const token = authHeader.slice(7);
      const decoded = await JwtUtils.verifyAccessToken(token);
      
      const user = await db
        .select()
        .from(users)
        .where(eq(users.id, decoded.userId));

      if (user[0] && user[0].isActive) {
        c.set("user", user[0]);
      }
    }
    
    await next();
  } catch (error) {
    // Silently continue without user context
    await next();
  }
});