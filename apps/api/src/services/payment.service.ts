import { PaymentRepository } from '../db/queries';
import type { DbClient } from '../db/client';

export class PaymentService {
  constructor(private db: DbClient) {}

  async processPayment(paymentId: string) {
    const paymentRepo = new PaymentRepository(this.db);
    return await paymentRepo.markCompleted(paymentId);
  }

  async handleMomoCallback(data: any) {
    const paymentRepo = new PaymentRepository(this.db);
    // Process mobile money callback
    return { status: 'processed' };
  }
}
