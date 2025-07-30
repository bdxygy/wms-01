import { Context, Next } from "hono";
import { z } from "zod";
import { HTTPException } from "hono/http-exception";

export class ValidationMiddleware {
  static body<T extends z.ZodType>(schema: T) {
    return async (c: Context, next: Next) => {
      try {
        const body = await c.req.json();
        const validatedData = schema.parse(body);
        c.set("validatedBody", validatedData);
        await next();
      } catch (error) {
        if (error instanceof z.ZodError) {
          throw new HTTPException(400, {
            message: error.errors
              .map((e) => `${e.path.join(".")}: ${e.message}`)
              .join(", "),
          });
        }
        throw error;
      }
    };
  }

  static query<T extends z.ZodType>(schema: T) {
    return async (c: Context, next: Next) => {
      try {
        const query = c.req.query();
        const validatedData = schema.parse(query);
        c.set("validatedQuery", validatedData);
        await next();
      } catch (error) {
        if (error instanceof z.ZodError) {
          throw new HTTPException(400, {
            message: error.errors
              .map((e) => `${e.path.join(".")}: ${e.message}`)
              .join(", "),
          });
        }
        throw error;
      }
    };
  }

  static params<T extends z.ZodType>(schema: T) {
    return async (c: Context, next: Next) => {
      try {
        const params = c.req.param();
        const validatedData = schema.parse(params);
        c.set("validatedParams", validatedData);
        await next();
      } catch (error) {
        if (error instanceof z.ZodError) {
          throw new HTTPException(400, {
            message: error.errors
              .map((e) => `${e.path.join(".")}: ${e.message}`)
              .join(", "),
          });
        }
        throw error;
      }
    };
  }

  /**
   * Validate uploaded image file
   */
  static validateImageUpload(imageFile: File | null): void {
    if (!imageFile) {
      throw new Error("Image file is required");
    }

    // Validate image file extension
    const validExtensions = [".jpg", ".jpeg", ".png", ".gif", ".webp", ".bmp"];
    const fileName = imageFile.name?.toLowerCase() || "";
    const hasValidExtension = validExtensions.some((ext) =>
      fileName.endsWith(ext)
    );

    if (!hasValidExtension) {
      throw new Error(
        `File must have a valid image extension: ${validExtensions.join(", ")}`
      );
    }
  }
}
