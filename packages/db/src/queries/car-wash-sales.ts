import { eq } from 'drizzle-orm';
import type { DbClient } from '../client';
import { carWashSales } from '../schema';

export class CarWashSaleRepository {
  constructor(private db: DbClient) {}

  async findById(id: string) {
    const result = await this.db
      .select()
      .from(carWashSales)
      .where(eq(carWashSales.id, id))
      .limit(1);
    return result[0] || null;
  }

  async findByTransaction(transactionId: string) {
    const result = await this.db
      .select()
      .from(carWashSales)
      .where(eq(carWashSales.transactionId, transactionId))
      .limit(1);
    return result[0] || null;
  }

  async create(data: {
    id: string;
    transactionId: string;
    serviceId?: string;
    serviceName: string;
    vehicleType: string;
    price: number;
    notes?: string;
  }) {
    await this.db.insert(carWashSales).values({
      ...data,
      createdAt: new Date(),
    });
    return await this.findById(data.id);
  }
}
