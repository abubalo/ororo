import type { ApiClient } from '../client';

// Types (temporary until @ororo/types is created)
export interface Shift {
  id: string;
  stationId: string;
  attendantId: string;
  pumpId?: string;
  startedAt: string;
  endedAt?: string;
  openingCash: number;
  openingMeterReading?: number;
  closingCash?: number;
  closingMeterReading?: number;
  actualCashCounted?: number;
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
  cashVariance?: number;
  fuelVariance?: number;
  status: string;
}

export interface StartShiftRequest {
  stationId: string;
  pumpId?: string;
  openingCash: number;
  openingMeterReading?: number;
}

export interface StartShiftResponse {
  shift: Shift;
}

export interface CloseShiftRequest {
  closingCash: number;
  closingMeterReading?: number;
  actualCashCounted: number;
  varianceNotes?: string;
}

export interface CloseShiftResponse {
  shift: Shift;
}

export class ShiftEndpoints {
  constructor(private client: ApiClient) {}

  async start(data: StartShiftRequest): Promise<StartShiftResponse> {
    return this.client.post<StartShiftResponse>('/api/shifts/start', data);
  }

  async getCurrent(): Promise<{ shift: Shift }> {
    return this.client.get<{ shift: Shift }>('/api/shifts/current');
  }

  async close(shiftId: string, data: CloseShiftRequest): Promise<CloseShiftResponse> {
    return this.client.post<CloseShiftResponse>(`/api/shifts/${shiftId}/close`, data);
  }

  async getPendingApprovals(): Promise<{ shifts: Shift[] }> {
    return this.client.get<{ shifts: Shift[] }>('/api/shifts/pending');
  }

  async approve(shiftId: string): Promise<{ shift: Shift }> {
    return this.client.post<{ shift: Shift }>(`/api/shifts/${shiftId}/approve`);
  }

  async reject(shiftId: string, reason: string): Promise<{ shift: Shift }> {
    return this.client.post<{ shift: Shift }>(`/api/shifts/${shiftId}/reject`, { reason });
  }

  async getHistory(limit = 10): Promise<{ shifts: Shift[] }> {
    return this.client.get<{ shifts: Shift[] }>(`/api/shifts/history?limit=${limit}`);
  }
}
