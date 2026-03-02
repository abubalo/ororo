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
