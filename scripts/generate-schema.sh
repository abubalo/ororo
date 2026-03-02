#!/bin/bash

# Create the schema directory if it doesn't exist
mkdir -p packages/db/src/schema

# ============================================================
# FILE: packages/db/src/schema/organizations.ts
# ============================================================
cat > packages/db/src/schema/organizations.ts << 'EOF'
import { sqliteTable, text, integer } from 'drizzle-orm/sqlite-core';

export const organizations = sqliteTable('organizations', {
  id: text('id').primaryKey(),
  name: text('name').notNull(),
  contactEmail: text('contact_email'),
  contactPhone: text('contact_phone'),
  createdAt: integer('created_at', { mode: 'timestamp' }).notNull(),
  updatedAt: integer('updated_at', { mode: 'timestamp' }).notNull(),
});
EOF

# ============================================================
# FILE: packages/db/src/schema/stations.ts
# ============================================================
cat > packages/db/src/schema/stations.ts << 'EOF'
import { sqliteTable, text, integer } from 'drizzle-orm/sqlite-core';
import { organizations } from './organizations';

export const stations = sqliteTable('stations', {
  id: text('id').primaryKey(),
  organizationId: text('organization_id')
    .notNull()
    .references(() => organizations.id),
  name: text('name').notNull(),
  address: text('address'),
  city: text('city'),
  phone: text('phone'),
  operatingHours: text('operating_hours'),
  
  // Features enabled at this station
  hasFuel: integer('has_fuel', { mode: 'boolean' }).notNull().default(true),
  hasCarWash: integer('has_car_wash', { mode: 'boolean' }).notNull().default(false),
  hasStore: integer('has_store', { mode: 'boolean' }).notNull().default(false),
  
  createdAt: integer('created_at', { mode: 'timestamp' }).notNull(),
  updatedAt: integer('updated_at', { mode: 'timestamp' }).notNull(),
});
EOF

# ============================================================
# FILE: packages/db/src/schema/users.ts
# ============================================================
cat > packages/db/src/schema/users.ts << 'EOF'
import { sqliteTable, text, integer } from 'drizzle-orm/sqlite-core';
import { stations } from './stations';

export const users = sqliteTable('users', {
  id: text('id').primaryKey(),
  phone: text('phone').notNull().unique(),
  name: text('name').notNull(),
  email: text('email'),
  role: text('role').notNull(),
  pinHash: text('pin_hash').notNull(),
  stationId: text('station_id').references(() => stations.id),
  isActive: integer('is_active', { mode: 'boolean' }).notNull().default(true),
  lastLoginAt: integer('last_login_at', { mode: 'timestamp' }),
  createdAt: integer('created_at', { mode: 'timestamp' }).notNull(),
  updatedAt: integer('updated_at', { mode: 'timestamp' }).notNull(),
});
EOF

# ============================================================
# FILE: packages/db/src/schema/fuel-tanks.ts
# ============================================================
cat > packages/db/src/schema/fuel-tanks.ts << 'EOF'
import { sqliteTable, text, integer, real } from 'drizzle-orm/sqlite-core';
import { stations } from './stations';

export const fuelTanks = sqliteTable('fuel_tanks', {
  id: text('id').primaryKey(),
  stationId: text('station_id')
    .notNull()
    .references(() => stations.id),
  name: text('name').notNull(),
  fuelType: text('fuel_type').notNull(),
  capacityLiters: real('capacity_liters').notNull(),
  currentLiters: real('current_liters').notNull().default(0),
  minimumLevel: real('minimum_level').notNull().default(0),
  isActive: integer('is_active', { mode: 'boolean' }).notNull().default(true),
  createdAt: integer('created_at', { mode: 'timestamp' }).notNull(),
  updatedAt: integer('updated_at', { mode: 'timestamp' }).notNull(),
});
EOF

# ============================================================
# FILE: packages/db/src/schema/fuel-pumps.ts
# ============================================================
cat > packages/db/src/schema/fuel-pumps.ts << 'EOF'
import { sqliteTable, text, integer, real } from 'drizzle-orm/sqlite-core';
import { stations } from './stations';
import { fuelTanks } from './fuel-tanks';

export const fuelPumps = sqliteTable('fuel_pumps', {
  id: text('id').primaryKey(),
  stationId: text('station_id')
    .notNull()
    .references(() => stations.id),
  tankId: text('tank_id')
    .notNull()
    .references(() => fuelTanks.id),
  name: text('name').notNull(),
  fuelType: text('fuel_type').notNull(),
  currentMeterReading: real('current_meter_reading').notNull().default(0),
  isActive: integer('is_active', { mode: 'boolean' }).notNull().default(true),
  createdAt: integer('created_at', { mode: 'timestamp' }).notNull(),
  updatedAt: integer('updated_at', { mode: 'timestamp' }).notNull(),
});
EOF

# ============================================================
# FILE: packages/db/src/schema/fuel-prices.ts
# ============================================================
cat > packages/db/src/schema/fuel-prices.ts << 'EOF'
import { sqliteTable, text, integer, real } from 'drizzle-orm/sqlite-core';
import { stations } from './stations';

export const fuelPrices = sqliteTable('fuel_prices', {
  id: text('id').primaryKey(),
  stationId: text('station_id')
    .notNull()
    .references(() => stations.id),
  fuelType: text('fuel_type').notNull(),
  pricePerLiter: real('price_per_liter').notNull(),
  effectiveFrom: integer('effective_from', { mode: 'timestamp' }).notNull(),
  effectiveTo: integer('effective_to', { mode: 'timestamp' }),
  createdAt: integer('created_at', { mode: 'timestamp' }).notNull(),
  createdBy: text('created_by').notNull(),
});
EOF

# ============================================================
# FILE: packages/db/src/schema/car-wash-services.ts
# ============================================================
cat > packages/db/src/schema/car-wash-services.ts << 'EOF'
import { sqliteTable, text, integer, real } from 'drizzle-orm/sqlite-core';
import { stations } from './stations';

export const carWashServices = sqliteTable('car_wash_services', {
  id: text('id').primaryKey(),
  stationId: text('station_id')
    .notNull()
    .references(() => stations.id),
  
  serviceType: text('service_type').notNull(),
  name: text('name').notNull(),
  description: text('description'),
  
  // Pricing by vehicle type
  priceSedan: real('price_sedan').notNull(),
  priceSuv: real('price_suv').notNull(),
  priceTruck: real('price_truck'),
  priceMotorcycle: real('price_motorcycle'),
  
  estimatedDurationMinutes: integer('estimated_duration_minutes'),
  isActive: integer('is_active', { mode: 'boolean' }).notNull().default(true),
  displayOrder: integer('display_order').notNull().default(0),
  
  createdAt: integer('created_at', { mode: 'timestamp' }).notNull(),
  updatedAt: integer('updated_at', { mode: 'timestamp' }).notNull(),
});
EOF

# ============================================================
# FILE: packages/db/src/schema/product-categories.ts
# ============================================================
cat > packages/db/src/schema/product-categories.ts << 'EOF'
import { sqliteTable, text, integer } from 'drizzle-orm/sqlite-core';
import { stations } from './stations';

export const productCategories = sqliteTable('product_categories', {
  id: text('id').primaryKey(),
  stationId: text('station_id')
    .notNull()
    .references(() => stations.id),
  
  name: text('name').notNull(),
  description: text('description'),
  displayOrder: integer('display_order').notNull().default(0),
  isActive: integer('is_active', { mode: 'boolean' }).notNull().default(true),
  
  createdAt: integer('created_at', { mode: 'timestamp' }).notNull(),
  updatedAt: integer('updated_at', { mode: 'timestamp' }).notNull(),
});
EOF

# ============================================================
# FILE: packages/db/src/schema/products.ts
# ============================================================
cat > packages/db/src/schema/products.ts << 'EOF'
import { sqliteTable, text, integer, real } from 'drizzle-orm/sqlite-core';
import { stations } from './stations';
import { productCategories } from './product-categories';

export const products = sqliteTable('products', {
  id: text('id').primaryKey(),
  stationId: text('station_id')
    .notNull()
    .references(() => stations.id),
  categoryId: text('category_id')
    .references(() => productCategories.id),
  
  name: text('name').notNull(),
  description: text('description'),
  sku: text('sku'),
  barcode: text('barcode'),
  
  // Pricing
  costPrice: real('cost_price').notNull(),
  sellingPrice: real('selling_price').notNull(),
  currency: text('currency').notNull().default('RWF'),
  
  // Inventory
  currentStock: integer('current_stock').notNull().default(0),
  minimumStock: integer('minimum_stock').notNull().default(0),
  unit: text('unit').notNull().default('piece'),
  
  // Metadata
  isActive: integer('is_active', { mode: 'boolean' }).notNull().default(true),
  notes: text('notes'),
  
  createdAt: integer('created_at', { mode: 'timestamp' }).notNull(),
  updatedAt: integer('updated_at', { mode: 'timestamp' }).notNull(),
  lastRestockedAt: integer('last_restocked_at', { mode: 'timestamp' }),
});
EOF

# ============================================================
# FILE: packages/db/src/schema/stock-movements.ts
# ============================================================
cat > packages/db/src/schema/stock-movements.ts << 'EOF'
import { sqliteTable, text, integer } from 'drizzle-orm/sqlite-core';
import { products } from './products';
import { users } from './users';

export const stockMovements = sqliteTable('stock_movements', {
  id: text('id').primaryKey(),
  productId: text('product_id')
    .notNull()
    .references(() => products.id),
  
  movementType: text('movement_type').notNull(),
  quantity: integer('quantity').notNull(),
  quantityBefore: integer('quantity_before').notNull(),
  quantityAfter: integer('quantity_after').notNull(),
  
  // Optional: link to transaction if this was a sale
  transactionId: text('transaction_id'),
  
  // Documentation
  reference: text('reference'),
  notes: text('notes'),
  recordedBy: text('recorded_by')
    .notNull()
    .references(() => users.id),
  
  movementDate: integer('movement_date', { mode: 'timestamp' }).notNull(),
  createdAt: integer('created_at', { mode: 'timestamp' }).notNull(),
});
EOF

# ============================================================
# FILE: packages/db/src/schema/shifts.ts
# ============================================================
cat > packages/db/src/schema/shifts.ts << 'EOF'
import { sqliteTable, text, integer, real } from 'drizzle-orm/sqlite-core';
import { users } from './users';
import { stations } from './stations';
import { fuelPumps } from './fuel-pumps';

export const shifts = sqliteTable('shifts', {
  id: text('id').primaryKey(),
  stationId: text('station_id')
    .notNull()
    .references(() => stations.id),
  attendantId: text('attendant_id')
    .notNull()
    .references(() => users.id),
  pumpId: text('pump_id').references(() => fuelPumps.id),
  
  // Timing
  startedAt: integer('started_at', { mode: 'timestamp' }).notNull(),
  endedAt: integer('ended_at', { mode: 'timestamp' }),
  
  // Opening readings
  openingCash: real('opening_cash').notNull(),
  openingMeterReading: real('opening_meter_reading'),
  
  // Closing readings
  closingCash: real('closing_cash'),
  closingMeterReading: real('closing_meter_reading'),
  actualCashCounted: real('actual_cash_counted'),
  
  // Sales totals (calculated when shift closes)
  totalSales: real('total_sales').default(0),
  totalFuelSales: real('total_fuel_sales').default(0),
  totalCarWashSales: real('total_car_wash_sales').default(0),
  totalStoreSales: real('total_store_sales').default(0),
  totalCashSales: real('total_cash_sales').default(0),
  totalMomoSales: real('total_momo_sales').default(0),
  totalCardSales: real('total_card_sales').default(0),
  totalCreditSales: real('total_credit_sales').default(0),
  transactionCount: integer('transaction_count').default(0),
  fuelDispensed: real('fuel_dispensed').default(0),
  
  // Variance
  cashVariance: real('cash_variance'),
  fuelVariance: real('fuel_variance'),
  variancePercentage: real('variance_percentage'),
  
  // Approval
  status: text('status').notNull().default('active'),
  varianceNotes: text('variance_notes'),
  approvedBy: text('approved_by'),
  approvedAt: integer('approved_at', { mode: 'timestamp' }),
  rejectionReason: text('rejection_reason'),
  
  createdAt: integer('created_at', { mode: 'timestamp' }).notNull(),
  updatedAt: integer('updated_at', { mode: 'timestamp' }).notNull(),
});
EOF

# ============================================================
# FILE: packages/db/src/schema/transactions.ts
# ============================================================
cat > packages/db/src/schema/transactions.ts << 'EOF'
import { sqliteTable, text, integer, real } from 'drizzle-orm/sqlite-core';
import { stations } from './stations';
import { users } from './users';
import { shifts } from './shifts';

export const transactions = sqliteTable('transactions', {
  id: text('id').primaryKey(),
  receiptNumber: text('receipt_number').notNull().unique(),
  stationId: text('station_id')
    .notNull()
    .references(() => stations.id),
  shiftId: text('shift_id')
    .notNull()
    .references(() => shifts.id),
  attendantId: text('attendant_id')
    .notNull()
    .references(() => users.id),
  
  type: text('type').notNull(),
  totalAmount: real('total_amount').notNull(),
  currency: text('currency').notNull().default('RWF'),
  status: text('status').notNull().default('completed'),
  
  transactionDate: integer('transaction_date', { mode: 'timestamp' }).notNull(),
  createdAt: integer('created_at', { mode: 'timestamp' }).notNull(),
  updatedAt: integer('updated_at', { mode: 'timestamp' }).notNull(),
  
  // Offline sync tracking
  syncedAt: integer('synced_at', { mode: 'timestamp' }),
  deviceId: text('device_id'),
});
EOF

# ============================================================
# FILE: packages/db/src/schema/fuel-sales.ts
# ============================================================
cat > packages/db/src/schema/fuel-sales.ts << 'EOF'
import { sqliteTable, text, integer, real } from 'drizzle-orm/sqlite-core';
import { transactions } from './transactions';
import { fuelPumps } from './fuel-pumps';

export const fuelSales = sqliteTable('fuel_sales', {
  id: text('id').primaryKey(),
  transactionId: text('transaction_id')
    .notNull()
    .references(() => transactions.id),
  pumpId: text('pump_id')
    .notNull()
    .references(() => fuelPumps.id),
  
  fuelType: text('fuel_type').notNull(),
  litersDispensed: real('liters_dispensed').notNull(),
  pricePerLiter: real('price_per_liter').notNull(),
  meterReadingBefore: real('meter_reading_before').notNull(),
  meterReadingAfter: real('meter_reading_after').notNull(),
  calculatedAmount: real('calculated_amount').notNull(),
  
  createdAt: integer('created_at', { mode: 'timestamp' }).notNull(),
});
EOF

# ============================================================
# FILE: packages/db/src/schema/car-wash-sales.ts
# ============================================================
cat > packages/db/src/schema/car-wash-sales.ts << 'EOF'
import { sqliteTable, text, integer, real } from 'drizzle-orm/sqlite-core';
import { transactions } from './transactions';
import { carWashServices } from './car-wash-services';

export const carWashSales = sqliteTable('car_wash_sales', {
  id: text('id').primaryKey(),
  transactionId: text('transaction_id')
    .notNull()
    .references(() => transactions.id),
  serviceId: text('service_id')
    .references(() => carWashServices.id),
  
  serviceName: text('service_name').notNull(),
  vehicleType: text('vehicle_type').notNull(),
  price: real('price').notNull(),
  notes: text('notes'),
  
  createdAt: integer('created_at', { mode: 'timestamp' }).notNull(),
});
EOF

# ============================================================
# FILE: packages/db/src/schema/store-sales.ts
# ============================================================
cat > packages/db/src/schema/store-sales.ts << 'EOF'
import { sqliteTable, text, integer } from 'drizzle-orm/sqlite-core';
import { transactions } from './transactions';

export const storeSales = sqliteTable('store_sales', {
  id: text('id').primaryKey(),
  transactionId: text('transaction_id')
    .notNull()
    .references(() => transactions.id),
  
  // Note: One transaction can have multiple store items
  // This is a line-item table
  createdAt: integer('created_at', { mode: 'timestamp' }).notNull(),
});
EOF

# ============================================================
# FILE: packages/db/src/schema/store-sale-items.ts
# ============================================================
cat > packages/db/src/schema/store-sale-items.ts << 'EOF'
import { sqliteTable, text, integer, real } from 'drizzle-orm/sqlite-core';
import { storeSales } from './store-sales';
import { products } from './products';

export const storeSaleItems = sqliteTable('store_sale_items', {
  id: text('id').primaryKey(),
  storeSaleId: text('store_sale_id')
    .notNull()
    .references(() => storeSales.id),
  productId: text('product_id')
    .notNull()
    .references(() => products.id),
  
  productName: text('product_name').notNull(),
  quantity: integer('quantity').notNull(),
  unitPrice: real('unit_price').notNull(),
  totalPrice: real('total_price').notNull(),
  
  createdAt: integer('created_at', { mode: 'timestamp' }).notNull(),
});
EOF

# ============================================================
# FILE: packages/db/src/schema/payments.ts
# ============================================================
cat > packages/db/src/schema/payments.ts << 'EOF'
import { sqliteTable, text, integer, real } from 'drizzle-orm/sqlite-core';
import { transactions } from './transactions';

export const payments = sqliteTable('payments', {
  id: text('id').primaryKey(),
  transactionId: text('transaction_id')
    .notNull()
    .references(() => transactions.id),
  
  paymentMethod: text('payment_method').notNull(),
  amount: real('amount').notNull(),
  currency: text('currency').notNull().default('RWF'),
  
  // Cash
  amountReceived: real('amount_received'),
  changeGiven: real('change_given'),
  
  // Mobile money
  momoProvider: text('momo_provider'),
  momoPhone: text('momo_phone'),
  momoTransactionId: text('momo_transaction_id'),
  momoReference: text('momo_reference'),
  
  // Card
  cardLast4: text('card_last_4'),
  cardType: text('card_type'),
  cardTransactionId: text('card_transaction_id'),
  
  // Credit
  creditCustomerId: text('credit_customer_id'),
  creditDueDate: integer('credit_due_date', { mode: 'timestamp' }),
  
  status: text('status').notNull().default('pending'),
  failureReason: text('failure_reason'),
  paidAt: integer('paid_at', { mode: 'timestamp' }),
  createdAt: integer('created_at', { mode: 'timestamp' }).notNull(),
  updatedAt: integer('updated_at', { mode: 'timestamp' }).notNull(),
});
EOF

# ============================================================
# FILE: packages/db/src/schema/credit-customers.ts
# ============================================================
cat > packages/db/src/schema/credit-customers.ts << 'EOF'
import { sqliteTable, text, integer, real } from 'drizzle-orm/sqlite-core';
import { stations } from './stations';

export const creditCustomers = sqliteTable('credit_customers', {
  id: text('id').primaryKey(),
  stationId: text('station_id')
    .notNull()
    .references(() => stations.id),
  
  name: text('name').notNull(),
  phone: text('phone').notNull(),
  email: text('email'),
  companyName: text('company_name'),
  
  creditLimit: real('credit_limit').notNull(),
  currentBalance: real('current_balance').notNull().default(0),
  paymentTermDays: integer('payment_term_days').notNull().default(30),
  
  isActive: integer('is_active', { mode: 'boolean' }).notNull().default(true),
  notes: text('notes'),
  
  createdAt: integer('created_at', { mode: 'timestamp' }).notNull(),
  updatedAt: integer('updated_at', { mode: 'timestamp' }).notNull(),
  lastPurchaseAt: integer('last_purchase_at', { mode: 'timestamp' }),
  lastPaymentAt: integer('last_payment_at', { mode: 'timestamp' }),
});
EOF

# ============================================================
# FILE: packages/db/src/schema/credit-transactions.ts
# ============================================================
cat > packages/db/src/schema/credit-transactions.ts << 'EOF'
import { sqliteTable, text, integer, real } from 'drizzle-orm/sqlite-core';
import { creditCustomers } from './credit-customers';
import { transactions } from './transactions';

export const creditTransactions = sqliteTable('credit_transactions', {
  id: text('id').primaryKey(),
  customerId: text('customer_id')
    .notNull()
    .references(() => creditCustomers.id),
  transactionId: text('transaction_id').references(() => transactions.id),
  
  type: text('type').notNull(),
  amount: real('amount').notNull(),
  runningBalance: real('running_balance').notNull(),
  
  paymentMethod: text('payment_method'),
  paymentReference: text('payment_reference'),
  notes: text('notes'),
  recordedBy: text('recorded_by').notNull(),
  
  createdAt: integer('created_at', { mode: 'timestamp' }).notNull(),
});
EOF

# ============================================================
# FILE: packages/db/src/schema/tank-readings.ts
# ============================================================
cat > packages/db/src/schema/tank-readings.ts << 'EOF'
import { sqliteTable, text, integer, real } from 'drizzle-orm/sqlite-core';
import { fuelTanks } from './fuel-tanks';
import { users } from './users';

export const tankReadings = sqliteTable('tank_readings', {
  id: text('id').primaryKey(),
  tankId: text('tank_id')
    .notNull()
    .references(() => fuelTanks.id),
  
  readingType: text('reading_type').notNull(),
  liters: real('liters').notNull(),
  depthCm: real('depth_cm'),
  temperature: real('temperature'),
  
  recordedBy: text('recorded_by')
    .notNull()
    .references(() => users.id),
  notes: text('notes'),
  
  readingDate: integer('reading_date', { mode: 'timestamp' }).notNull(),
  createdAt: integer('created_at', { mode: 'timestamp' }).notNull(),
});
EOF

# ============================================================
# FILE: packages/db/src/schema/fuel-deliveries.ts
# ============================================================
cat > packages/db/src/schema/fuel-deliveries.ts << 'EOF'
import { sqliteTable, text, integer, real } from 'drizzle-orm/sqlite-core';
import { fuelTanks } from './fuel-tanks';
import { users } from './users';

export const fuelDeliveries = sqliteTable('fuel_deliveries', {
  id: text('id').primaryKey(),
  tankId: text('tank_id')
    .notNull()
    .references(() => fuelTanks.id),
  
  supplierName: text('supplier_name').notNull(),
  fuelType: text('fuel_type').notNull(),
  invoiceQuantity: real('invoice_quantity').notNull(),
  deliveredQuantity: real('delivered_quantity').notNull(),
  pricePerLiter: real('price_per_liter').notNull(),
  totalCost: real('total_cost').notNull(),
  
  tankLevelBefore: real('tank_level_before').notNull(),
  tankLevelAfter: real('tank_level_after').notNull(),
  variance: real('variance'),
  variancePercentage: real('variance_percentage'),
  
  invoiceNumber: text('invoice_number').notNull(),
  deliveryNoteNumber: text('delivery_note_number'),
  
  receivedBy: text('received_by')
    .notNull()
    .references(() => users.id),
  approvedBy: text('approved_by').references(() => users.id),
  approvedAt: integer('approved_at', { mode: 'timestamp' }),
  
  notes: text('notes'),
  deliveryDate: integer('delivery_date', { mode: 'timestamp' }).notNull(),
  createdAt: integer('created_at', { mode: 'timestamp' }).notNull(),
  updatedAt: integer('updated_at', { mode: 'timestamp' }).notNull(),
});
EOF

# ============================================================
# FILE: packages/db/src/schema/index.ts
# ============================================================
cat > packages/db/src/schema/index.ts << 'EOF'
export * from './organizations';
export * from './stations';
export * from './users';
export * from './fuel-tanks';
export * from './fuel-pumps';
export * from './fuel-prices';
export * from './car-wash-services';
export * from './product-categories';
export * from './products';
export * from './stock-movements';
export * from './shifts';
export * from './transactions';
export * from './fuel-sales';
export * from './car-wash-sales';
export * from './store-sales';
export * from './store-sale-items';
export * from './payments';
export * from './credit-customers';
export * from './credit-transactions';
export * from './tank-readings';
export * from './fuel-deliveries';
EOF

# ============================================================
# FILE: packages/db/src/client.ts
# ============================================================
cat > packages/db/src/client.ts << 'EOF'
import { drizzle } from 'drizzle-orm/d1';
import * as schema from './schema';

export function createDbClient(db: D1Database) {
  return drizzle(db, { schema });
}

export type DbClient = ReturnType<typeof createDbClient>;
EOF

# ============================================================
# FILE: packages/db/src/index.ts
# ============================================================
cat > packages/db/src/index.ts << 'EOF'
export * from './schema';
export * from './client';
EOF

# ============================================================
# FILE: packages/db/drizzle.config.ts
# ============================================================
cat > packages/db/drizzle.config.ts << 'EOF'
import type { Config } from 'drizzle-kit';

export default {
  schema: './src/schema/index.ts',
  out: './src/migrations',
  dialect: 'sqlite',
  driver: 'd1-http',
} satisfies Config;
EOF

# ============================================================
# FILE: packages/db/package.json
# ============================================================
cat > packages/db/package.json << 'EOF'
{
  "name": "@ororo/db",
  "version": "1.0.0",
  "private": true,
  "exports": {
    ".": "./src/index.ts",
    "./schema": "./src/schema/index.ts",
    "./client": "./src/client.ts"
  },
  "scripts": {
    "generate": "drizzle-kit generate",
    "migrate": "drizzle-kit migrate",
    "studio": "drizzle-kit studio",
    "push": "drizzle-kit push",
    "type-check": "tsc --noEmit"
  },
  "dependencies": {
    "drizzle-orm": "^0.36.4"
  },
  "devDependencies": {
    "@cloudflare/workers-types": "^4.20250110.0",
    "drizzle-kit": "^0.29.1",
    "typescript": "^5.7.2"
  }
}
EOF

# ============================================================
# FILE: packages/db/tsconfig.json
# ============================================================
cat > packages/db/tsconfig.json << 'EOF'
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
    "outDir": "./dist",
    "types": ["@cloudflare/workers-types"]
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
EOF

echo "✅ All database schema files have been created successfully in packages/db/src/schema/"
echo "📁 Location: $(pwd)/packages/db/src/schema/"