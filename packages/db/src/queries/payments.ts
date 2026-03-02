import { eq } from 'drizzle-orm';
import type { DbClient } from '../client';
import { payments } from '../schema';

export class PaymentRepository {
  constructor(private db: DbClient) {}

  async findById(id: string) {
    const result = await this.db
      .select()
      .from(payments)
      .where(eq(payments.id, id))
      .limit(1);
    return result[0] || null;
  }

  async findByTransaction(transactionId: string) {
    return await this.db
      .select()
      .from(payments)
      .where(eq(payments.transactionId, transactionId));
  }

  async create(data: {
    id: string;
    transactionId: string;
    paymentMethod: string;
    amount: number;
    currency?: string;
    // Optional fields based on payment method
    amountReceived?: number;
    changeGiven?: number;
    momoProvider?: string;
    momoPhone?: string;
    momoTransactionId?: string;
    momoReference?: string;
    cardLast4?: string;
    cardType?: string;
    cardTransactionId?: string;
    creditCustomerId?: string;
    creditDueDate?: Date;
  }) {
    const now = new Date();
    await this.db.insert(payments).values({
      ...data,
      status: 'pending',
      createdAt: now,
      updatedAt: now,
    });
    return await this.findById(data.id);
  }

  async markCompleted(id: string) {
    await this.db
      .update(payments)
      .set({
        status: 'completed',
        paidAt: new Date(),
        updatedAt: new Date(),
      })
      .where(eq(payments.id, id));
    return await this.findById(id);
  }

  async markFailed(id: string, reason: string) {
    await this.db
      .update(payments)
      .set({
        status: 'failed',
        failureReason: reason,
        updatedAt: new Date(),
      })
      .where(eq(payments.id, id));
    return await this.findById(id);
  }
}
