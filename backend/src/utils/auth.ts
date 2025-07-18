import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import { env } from "../config/env";

export const hashPassword = async (password: string): Promise<string> => {
  return bcrypt.hash(password, 10);
};

export const verifyPassword = async (
  password: string,
  hashedPassword: string
): Promise<boolean> => {
  return bcrypt.compare(password, hashedPassword);
};

export const generateToken = (payload: {
  userId: string;
  role: string;
  ownerId?: string;
}): string => {
  return jwt.sign(payload, env.JWT_SECRET, { expiresIn: "7d" });
};

export const verifyToken = (
  token: string
): { userId: string; role: string; ownerId?: string } => {
  return jwt.verify(token, env.JWT_SECRET) as {
    userId: string;
    role: string;
    ownerId?: string;
  };
};
