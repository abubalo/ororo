import { Hono } from 'hono';
import { zValidator } from '@hono/zod-validator';
import { z } from 'zod';
import { createDbClient } from '../db/client';
import { TransactionService } from '../services/transaction.service';
import { TransactionRepository } from '../db/queries';
import type { Bindings, Variables } from '../index';

const app = new Hono<{ Bindings: Bindings; Variables: Variables }>();

const createFuelTransactionSchema = z.object({
  shiftId: z.string(),
  pumpId: z.string(),
  fuelType: z.string(),
  litersDispensed: z.number(),
  pricePerLiter: z.number(),
  meterReadingBefore: z.number(),
  meterReadingAfter: z.number(),
  paymentMethod: z.string(),
  amountReceived: z.number().optional(),
  momoPhone: z.string().optional(),
  creditCustomerId: z.string().optional(),
});

app.post('/fuel', zValidator('json', createFuelTransactionSchema), async (c) => {
  const data = c.req.valid('json');
  const attendantId = c.get('userId');
  const stationId = c.get('stationId');

  if (!stationId) {
    return c.json({ error: 'No station assigned' }, 400);
  }

  const db = createDbClient(c.env.DB);
  const transactionService = new TransactionService(db);

  try {
    const result = await transactionService.createFuelTransaction({
      attendantId,
      stationId,
      ...data,
    });
    return c.json(result, 201);
  } catch (error) {
    return c.json({ error: (error as Error).message }, 400);
  }
});

app.get('/:id', async (c) => {
  const id = c.req.param('id');

  const db = createDbClient(c.env.DB);
  const txnRepo = new TransactionRepository(db);

  const transaction = await txnRepo.findById(id);

  if (!transaction) {
    return c.json({ error: 'Transaction not found' }, 404);
  }

  return c.json({ transaction });
});

app.get('/shift/:shiftId', async (c) => {
  const shiftId = c.req.param('shiftId');

  const db = createDbClient(c.env.DB);
  const txnRepo = new TransactionRepository(db);

  const transactions = await txnRepo.findByShift(shiftId);

  return c.json({ transactions });
});

app.get('/today/stats', async (c) => {
  const stationId = c.get('stationId');

  if (!stationId) {
    return c.json({ error: 'No station assigned' }, 400);
  }

  const db = createDbClient(c.env.DB);
  const txnRepo = new TransactionRepository(db);

  const stats = await txnRepo.getTodayStats(stationId);

  return c.json({ stats });
});

export default app;
