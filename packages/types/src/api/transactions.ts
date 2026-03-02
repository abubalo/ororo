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
  transaction: {
    id: string;
    receiptNumber: string;
    type: string;
    totalAmount: number;
    status: string;
    transactionDate: Date;
  };
  payment: {
    id: string;
    paymentMethod: string;
    amount: number;
    status: string;
  };
}
