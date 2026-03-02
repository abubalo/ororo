import { sign } from 'hono/jwt';
import { JWT_EXPIRY } from './constants';

export async function generateToken(
  userId: string,
  secret: string,
  expiresIn: number = JWT_EXPIRY
) {
  const now = Math.floor(Date.now() / 1000);

  return await sign(
    {
      sub: userId,
      iat: now,
      exp: now + expiresIn,
    },
    secret
  );
}
