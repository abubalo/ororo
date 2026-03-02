import { sqliteTable, text, integer, real } from 'drizzle-orm/sqlite-core';
import { stations } from './stations';

export const fuelPrices = sqliteTable('fuel_prices', {
  id: text('id').primaryKey(),
  stationId: text('station_id')
    .notNull()
    .references(() => stations.id),
  fuelType: text('fuel_type').notNull(),
  pricePerLiter: real('price_per_liter').notNull(),
  effectiveFrom: integer('effective_from', { mode: 'timestamp' }).notNull(),
  effectiveTo: integer('effective_to', { mode: 'timestamp' }),
  createdAt: integer('created_at', { mode: 'timestamp' }).notNull(),
  createdBy: text('created_by').notNull(),
});
