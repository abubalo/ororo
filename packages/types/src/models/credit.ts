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
  notes?: string;
  createdAt: Date;
  updatedAt: Date;
  lastPurchaseAt?: Date;
  lastPaymentAt?: Date;
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
  createdAt: Date;
}
