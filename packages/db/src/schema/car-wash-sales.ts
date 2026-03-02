import { sqliteTable, text, integer, real } from 'drizzle-orm/sqlite-core';
import { transactions } from './transactions';
import { carWashServices } from './car-wash-services';

export const carWashSales = sqliteTable('car_wash_sales', {
  id: text('id').primaryKey(),
  transactionId: text('transaction_id')
    .notNull()
    .references(() => transactions.id),
  serviceId: text('service_id')
    .references(() => carWashServices.id),
  
  serviceName: text('service_name').notNull(),
  vehicleType: text('vehicle_type').notNull(),
  price: real('price').notNull(),
  notes: text('notes'),
  
  createdAt: integer('created_at', { mode: 'timestamp' }).notNull(),
});
