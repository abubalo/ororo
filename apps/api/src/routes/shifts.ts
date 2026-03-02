import { Hono } from 'hono';
import { zValidator } from '@hono/zod-validator';
import { z } from 'zod';
import { createDbClient } from '../db/client';
import { ShiftService } from '../services/shift.service';
import { ShiftRepository } from '../db/queries';
import { requireRole } from '../middleware/auth';
import type { Bindings, Variables } from '../index';

const app = new Hono<{ Bindings: Bindings; Variables: Variables }>();

const startShiftSchema = z.object({
  stationId: z.string(),
  pumpId: z.string().optional(),
  openingCash: z.number(),
  openingMeterReading: z.number().optional(),
});

app.post('/start', zValidator('json', startShiftSchema), async (c) => {
  const data = c.req.valid('json');
  const attendantId = c.get('userId');

  const db = createDbClient(c.env.DB);
  const shiftService = new ShiftService(db);

  try {
    const shift = await shiftService.startShift({
      attendantId,
      ...data,
    });
    return c.json({ shift }, 201);
  } catch (error) {
    return c.json({ error: (error as Error).message }, 400);
  }
});

app.get('/current', async (c) => {
  const attendantId = c.get('userId');

  const db = createDbClient(c.env.DB);
  const shiftRepo = new ShiftRepository(db);

  const shift = await shiftRepo.findActiveByAttendant(attendantId);

  if (!shift) {
    return c.json({ error: 'No active shift found' }, 404);
  }

  return c.json({ shift });
});

const closeShiftSchema = z.object({
  closingCash: z.number(),
  closingMeterReading: z.number().optional(),
  actualCashCounted: z.number(),
  varianceNotes: z.string().optional(),
});

app.post('/:id/close', zValidator('json', closeShiftSchema), async (c) => {
  const shiftId = c.req.param('id');
  const data = c.req.valid('json');
  const attendantId = c.get('userId');

  const db = createDbClient(c.env.DB);
  const shiftService = new ShiftService(db);

  try {
    const shift = await shiftService.closeShift(shiftId, attendantId, data);
    return c.json({ shift });
  } catch (error) {
    return c.json({ error: (error as Error).message }, 400);
  }
});

app.get('/pending', requireRole('manager', 'owner'), async (c) => {
  const stationId = c.get('stationId');

  const db = createDbClient(c.env.DB);
  const shiftRepo = new ShiftRepository(db);

  const shifts = await shiftRepo.findPendingApproval(stationId);

  return c.json({ shifts });
});

app.post('/:id/approve', requireRole('manager', 'owner'), async (c) => {
  const shiftId = c.req.param('id');
  const managerId = c.get('userId');

  const db = createDbClient(c.env.DB);
  const shiftService = new ShiftService(db);

  const shift = await shiftService.approveShift(shiftId, managerId);

  return c.json({ shift });
});

const rejectSchema = z.object({
  reason: z.string().min(10),
});

app.post(
  '/:id/reject',
  requireRole('manager', 'owner'),
  zValidator('json', rejectSchema),
  async (c) => {
    const shiftId = c.req.param('id');
    const { reason } = c.req.valid('json');
    const managerId = c.get('userId');

    const db = createDbClient(c.env.DB);
    const shiftService = new ShiftService(db);

    const shift = await shiftService.rejectShift(shiftId, managerId, reason);

    return c.json({ shift });
  }
);

app.get('/history', async (c) => {
  const attendantId = c.get('userId');
  const limit = parseInt(c.req.query('limit') || '10');

  const db = createDbClient(c.env.DB);
  const shiftRepo = new ShiftRepository(db);

  const shifts = await shiftRepo.findByAttendant(attendantId, limit);

  return c.json({ shifts });
});

export default app;
