import type { DbClient } from '../db/client';

export class FuelService {
  constructor(private db: DbClient) {}

  async calculateVariance(
    meterDifference: number,
    recordedSales: number
  ): Promise<{ variance: number; percentage: number }> {
    const variance = meterDifference - recordedSales;
    const percentage =
      recordedSales > 0 ? (variance / recordedSales) * 100 : 0;

    return { variance, percentage };
  }
}
