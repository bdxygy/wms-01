import { User } from '@/models/users';

declare module 'hono' {
  interface ContextVariableMap {
    user: User;
  }
}