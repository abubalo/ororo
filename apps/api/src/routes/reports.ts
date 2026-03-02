import { Hono } from 'hono';
import { zValidator } from '@hono/zod-validator';
import { z } from 'zod';
import { createDbClient } from '../db/client';
import { TransactionRepository, ShiftRepository } from '../db/queries';
import { requireRole } from '../middleware/auth';
import type { Bindings, Variables } from '../index';

const app = new Hono<{ Bindings: Bindings; Variables: Variables }>();

const dateRangeSchema = z.object({
  start: z.string().optional(),
  end: z.string().optional(),
});

app.get('/daily-sales', requireRole('manager', 'owner'), zValidator('query', dateRangeSchema), async (c) => {
  const { start, end } = c.req.valid('query');
  const stationId = c.get('stationId');

  if (!stationId) {
    return c.json({ error: 'No station assigned' }, 400);
  }

  const db = createDbClient(c.env.DB);
  const txnRepo = new TransactionRepository(db);

  const startDate = start ? new Date(start) : new Date(new Date().setHours(0, 0, 0, 0));
  const endDate = end ? new Date(end) : new Date(new Date().setHours(23, 59, 59, 999));

  const transactions = await txnRepo.findByDateRange(stationId, startDate, endDate);

  // Calculate summary
  const summary = transactions.reduce(
    (acc, t) => {
      acc.totalRevenue += t.totalAmount;
      acc.totalTransactions += 1;
      
      if (t.type === 'fuel') acc.fuelRevenue += t.totalAmount;
      else if (t.type === 'car_wash') acc.carWashRevenue += t.totalAmount;
      else if (t.type === 'store') acc.storeRevenue += t.totalAmount;
      
      return acc;
    },
    {
      totalRevenue: 0,
      totalTransactions: 0,
      fuelRevenue: 0,
      carWashRevenue: 0,
      storeRevenue: 0,
    }
  );

  return c.json({
    summary,
    transactions,
  });
});

app.get('/shift-performance', requireRole('manager', 'owner'), zValidator('query', dateRangeSchema), async (c) => {
  const { start, end } = c.req.valid('query');
  const stationId = c.get('stationId');

  if (!stationId) {
    return c.json({ error: 'No station assigned' }, 400);
  }

  const db = createDbClient(c.env.DB);
  const shiftRepo = new ShiftRepository(db);

  const startDate = start ? new Date(start) : new Date(new Date().setDate(new Date().getDate() - 7));
  const endDate = end ? new Date(end) : new Date();

  const shifts = await shiftRepo.findByDateRange(stationId, startDate, endDate);

  return c.json({ shifts });
});

export default app;
