import { describe, it, expect, beforeEach } from "vitest";
import { app } from "../../src/index";
import { db } from "../../src/config/database";
import { users } from "../../src/models/users";
import { eq } from "drizzle-orm";
import { env } from "../../src/config/env";

describe("Auth Routes", () => {
  beforeEach(async () => {
    // Clean up users table before each test
    await db.delete(users);
  });

  describe("POST /api/v1/auth/dev/register", () => {
    it("should register a new owner user with valid basic auth", async () => {
      const basicAuthHeader = `Basic ${Buffer.from(
        `${env.BASIC_AUTH_USERNAME}:${env.BASIC_AUTH_PASSWORD}`
      ).toString("base64")}`;

      const response = await app.request("/api/v1/auth/dev/register", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: basicAuthHeader,
        },
        body: JSON.stringify({
          name: "Owner User",
          username: "owner",
          password: "password123",
        }),
      });

      expect(response.status).toBe(201);
      const data = await response.json();
      expect(data.success).toBe(true);
      expect(data.data.user.role).toBe("OWNER");
      expect(data.data.user.ownerId).toBe(null);
      expect(data.data.tokens.accessToken).toBeDefined();
      expect(data.data.tokens.refreshToken).toBeDefined();
    });

    it("should return 401 without basic auth", async () => {
      const response = await app.request("/api/v1/auth/dev/register", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          name: "Owner User",
          username: "owner",
          password: "password123",
        }),
      });

      expect(response.status).toBe(401);
    });

    it("should return 401 with invalid basic auth", async () => {
      const basicAuthHeader = `Basic ${Buffer.from("invalid:credentials").toString("base64")}`;

      const response = await app.request("/api/v1/auth/dev/register", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: basicAuthHeader,
        },
        body: JSON.stringify({
          name: "Owner User",
          username: "owner",
          password: "password123",
        }),
      });

      expect(response.status).toBe(401);
    });

    it("should return 400 for duplicate username", async () => {
      const basicAuthHeader = `Basic ${Buffer.from(
        `${env.BASIC_AUTH_USERNAME}:${env.BASIC_AUTH_PASSWORD}`
      ).toString("base64")}`;

      // First registration
      await app.request("/api/v1/auth/dev/register", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: basicAuthHeader,
        },
        body: JSON.stringify({
          name: "Owner User",
          username: "owner",
          password: "password123",
        }),
      });

      // Second registration with same username
      const response = await app.request("/api/v1/auth/dev/register", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: basicAuthHeader,
        },
        body: JSON.stringify({
          name: "Another Owner",
          username: "owner",
          password: "password456",
        }),
      });

      expect(response.status).toBe(400);
      const data = await response.json();
      expect(data.success).toBe(false);
      expect(data.error.message).toBe("Username already exists");
    });

    it("should return 400 for invalid data", async () => {
      const basicAuthHeader = `Basic ${Buffer.from(
        `${env.BASIC_AUTH_USERNAME}:${env.BASIC_AUTH_PASSWORD}`
      ).toString("base64")}`;

      const response = await app.request("/api/v1/auth/dev/register", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: basicAuthHeader,
        },
        body: JSON.stringify({
          name: "",
          username: "ab",
          password: "123",
        }),
      });

      expect(response.status).toBe(400);
      const data = await response.json();
      expect(data.success).toBe(false);
      expect(data.error.code).toBe("VALIDATION_ERROR");
    });
  });

  describe("POST /api/v1/auth/login", () => {
    beforeEach(async () => {
      // Create a test user
      const basicAuthHeader = `Basic ${Buffer.from(
        `${env.BASIC_AUTH_USERNAME}:${env.BASIC_AUTH_PASSWORD}`
      ).toString("base64")}`;

      await app.request("/api/v1/auth/dev/register", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: basicAuthHeader,
        },
        body: JSON.stringify({
          name: "Test User",
          username: "testuser",
          password: "password123",
        }),
      });
    });

    it("should login with valid credentials", async () => {
      const response = await app.request("/api/v1/auth/login", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          username: "testuser",
          password: "password123",
        }),
      });

      expect(response.status).toBe(200);
      const data = await response.json();
      expect(data.success).toBe(true);
      expect(data.data.user.username).toBe("testuser");
      expect(data.data.tokens.accessToken).toBeDefined();
      expect(data.data.tokens.refreshToken).toBeDefined();
    });

    it("should return 401 with invalid username", async () => {
      const response = await app.request("/api/v1/auth/login", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          username: "nonexistent",
          password: "password123",
        }),
      });

      expect(response.status).toBe(401);
      const data = await response.json();
      expect(data.success).toBe(false);
      expect(data.error.message).toBe("Invalid credentials");
    });

    it("should return 401 with invalid password", async () => {
      const response = await app.request("/api/v1/auth/login", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          username: "testuser",
          password: "wrongpassword",
        }),
      });

      expect(response.status).toBe(401);
      const data = await response.json();
      expect(data.success).toBe(false);
      expect(data.error.message).toBe("Invalid credentials");
    });

    it("should return 401 for deactivated user", async () => {
      // Deactivate the user
      await db.update(users).set({ isActive: false }).where(eq(users.username, "testuser"));

      const response = await app.request("/api/v1/auth/login", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          username: "testuser",
          password: "password123",
        }),
      });

      expect(response.status).toBe(401);
      const data = await response.json();
      expect(data.success).toBe(false);
      expect(data.error.message).toBe("Account is deactivated");
    });

    it("should return 400 for missing credentials", async () => {
      const response = await app.request("/api/v1/auth/login", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          username: "",
          password: "",
        }),
      });

      expect(response.status).toBe(400);
      const data = await response.json();
      expect(data.success).toBe(false);
      expect(data.error.code).toBe("VALIDATION_ERROR");
    });
  });

  describe("POST /api/v1/auth/refresh", () => {
    let refreshToken: string;

    beforeEach(async () => {
      // Create a test user and get tokens
      const basicAuthHeader = `Basic ${Buffer.from(
        `${env.BASIC_AUTH_USERNAME}:${env.BASIC_AUTH_PASSWORD}`
      ).toString("base64")}`;

      await app.request("/api/v1/auth/dev/register", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: basicAuthHeader,
        },
        body: JSON.stringify({
          name: "Test User",
          username: "testuser",
          password: "password123",
        }),
      });

      const loginResponse = await app.request("/api/v1/auth/login", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          username: "testuser",
          password: "password123",
        }),
      });

      const loginData = await loginResponse.json();
      refreshToken = loginData.data.tokens.refreshToken;
    });

    it("should refresh tokens with valid refresh token", async () => {
      const response = await app.request("/api/v1/auth/refresh", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          refreshToken,
        }),
      });

      expect(response.status).toBe(200);
      const data = await response.json();
      expect(data.success).toBe(true);
      expect(data.data.user.username).toBe("testuser");
      expect(data.data.tokens.accessToken).toBeDefined();
      expect(data.data.tokens.refreshToken).toBeDefined();
    });

    it("should return 401 with invalid refresh token", async () => {
      const response = await app.request("/api/v1/auth/refresh", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          refreshToken: "invalid-token",
        }),
      });

      expect(response.status).toBe(401);
      const data = await response.json();
      expect(data.success).toBe(false);
      expect(data.error.message).toBe("Invalid refresh token");
    });

    it("should return 401 for deactivated user", async () => {
      // Deactivate the user
      await db.update(users).set({ isActive: false }).where(eq(users.username, "testuser"));

      const response = await app.request("/api/v1/auth/refresh", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          refreshToken,
        }),
      });

      expect(response.status).toBe(401);
      const data = await response.json();
      expect(data.success).toBe(false);
      expect(data.error.message).toBe("Account is deactivated");
    });

    it("should return 400 for missing refresh token", async () => {
      const response = await app.request("/api/v1/auth/refresh", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          refreshToken: "",
        }),
      });

      expect(response.status).toBe(400);
      const data = await response.json();
      expect(data.success).toBe(false);
      expect(data.error.code).toBe("VALIDATION_ERROR");
    });
  });
});