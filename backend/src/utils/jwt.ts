import { SignJWT, jwtVerify } from "jose";
import { env } from "../config/env";

export interface JwtPayload {
  userId: string;
  role: string;
  ownerId?: string;
  iat?: number;
  exp?: number;
}

export class JwtUtils {
  // Convert JWT_SECRET to Uint8Array
  private static getSecretKey(): Uint8Array {
    return new TextEncoder().encode(env.JWT_SECRET);
  }

  // Convert JWT_REFRESH_SECRET to Uint8Array
  private static getRefreshSecretKey(): Uint8Array {
    return new TextEncoder().encode(env.JWT_REFRESH_SECRET);
  }

  static async generateAccessToken(
    payload: Omit<JwtPayload, "iat" | "exp">
  ): Promise<string> {
    const secret = this.getSecretKey();

    return await new SignJWT(payload)
      .setProtectedHeader({ alg: "HS256" })
      .setIssuedAt()
      .setExpirationTime(env.JWT_EXPIRES_IN)
      .sign(secret);
  }

  static async generateRefreshToken(
    payload: Omit<JwtPayload, "iat" | "exp">
  ): Promise<string> {
    const secret = this.getRefreshSecretKey();

    return await new SignJWT(payload)
      .setProtectedHeader({ alg: "HS256" })
      .setIssuedAt()
      .setExpirationTime(env.JWT_REFRESH_EXPIRES_IN)
      .sign(secret);
  }

  static async verifyAccessToken(token: string): Promise<JwtPayload> {
    try {
      const secret = this.getSecretKey();
      const { payload } = await jwtVerify(token, secret);
      return payload as unknown as JwtPayload;
    } catch (error) {
      throw new Error("Invalid access token");
    }
  }

  static async verifyRefreshToken(token: string): Promise<JwtPayload> {
    try {
      const secret = this.getRefreshSecretKey();
      const { payload } = await jwtVerify(token, secret);
      return payload as unknown as JwtPayload;
    } catch (error) {
      throw new Error("Invalid refresh token");
    }
  }

  static async generateTokenPair(payload: Omit<JwtPayload, "iat" | "exp">) {
    const [accessToken, refreshToken] = await Promise.all([
      this.generateAccessToken(payload),
      this.generateRefreshToken(payload),
    ]);

    return {
      accessToken,
      refreshToken,
    };
  }
}
