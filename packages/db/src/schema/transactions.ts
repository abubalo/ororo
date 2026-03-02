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
