import { Hono } from 'hono';
import { zValidator } from '@hono/zod-validator';
import { z } from 'zod';
import { createDbClient } from '../db/client';
import { UserRepository } from '../db/queries';
import { requireRole } from '../middleware/auth';
import { hashPin } from '../utils/hash';
import { ulid } from '../utils/ulid';
import { phoneSchema, pinSchema } from '../utils/validation';
import type { Bindings, Variables } from '../index';

const app = new Hono<{ Bindings: Bindings; Variables: Variables }>();

app.get('/', requireRole('manager', 'owner'), async (c) => {
  const stationId = c.get('stationId');

  const db = createDbClient(c.env.DB);
  const userRepo = new UserRepository(db);

  const users = stationId
    ? await userRepo.findByStation(stationId)
    : await userRepo.findActiveUsers();

  return c.json({ users });
});

app.get('/:id', requireRole('manager', 'owner'), async (c) => {
  const id = c.req.param('id');

  const db = createDbClient(c.env.DB);
  const userRepo = new UserRepository(db);

  const user = await userRepo.findById(id);

  if (!user) {
    return c.json({ error: 'User not found' }, 404);
  }

  return c.json({ user });
});

const createUserSchema = z.object({
  phone: phoneSchema,
  name: z.string().min(2),
  pin: pinSchema,
  email: z.string().email().optional(),
  role: z.enum(['attendant', 'manager']),
  stationId: z.string().optional(),
});

app.post('/', requireRole('manager', 'owner'), zValidator('json', createUserSchema), async (c) => {
  const data = c.req.valid('json');
  const stationId = c.get('stationId');

  // Ensure users are created for the manager's station
  if (data.role === 'attendant' && !data.stationId && stationId) {
    data.stationId = stationId;
  }

  const db = createDbClient(c.env.DB);
  const userRepo = new UserRepository(db);

  const existing = await userRepo.findByPhone(data.phone);
  if (existing) {
    return c.json({ error: 'User already exists' }, 409);
  }

  const pinHash = await hashPin(data.pin);

  const user = await userRepo.create({
    id: ulid(),
    ...data,
    pinHash,
  });

  return c.json({ user }, 201);
});

const updateUserSchema = z.object({
  name: z.string().min(2).optional(),
  email: z.string().email().optional(),
  role: z.enum(['attendant', 'manager']).optional(),
  isActive: z.boolean().optional(),
});

app.put('/:id', requireRole('manager', 'owner'), zValidator('json', updateUserSchema), async (c) => {
  const id = c.req.param('id');
  const data = c.req.valid('json');

  const db = createDbClient(c.env.DB);
  const userRepo = new UserRepository(db);

  const user = await userRepo.update(id, data);

  return c.json({ user });
});

app.delete('/:id', requireRole('manager', 'owner'), async (c) => {
  const id = c.req.param('id');

  const db = createDbClient(c.env.DB);
  const userRepo = new UserRepository(db);

  await userRepo.deactivate(id);

  return c.json({ message: 'User deactivated successfully' });
});

export default app;
