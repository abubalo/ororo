import { Hono } from 'hono';
import { zValidator } from '@hono/zod-validator';
import { z } from 'zod';
import { createDbClient } from '../db/client';
import { requireRole } from '../middleware/auth';
import { FuelService } from '../services/fuel.service';
import type { Bindings, Variables } from '../index';

const app = new Hono<{ Bindings: Bindings; Variables: Variables }>();

const updatePriceSchema = z.object({
  fuelType: z.string(),
  pricePerLiter: z.number(),
});

app.post('/prices', requireRole('manager', 'owner'), zValidator('json', updatePriceSchema), async (c) => {
  const data = c.req.valid('json');
  const stationId = c.get('stationId');

  // Implementation would use FuelPriceRepository
  return c.json({ message: 'Price updated', data });
});

const deliverySchema = z.object({
  tankId: z.string(),
  supplierName: z.string(),
  invoiceQuantity: z.number(),
  deliveredQuantity: z.number(),
  pricePerLiter: z.number(),
  invoiceNumber: z.string(),
});

app.post('/deliveries', requireRole('manager', 'owner'), zValidator('json', deliverySchema), async (c) => {
  const data = c.req.valid('json');

  // Implementation would use FuelDeliveryRepository
  return c.json({ message: 'Delivery recorded', data }, 201);
});

app.get('/variance/calculate', async (c) => {
  const meterDiff = parseFloat(c.req.query('meterDiff') || '0');
  const recordedSales = parseFloat(c.req.query('recordedSales') || '0');

  const db = createDbClient(c.env.DB);
  const fuelService = new FuelService(db);

  const result = await fuelService.calculateVariance(meterDiff, recordedSales);

  return c.json(result);
});

export default app;
