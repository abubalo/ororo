import { z } from 'zod';

export const phoneSchema = z.string().min(10).max(15);
export const pinSchema = z.string().length(4).regex(/^\d{4}$/);
export const ulidSchema = z.string().length(26);

export const paginationSchema = z.object({
  limit: z.number().min(1).max(100).default(20),
  offset: z.number().min(0).default(0),
});
