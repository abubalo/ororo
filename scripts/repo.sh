#!/bin/bash

# Create the queries directory if it doesn't exist
mkdir -p packages/db/src/queries

# ============================================================
# FILE: packages/db/src/queries/organizations.ts
# ============================================================
cat > packages/db/src/queries/organizations.ts << 'EOF'
import { eq } from 'drizzle-orm';
import type { DbClient } from '../client';
import { organizations } from '../schema';

export class OrganizationRepository {
  constructor(private db: DbClient) {}

  async findById(id: string) {
    const result = await this.db
      .select()
      .from(organizations)
      .where(eq(organizations.id, id))
      .limit(1);
    return result[0] || null;
  }

  async findAll() {
    return await this.db.select().from(organizations);
  }

  async create(data: {
    id: string;
    name: string;
    contactEmail?: string;
    contactPhone?: string;
  }) {
    const now = new Date();
    await this.db.insert(organizations).values({
      ...data,
      createdAt: now,
      updatedAt: now,
    });
    return await this.findById(data.id);
  }

  async update(
    id: string,
    data: {
      name?: string;
      contactEmail?: string;
      contactPhone?: string;
    }
  ) {
    await this.db
      .update(organizations)
      .set({
        ...data,
        updatedAt: new Date(),
      })
      .where(eq(organizations.id, id));
    return await this.findById(id);
  }

  async delete(id: string) {
    await this.db.delete(organizations).where(eq(organizations.id, id));
  }
}
EOF

# ============================================================
# FILE: packages/db/src/queries/stations.ts
# ============================================================
cat > packages/db/src/queries/stations.ts << 'EOF'
import { eq, and } from 'drizzle-orm';
import type { DbClient } from '../client';
import { stations } from '../schema';

export class StationRepository {
  constructor(private db: DbClient) {}

  async findById(id: string) {
    const result = await this.db
      .select()
      .from(stations)
      .where(eq(stations.id, id))
      .limit(1);
    return result[0] || null;
  }

  async findByOrganization(organizationId: string) {
    return await this.db
      .select()
      .from(stations)
      .where(eq(stations.organizationId, organizationId));
  }

  async findAll() {
    return await this.db.select().from(stations);
  }

  async create(data: {
    id: string;
    organizationId: string;
    name: string;
    address?: string;
    city?: string;
    phone?: string;
    operatingHours?: string;
    hasFuel?: boolean;
    hasCarWash?: boolean;
    hasStore?: boolean;
  }) {
    const now = new Date();
    await this.db.insert(stations).values({
      ...data,
      createdAt: now,
      updatedAt: now,
    });
    return await this.findById(data.id);
  }

  async update(id: string, data: Partial<typeof stations.$inferInsert>) {
    await this.db
      .update(stations)
      .set({
        ...data,
        updatedAt: new Date(),
      })
      .where(eq(stations.id, id));
    return await this.findById(id);
  }

  async delete(id: string) {
    await this.db.delete(stations).where(eq(stations.id, id));
  }
}
EOF

# ============================================================
# FILE: packages/db/src/queries/users.ts
# ============================================================
cat > packages/db/src/queries/users.ts << 'EOF'
import { eq, and } from 'drizzle-orm';
import type { DbClient } from '../client';
import { users } from '../schema';

export class UserRepository {
  constructor(private db: DbClient) {}

  async findById(id: string) {
    const result = await this.db
      .select()
      .from(users)
      .where(eq(users.id, id))
      .limit(1);
    return result[0] || null;
  }

  async findByPhone(phone: string) {
    const result = await this.db
      .select()
      .from(users)
      .where(eq(users.phone, phone))
      .limit(1);
    return result[0] || null;
  }

  async findByStation(stationId: string) {
    return await this.db
      .select()
      .from(users)
      .where(eq(users.stationId, stationId));
  }

  async findByRole(role: string) {
    return await this.db.select().from(users).where(eq(users.role, role));
  }

  async findActiveUsers() {
    return await this.db.select().from(users).where(eq(users.isActive, true));
  }

  async create(data: {
    id: string;
    phone: string;
    name: string;
    email?: string;
    role: string;
    pinHash: string;
    stationId?: string;
  }) {
    const now = new Date();
    await this.db.insert(users).values({
      ...data,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    });
    return await this.findById(data.id);
  }

  async update(id: string, data: Partial<typeof users.$inferInsert>) {
    await this.db
      .update(users)
      .set({
        ...data,
        updatedAt: new Date(),
      })
      .where(eq(users.id, id));
    return await this.findById(id);
  }

  async updateLastLogin(id: string) {
    await this.db
      .update(users)
      .set({
        lastLoginAt: new Date(),
        updatedAt: new Date(),
      })
      .where(eq(users.id, id));
  }

  async deactivate(id: string) {
    await this.db
      .update(users)
      .set({
        isActive: false,
        updatedAt: new Date(),
      })
      .where(eq(users.id, id));
  }

  async delete(id: string) {
    await this.db.delete(users).where(eq(users.id, id));
  }
}
EOF

# ============================================================
# FILE: packages/db/src/queries/shifts.ts
# ============================================================
cat > packages/db/src/queries/shifts.ts << 'EOF'
import { eq, and, desc, between } from 'drizzle-orm';
import type { DbClient } from '../client';
import { shifts } from '../schema';

export class ShiftRepository {
  constructor(private db: DbClient) {}

  async findById(id: string) {
    const result = await this.db
      .select()
      .from(shifts)
      .where(eq(shifts.id, id))
      .limit(1);
    return result[0] || null;
  }

  async findActiveByAttendant(attendantId: string) {
    const result = await this.db
      .select()
      .from(shifts)
      .where(
        and(
          eq(shifts.attendantId, attendantId),
          eq(shifts.status, 'active')
        )
      )
      .limit(1);
    return result[0] || null;
  }

  async findActiveByStation(stationId: string) {
    return await this.db
      .select()
      .from(shifts)
      .where(
        and(
          eq(shifts.stationId, stationId),
          eq(shifts.status, 'active')
        )
      );
  }

  async findPendingApproval(stationId?: string) {
    const conditions: (typeof eq)[] = [eq(shifts.status, 'pending_approval')];
    if (stationId) {
      conditions.push(eq(shifts.stationId, stationId));
    }
    
    return await this.db
      .select()
      .from(shifts)
      .where(and(...conditions))
      .orderBy(desc(shifts.endedAt));
  }

  async findByDateRange(stationId: string, startDate: Date, endDate: Date) {
    return await this.db
      .select()
      .from(shifts)
      .where(
        and(
          eq(shifts.stationId, stationId),
          between(shifts.startedAt, startDate, endDate)
        )
      )
      .orderBy(desc(shifts.startedAt));
  }

  async findByAttendant(attendantId: string, limit: number = 10) {
    return await this.db
      .select()
      .from(shifts)
      .where(eq(shifts.attendantId, attendantId))
      .orderBy(desc(shifts.startedAt))
      .limit(limit);
  }

  async create(data: {
    id: string;
    stationId: string;
    attendantId: string;
    pumpId?: string;
    openingCash: number;
    openingMeterReading?: number;
  }) {
    const now = new Date();
    await this.db.insert(shifts).values({
      ...data,
      startedAt: now,
      status: 'active',
      createdAt: now,
      updatedAt: now,
    });
    return await this.findById(data.id);
  }

  async close(
    id: string,
    data: {
      closingCash: number;
      closingMeterReading?: number;
      actualCashCounted: number;
      varianceNotes?: string;
    }
  ) {
    const shift = await this.findById(id);
    if (!shift) throw new Error('Shift not found');

    // Calculate variances
    const expectedCash = shift.openingCash + (shift.totalCashSales || 0);
    const cashVariance = data.actualCashCounted - expectedCash;
    const cashVariancePercentage = expectedCash > 0 
      ? (cashVariance / expectedCash) * 100 
      : 0;

    let fuelVariance = null;
    if (shift.openingMeterReading && data.closingMeterReading) {
      const meterDiff = data.closingMeterReading - shift.openingMeterReading;
      fuelVariance = meterDiff - (shift.fuelDispensed || 0);
    }

    const variancePercentage = Math.abs(cashVariancePercentage);

    await this.db
      .update(shifts)
      .set({
        ...data,
        endedAt: new Date(),
        cashVariance,
        fuelVariance,
        variancePercentage,
        status: variancePercentage > 2 ? 'pending_approval' : 'approved',
        updatedAt: new Date(),
      })
      .where(eq(shifts.id, id));

    return await this.findById(id);
  }

  async updateTotals(
    id: string,
    totals: {
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
    }
  ) {
    await this.db
      .update(shifts)
      .set({
        ...totals,
        updatedAt: new Date(),
      })
      .where(eq(shifts.id, id));
  }

  async approve(id: string, approvedBy: string) {
    await this.db
      .update(shifts)
      .set({
        status: 'approved',
        approvedBy,
        approvedAt: new Date(),
        updatedAt: new Date(),
      })
      .where(eq(shifts.id, id));
    return await this.findById(id);
  }

  async reject(id: string, approvedBy: string, reason: string) {
    await this.db
      .update(shifts)
      .set({
        status: 'rejected',
        approvedBy,
        rejectionReason: reason,
        approvedAt: new Date(),
        updatedAt: new Date(),
      })
      .where(eq(shifts.id, id));
    return await this.findById(id);
  }
}
EOF

# ============================================================
# FILE: packages/db/src/queries/transactions.ts
# ============================================================
cat > packages/db/src/queries/transactions.ts << 'EOF'
import { eq, and, desc, between, sql } from 'drizzle-orm';
import type { DbClient } from '../client';
import { transactions } from '../schema';

export class TransactionRepository {
  constructor(private db: DbClient) {}

  async findById(id: string) {
    const result = await this.db
      .select()
      .from(transactions)
      .where(eq(transactions.id, id))
      .limit(1);
    return result[0] || null;
  }

  async findByReceiptNumber(receiptNumber: string) {
    const result = await this.db
      .select()
      .from(transactions)
      .where(eq(transactions.receiptNumber, receiptNumber))
      .limit(1);
    return result[0] || null;
  }

  async findByShift(shiftId: string) {
    return await this.db
      .select()
      .from(transactions)
      .where(eq(transactions.shiftId, shiftId))
      .orderBy(desc(transactions.transactionDate));
  }

  async findByStation(stationId: string, limit: number = 100) {
    return await this.db
      .select()
      .from(transactions)
      .where(eq(transactions.stationId, stationId))
      .orderBy(desc(transactions.transactionDate))
      .limit(limit);
  }

  async findByDateRange(
    stationId: string,
    startDate: Date,
    endDate: Date
  ) {
    return await this.db
      .select()
      .from(transactions)
      .where(
        and(
          eq(transactions.stationId, stationId),
          between(transactions.transactionDate, startDate, endDate)
        )
      )
      .orderBy(desc(transactions.transactionDate));
  }

  async findPendingSync(deviceId?: string) {
    const conditions = [sql`${transactions.syncedAt} IS NULL`];
    if (deviceId) {
      conditions.push(eq(transactions.deviceId, deviceId));
    }

    return await this.db
      .select()
      .from(transactions)
      .where(and(...conditions))
      .orderBy(transactions.createdAt);
  }

  async create(data: {
    id: string;
    receiptNumber: string;
    stationId: string;
    shiftId: string;
    attendantId: string;
    type: string;
    totalAmount: number;
    currency?: string;
    status?: string;
    deviceId?: string;
  }) {
    const now = new Date();
    await this.db.insert(transactions).values({
      ...data,
      transactionDate: now,
      createdAt: now,
      updatedAt: now,
    });
    return await this.findById(data.id);
  }

  async markSynced(id: string) {
    await this.db
      .update(transactions)
      .set({
        syncedAt: new Date(),
        updatedAt: new Date(),
      })
      .where(eq(transactions.id, id));
  }

  async cancel(id: string) {
    await this.db
      .update(transactions)
      .set({
        status: 'cancelled',
        updatedAt: new Date(),
      })
      .where(eq(transactions.id, id));
    return await this.findById(id);
  }

  async getTodayStats(stationId: string) {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    const result = await this.db
      .select({
        totalRevenue: sql<number>`SUM(${transactions.totalAmount})`,
        totalCount: sql<number>`COUNT(*)`,
      })
      .from(transactions)
      .where(
        and(
          eq(transactions.stationId, stationId),
          between(transactions.transactionDate, today, tomorrow),
          eq(transactions.status, 'completed')
        )
      );

    return result[0] || { totalRevenue: 0, totalCount: 0 };
  }
}
EOF

# ============================================================
# FILE: packages/db/src/queries/fuel-sales.ts
# ============================================================
cat > packages/db/src/queries/fuel-sales.ts << 'EOF'
import { eq } from 'drizzle-orm';
import type { DbClient } from '../client';
import { fuelSales } from '../schema';

export class FuelSaleRepository {
  constructor(private db: DbClient) {}

  async findById(id: string) {
    const result = await this.db
      .select()
      .from(fuelSales)
      .where(eq(fuelSales.id, id))
      .limit(1);
    return result[0] || null;
  }

  async findByTransaction(transactionId: string) {
    const result = await this.db
      .select()
      .from(fuelSales)
      .where(eq(fuelSales.transactionId, transactionId))
      .limit(1);
    return result[0] || null;
  }

  async create(data: {
    id: string;
    transactionId: string;
    pumpId: string;
    fuelType: string;
    litersDispensed: number;
    pricePerLiter: number;
    meterReadingBefore: number;
    meterReadingAfter: number;
  }) {
    const calculatedAmount = data.litersDispensed * data.pricePerLiter;
    
    await this.db.insert(fuelSales).values({
      ...data,
      calculatedAmount,
      createdAt: new Date(),
    });
    return await this.findById(data.id);
  }
}
EOF

# ============================================================
# FILE: packages/db/src/queries/car-wash-sales.ts
# ============================================================
cat > packages/db/src/queries/car-wash-sales.ts << 'EOF'
import { eq } from 'drizzle-orm';
import type { DbClient } from '../client';
import { carWashSales } from '../schema';

export class CarWashSaleRepository {
  constructor(private db: DbClient) {}

  async findById(id: string) {
    const result = await this.db
      .select()
      .from(carWashSales)
      .where(eq(carWashSales.id, id))
      .limit(1);
    return result[0] || null;
  }

  async findByTransaction(transactionId: string) {
    const result = await this.db
      .select()
      .from(carWashSales)
      .where(eq(carWashSales.transactionId, transactionId))
      .limit(1);
    return result[0] || null;
  }

  async create(data: {
    id: string;
    transactionId: string;
    serviceId?: string;
    serviceName: string;
    vehicleType: string;
    price: number;
    notes?: string;
  }) {
    await this.db.insert(carWashSales).values({
      ...data,
      createdAt: new Date(),
    });
    return await this.findById(data.id);
  }
}
EOF

# ============================================================
# FILE: packages/db/src/queries/store-sales.ts
# ============================================================
cat > packages/db/src/queries/store-sales.ts << 'EOF'
import { eq } from 'drizzle-orm';
import type { DbClient } from '../client';
import { storeSales, storeSaleItems } from '../schema';

export class StoreSaleRepository {
  constructor(private db: DbClient) {}

  async findById(id: string) {
    const result = await this.db
      .select()
      .from(storeSales)
      .where(eq(storeSales.id, id))
      .limit(1);
    return result[0] || null;
  }

  async findByTransaction(transactionId: string) {
    const result = await this.db
      .select()
      .from(storeSales)
      .where(eq(storeSales.transactionId, transactionId))
      .limit(1);
    return result[0] || null;
  }

  async findItemsByStoreSale(storeSaleId: string) {
    return await this.db
      .select()
      .from(storeSaleItems)
      .where(eq(storeSaleItems.storeSaleId, storeSaleId));
  }

  async create(
    data: {
      id: string;
      transactionId: string;
    },
    items: Array<{
      id: string;
      productId: string;
      productName: string;
      quantity: number;
      unitPrice: number;
    }>
  ) {
    // Create store sale
    await this.db.insert(storeSales).values({
      ...data,
      createdAt: new Date(),
    });

    // Create line items
    const now = new Date();
    await this.db.insert(storeSaleItems).values(
      items.map((item) => ({
        ...item,
        storeSaleId: data.id,
        totalPrice: item.quantity * item.unitPrice,
        createdAt: now,
      }))
    );

    return await this.findById(data.id);
  }
}
EOF

# ============================================================
# FILE: packages/db/src/queries/payments.ts
# ============================================================
cat > packages/db/src/queries/payments.ts << 'EOF'
import { eq } from 'drizzle-orm';
import type { DbClient } from '../client';
import { payments } from '../schema';

export class PaymentRepository {
  constructor(private db: DbClient) {}

  async findById(id: string) {
    const result = await this.db
      .select()
      .from(payments)
      .where(eq(payments.id, id))
      .limit(1);
    return result[0] || null;
  }

  async findByTransaction(transactionId: string) {
    return await this.db
      .select()
      .from(payments)
      .where(eq(payments.transactionId, transactionId));
  }

  async create(data: {
    id: string;
    transactionId: string;
    paymentMethod: string;
    amount: number;
    currency?: string;
    // Optional fields based on payment method
    amountReceived?: number;
    changeGiven?: number;
    momoProvider?: string;
    momoPhone?: string;
    momoTransactionId?: string;
    momoReference?: string;
    cardLast4?: string;
    cardType?: string;
    cardTransactionId?: string;
    creditCustomerId?: string;
    creditDueDate?: Date;
  }) {
    const now = new Date();
    await this.db.insert(payments).values({
      ...data,
      status: 'pending',
      createdAt: now,
      updatedAt: now,
    });
    return await this.findById(data.id);
  }

  async markCompleted(id: string) {
    await this.db
      .update(payments)
      .set({
        status: 'completed',
        paidAt: new Date(),
        updatedAt: new Date(),
      })
      .where(eq(payments.id, id));
    return await this.findById(id);
  }

  async markFailed(id: string, reason: string) {
    await this.db
      .update(payments)
      .set({
        status: 'failed',
        failureReason: reason,
        updatedAt: new Date(),
      })
      .where(eq(payments.id, id));
    return await this.findById(id);
  }
}
EOF

# ============================================================
# FILE: packages/db/src/queries/products.ts
# ============================================================
cat > packages/db/src/queries/products.ts << 'EOF'
import { eq, and, sql } from 'drizzle-orm';
import type { DbClient } from '../client';
import { products, stockMovements } from '../schema';

// Helper function for ULID generation (simplified version)
function ulid() {
  return Date.now().toString(36) + Math.random().toString(36).substring(2);
}

export class ProductRepository {
  constructor(private db: DbClient) {}

  async findById(id: string) {
    const result = await this.db
      .select()
      .from(products)
      .where(eq(products.id, id))
      .limit(1);
    return result[0] || null;
  }

  async findByStation(stationId: string) {
    return await this.db
      .select()
      .from(products)
      .where(eq(products.stationId, stationId));
  }

  async findActiveByStation(stationId: string) {
    return await this.db
      .select()
      .from(products)
      .where(
        and(
          eq(products.stationId, stationId),
          eq(products.isActive, true)
        )
      );
  }

  async findLowStock(stationId: string) {
    return await this.db
      .select()
      .from(products)
      .where(
        and(
          eq(products.stationId, stationId),
          eq(products.isActive, true),
          sql`${products.currentStock} <= ${products.minimumStock}`
        )
      );
  }

  async create(data: {
    id: string;
    stationId: string;
    categoryId?: string;
    name: string;
    description?: string;
    sku?: string;
    barcode?: string;
    costPrice: number;
    sellingPrice: number;
    currency?: string;
    currentStock?: number;
    minimumStock?: number;
    unit?: string;
  }) {
    const now = new Date();
    await this.db.insert(products).values({
      ...data,
      createdAt: now,
      updatedAt: now,
    });
    return await this.findById(data.id);
  }

  async update(id: string, data: Partial<typeof products.$inferInsert>) {
    await this.db
      .update(products)
      .set({
        ...data,
        updatedAt: new Date(),
      })
      .where(eq(products.id, id));
    return await this.findById(id);
  }

  async adjustStock(
    productId: string,
    movementType: string,
    quantity: number,
    recordedBy: string,
    reference?: string,
    notes?: string,
    transactionId?: string
  ) {
    const product = await this.findById(productId);
    if (!product) throw new Error('Product not found');

    const quantityBefore = product.currentStock;
    const quantityAfter = quantityBefore + quantity;

    // Update product stock
    await this.db
      .update(products)
      .set({
        currentStock: quantityAfter,
        updatedAt: new Date(),
        ...(movementType === 'purchase' ? { lastRestockedAt: new Date() } : {}),
      })
      .where(eq(products.id, productId));

    // Record stock movement
    await this.db.insert(stockMovements).values({
      id: ulid(),
      productId,
      movementType,
      quantity,
      quantityBefore,
      quantityAfter,
      transactionId,
      reference,
      notes,
      recordedBy,
      movementDate: new Date(),
      createdAt: new Date(),
    });

    return await this.findById(productId);
  }
}
EOF

# ============================================================
# FILE: packages/db/src/queries/credit-customers.ts
# ============================================================
cat > packages/db/src/queries/credit-customers.ts << 'EOF'
import { eq, and, gt, desc } from 'drizzle-orm';
import type { DbClient } from '../client';
import { creditCustomers, creditTransactions } from '../schema';

// Helper function for ULID generation (simplified version)
function ulid() {
  return Date.now().toString(36) + Math.random().toString(36).substring(2);
}

export class CreditCustomerRepository {
  constructor(private db: DbClient) {}

  async findById(id: string) {
    const result = await this.db
      .select()
      .from(creditCustomers)
      .where(eq(creditCustomers.id, id))
      .limit(1);
    return result[0] || null;
  }

  async findByStation(stationId: string) {
    return await this.db
      .select()
      .from(creditCustomers)
      .where(eq(creditCustomers.stationId, stationId));
  }

  async findActiveByStation(stationId: string) {
    return await this.db
      .select()
      .from(creditCustomers)
      .where(
        and(
          eq(creditCustomers.stationId, stationId),
          eq(creditCustomers.isActive, true)
        )
      );
  }

  async findWithOutstandingBalance(stationId: string) {
    return await this.db
      .select()
      .from(creditCustomers)
      .where(
        and(
          eq(creditCustomers.stationId, stationId),
          gt(creditCustomers.currentBalance, 0)
        )
      );
  }

  async create(data: {
    id: string;
    stationId: string;
    name: string;
    phone: string;
    email?: string;
    companyName?: string;
    creditLimit: number;
    paymentTermDays?: number;
  }) {
    const now = new Date();
    await this.db.insert(creditCustomers).values({
      ...data,
      currentBalance: 0,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    });
    return await this.findById(data.id);
  }

  async update(id: string, data: Partial<typeof creditCustomers.$inferInsert>) {
    await this.db
      .update(creditCustomers)
      .set({
        ...data,
        updatedAt: new Date(),
      })
      .where(eq(creditCustomers.id, id));
    return await this.findById(id);
  }

  async addCharge(
    customerId: string,
    amount: number,
    recordedBy: string,
    transactionId?: string,
    notes?: string
  ) {
    const customer = await this.findById(customerId);
    if (!customer) throw new Error('Customer not found');

    const newBalance = customer.currentBalance + amount;

    // Check credit limit
    if (newBalance > customer.creditLimit) {
      throw new Error('Credit limit exceeded');
    }

    // Update customer balance
    await this.db
      .update(creditCustomers)
      .set({
        currentBalance: newBalance,
        lastPurchaseAt: new Date(),
        updatedAt: new Date(),
      })
      .where(eq(creditCustomers.id, customerId));

    // Record transaction
    await this.db.insert(creditTransactions).values({
      id: ulid(),
      customerId,
      transactionId,
      type: 'charge',
      amount,
      runningBalance: newBalance,
      notes,
      recordedBy,
      createdAt: new Date(),
    });

    return await this.findById(customerId);
  }

  async addPayment(
    customerId: string,
    amount: number,
    recordedBy: string,
    paymentMethod: string,
    paymentReference?: string,
    notes?: string
  ) {
    const customer = await this.findById(customerId);
    if (!customer) throw new Error('Customer not found');

    const newBalance = customer.currentBalance - amount;

    // Update customer balance
    await this.db
      .update(creditCustomers)
      .set({
        currentBalance: Math.max(0, newBalance),
        lastPaymentAt: new Date(),
        updatedAt: new Date(),
      })
      .where(eq(creditCustomers.id, customerId));

    // Record transaction
    await this.db.insert(creditTransactions).values({
      id: ulid(),
      customerId,
      transactionId: null,
      type: 'payment',
      amount: -amount,
      runningBalance: Math.max(0, newBalance),
      paymentMethod,
      paymentReference,
      notes,
      recordedBy,
      createdAt: new Date(),
    });

    return await this.findById(customerId);
  }

  async getTransactionHistory(customerId: string, limit: number = 50) {
    return await this.db
      .select()
      .from(creditTransactions)
      .where(eq(creditTransactions.customerId, customerId))
      .orderBy(desc(creditTransactions.createdAt))
      .limit(limit);
  }
}
EOF

# ============================================================
# FILE: packages/db/src/queries/index.ts
# Export all repositories
# ============================================================
cat > packages/db/src/queries/index.ts << 'EOF'
export * from './organizations';
export * from './stations';
export * from './users';
export * from './shifts';
export * from './transactions';
export * from './fuel-sales';
export * from './car-wash-sales';
export * from './store-sales';
export * from './payments';
export * from './products';
export * from './credit-customers';
EOF

# ============================================================
# USAGE IN API (as a comment file for reference)
# ============================================================
cat > packages/db/src/queries/README.md << 'EOF'
# Database Query Repositories

This directory contains repository classes that provide a clean API for database operations.

## Usage Example

```typescript
import { createDbClient } from '@ororo/db';
import { TransactionRepository, ShiftRepository } from '@ororo/db/queries';

export default {
  async fetch(request, env, ctx) {
    const db = createDbClient(env.DB);
    
    // Initialize repositories
    const transactionRepo = new TransactionRepository(db);
    const shiftRepo = new ShiftRepository(db);
    
    // Use clean methods
    const transactions = await transactionRepo.findByStation('station-123');
    const activeShifts = await shiftRepo.findActiveByStation('station-123');
    
    return Response.json({ transactions, activeShifts });
  }
}

EOF

echo "✅ All database repository files have been created successfully in packages/db/src/queries/"
echo "📁 Location: $(pwd)/packages/db/src/queries/"