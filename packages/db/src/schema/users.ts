import { sqliteTable, text, integer } from 'drizzle-orm/sqlite-core';
import { stations } from './stations';

export const users = sqliteTable('users', {
  id: text('id').primaryKey(),
  phone: text('phone').notNull().unique(),
  name: text('name').notNull(),
  email: text('email'),
  role: text('role').notNull(),
  pinHash: text('pin_hash').notNull(),
  stationId: text('station_id').references(() => stations.id),
  isActive: integer('is_active', { mode: 'boolean' }).notNull().default(true),
  lastLoginAt: integer('last_login_at', { mode: 'timestamp' }),
  createdAt: integer('created_at', { mode: 'timestamp' }).notNull(),
  updatedAt: integer('updated_at', { mode: 'timestamp' }).notNull(),
});
