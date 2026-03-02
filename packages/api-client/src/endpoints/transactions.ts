import type { ApiClient } from '../client';

// Types (temporary until @ororo/types is created)
export interface Transaction {
  id: string;
  receiptNumber: string;
  stationId: string;
  shiftId: string;
  attendantId: string;
  type: string;
  totalAmount: number;
  currency: string;
  status: string;
  transactionDate: string;
  createdAt: string;
  updatedAt: string;
  deviceId?: string;
}

export interface CreateFuelTransactionRequest {
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
}

export interface CreateCarWashTransactionRequest {
  shiftId: string;
  serviceId?: string;
  serviceName: string;
  vehicleType: string;
  price: number;
  paymentMethod: string;
  amountReceived?: number;
  momoPhone?: string;
  creditCustomerId?: string;
  notes?: string;
}

export interface CreateStoreTransactionRequest {
  shiftId: string;
  items: Array<{
    productId: string;
    quantity: number;
  }>;
  paymentMethod: string;
  amountReceived?: number;
  momoPhone?: string;
  creditCustomerId?: string;
}

export interface TransactionResponse {
  transaction: Transaction;
  payment: any;
  items?: any[];
}

export class TransactionEndpoints {
  constructor(private client: ApiClient) {}

  async createFuelTransaction(data: CreateFuelTransactionRequest): Promise<TransactionResponse> {
    return this.client.post<TransactionResponse>('/api/transactions/fuel', data);
  }

  async createCarWashTransaction(data: CreateCarWashTransactionRequest): Promise<TransactionResponse> {
    return this.client.post<TransactionResponse>('/api/transactions/car-wash', data);
  }

  async createStoreTransaction(data: CreateStoreTransactionRequest): Promise<TransactionResponse> {
    return this.client.post<TransactionResponse>('/api/transactions/store', data);
  }

  async getById(id: string): Promise<{ transaction: Transaction }> {
    return this.client.get<{ transaction: Transaction }>(`/api/transactions/${id}`);
  }

  async getByShift(shiftId: string): Promise<{ transactions: Transaction[] }> {
    return this.client.get<{ transactions: Transaction[] }>(`/api/transactions/shift/${shiftId}`);
  }

  async getTodayStats(): Promise<{ stats: { totalRevenue: number; totalCount: number } }> {
    return this.client.get('/api/transactions/today');
  }
}
