import { sqliteTable, text, integer, real } from 'drizzle-orm/sqlite-core';
import { fuelTanks } from './fuel-tanks';
import { users } from './users';

export const tankReadings = sqliteTable('tank_readings', {
  id: text('id').primaryKey(),
  tankId: text('tank_id')
    .notNull()
    .references(() => fuelTanks.id),
  
  readingType: text('reading_type').notNull(),
  liters: real('liters').notNull(),
  depthCm: real('depth_cm'),
  temperature: real('temperature'),
  
  recordedBy: text('recorded_by')
    .notNull()
    .references(() => users.id),
  notes: text('notes'),
  
  readingDate: integer('reading_date', { mode: 'timestamp' }).notNull(),
  createdAt: integer('created_at', { mode: 'timestamp' }).notNull(),
});
