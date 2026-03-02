import { sqliteTable, text, integer, real } from 'drizzle-orm/sqlite-core';
import { stations } from './stations';

export const carWashServices = sqliteTable('car_wash_services', {
  id: text('id').primaryKey(),
  stationId: text('station_id')
    .notNull()
    .references(() => stations.id),
  
  serviceType: text('service_type').notNull(),
  name: text('name').notNull(),
  description: text('description'),
  
  // Pricing by vehicle type
  priceSedan: real('price_sedan').notNull(),
  priceSuv: real('price_suv').notNull(),
  priceTruck: real('price_truck'),
  priceMotorcycle: real('price_motorcycle'),
  
  estimatedDurationMinutes: integer('estimated_duration_minutes'),
  isActive: integer('is_active', { mode: 'boolean' }).notNull().default(true),
  displayOrder: integer('display_order').notNull().default(0),
  
  createdAt: integer('created_at', { mode: 'timestamp' }).notNull(),
  updatedAt: integer('updated_at', { mode: 'timestamp' }).notNull(),
});
