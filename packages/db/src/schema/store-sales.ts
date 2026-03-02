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
