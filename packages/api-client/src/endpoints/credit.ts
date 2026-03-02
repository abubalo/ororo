import type { ApiClient } from '../client';

export interface CreditCustomer {
  id: string;
  stationId: string;
  name: string;
  phone: string;
  email?: string;
  companyName?: string;
  creditLimit: number;
  currentBalance: number;
  paymentTermDays: number;
  isActive: boolean;
  createdAt: string;
  updatedAt: string;
  lastPurchaseAt?: string;
  lastPaymentAt?: string;
}

export interface CreditTransaction {
  id: string;
  customerId: string;
  transactionId?: string;
  type: string;
  amount: number;
  runningBalance: number;
  paymentMethod?: string;
  paymentReference?: string;
  notes?: string;
  recordedBy: string;
  createdAt: string;
}

export interface CreateCreditCustomerRequest {
  name: string;
  phone: string;
  email?: string;
  companyName?: string;
  creditLimit: number;
  paymentTermDays?: number;
}

export interface RecordCreditPaymentRequest {
  amount: number;
  paymentMethod: string;
  paymentReference?: string;
  notes?: string;
}

export class CreditEndpoints {
  constructor(private client: ApiClient) {}

  async getCustomers(): Promise<{ customers: CreditCustomer[] }> {
    return this.client.get<{ customers: CreditCustomer[] }>('/api/credit/customers');
  }

  async getOutstanding(): Promise<{ customers: CreditCustomer[] }> {
    return this.client.get<{ customers: CreditCustomer[] }>('/api/credit/customers/outstanding');
  }

  async createCustomer(data: CreateCreditCustomerRequest): Promise<{ customer: CreditCustomer }> {
    return this.client.post<{ customer: CreditCustomer }>('/api/credit/customers', data);
  }

  async recordPayment(
    customerId: string,
    data: RecordCreditPaymentRequest
  ): Promise<{ customer: CreditCustomer }> {
    return this.client.post<{ customer: CreditCustomer }>(
      `/api/credit/customers/${customerId}/payment`,
      data
    );
  }

  async getTransactionHistory(
    customerId: string,
    limit = 50
  ): Promise<{ transactions: CreditTransaction[] }> {
    return this.client.get<{ transactions: CreditTransaction[] }>(
      `/api/credit/customers/${customerId}/transactions?limit=${limit}`
    );
  }
}
