import { env } from "../config/env";
import type { Context } from "hono";

export class CookieUtils {
  static readonly REFRESH_TOKEN_COOKIE_NAME = "refresh_token";
  
  // Get cookie settings based on environment
  private static getCookieSettings() {
    const isProduction = env.NODE_ENV === "production";
    
    return {
      httpOnly: true,
      secure: isProduction, // Only use secure in production
      sameSite: isProduction ? "strict" as const : "lax" as const,
      path: "/",
      maxAge: 7 * 24 * 60 * 60, // 7 days in seconds
    };
  }

  // Set refresh token cookie
  static setRefreshTokenCookie(c: Context, refreshToken: string): void {
    const settings = this.getCookieSettings();
    c.res.headers.set(
      "Set-Cookie",
      `${this.REFRESH_TOKEN_COOKIE_NAME}=${refreshToken}; HttpOnly; Path=${settings.path}; Max-Age=${settings.maxAge}; SameSite=${settings.sameSite}${settings.secure ? "; Secure" : ""}`
    );
  }

  // Get refresh token from cookie
  static getRefreshTokenFromCookie(c: Context): string | null {
    const cookies = c.req.header("cookie");
    if (!cookies) return null;

    const cookieMatch = cookies.match(
      new RegExp(`${this.REFRESH_TOKEN_COOKIE_NAME}=([^;]+)`)
    );
    
    return cookieMatch ? cookieMatch[1] : null;
  }

  // Clear refresh token cookie
  static clearRefreshTokenCookie(c: Context): void {
    const settings = this.getCookieSettings();
    c.res.headers.set(
      "Set-Cookie",
      `${this.REFRESH_TOKEN_COOKIE_NAME}=; HttpOnly; Path=${settings.path}; Max-Age=0; SameSite=${settings.sameSite}${settings.secure ? "; Secure" : ""}`
    );
  }
}