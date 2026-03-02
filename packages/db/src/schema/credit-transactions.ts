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
