import { sqliteTable, text, integer, real } from 'drizzle-orm/sqlite-core';
import { stations } from './stations';
import { productCategories } from './product-categories';

export const products = sqliteTable('products', {
  id: text('id').primaryKey(),
  stationId: text('station_id')
    .notNull()
    .references(() => stations.id),
  categoryId: text('category_id')
    .references(() => productCategories.id),
  
  name: text('name').notNull(),
  description: text('description'),
  sku: text('sku'),
  barcode: text('barcode'),
  
  // Pricing
  costPrice: real('cost_price').notNull(),
  sellingPrice: real('selling_price').notNull(),
  currency: text('currency').notNull().default('RWF'),
  
  // Inventory
  currentStock: integer('current_stock').notNull().default(0),
  minimumStock: integer('minimum_stock').notNull().default(0),
  unit: text('unit').notNull().default('piece'),
  
  // Metadata
  isActive: integer('is_active', { mode: 'boolean' }).notNull().default(true),
  notes: text('notes'),
  
  createdAt: integer('created_at', { mode: 'timestamp' }).notNull(),
  updatedAt: integer('updated_at', { mode: 'timestamp' }).notNull(),
  lastRestockedAt: integer('last_restocked_at', { mode: 'timestamp' }),
});
