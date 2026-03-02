import { PaymentMethod, PaymentStatus } from '../enums';

export interface Payment {
  id: string;
  transactionId: string;
  paymentMethod: PaymentMethod;
  amount: number;
  currency: string;
  
  // Cash
  amountReceived?: number;
  changeGiven?: number;
  
  // Mobile money
  momoProvider?: string;
  momoPhone?: string;
  momoTransactionId?: string;
  momoReference?: string;
  
  // Card
  cardLast4?: string;
  cardType?: string;
  cardTransactionId?: string;
  
  // Credit
  creditCustomerId?: string;
  creditDueDate?: Date;
  
  status: PaymentStatus;
  failureReason?: string;
  paidAt?: Date;
  createdAt: Date;
  updatedAt: Date;
}
