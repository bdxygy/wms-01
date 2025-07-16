import { describe, it, expect } from 'vitest';
import { 
  setupTestDatabase, 
  createTestOwner,
  createTestApp
} from '../utils';

setupTestDatabase();

describe('User Routes Simple Test', () => {
  it('should handle basic user creation', async () => {
    const owner = await createTestOwner();
    const app = createTestApp(owner);
    
    const newUserData = {
      email: 'test@example.com',
      password: 'password123',
      name: 'Test User',
      role: 'STAFF',
    };

    const response = await app.request('/api/v1/users', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(newUserData),
    });

    console.log('Response status:', response.status);
    const body = await response.json();
    console.log('Response body:', body);
    
    expect(response.status).toBeLessThan(500); // Just check it doesn't crash
  });
});