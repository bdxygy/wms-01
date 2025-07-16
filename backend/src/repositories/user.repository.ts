import { BaseRepositoryImpl } from "./base.repository";
import { users, type User, type NewUser } from "../models/users";
import { and, eq, isNull } from "drizzle-orm";

export class UserRepository extends BaseRepositoryImpl<
  User,
  NewUser,
  Partial<User>
> {
  constructor() {
    super(users);
  }

  // Add any user-specific methods here
  async findByEmail(email: string): Promise<User | null> {
    const [result] = await this.getDb()
      .select()
      .from(this.table)
      .where(
        and(
          eq(this.getColumn("email"), email),
          isNull(this.getColumn("deletedAt"))
        )
      )
      .limit(1);

    return (result as User) || null;
  }

  async findByOwnerId(ownerId: string, options: any = {}) {
    return this.findAll({
      ...options,
      filters: { ...(options.filters || {}), ownerId },
    });
  }

  async findActiveUsers() {
    return this.findAll({
      filters: { isActive: true },
    });
  }
}
