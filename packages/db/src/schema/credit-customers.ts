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
