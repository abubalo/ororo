import { Context, Next } from 'hono';

const allowedOrigins = [
  'http://localhost:3000',
  'http://localhost:5173',
  'https://ororo.app',
  'https://www.ororo.app',
];

export async function corsMiddleware(c: Context, next: Next) {
  const origin = c.req.header('Origin');

  if (origin && allowedOrigins.includes(origin)) {
    c.header('Access-Control-Allow-Origin', origin);
    c.header('Access-Control-Allow-Credentials', 'true');
  }

  c.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  c.header(
    'Access-Control-Allow-Headers',
    'Content-Type, Authorization'
  );

  if (c.req.method === 'OPTIONS') {
    return c.text('', 204);
  }

  await next();
}
