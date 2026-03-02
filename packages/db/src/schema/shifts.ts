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
