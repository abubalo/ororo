import { Hono } from 'hono';
import { zValidator } from '@hono/zod-validator';
import { z } from 'zod';
import { createDbClient } from '../db/client';
import { PaymentService } from '../services/payment.service';
import { PaymentRepository } from '../db/queries';
import type { Bindings, Variables } from '../index';

const app = new Hono<{ Bindings: Bindings; Variables: Variables }>();

app.get('/:id', async (c) => {
  const id = c.req.param('id');

  const db = createDbClient(c.env.DB);
  const paymentRepo = new PaymentRepository(db);

  const payment = await paymentRepo.findById(id);

  if (!payment) {
    return c.json({ error: 'Payment not found' }, 404);
  }

  return c.json({ payment });
});

const momoCallbackSchema = z.object({
  transactionId: z.string(),
  status: z.string(),
  amount: z.number(),
  phone: z.string(),
});

app.post('/momo/callback', zValidator('json', momoCallbackSchema), async (c) => {
  const data = c.req.valid('json');

  const db = createDbClient(c.env.DB);
  const paymentService = new PaymentService(db);

  const result = await paymentService.handleMomoCallback(data);

  return c.json(result);
});

export default app;
