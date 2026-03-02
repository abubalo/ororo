export interface Product {
  id: string;
  stationId: string;
  categoryId?: string;
  name: string;
  description?: string;
  sku?: string;
  barcode?: string;
  costPrice: number;
  sellingPrice: number;
  currency: string;
  currentStock: number;
  minimumStock: number;
  unit: string;
  isActive: boolean;
  notes?: string;
  createdAt: Date;
  updatedAt: Date;
  lastRestockedAt?: Date;
}

export interface ProductCategory {
  id: string;
  stationId: string;
  name: string;
  description?: string;
  displayOrder: number;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}

export interface StockMovement {
  id: string;
  productId: string;
  movementType: string;
  quantity: number;
  quantityBefore: number;
  quantityAfter: number;
  transactionId?: string;
  reference?: string;
  notes?: string;
  recordedBy: string;
  movementDate: Date;
  createdAt: Date;
}
