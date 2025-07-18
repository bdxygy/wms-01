import jwt from "jsonwebtoken";
import { env } from "../config/env";

export interface JwtPayload {
  userId: string;
  role: string;
  ownerId?: string;
  iat?: number;
  exp?: number;
}

export class JwtUtils {
  static generateAccessToken(payload: Omit<JwtPayload, "iat" | "exp">): string {
    return jwt.sign(payload, env.JWT_SECRET, {
      expiresIn: env.JWT_EXPIRES_IN,
    });
  }

  static generateRefreshToken(payload: Omit<JwtPayload, "iat" | "exp">): string {
    return jwt.sign(payload, env.JWT_REFRESH_SECRET, {
      expiresIn: env.JWT_REFRESH_EXPIRES_IN,
    });
  }

  static verifyAccessToken(token: string): JwtPayload {
    try {
      return jwt.verify(token, env.JWT_SECRET) as JwtPayload;
    } catch (error) {
      throw new Error("Invalid access token");
    }
  }

  static verifyRefreshToken(token: string): JwtPayload {
    try {
      return jwt.verify(token, env.JWT_REFRESH_SECRET) as JwtPayload;
    } catch (error) {
      throw new Error("Invalid refresh token");
    }
  }

  static generateTokenPair(payload: Omit<JwtPayload, "iat" | "exp">) {
    return {
      accessToken: this.generateAccessToken(payload),
      refreshToken: this.generateRefreshToken(payload),
    };
  }
}