import { eq, and } from 'drizzle-orm';
import type { DbClient } from '../client';
import { users } from '../schema';

export class UserRepository {
  constructor(private db: DbClient) {}

  async findById(id: string) {
    const result = await this.db
      .select()
      .from(users)
      .where(eq(users.id, id))
      .limit(1);
    return result[0] || null;
  }

  async findByPhone(phone: string) {
    const result = await this.db
      .select()
      .from(users)
      .where(eq(users.phone, phone))
      .limit(1);
    return result[0] || null;
  }

  async findByStation(stationId: string) {
    return await this.db
      .select()
      .from(users)
      .where(eq(users.stationId, stationId));
  }

  async findByRole(role: string) {
    return await this.db.select().from(users).where(eq(users.role, role));
  }

  async findActiveUsers() {
    return await this.db.select().from(users).where(eq(users.isActive, true));
  }

  async create(data: {
    id: string;
    phone: string;
    name: string;
    email?: string;
    role: string;
    pinHash: string;
    stationId?: string;
  }) {
    const now = new Date();
    await this.db.insert(users).values({
      ...data,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    });
    return await this.findById(data.id);
  }

  async update(id: string, data: Partial<typeof users.$inferInsert>) {
    await this.db
      .update(users)
      .set({
        ...data,
        updatedAt: new Date(),
      })
      .where(eq(users.id, id));
    return await this.findById(id);
  }

  async updateLastLogin(id: string) {
    await this.db
      .update(users)
      .set({
        lastLoginAt: new Date(),
        updatedAt: new Date(),
      })
      .where(eq(users.id, id));
  }

  async deactivate(id: string) {
    await this.db
      .update(users)
      .set({
        isActive: false,
        updatedAt: new Date(),
      })
      .where(eq(users.id, id));
  }

  async delete(id: string) {
    await this.db.delete(users).where(eq(users.id, id));
  }
}
