import { Hono } from 'hono';
import { zValidator } from '@hono/zod-validator';
import { z } from 'zod';
import { createDbClient } from '../db/client';
import { AuthService } from '../services/auth.service';
import { phoneSchema, pinSchema } from '../utils/validation';
import type { Bindings, Variables } from '../index';

const app = new Hono<{ Bindings: Bindings; Variables: Variables }>();

const loginSchema = z.object({
  phone: phoneSchema,
  pin: pinSchema,
});

app.post('/login', zValidator('json', loginSchema), async (c) => {
  const { phone, pin } = c.req.valid('json');

  const db = createDbClient(c.env.DB);
  const authService = new AuthService(db, c.env.JWT_SECRET);

  try {
    const result = await authService.login(phone, pin);
    return c.json(result);
  } catch (error) {
    return c.json({ error: (error as Error).message }, 401);
  }
});

const registerSchema = z.object({
  phone: phoneSchema,
  name: z.string().min(2),
  pin: pinSchema,
  email: z.string().email().optional(),
});

app.post('/register', zValidator('json', registerSchema), async (c) => {
  const data = c.req.valid('json');

  const db = createDbClient(c.env.DB);
  const authService = new AuthService(db, c.env.JWT_SECRET);

  try {
    const result = await authService.register(data);
    return c.json(result, 201);
  } catch (error) {
    return c.json({ error: (error as Error).message }, 400);
  }
});

app.post('/logout', async (c) => {
  return c.json({ message: 'Logged out successfully' });
});

export default app;
