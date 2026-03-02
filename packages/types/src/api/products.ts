export interface CreateProductRequest {
  categoryId?: string;
  name: string;
  description?: string;
  sku?: string;
  barcode?: string;
  costPrice: number;
  sellingPrice: number;
  currentStock?: number;
  minimumStock?: number;
  unit?: string;
}

export interface UpdateProductRequest {
  categoryId?: string;
  name?: string;
  description?: string;
  sku?: string;
  barcode?: string;
  costPrice?: number;
  sellingPrice?: number;
  minimumStock?: number;
  unit?: string;
}

export interface AdjustStockRequest {
  movementType: 'purchase' | 'adjustment' | 'damage' | 'return';
  quantity: number;
  reference?: string;
  notes?: string;
}
