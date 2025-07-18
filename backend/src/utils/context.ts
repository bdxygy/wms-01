import { Context } from "hono";

export function getValidated<T>(c: Context, key: string): T {
  const data = c.get(key);
  if (!data) {
    throw new Error(`Validated data not found for key: ${key}`);
  }
  return data as T;
}