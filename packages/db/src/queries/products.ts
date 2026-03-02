import { eq, and, sql } from 'drizzle-orm';
import type { DbClient } from '../client';
import { products, stockMovements } from '../schema';

// Helper function for ULID generation (simplified version)
function ulid() {
  return Date.now().toString(36) + Math.random().toString(36).substring(2);
}

export class ProductRepository {
  constructor(private db: DbClient) {}

  async findById(id: string) {
    const result = await this.db
      .select()
      .from(products)
      .where(eq(products.id, id))
      .limit(1);
    return result[0] || null;
  }

  async findByStation(stationId: string) {
    return await this.db
      .select()
      .from(products)
      .where(eq(products.stationId, stationId));
  }

  async findActiveByStation(stationId: string) {
    return await this.db
      .select()
      .from(products)
      .where(
        and(
          eq(products.stationId, stationId),
          eq(products.isActive, true)
        )
      );
  }

  async findLowStock(stationId: string) {
    return await this.db
      .select()
      .from(products)
      .where(
        and(
          eq(products.stationId, stationId),
          eq(products.isActive, true),
          sql`${products.currentStock} <= ${products.minimumStock}`
        )
      );
  }

  async create(data: {
    id: string;
    stationId: string;
    categoryId?: string;
    name: string;
    description?: string;
    sku?: string;
    barcode?: string;
    costPrice: number;
    sellingPrice: number;
    currency?: string;
    currentStock?: number;
    minimumStock?: number;
    unit?: string;
  }) {
    const now = new Date();
    await this.db.insert(products).values({
      ...data,
      createdAt: now,
      updatedAt: now,
    });
    return await this.findById(data.id);
  }

  async update(id: string, data: Partial<typeof products.$inferInsert>) {
    await this.db
      .update(products)
      .set({
        ...data,
        updatedAt: new Date(),
      })
      .where(eq(products.id, id));
    return await this.findById(id);
  }

  async adjustStock(
    productId: string,
    movementType: string,
    quantity: number,
    recordedBy: string,
    reference?: string,
    notes?: string,
    transactionId?: string
  ) {
    const product = await this.findById(productId);
    if (!product) throw new Error('Product not found');

    const quantityBefore = product.currentStock;
    const quantityAfter = quantityBefore + quantity;

    // Update product stock
    await this.db
      .update(products)
      .set({
        currentStock: quantityAfter,
        updatedAt: new Date(),
        ...(movementType === 'purchase' ? { lastRestockedAt: new Date() } : {}),
      })
      .where(eq(products.id, productId));

    // Record stock movement
    await this.db.insert(stockMovements).values({
      id: ulid(),
      productId,
      movementType,
      quantity,
      quantityBefore,
      quantityAfter,
      transactionId,
      reference,
      notes,
      recordedBy,
      movementDate: new Date(),
      createdAt: new Date(),
    });

    return await this.findById(productId);
  }
}
