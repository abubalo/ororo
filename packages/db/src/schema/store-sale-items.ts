import { sqliteTable, text, integer, real } from 'drizzle-orm/sqlite-core';
import { storeSales } from './store-sales';
import { products } from './products';

export const storeSaleItems = sqliteTable('store_sale_items', {
  id: text('id').primaryKey(),
  storeSaleId: text('store_sale_id')
    .notNull()
    .references(() => storeSales.id),
  productId: text('product_id')
    .notNull()
    .references(() => products.id),
  
  productName: text('product_name').notNull(),
  quantity: integer('quantity').notNull(),
  unitPrice: real('unit_price').notNull(),
  totalPrice: real('total_price').notNull(),
  
  createdAt: integer('created_at', { mode: 'timestamp' }).notNull(),
});
