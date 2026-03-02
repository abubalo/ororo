import type { ApiClient } from '../client';
import type { Transaction } from './transactions';
import type { Shift } from './shifts';

export interface DailySalesReport {
  summary: {
    date: string;
    totalRevenue: number;
    totalTransactions: number;
    fuelRevenue: number;
    carWashRevenue: number;
    storeRevenue: number;
    cashSales: number;
    momoSales: number;
    cardSales: number;
    creditSales: number;
  };
  transactions: Transaction[];
}

export class ReportEndpoints {
  constructor(private client: ApiClient) {}

  async getDailySales(date?: string): Promise<DailySalesReport> {
    const query = date ? `?date=${date}` : '';
    return this.client.get<DailySalesReport>(`/api/reports/daily-sales${query}`);
  }

  async getShiftPerformance(start?: string, end?: string): Promise<{ shifts: Shift[] }> {
    const params = new URLSearchParams();
    if (start) params.set('start', start);
    if (end) params.set('end', end);
    
    return this.client.get<{ shifts: Shift[] }>(
      `/api/reports/shift-performance?${params.toString()}`
    );
  }
}
