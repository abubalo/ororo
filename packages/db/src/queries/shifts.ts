import { eq, and, desc, between } from 'drizzle-orm';
import type { DbClient } from '../client';
import { shifts } from '../schema';

export class ShiftRepository {
  constructor(private db: DbClient) {}

  async findById(id: string) {
    const result = await this.db
      .select()
      .from(shifts)
      .where(eq(shifts.id, id))
      .limit(1);
    return result[0] || null;
  }

  async findActiveByAttendant(attendantId: string) {
    const result = await this.db
      .select()
      .from(shifts)
      .where(
        and(
          eq(shifts.attendantId, attendantId),
          eq(shifts.status, 'active')
        )
      )
      .limit(1);
    return result[0] || null;
  }

  async findActiveByStation(stationId: string) {
    return await this.db
      .select()
      .from(shifts)
      .where(
        and(
          eq(shifts.stationId, stationId),
          eq(shifts.status, 'active')
        )
      );
  }

  async findPendingApproval(stationId?: string) {
    const conditions: (typeof eq)[] = [eq(shifts.status, 'pending_approval')];
    if (stationId) {
      conditions.push(eq(shifts.stationId, stationId));
    }
    
    return await this.db
      .select()
      .from(shifts)
      .where(and(...conditions))
      .orderBy(desc(shifts.endedAt));
  }

  async findByDateRange(stationId: string, startDate: Date, endDate: Date) {
    return await this.db
      .select()
      .from(shifts)
      .where(
        and(
          eq(shifts.stationId, stationId),
          between(shifts.startedAt, startDate, endDate)
        )
      )
      .orderBy(desc(shifts.startedAt));
  }

  async findByAttendant(attendantId: string, limit: number = 10) {
    return await this.db
      .select()
      .from(shifts)
      .where(eq(shifts.attendantId, attendantId))
      .orderBy(desc(shifts.startedAt))
      .limit(limit);
  }

  async create(data: {
    id: string;
    stationId: string;
    attendantId: string;
    pumpId?: string;
    openingCash: number;
    openingMeterReading?: number;
  }) {
    const now = new Date();
    await this.db.insert(shifts).values({
      ...data,
      startedAt: now,
      status: 'active',
      createdAt: now,
      updatedAt: now,
    });
    return await this.findById(data.id);
  }

  async close(
    id: string,
    data: {
      closingCash: number;
      closingMeterReading?: number;
      actualCashCounted: number;
      varianceNotes?: string;
    }
  ) {
    const shift = await this.findById(id);
    if (!shift) throw new Error('Shift not found');

    // Calculate variances
    const expectedCash = shift.openingCash + (shift.totalCashSales || 0);
    const cashVariance = data.actualCashCounted - expectedCash;
    const cashVariancePercentage = expectedCash > 0 
      ? (cashVariance / expectedCash) * 100 
      : 0;

    let fuelVariance = null;
    if (shift.openingMeterReading && data.closingMeterReading) {
      const meterDiff = data.closingMeterReading - shift.openingMeterReading;
      fuelVariance = meterDiff - (shift.fuelDispensed || 0);
    }

    const variancePercentage = Math.abs(cashVariancePercentage);

    await this.db
      .update(shifts)
      .set({
        ...data,
        endedAt: new Date(),
        cashVariance,
        fuelVariance,
        variancePercentage,
        status: variancePercentage > 2 ? 'pending_approval' : 'approved',
        updatedAt: new Date(),
      })
      .where(eq(shifts.id, id));

    return await this.findById(id);
  }

  async updateTotals(
    id: string,
    totals: {
      totalSales?: number;
      totalFuelSales?: number;
      totalCarWashSales?: number;
      totalStoreSales?: number;
      totalCashSales?: number;
      totalMomoSales?: number;
      totalCardSales?: number;
      totalCreditSales?: number;
      transactionCount?: number;
      fuelDispensed?: number;
    }
  ) {
    await this.db
      .update(shifts)
      .set({
        ...totals,
        updatedAt: new Date(),
      })
      .where(eq(shifts.id, id));
  }

  async approve(id: string, approvedBy: string) {
    await this.db
      .update(shifts)
      .set({
        status: 'approved',
        approvedBy,
        approvedAt: new Date(),
        updatedAt: new Date(),
      })
      .where(eq(shifts.id, id));
    return await this.findById(id);
  }

  async reject(id: string, approvedBy: string, reason: string) {
    await this.db
      .update(shifts)
      .set({
        status: 'rejected',
        approvedBy,
        rejectionReason: reason,
        approvedAt: new Date(),
        updatedAt: new Date(),
      })
      .where(eq(shifts.id, id));
    return await this.findById(id);
  }
}
