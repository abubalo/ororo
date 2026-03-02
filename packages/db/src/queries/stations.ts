import { eq, and } from 'drizzle-orm';
import type { DbClient } from '../client';
import { stations } from '../schema';

export class StationRepository {
  constructor(private db: DbClient) {}

  async findById(id: string) {
    const result = await this.db
      .select()
      .from(stations)
      .where(eq(stations.id, id))
      .limit(1);
    return result[0] || null;
  }

  async findByOrganization(organizationId: string) {
    return await this.db
      .select()
      .from(stations)
      .where(eq(stations.organizationId, organizationId));
  }

  async findAll() {
    return await this.db.select().from(stations);
  }

  async create(data: {
    id: string;
    organizationId: string;
    name: string;
    address?: string;
    city?: string;
    phone?: string;
    operatingHours?: string;
    hasFuel?: boolean;
    hasCarWash?: boolean;
    hasStore?: boolean;
  }) {
    const now = new Date();
    await this.db.insert(stations).values({
      ...data,
      createdAt: now,
      updatedAt: now,
    });
    return await this.findById(data.id);
  }

  async update(id: string, data: Partial<typeof stations.$inferInsert>) {
    await this.db
      .update(stations)
      .set({
        ...data,
        updatedAt: new Date(),
      })
      .where(eq(stations.id, id));
    return await this.findById(id);
  }

  async delete(id: string) {
    await this.db.delete(stations).where(eq(stations.id, id));
  }
}
