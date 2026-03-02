import { Context } from 'hono';
import type { Bindings } from '../index';

export function errorHandler(err: Error, c: Context<{ Bindings: Bindings }>) {
  console.error('Error:', err);

  if (err.message.includes('not found')) {
    return c.json({ error: err.message }, 404);
  }

  if (err.message.includes('already exists')) {
    return c.json({ error: err.message }, 409);
  }

  if (err.message.includes('Unauthorized')) {
    return c.json({ error: err.message }, 401);
  }

  if (err.message.includes('Forbidden')) {
    return c.json({ error: err.message }, 403);
  }

  return c.json({
    error: 'Internal server error',
    message: c.env?.ENVIRONMENT === 'development' ? err.message : undefined,
  }, 500);
}
