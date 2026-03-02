import { sqliteTable, text, integer } from 'drizzle-orm/sqlite-core';
import { organizations } from './organizations';

export const stations = sqliteTable('stations', {
  id: text('id').primaryKey(),
  organizationId: text('organization_id')
    .notNull()
    .references(() => organizations.id),
  name: text('name').notNull(),
  address: text('address'),
  city: text('city'),
  phone: text('phone'),
  operatingHours: text('operating_hours'),
  
  // Features enabled at this station
  hasFuel: integer('has_fuel', { mode: 'boolean' }).notNull().default(true),
  hasCarWash: integer('has_car_wash', { mode: 'boolean' }).notNull().default(false),
  hasStore: integer('has_store', { mode: 'boolean' }).notNull().default(false),
  
  createdAt: integer('created_at', { mode: 'timestamp' }).notNull(),
  updatedAt: integer('updated_at', { mode: 'timestamp' }).notNull(),
});
