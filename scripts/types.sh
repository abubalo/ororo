#!/bin/bash

# Create the directory structure
mkdir -p packages/types/src/{models,api}

# ============================================================
# FILE: packages/types/src/enums.ts
# Shared enums used throughout the system
# ============================================================
cat > packages/types/src/enums.ts << 'EOF'
export enum UserRole {
  ATTENDANT = 'attendant',
  MANAGER = 'manager',
  OWNER = 'owner',
  ADMIN = 'admin',
}

export enum FuelType {
  PETROL = 'petrol',
  DIESEL = 'diesel',
  KEROSENE = 'kerosene',
}

export enum TransactionType {
  FUEL = 'fuel',
  CAR_WASH = 'car_wash',
  STORE = 'store',
  MIXED = 'mixed',
}

export enum TransactionStatus {
  PENDING = 'pending',
  COMPLETED = 'completed',
  CANCELLED = 'cancelled',
  REFUNDED = 'refunded',
}

export enum PaymentMethod {
  CASH = 'cash',
  MOMO_MTN = 'momo_mtn',
  MOMO_AIRTEL = 'momo_airtel',
  CARD = 'card',
  CREDIT = 'credit',
}

export enum PaymentStatus {
  PENDING = 'pending',
  COMPLETED = 'completed',
  FAILED = 'failed',
  CANCELLED = 'cancelled',
}

export enum ShiftStatus {
  ACTIVE = 'active',
  PENDING_APPROVAL = 'pending_approval',
  APPROVED = 'approved',
  REJECTED = 'rejected',
}

export enum StockMovementType {
  PURCHASE = 'purchase',
  SALE = 'sale',
  ADJUSTMENT = 'adjustment',
  RETURN = 'return',
  DAMAGE = 'damage',
}

export enum CreditTransactionType {
  CHARGE = 'charge',
  PAYMENT = 'payment',
  ADJUSTMENT = 'adjustment',
}

export enum VehicleType {
  SEDAN = 'sedan',
  SUV = 'suv',
  TRUCK = 'truck',
  MOTORCYCLE = 'motorcycle',
}

export enum CarWashServiceType {
  BASIC = 'basic',
  PREMIUM = 'premium',
  FULL = 'full',
  CUSTOM = 'custom',
}
EOF

# ============================================================
# FILE: packages/types/src/models/user.ts
# User domain models
# ============================================================
cat > packages/types/src/models/user.ts << 'EOF'
import { UserRole } from '../enums';

export interface User {
  id: string;
  phone: string;
  name: string;
  email?: string;
  role: UserRole;
  stationId?: string;
  isActive: boolean;
  lastLoginAt?: Date;
  createdAt: Date;
  updatedAt: Date;
}

export interface UserWithoutSensitive extends Omit<User, 'pinHash'> {}

export interface LoginCredentials {
  phone: string;
  pin: string;
}

export interface AuthToken {
  token: string;
  user: UserWithoutSensitive;
}
EOF

# ============================================================
# FILE: packages/types/src/models/station.ts
# Station domain models
# ============================================================
cat > packages/types/src/models/station.ts << 'EOF'
export interface Station {
  id: string;
  organizationId: string;
  name: string;
  address?: string;
  city?: string;
  phone?: string;
  operatingHours?: string; // JSON string
  hasFuel: boolean;
  hasCarWash: boolean;
  hasStore: boolean;
  createdAt: Date;
  updatedAt: Date;
}

export interface OperatingHours {
  open: string; // "06:00"
  close: string; // "22:00"
}
EOF

# ============================================================
# FILE: packages/types/src/models/shift.ts
# Shift domain models
# ============================================================
cat > packages/types/src/models/shift.ts << 'EOF'
import { ShiftStatus } from '../enums';

export interface Shift {
  id: string;
  stationId: string;
  attendantId: string;
  pumpId?: string;
  
  // Timing
  startedAt: Date;
  endedAt?: Date;
  
  // Opening readings
  openingCash: number;
  openingMeterReading?: number;
  
  // Closing readings
  closingCash?: number;
  closingMeterReading?: number;
  actualCashCounted?: number;
  
  // Totals
  totalSales: number;
  totalFuelSales: number;
  totalCarWashSales: number;
  totalStoreSales: number;
  totalCashSales: number;
  totalMomoSales: number;
  totalCardSales: number;
  totalCreditSales: number;
  transactionCount: number;
  fuelDispensed: number;
  
  // Variance
  cashVariance?: number;
  fuelVariance?: number;
  variancePercentage?: number;
  
  // Approval
  status: ShiftStatus;
  varianceNotes?: string;
  approvedBy?: string;
  approvedAt?: Date;
  rejectionReason?: string;
  
  createdAt: Date;
  updatedAt: Date;
}

export interface ShiftSummary {
  shiftId: string;
  attendantName: string;
  startTime: Date;
  endTime?: Date;
  duration?: number; // minutes
  totalSales: number;
  transactionCount: number;
  cashVariance?: number;
  fuelVariance?: number;
  status: ShiftStatus;
}
EOF

# ============================================================
# FILE: packages/types/src/models/transaction.ts
# Transaction domain models
# ============================================================
cat > packages/types/src/models/transaction.ts << 'EOF'
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
EOF

# ============================================================
# FILE: packages/types/src/models/payment.ts
# Payment domain models
# ============================================================
cat > packages/types/src/models/payment.ts << 'EOF'
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
EOF

# ============================================================
# FILE: packages/types/src/models/product.ts
# Product/inventory domain models
# ============================================================
cat > packages/types/src/models/product.ts << 'EOF'
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
EOF

# ============================================================
# FILE: packages/types/src/models/credit.ts
# Credit customer domain models
# ============================================================
cat > packages/types/src/models/credit.ts << 'EOF'
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
EOF

# ============================================================
# FILE: packages/types/src/models/index.ts
# Export all models
# ============================================================
cat > packages/types/src/models/index.ts << 'EOF'
export * from './user';
export * from './station';
export * from './shift';
export * from './transaction';
export * from './payment';
export * from './product';
export * from './credit';
EOF

# ============================================================
# FILE: packages/types/src/api/auth.ts
# Auth API request/response types
# ============================================================
cat > packages/types/src/api/auth.ts << 'EOF'
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
EOF

# ============================================================
# FILE: packages/types/src/api/shifts.ts
# Shift API request/response types
# ============================================================
cat > packages/types/src/api/shifts.ts << 'EOF'
export interface StartShiftRequest {
  stationId: string;
  pumpId?: string;
  openingCash: number;
  openingMeterReading?: number;
}

export interface StartShiftResponse {
  shift: {
    id: string;
    stationId: string;
    attendantId: string;
    pumpId?: string;
    startedAt: Date;
    openingCash: number;
    openingMeterReading?: number;
    status: string;
  };
}

export interface CloseShiftRequest {
  closingCash: number;
  closingMeterReading?: number;
  actualCashCounted: number;
  varianceNotes?: string;
}

export interface CloseShiftResponse {
  shift: {
    id: string;
    endedAt: Date;
    cashVariance?: number;
    fuelVariance?: number;
    variancePercentage?: number;
    status: string;
  };
}

export interface ApproveShiftRequest {
  shiftId: string;
}

export interface RejectShiftRequest {
  shiftId: string;
  reason: string;
}
EOF

# ============================================================
# FILE: packages/types/src/api/transactions.ts
# Transaction API request/response types
# ============================================================
cat > packages/types/src/api/transactions.ts << 'EOF'
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
EOF

# ============================================================
# FILE: packages/types/src/api/products.ts
# Product API request/response types
# ============================================================
cat > packages/types/src/api/products.ts << 'EOF'
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
EOF

# ============================================================
# FILE: packages/types/src/api/credit.ts
# Credit API request/response types
# ============================================================
cat > packages/types/src/api/credit.ts << 'EOF'
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
EOF

# ============================================================
# FILE: packages/types/src/api/index.ts
# Export all API types
# ============================================================
cat > packages/types/src/api/index.ts << 'EOF'
export * from './auth';
export * from './shifts';
export * from './transactions';
export * from './products';
export * from './credit';
EOF

# ============================================================
# FILE: packages/types/src/constants.ts
# Shared constants
# ============================================================
cat > packages/types/src/constants.ts << 'EOF'
export const CURRENCY = {
  RWF: 'RWF',
  NGN: 'NGN',
  USD: 'USD',
} as const;

export const VARIANCE_THRESHOLD = 2; // 2% variance triggers approval

export const PIN_LENGTH = 4;

export const DEFAULT_PAYMENT_TERM_DAYS = 30;

export const RECEIPT_PREFIX = 'R-';

export const UNITS = {
  PIECE: 'piece',
  LITER: 'liter',
  KILOGRAM: 'kg',
  GRAM: 'g',
  BOTTLE: 'bottle',
  CAN: 'can',
} as const;
EOF

# ============================================================
# FILE: packages/types/src/index.ts
# Main entry point - export everything
# ============================================================
cat > packages/types/src/index.ts << 'EOF'
// Enums
export * from './enums';

// Models
export * from './models';

// API types
export * from './api';

// Constants
export * from './constants';
EOF

# ============================================================
# FILE: packages/types/package.json
# ============================================================
cat > packages/types/package.json << 'EOF'
{
  "name": "@ororo/types",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "exports": {
    ".": "./src/index.ts",
    "./api": "./src/api/index.ts",
    "./models": "./src/models/index.ts",
    "./enums": "./src/enums.ts",
    "./constants": "./src/constants.ts"
  },
  "scripts": {
    "type-check": "tsc --noEmit"
  },
  "devDependencies": {
    "typescript": "^5.7.2"
  }
}
EOF

# ============================================================
# FILE: packages/types/tsconfig.json
# ============================================================
cat > packages/types/tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "lib": ["ES2022"],
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
# FILE: packages/types/README.md
# ============================================================
cat > packages/types/README.md << 'EOF'
# @ororo/types

Shared TypeScript types for the Ororo gas station ERP system.

## Usage

```typescript
// Import enums
import { UserRole, PaymentMethod, TransactionType } from '@ororo/types';

// Import models
import type { User, Transaction, Shift } from '@ororo/types/models';

// Import API types
import type { LoginRequest, LoginResponse } from '@ororo/types/api';

// Import constants
import { VARIANCE_THRESHOLD, CURRENCY } from '@ororo/types/constants';
Structure
enums.ts - Shared enums (UserRole, PaymentMethod, etc.)

models/ - Domain models (User, Transaction, Product, etc.)

api/ - API request/response types

constants.ts - Shared constants
EOF

echo "✅ Types package has been created successfully in packages/types/"
echo ""
echo "Files created:"
echo " - packages/types/src/enums.ts (14 enums)"
echo " - packages/types/src/constants.ts"
echo " - packages/types/src/models/ (7 model files)"
echo " - packages/types/src/api/ (5 API type files)"
echo " - packages/types/src/index.ts"
echo " - packages/types/package.json"
echo " - packages/types/tsconfig.json"
echo " - packages/types/README.md"
echo ""
echo "Next steps:"
echo " 1. cd packages/types"
echo " 2. npm install"
echo ""
echo "This package is now ready to be used by:"
echo " - @ororo/db (schema definitions)"
echo " - @ororo/api (request/response handling)"
echo " - @ororo/api-client (type-safe client)"
echo " - Frontend apps (web/mobile)"

