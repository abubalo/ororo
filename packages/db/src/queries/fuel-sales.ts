import { eq } from 'drizzle-orm';
import type { DbClient } from '../client';
import { fuelSales } from '../schema';

export class FuelSaleRepository {
  constructor(private db: DbClient) {}

  async findById(id: string) {
    const result = await this.db
      .select()
      .from(fuelSales)
      .where(eq(fuelSales.id, id))
      .limit(1);
    return result[0] || null;
  }

  async findByTransaction(transactionId: string) {
    const result = await this.db
      .select()
      .from(fuelSales)
      .where(eq(fuelSales.transactionId, transactionId))
      .limit(1);
    return result[0] || null;
  }

  async create(data: {
    id: string;
    transactionId: string;
    pumpId: string;
    fuelType: string;
    litersDispensed: number;
    pricePerLiter: number;
    meterReadingBefore: number;
    meterReadingAfter: number;
  }) {
    const calculatedAmount = data.litersDispensed * data.pricePerLiter;
    
    await this.db.insert(fuelSales).values({
      ...data,
      calculatedAmount,
      createdAt: new Date(),
    });
    return await this.findById(data.id);
  }
}
