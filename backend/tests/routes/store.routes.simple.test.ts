import { describe, it, expect, beforeEach, afterEach, beforeAll } from 'vitest';
import { testClient } from 'hono/testing';
import { app } from '../../src/index';
import { db } from '../../src/config/database';
import { users, stores } from '../../src/models';
import { nanoid } from 'nanoid';
import bcrypt from 'bcryptjs';

// Test client
const client = testClient(app);

describe('Store Routes Simple Test', () => {
  beforeAll(async () => {
    // Clean up before tests
    await db.delete(stores).execute();
    await db.delete(users).execute();
  });

  it('should handle basic store creation workflow', async () => {
    // Create an OWNER user first
    const hashedPassword = await bcrypt.hash('password123', 12);
    const ownerUser = {
      id: nanoid(),
      email: 'owner@test.com',
      password: hashedPassword,
      name: 'Owner User',
      role: 'OWNER' as const,
      ownerId: null,
      storeId: null,
      isActive: true,
    };
    await db.insert(users).values(ownerUser).execute();

    console.log('Created owner user:', ownerUser.id);

    // Test store creation endpoint structure
    const response = await client.api.v1.stores.$post({
      json: {
        name: 'Test Store',
        address: '123 Test Street',
        phone: '+1-234-567-8900',
        email: 'test@store.com',
      }
    });

    console.log('Response status:', response.status);
    
    const body = await response.json();
    console.log('Response body:', JSON.stringify(body, null, 2));

    // Should return 401 (Unauthorized) since no user is authenticated
    expect(response.status).toBe(401);
    expect(body.success).toBe(false);
    expect(body.error?.code).toBe('UNAUTHORIZED');

    // Clean up
    await db.delete(stores).execute();
    await db.delete(users).execute();
  });
});