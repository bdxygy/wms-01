import { config } from 'dotenv';
import { execSync } from 'child_process';
import path from 'path';
import { beforeAll, afterAll } from 'vitest';

// Load test environment variables
config({ path: '.env.test' });

// Set test environment
process.env.NODE_ENV = 'test';

// Use a unique test database file to avoid locks
const testDbPath = `./test-${Date.now()}.db`;
process.env.DATABASE_URL = `file:${testDbPath}`;

// Ensure test database is used
if (!process.env.DATABASE_URL?.includes('test')) {
  throw new Error('Test database must be used for testing');
}

// Run migrations before tests
beforeAll(() => {
  try {
    execSync('pnpm run db:migrate', { 
      cwd: path.resolve(__dirname, '..'),
      stdio: 'inherit'
    });
  } catch (error) {
    console.error('Failed to run migrations:', error);
    throw error;
  }
});

// Clean up test database file after tests
afterAll(() => {
  try {
    execSync(`rm -f ${testDbPath}`, { 
      cwd: path.resolve(__dirname, '..')
    });
  } catch (error) {
    console.error('Failed to clean up test database:', error);
  }
});