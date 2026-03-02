import { sqliteTable, text, integer, real } from 'drizzle-orm/sqlite-core';
import { stations } from './stations';

export const fuelTanks = sqliteTable('fuel_tanks', {
  id: text('id').primaryKey(),
  stationId: text('station_id')
    .notNull()
    .references(() => stations.id),
  name: text('name').notNull(),
  fuelType: text('fuel_type').notNull(),
  capacityLiters: real('capacity_liters').notNull(),
  currentLiters: real('current_liters').notNull().default(0),
  minimumLevel: real('minimum_level').notNull().default(0),
  isActive: integer('is_active', { mode: 'boolean' }).notNull().default(true),
  createdAt: integer('created_at', { mode: 'timestamp' }).notNull(),
  updatedAt: integer('updated_at', { mode: 'timestamp' }).notNull(),
});
