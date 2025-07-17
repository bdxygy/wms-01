import { serve } from "@hono/node-server";
import { swaggerUI } from "@hono/swagger-ui";
import { OpenAPIHono } from "@hono/zod-openapi";
import { cors } from "hono/cors";
import { logger } from "hono/logger";
import { prettyJSON } from "hono/pretty-json";
import { secureHeaders } from "hono/secure-headers";
import { env } from "./config/env";
import { userRoutes } from "./routes/user.routes";
import { storeRoutes } from "./routes/store.routes";

const app = new OpenAPIHono();

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

// Health check endpoint
app.get("/health", (c) => {
  return c.json({
    status: "ok",
    timestamp: new Date().toISOString(),
    environment: env.NODE_ENV,
  });
});

// API routes
// app.route('/api/v1/auth', authRoutes);
app.route('/api/v1/users', userRoutes);
app.route('/api/v1/stores', storeRoutes);
// app.route('/api/v1/products', productRoutes);
// app.route('/api/v1/transactions', transactionRoutes);

// OpenAPI documentation
app.doc("/doc", {
  openapi: "3.0.0",
  info: {
    version: "1.0.0",
    title: "WMS API",
    description: "Warehouse Management System API",
  },
});

app.get("/ui", swaggerUI({ url: "/doc" }));

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
console.log(`📚 API Documentation: http://localhost:${port}/ui`);
console.log(
  `📊 Database: ${env.NODE_ENV === "production" ? "Turso" : "better-sqlite3"}`
);

// Only start server if not in test environment
if (process.env.NODE_ENV !== "test") {
  serve({
    fetch: app.fetch,
    port,
  });
}

export { app };
