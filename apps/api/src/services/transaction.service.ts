import {
  TransactionRepository,
  FuelSaleRepository,
  PaymentRepository,
  ShiftRepository,
} from '../db/queries';
import type { DbClient } from '../db/client';
import { ulid } from '../utils/ulid';
import { RECEIPT_PREFIX } from '../utils/constants';

export class TransactionService {
  constructor(private db: DbClient) {}

  async createFuelTransaction(data: {
    attendantId: string;
    stationId: string;
    shiftId: string;
    pumpId: string;
    fuelType: string;
    litersDispensed: number;
    pricePerLiter: number;
    meterReadingBefore: number;
    meterReadingAfter: number;
    paymentMethod: string;
    amountReceived?: number;
    momoPhone?: string;
    creditCustomerId?: string;
  }) {
    const txnRepo = new TransactionRepository(this.db);
    const fuelSaleRepo = new FuelSaleRepository(this.db);
    const paymentRepo = new PaymentRepository(this.db);
    const shiftRepo = new ShiftRepository(this.db);

    const totalAmount = data.litersDispensed * data.pricePerLiter;

    // Create transaction
    const transaction = await txnRepo.create({
      id: ulid(),
      receiptNumber: `${RECEIPT_PREFIX}${Date.now()}`,
      stationId: data.stationId,
      shiftId: data.shiftId,
      attendantId: data.attendantId,
      type: 'fuel',
      totalAmount,
    });

    // Add fuel sale
    await fuelSaleRepo.create({
      id: ulid(),
      transactionId: transaction.id,
      pumpId: data.pumpId,
      fuelType: data.fuelType,
      litersDispensed: data.litersDispensed,
      pricePerLiter: data.pricePerLiter,
      meterReadingBefore: data.meterReadingBefore,
      meterReadingAfter: data.meterReadingAfter,
    });

    // Record payment
    const payment = await paymentRepo.create({
      id: ulid(),
      transactionId: transaction.id,
      paymentMethod: data.paymentMethod,
      amount: totalAmount,
      amountReceived: data.amountReceived,
      changeGiven: data.amountReceived
        ? data.amountReceived - totalAmount
        : undefined,
      momoPhone: data.momoPhone,
      creditCustomerId: data.creditCustomerId,
    });

    await paymentRepo.markCompleted(payment.id);

    // Update shift totals
    const shift = await shiftRepo.findById(data.shiftId);
    if (shift) {
      await shiftRepo.updateTotals(data.shiftId, {
        totalSales: (shift.totalSales || 0) + totalAmount,
        totalFuelSales: (shift.totalFuelSales || 0) + totalAmount,
        totalCashSales:
          data.paymentMethod === 'cash'
            ? (shift.totalCashSales || 0) + totalAmount
            : shift.totalCashSales,
        transactionCount: (shift.transactionCount || 0) + 1,
        fuelDispensed: (shift.fuelDispensed || 0) + data.litersDispensed,
      });
    }

    return { transaction, payment };
  }
}
