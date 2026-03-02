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
