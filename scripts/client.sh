#!/bin/bash

# Create the directory structure
mkdir -p packages/api-client/src/endpoints

# ============================================================
# FILE: packages/api-client/src/client.ts
# Base HTTP client with auth handling
# ============================================================
cat > packages/api-client/src/client.ts << 'EOF'
export interface ApiClientConfig {
  baseUrl: string;
  getToken?: () => string | null;
  onUnauthorized?: () => void;
}

export class ApiError extends Error {
  constructor(
    message: string,
    public status: number,
    public data?: any
  ) {
    super(message);
    this.name = 'ApiError';
  }
}

export class ApiClient {
  private baseUrl: string;
  private getToken?: () => string | null;
  private onUnauthorized?: () => void;

  constructor(config: ApiClientConfig) {
    this.baseUrl = config.baseUrl.replace(/\/$/, ''); // Remove trailing slash
    this.getToken = config.getToken;
    this.onUnauthorized = config.onUnauthorized;
  }

  private async request<T>(
    method: string,
    path: string,
    options?: {
      body?: any;
      headers?: Record<string, string>;
      requiresAuth?: boolean;
    }
  ): Promise<T> {
    const url = `${this.baseUrl}${path}`;
    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
      ...options?.headers,
    };

    // Add auth token if required
    if (options?.requiresAuth !== false) {
      const token = this.getToken?.();
      if (token) {
        headers['Authorization'] = `Bearer ${token}`;
      }
    }

    const fetchOptions: RequestInit = {
      method,
      headers,
    };

    if (options?.body) {
      fetchOptions.body = JSON.stringify(options.body);
    }

    try {
      const response = await fetch(url, fetchOptions);

      // Handle 401 Unauthorized
      if (response.status === 401) {
        this.onUnauthorized?.();
        throw new ApiError('Unauthorized', 401);
      }

      // Parse response
      const data = await response.json();

      // Handle error responses
      if (!response.ok) {
        throw new ApiError(
          data.error || 'Request failed',
          response.status,
          data
        );
      }

      return data as T;
    } catch (error) {
      if (error instanceof ApiError) {
        throw error;
      }
      
      // Network errors
      throw new ApiError(
        'Network error',
        0,
        error
      );
    }
  }

  async get<T>(path: string, requiresAuth = true): Promise<T> {
    return this.request<T>('GET', path, { requiresAuth });
  }

  async post<T>(path: string, body?: any, requiresAuth = true): Promise<T> {
    return this.request<T>('POST', path, { body, requiresAuth });
  }

  async put<T>(path: string, body?: any, requiresAuth = true): Promise<T> {
    return this.request<T>('PUT', path, { body, requiresAuth });
  }

  async delete<T>(path: string, requiresAuth = true): Promise<T> {
    return this.request<T>('DELETE', path, { requiresAuth });
  }
}
EOF

# ============================================================
# FILE: packages/api-client/src/endpoints/auth.ts
# Auth endpoints
# ============================================================
cat > packages/api-client/src/endpoints/auth.ts << 'EOF'
import type { ApiClient } from '../client';

// Types (temporary until @ororo/types is created)
export interface LoginRequest {
  phone: string;
  pin: string;
}

export interface LoginResponse {
  token: string;
  user: {
    id: string;
    phone: string;
    name: string;
    role: string;
    stationId?: string;
  };
}

export interface RegisterRequest {
  phone: string;
  name: string;
  pin: string;
  email?: string;
}

export interface RegisterResponse {
  token: string;
  user: {
    id: string;
    phone: string;
    name: string;
    role: string;
  };
}

export class AuthEndpoints {
  constructor(private client: ApiClient) {}

  async login(credentials: LoginRequest): Promise<LoginResponse> {
    return this.client.post<LoginResponse>('/auth/login', credentials, false);
  }

  async register(data: RegisterRequest): Promise<RegisterResponse> {
    return this.client.post<RegisterResponse>('/auth/register', data, false);
  }

  async logout(): Promise<void> {
    return this.client.post<void>('/auth/logout');
  }
}
EOF

# ============================================================
# FILE: packages/api-client/src/endpoints/shifts.ts
# Shift endpoints
# ============================================================
cat > packages/api-client/src/endpoints/shifts.ts << 'EOF'
import type { ApiClient } from '../client';

// Types (temporary until @ororo/types is created)
export interface Shift {
  id: string;
  stationId: string;
  attendantId: string;
  pumpId?: string;
  startedAt: string;
  endedAt?: string;
  openingCash: number;
  openingMeterReading?: number;
  closingCash?: number;
  closingMeterReading?: number;
  actualCashCounted?: number;
  totalSales?: number;
  totalFuelSales?: number;
  totalCarWashSales?: number;
  totalStoreSales?: number;
  totalCashSales?: number;
  totalMomoSales?: number;
  totalCardSales?: number;
  totalCreditSales?: number;
  transactionCount?: number;
  fuelDispensed?: number;
  cashVariance?: number;
  fuelVariance?: number;
  status: string;
}

export interface StartShiftRequest {
  stationId: string;
  pumpId?: string;
  openingCash: number;
  openingMeterReading?: number;
}

export interface StartShiftResponse {
  shift: Shift;
}

export interface CloseShiftRequest {
  closingCash: number;
  closingMeterReading?: number;
  actualCashCounted: number;
  varianceNotes?: string;
}

export interface CloseShiftResponse {
  shift: Shift;
}

export class ShiftEndpoints {
  constructor(private client: ApiClient) {}

  async start(data: StartShiftRequest): Promise<StartShiftResponse> {
    return this.client.post<StartShiftResponse>('/api/shifts/start', data);
  }

  async getCurrent(): Promise<{ shift: Shift }> {
    return this.client.get<{ shift: Shift }>('/api/shifts/current');
  }

  async close(shiftId: string, data: CloseShiftRequest): Promise<CloseShiftResponse> {
    return this.client.post<CloseShiftResponse>(`/api/shifts/${shiftId}/close`, data);
  }

  async getPendingApprovals(): Promise<{ shifts: Shift[] }> {
    return this.client.get<{ shifts: Shift[] }>('/api/shifts/pending');
  }

  async approve(shiftId: string): Promise<{ shift: Shift }> {
    return this.client.post<{ shift: Shift }>(`/api/shifts/${shiftId}/approve`);
  }

  async reject(shiftId: string, reason: string): Promise<{ shift: Shift }> {
    return this.client.post<{ shift: Shift }>(`/api/shifts/${shiftId}/reject`, { reason });
  }

  async getHistory(limit = 10): Promise<{ shifts: Shift[] }> {
    return this.client.get<{ shifts: Shift[] }>(`/api/shifts/history?limit=${limit}`);
  }
}
EOF

# ============================================================
# FILE: packages/api-client/src/endpoints/transactions.ts
# Transaction endpoints
# ============================================================
cat > packages/api-client/src/endpoints/transactions.ts << 'EOF'
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
EOF

# ============================================================
# FILE: packages/api-client/src/endpoints/products.ts
# Product endpoints
# ============================================================
cat > packages/api-client/src/endpoints/products.ts << 'EOF'
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
EOF

# ============================================================
# FILE: packages/api-client/src/endpoints/credit.ts
# Credit customer endpoints
# ============================================================
cat > packages/api-client/src/endpoints/credit.ts << 'EOF'
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
EOF

# ============================================================
# FILE: packages/api-client/src/endpoints/reports.ts
# Reporting endpoints
# ============================================================
cat > packages/api-client/src/endpoints/reports.ts << 'EOF'
import type { ApiClient } from '../client';
import type { Transaction } from './transactions';
import type { Shift } from './shifts';

export interface DailySalesReport {
  summary: {
    date: string;
    totalRevenue: number;
    totalTransactions: number;
    fuelRevenue: number;
    carWashRevenue: number;
    storeRevenue: number;
    cashSales: number;
    momoSales: number;
    cardSales: number;
    creditSales: number;
  };
  transactions: Transaction[];
}

export class ReportEndpoints {
  constructor(private client: ApiClient) {}

  async getDailySales(date?: string): Promise<DailySalesReport> {
    const query = date ? `?date=${date}` : '';
    return this.client.get<DailySalesReport>(`/api/reports/daily-sales${query}`);
  }

  async getShiftPerformance(start?: string, end?: string): Promise<{ shifts: Shift[] }> {
    const params = new URLSearchParams();
    if (start) params.set('start', start);
    if (end) params.set('end', end);
    
    return this.client.get<{ shifts: Shift[] }>(
      `/api/reports/shift-performance?${params.toString()}`
    );
  }
}
EOF

# ============================================================
# FILE: packages/api-client/src/endpoints/stations.ts
# Station endpoints
# ============================================================
cat > packages/api-client/src/endpoints/stations.ts << 'EOF'
import type { ApiClient } from '../client';

export interface Station {
  id: string;
  organizationId: string;
  name: string;
  address?: string;
  city?: string;
  phone?: string;
  operatingHours?: string;
  hasFuel: boolean;
  hasCarWash: boolean;
  hasStore: boolean;
  createdAt: string;
  updatedAt: string;
}

export class StationEndpoints {
  constructor(private client: ApiClient) {}

  async getCurrent(): Promise<{ station: Station }> {
    return this.client.get<{ station: Station }>('/api/stations/current');
  }

  async getAll(): Promise<{ stations: Station[] }> {
    return this.client.get<{ stations: Station[] }>('/api/stations');
  }
}
EOF

# ============================================================
# FILE: packages/api-client/src/index.ts
# Main API client export
# ============================================================
cat > packages/api-client/src/index.ts << 'EOF'
import { ApiClient, type ApiClientConfig, ApiError } from './client';
import { AuthEndpoints } from './endpoints/auth';
import { ShiftEndpoints } from './endpoints/shifts';
import { TransactionEndpoints } from './endpoints/transactions';
import { ProductEndpoints } from './endpoints/products';
import { CreditEndpoints } from './endpoints/credit';
import { ReportEndpoints } from './endpoints/reports';
import { StationEndpoints } from './endpoints/stations';

export class OroroApiClient {
  private client: ApiClient;

  // Endpoint groups
  public auth: AuthEndpoints;
  public shifts: ShiftEndpoints;
  public transactions: TransactionEndpoints;
  public products: ProductEndpoints;
  public credit: CreditEndpoints;
  public reports: ReportEndpoints;
  public stations: StationEndpoints;

  constructor(config: ApiClientConfig) {
    this.client = new ApiClient(config);

    // Initialize endpoint groups
    this.auth = new AuthEndpoints(this.client);
    this.shifts = new ShiftEndpoints(this.client);
    this.transactions = new TransactionEndpoints(this.client);
    this.products = new ProductEndpoints(this.client);
    this.credit = new CreditEndpoints(this.client);
    this.reports = new ReportEndpoints(this.client);
    this.stations = new StationEndpoints(this.client);
  }
}

export { ApiError };
export type { ApiClientConfig };

// Re-export types
export * from './endpoints/auth';
export * from './endpoints/shifts';
export * from './endpoints/transactions';
export * from './endpoints/products';
export * from './endpoints/credit';
export * from './endpoints/reports';
export * from './endpoints/stations';
EOF

# ============================================================
# FILE: packages/api-client/package.json
# ============================================================
cat > packages/api-client/package.json << 'EOF'
{
  "name": "@ororo/api-client",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "exports": {
    ".": "./src/index.ts"
  },
  "scripts": {
    "type-check": "tsc --noEmit"
  },
  "dependencies": {},
  "devDependencies": {
    "typescript": "^5.7.2"
  }
}
EOF

# ============================================================
# FILE: packages/api-client/tsconfig.json
# ============================================================
cat > packages/api-client/tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "lib": ["ES2022", "DOM"],
    "moduleResolution": "bundler",
    "strict": true,
    "skipLibCheck": true,
    "esModuleInterop": true,
    "resolveJsonModule": true,
    "declaration": true,
    "declarationMap": true,
    "outDir": "./dist"
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
EOF

# ============================================================
# FILE: packages/api-client/README.md
# ============================================================
cat > packages/api-client/README.md << 'EOF'
# @ororo/api-client

Type-safe API client for Ororo.

## Usage

### Web App (React)

```typescript
import { OroroApiClient, ApiError } from '@ororo/api-client';

// Initialize client
const apiClient = new OroroApiClient({
  baseUrl: 'https://api.ororo.app',
  getToken: () => localStorage.getItem('token'),
  onUnauthorized: () => {
    // Redirect to login
    window.location.href = '/login';
  },
});

// Use in component
async function login(phone: string, pin: string) {
  try {
    const { token, user } = await apiClient.auth.login({ phone, pin });
    localStorage.setItem('token', token);
    return user;
  } catch (error) {
    if (error instanceof ApiError) {
      console.error(error.message, error.status);
    }
  }
}

// Get current shift
const { shift } = await apiClient.shifts.getCurrent();

// Create fuel transaction
const result = await apiClient.transactions.createFuelTransaction({
  shiftId: shift.id,
  pumpId: 'pump-123',
  fuelType: 'petrol',
  litersDispensed: 45.5,
  pricePerLiter: 1099,
  meterReadingBefore: 125678.5,
  meterReadingAfter: 125724.0,
  paymentMethod: 'cash',
  amountReceived: 50000,
});
EOF

echo "✅ API Client package has been created successfully in packages/api-client/"
echo ""
echo "Files created:"
echo " - packages/api-client/src/client.ts (base HTTP client)"
echo " - packages/api-client/src/endpoints/auth.ts"
echo " - packages/api-client/src/endpoints/shifts.ts"
echo " - packages/api-client/src/endpoints/transactions.ts"
echo " - packages/api-client/src/endpoints/products.ts"
echo " - packages/api-client/src/endpoints/credit.ts"
echo " - packages/api-client/src/endpoints/reports.ts"
echo " - packages/api-client/src/endpoints/stations.ts"
echo " - packages/api-client/src/index.ts (main export)"
echo " - packages/api-client/package.json"
echo " - packages/api-client/tsconfig.json"
echo " - packages/api-client/README.md"
echo ""
echo "Next steps:"
echo " 1. cd packages/api-client"
echo " 2. npm install"
echo " 3. When @ororo/types is created, update imports"

