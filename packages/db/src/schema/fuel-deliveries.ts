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
