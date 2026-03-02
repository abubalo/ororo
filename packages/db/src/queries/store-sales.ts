import { eq } from 'drizzle-orm';
import type { DbClient } from '../client';
import { storeSales, storeSaleItems } from '../schema';

export class StoreSaleRepository {
  constructor(private db: DbClient) {}

  async findById(id: string) {
    const result = await this.db
      .select()
      .from(storeSales)
      .where(eq(storeSales.id, id))
      .limit(1);
    return result[0] || null;
  }

  async findByTransaction(transactionId: string) {
    const result = await this.db
      .select()
      .from(storeSales)
      .where(eq(storeSales.transactionId, transactionId))
      .limit(1);
    return result[0] || null;
  }

  async findItemsByStoreSale(storeSaleId: string) {
    return await this.db
      .select()
      .from(storeSaleItems)
      .where(eq(storeSaleItems.storeSaleId, storeSaleId));
  }

  async create(
    data: {
      id: string;
      transactionId: string;
    },
    items: Array<{
      id: string;
      productId: string;
      productName: string;
      quantity: number;
      unitPrice: number;
    }>
  ) {
    // Create store sale
    await this.db.insert(storeSales).values({
      ...data,
      createdAt: new Date(),
    });

    // Create line items
    const now = new Date();
    await this.db.insert(storeSaleItems).values(
      items.map((item) => ({
        ...item,
        storeSaleId: data.id,
        totalPrice: item.quantity * item.unitPrice,
        createdAt: now,
      }))
    );

    return await this.findById(data.id);
  }
}
