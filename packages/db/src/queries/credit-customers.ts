import { eq, and, gt, desc } from 'drizzle-orm';
import type { DbClient } from '../client';
import { creditCustomers, creditTransactions } from '../schema';

// Helper function for ULID generation (simplified version)
function ulid() {
  return Date.now().toString(36) + Math.random().toString(36).substring(2);
}

export class CreditCustomerRepository {
  constructor(private db: DbClient) {}

  async findById(id: string) {
    const result = await this.db
      .select()
      .from(creditCustomers)
      .where(eq(creditCustomers.id, id))
      .limit(1);
    return result[0] || null;
  }

  async findByStation(stationId: string) {
    return await this.db
      .select()
      .from(creditCustomers)
      .where(eq(creditCustomers.stationId, stationId));
  }

  async findActiveByStation(stationId: string) {
    return await this.db
      .select()
      .from(creditCustomers)
      .where(
        and(
          eq(creditCustomers.stationId, stationId),
          eq(creditCustomers.isActive, true)
        )
      );
  }

  async findWithOutstandingBalance(stationId: string) {
    return await this.db
      .select()
      .from(creditCustomers)
      .where(
        and(
          eq(creditCustomers.stationId, stationId),
          gt(creditCustomers.currentBalance, 0)
        )
      );
  }

  async create(data: {
    id: string;
    stationId: string;
    name: string;
    phone: string;
    email?: string;
    companyName?: string;
    creditLimit: number;
    paymentTermDays?: number;
  }) {
    const now = new Date();
    await this.db.insert(creditCustomers).values({
      ...data,
      currentBalance: 0,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    });
    return await this.findById(data.id);
  }

  async update(id: string, data: Partial<typeof creditCustomers.$inferInsert>) {
    await this.db
      .update(creditCustomers)
      .set({
        ...data,
        updatedAt: new Date(),
      })
      .where(eq(creditCustomers.id, id));
    return await this.findById(id);
  }

  async addCharge(
    customerId: string,
    amount: number,
    recordedBy: string,
    transactionId?: string,
    notes?: string
  ) {
    const customer = await this.findById(customerId);
    if (!customer) throw new Error('Customer not found');

    const newBalance = customer.currentBalance + amount;

    // Check credit limit
    if (newBalance > customer.creditLimit) {
      throw new Error('Credit limit exceeded');
    }

    // Update customer balance
    await this.db
      .update(creditCustomers)
      .set({
        currentBalance: newBalance,
        lastPurchaseAt: new Date(),
        updatedAt: new Date(),
      })
      .where(eq(creditCustomers.id, customerId));

    // Record transaction
    await this.db.insert(creditTransactions).values({
      id: ulid(),
      customerId,
      transactionId,
      type: 'charge',
      amount,
      runningBalance: newBalance,
      notes,
      recordedBy,
      createdAt: new Date(),
    });

    return await this.findById(customerId);
  }

  async addPayment(
    customerId: string,
    amount: number,
    recordedBy: string,
    paymentMethod: string,
    paymentReference?: string,
    notes?: string
  ) {
    const customer = await this.findById(customerId);
    if (!customer) throw new Error('Customer not found');

    const newBalance = customer.currentBalance - amount;

    // Update customer balance
    await this.db
      .update(creditCustomers)
      .set({
        currentBalance: Math.max(0, newBalance),
        lastPaymentAt: new Date(),
        updatedAt: new Date(),
      })
      .where(eq(creditCustomers.id, customerId));

    // Record transaction
    await this.db.insert(creditTransactions).values({
      id: ulid(),
      customerId,
      transactionId: null,
      type: 'payment',
      amount: -amount,
      runningBalance: Math.max(0, newBalance),
      paymentMethod,
      paymentReference,
      notes,
      recordedBy,
      createdAt: new Date(),
    });

    return await this.findById(customerId);
  }

  async getTransactionHistory(customerId: string, limit: number = 50) {
    return await this.db
      .select()
      .from(creditTransactions)
      .where(eq(creditTransactions.customerId, customerId))
      .orderBy(desc(creditTransactions.createdAt))
      .limit(limit);
  }
}
