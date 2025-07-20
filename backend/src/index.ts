import { cors } from "hono/cors";
import { logger } from "hono/logger";
import { prettyJSON } from "hono/pretty-json";
import { secureHeaders } from "hono/secure-headers";
import { env } from "./config/env";
import { serve } from "@hono/node-server";
import { createApp } from "./http/hono";
import { authRoutes } from "./routes/auth/routes";
import { userRoutes } from "./routes/users/routes";
import { categoryRoutes } from "./routes/categories/routes";
import { productRoutes } from "./routes/products/routes";
import { transactionRoutes } from "./routes/transactions/routes";
import { storeRoutes } from "./routes/stores/routes";
import { imeiRoutes } from "./routes/imeis/routes";

const app = createApp();

// Global middleware
app.use(
  "*",
  cors({
    origin: env.CORS_ORIGIN,
    credentials: true,
  })
);

app.use("*", logger());
app.use("*", prettyJSON());
app.use("*", secureHeaders());

// Routes
app.route("/api/v1/auth", authRoutes);
app.route("/api/v1/users", userRoutes);
app.route("/api/v1/categories", categoryRoutes);
app.route("/api/v1/products", productRoutes);
app.route("/api/v1/transactions", transactionRoutes);
app.route("/api/v1/stores", storeRoutes);
app.route("/api/v1", imeiRoutes);

// Health check endpoint
app.get("/health", (c) => {
  return c.json({
    status: "ok",
    timestamp: new Date().toISOString(),
    environment: env.NODE_ENV,
  });
});

// 404 handler
app.notFound((c) => {
  return c.json({ message: "Not Found", status: 404 }, 404);
});

// Error handler
app.onError((err, c) => {
  console.error(`${err}`);
  return c.json(
    {
      message: "Internal Server Error",
      status: 500,
      ...(env.NODE_ENV === "development" && { stack: err.stack }),
    },
    500
  );
});

const port = env.PORT;

console.log(`🚀 Server is running on http://localhost:${port}`);
// Only start server if not in test environment
if (process.env.NODE_ENV !== "test") {
  serve({
    fetch: app.fetch,
    port,
    hostname: "0.0.0.0",
  });
}

export { app };
