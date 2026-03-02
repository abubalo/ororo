import { eq, and, desc, between, sql } from 'drizzle-orm';
import type { DbClient } from '../client';
import { transactions } from '../schema';

export class TransactionRepository {
  constructor(private db: DbClient) {}

  async findById(id: string) {
    const result = await this.db
      .select()
      .from(transactions)
      .where(eq(transactions.id, id))
      .limit(1);
    return result[0] || null;
  }

  async findByReceiptNumber(receiptNumber: string) {
    const result = await this.db
      .select()
      .from(transactions)
      .where(eq(transactions.receiptNumber, receiptNumber))
      .limit(1);
    return result[0] || null;
  }

  async findByShift(shiftId: string) {
    return await this.db
      .select()
      .from(transactions)
      .where(eq(transactions.shiftId, shiftId))
      .orderBy(desc(transactions.transactionDate));
  }

  async findByStation(stationId: string, limit: number = 100) {
    return await this.db
      .select()
      .from(transactions)
      .where(eq(transactions.stationId, stationId))
      .orderBy(desc(transactions.transactionDate))
      .limit(limit);
  }

  async findByDateRange(
    stationId: string,
    startDate: Date,
    endDate: Date
  ) {
    return await this.db
      .select()
      .from(transactions)
      .where(
        and(
          eq(transactions.stationId, stationId),
          between(transactions.transactionDate, startDate, endDate)
        )
      )
      .orderBy(desc(transactions.transactionDate));
  }

  async findPendingSync(deviceId?: string) {
    const conditions = [sql`${transactions.syncedAt} IS NULL`];
    if (deviceId) {
      conditions.push(eq(transactions.deviceId, deviceId));
    }

    return await this.db
      .select()
      .from(transactions)
      .where(and(...conditions))
      .orderBy(transactions.createdAt);
  }

  async create(data: {
    id: string;
    receiptNumber: string;
    stationId: string;
    shiftId: string;
    attendantId: string;
    type: string;
    totalAmount: number;
    currency?: string;
    status?: string;
    deviceId?: string;
  }) {
    const now = new Date();
    await this.db.insert(transactions).values({
      ...data,
      transactionDate: now,
      createdAt: now,
      updatedAt: now,
    });
    return await this.findById(data.id);
  }

  async markSynced(id: string) {
    await this.db
      .update(transactions)
      .set({
        syncedAt: new Date(),
        updatedAt: new Date(),
      })
      .where(eq(transactions.id, id));
  }

  async cancel(id: string) {
    await this.db
      .update(transactions)
      .set({
        status: 'cancelled',
        updatedAt: new Date(),
      })
      .where(eq(transactions.id, id));
    return await this.findById(id);
  }

  async getTodayStats(stationId: string) {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    const result = await this.db
      .select({
        totalRevenue: sql<number>`SUM(${transactions.totalAmount})`,
        totalCount: sql<number>`COUNT(*)`,
      })
      .from(transactions)
      .where(
        and(
          eq(transactions.stationId, stationId),
          between(transactions.transactionDate, today, tomorrow),
          eq(transactions.status, 'completed')
        )
      );

    return result[0] || { totalRevenue: 0, totalCount: 0 };
  }
}
