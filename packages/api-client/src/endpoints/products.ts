import type { ApiClient } from '../client';

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
  createdAt: string;
  updatedAt: string;
}

export interface CreateProductRequest {
  name: string;
  categoryId?: string;
  description?: string;
  sku?: string;
  barcode?: string;
  costPrice: number;
  sellingPrice: number;
  currency?: string;
  currentStock?: number;
  minimumStock?: number;
  unit?: string;
}

export interface UpdateProductRequest {
  name?: string;
  categoryId?: string;
  description?: string;
  sku?: string;
  barcode?: string;
  costPrice?: number;
  sellingPrice?: number;
  minimumStock?: number;
  isActive?: boolean;
}

export interface AdjustStockRequest {
  movementType: string;
  quantity: number;
  reference?: string;
  notes?: string;
}

export class ProductEndpoints {
  constructor(private client: ApiClient) {}

  async getAll(): Promise<{ products: Product[] }> {
    return this.client.get<{ products: Product[] }>('/api/store/products');
  }

  async getLowStock(): Promise<{ products: Product[] }> {
    return this.client.get<{ products: Product[] }>('/api/store/products/low-stock');
  }

  async create(data: CreateProductRequest): Promise<{ product: Product }> {
    return this.client.post<{ product: Product }>('/api/store/products', data);
  }

  async update(id: string, data: UpdateProductRequest): Promise<{ product: Product }> {
    return this.client.put<{ product: Product }>(`/api/store/products/${id}`, data);
  }

  async adjustStock(id: string, data: AdjustStockRequest): Promise<{ product: Product }> {
    return this.client.post<{ product: Product }>(`/api/store/products/${id}/adjust-stock`, data);
  }
}
