import { eq } from 'drizzle-orm';
import type { DbClient } from '../client';
import { organizations } from '../schema';

export class OrganizationRepository {
  constructor(private db: DbClient) {}

  async findById(id: string) {
    const result = await this.db
      .select()
      .from(organizations)
      .where(eq(organizations.id, id))
      .limit(1);
    return result[0] || null;
  }

  async findAll() {
    return await this.db.select().from(organizations);
  }

  async create(data: {
    id: string;
    name: string;
    contactEmail?: string;
    contactPhone?: string;
  }) {
    const now = new Date();
    await this.db.insert(organizations).values({
      ...data,
      createdAt: now,
      updatedAt: now,
    });
    return await this.findById(data.id);
  }

  async update(
    id: string,
    data: {
      name?: string;
      contactEmail?: string;
      contactPhone?: string;
    }
  ) {
    await this.db
      .update(organizations)
      .set({
        ...data,
        updatedAt: new Date(),
      })
      .where(eq(organizations.id, id));
    return await this.findById(id);
  }

  async delete(id: string) {
    await this.db.delete(organizations).where(eq(organizations.id, id));
  }
}
