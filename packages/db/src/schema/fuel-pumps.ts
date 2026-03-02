import { sqliteTable, text, integer, real } from 'drizzle-orm/sqlite-core';
import { stations } from './stations';
import { fuelTanks } from './fuel-tanks';

export const fuelPumps = sqliteTable('fuel_pumps', {
  id: text('id').primaryKey(),
  stationId: text('station_id')
    .notNull()
    .references(() => stations.id),
  tankId: text('tank_id')
    .notNull()
    .references(() => fuelTanks.id),
  name: text('name').notNull(),
  fuelType: text('fuel_type').notNull(),
  currentMeterReading: real('current_meter_reading').notNull().default(0),
  isActive: integer('is_active', { mode: 'boolean' }).notNull().default(true),
  createdAt: integer('created_at', { mode: 'timestamp' }).notNull(),
  updatedAt: integer('updated_at', { mode: 'timestamp' }).notNull(),
});
