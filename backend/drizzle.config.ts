import type { Config } from "drizzle-kit";
import dotenv from "dotenv";

const envFile =
  process.env.NODE_ENV === "production"
    ? ".env.production"
    : process.env.NODE_ENV === "test"
    ? ".env.test"
    : ".env.development";

dotenv.config({ path: envFile });

export default {
  schema: "./src/models/*.ts",
  out: "./drizzle",
  dialect: "sqlite",
  dbCredentials: {
    url: process.env.DATABASE_URL!,
  },
} satisfies Config;
