import { z } from 'zod';
import dotenv from 'dotenv';

// Load appropriate environment file based on NODE_ENV
const envFile = process.env.NODE_ENV === 'production' 
  ? '.env.production' 
  : process.env.NODE_ENV === 'test' 
  ? '.env.test' 
  : '.env.development';

dotenv.config({ path: envFile });

const envSchema = z.object({
  // Database
  DATABASE_URL: z.string().min(1, 'DATABASE_URL is required'),
  DATABASE_AUTH_TOKEN: z.string().optional(),
  
  // JWT
  JWT_SECRET: z.string().min(32, 'JWT_SECRET must be at least 32 characters'),
  JWT_REFRESH_SECRET: z.string().min(32, 'JWT_REFRESH_SECRET must be at least 32 characters'),
  JWT_EXPIRES_IN: z.string().default('15m'),
  JWT_REFRESH_EXPIRES_IN: z.string().default('7d'),
  
  // Server
  PORT: z.coerce.number().int().min(1000).max(65535).default(3000),
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
  
  // CORS
  CORS_ORIGIN: z.string().default('*'),

  // Basic Auth
  BASIC_AUTH_USERNAME: z.string().min(1, 'BASIC_AUTH_USERNAME is required'),
  BASIC_AUTH_PASSWORD: z.string().min(1, 'BASIC_AUTH_PASSWORD is required'),
  
  // Barcode
  BARCODE_PREFIX: z.string().min(1, 'BARCODE_PREFIX is required').default('A'),
});

export const env = envSchema.parse(process.env);