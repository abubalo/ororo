import { TransactionType, TransactionStatus } from '../enums';

export interface Transaction {
  id: string;
  receiptNumber: string;
  stationId: string;
  shiftId: string;
  attendantId: string;
  type: TransactionType;
  totalAmount: number;
  currency: string;
  status: TransactionStatus;
  transactionDate: Date;
  createdAt: Date;
  updatedAt: Date;
  syncedAt?: Date;
  deviceId?: string;
}

export interface FuelSale {
  id: string;
  transactionId: string;
  pumpId: string;
  fuelType: string;
  litersDispensed: number;
  pricePerLiter: number;
  meterReadingBefore: number;
  meterReadingAfter: number;
  calculatedAmount: number;
  createdAt: Date;
}

export interface CarWashSale {
  id: string;
  transactionId: string;
  serviceId?: string;
  serviceName: string;
  vehicleType: string;
  price: number;
  notes?: string;
  createdAt: Date;
}

export interface StoreSale {
  id: string;
  transactionId: string;
  items: StoreSaleItem[];
  createdAt: Date;
}

export interface StoreSaleItem {
  id: string;
  storeSaleId: string;
  productId: string;
  productName: string;
  quantity: number;
  unitPrice: number;
  totalPrice: number;
  createdAt: Date;
}
