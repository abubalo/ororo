import { Context, Next } from 'hono';
import { verify } from 'hono/jwt';
import { createDbClient } from '../db/client';
import { UserRepository } from '../db/queries';
import type { Bindings, Variables } from '../index';

export async function authMiddleware(
  c: Context<{ Bindings: Bindings; Variables: Variables }>,
  next: Next
) {
  const authHeader = c.req.header('Authorization');

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return c.json({ error: 'Unauthorized - No token provided' }, 401);
  }

  const token = authHeader.substring(7);

  try {
    const payload = await verify(token, c.env.JWT_SECRET);

    const db = createDbClient(c.env.DB);
    const userRepo = new UserRepository(db);
    const user = await userRepo.findById(payload.sub as string);

    if (!user || !user.isActive) {
      return c.json({ error: 'Unauthorized - Invalid user' }, 401);
    }

    c.set('userId', user.id);
    c.set('userRole', user.role);
    c.set('stationId', user.stationId || undefined);

    await next();
  } catch (error) {
    return c.json({ error: 'Unauthorized - Invalid token' }, 401);
  }
}

export function requireRole(...allowedRoles: string[]) {
  return async (c: Context, next: Next) => {
    const userRole = c.get('userRole');

    if (!allowedRoles.includes(userRole)) {
      return c.json({
        error: 'Forbidden',
        required: allowedRoles,
        current: userRole,
      }, 403);
    }

    await next();
  };
}
