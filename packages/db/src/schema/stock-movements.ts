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
