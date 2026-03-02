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
